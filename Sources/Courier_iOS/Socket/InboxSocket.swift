//
//  InboxSocket.swift
//
//
//  Created by https://github.com/mikemilla on 7/23/24.
//

import Foundation

// MARK: Inbox Socket Singleton

@CourierActor internal class InboxSocketManager {

    var socket: InboxSocket?

    @discardableResult func updateInstance(options: CourierClient.Options) async -> InboxSocket {
        await closeSocket()
        socket = InboxSocket(options: options)
        return socket!
    }

    func closeSocket() async {
        await socket?.disconnect()
        socket?.receivedMessage = nil
        socket?.receivedMessageEvent = nil
        socket = nil
    }
    
}

// MARK: Socket state. Prevents data races

internal actor InboxSocketState {
    
    private var receivedMessage: ((InboxMessage) -> Void)?
    private var receivedMessageEvent: ((InboxSocket.MessageEvent) -> Void)?

    func setReceivedMessage(_ handler: ((InboxMessage) -> Void)?) {
        self.receivedMessage = handler
    }

    func setReceivedMessageEvent(_ handler: ((InboxSocket.MessageEvent) -> Void)?) {
        self.receivedMessageEvent = handler
    }

    func callReceivedMessage(_ message: InboxMessage) {
        receivedMessage?(message)
    }

    func callReceivedMessageEvent(_ event: InboxSocket.MessageEvent) {
        receivedMessageEvent?(event)
    }
}


// MARK: Inbox Socket

public class InboxSocket: CourierSocket {

    private let options: CourierClient.Options
    private let state = InboxSocketState()

    /**
     Inbox wire protocol version, negotiated per connection via the `iwpv` query parameter.

     `v2` publishes the canonical message — the same object the GraphQL read returns, with
     `trackingIds` at the root and no nested `data.trackingIds` duplicate.

     Previously this SDK sent no `iwpv` at all, which the server treats as `legacy`: a
     different envelope (no `tid`, `keepAlive` instead of ping/pong) and a frame whose
     message fields sit at the root. That is why `clickTrackingId` had to read
     `data["trackingIds"]` first — on `legacy` the nested copy is the only one present.

     The server downgrades an unrecognized version to `legacy` rather than rejecting the
     connection, so this must not be raised ahead of server support: a client asking for a
     version the server does not know gets the legacy shape and no error. v2 message frames
     carry `iwpv` so a downgrade is detectable rather than silent.
     */
    internal static let protocolVersion = "v2"

    enum PayloadType: String, Codable {
        case event = "event"
        case message = "message"
    }

    struct SocketPayload: Codable {
        let type: PayloadType
    }

    public struct MessageEvent: Codable {
        let event: InboxEventType
        let messageId: String?
        let type: String
    }

    /**
     A v2 frame. Messages arrive as `{"event":"message","iwpv":"v2","data":{…}}`; anything
     else is a message event carrying its own `event` name at the root.
     */
    internal struct MessageFrame: Decodable {
        let event: String
        let iwpv: String?
        let data: InboxMessage
    }

    /**
     Server control frames: `{"tid":…,"response":"ack"|"pong"|"config"}` and
     `{"iwpv":…,"tid":…,"action":"ping"}`.

     Responding to `ping` is not optional — the server terminates a connection that fails to
     pong within its timeout, so a client that ignores pings is dropped mid-session.
     */
    internal struct ControlFrame: Decodable {
        let tid: String?
        let action: String?
        let response: String?
    }

    internal var receivedMessage: ((InboxMessage) -> Void)?
    internal var receivedMessageEvent: ((MessageEvent) -> Void)?
    
    init(options: CourierClient.Options) {
        self.options = options
        
        let url = InboxSocket.buildUrl(options: options)
        super.init(url: url)
        
        // Handle received messages
        self.onMessageReceived = { [weak self] data in
            self?.convertToType(from: data)
        }
        
    }
    
    public func connect(receivedMessage: ((InboxMessage) -> Void)? = nil, receivedMessageEvent: ((MessageEvent) -> Void)? = nil) async throws {
        await state.setReceivedMessage(receivedMessage)
        await state.setReceivedMessageEvent(receivedMessageEvent)
        try await super.connect()
    }
    
    /**
     Subscribe using the IWP envelope: `tid` and `action` at the root, options under `data`.

     The `version` parameter is retained for source compatibility but is no longer sent — the
     server hardcodes `clientVersion` for every IWP subscription, so passing it implied a
     negotiation that does not happen.
     */
    public func sendSubscribe(version: Int = 5) async throws {

        var subscription: [String: Any] = [
            "userAgent": Courier.agent.value,
            "event": "*"
        ]

        if let tenantId = self.options.tenantId {
            subscription["accountId"] = tenantId
        }

        try await send([
            "tid": UUID().uuidString,
            "action": "subscribe",
            "data": subscription
        ])

    }
    
    /**
     Route an incoming v2 frame.

     Three kinds arrive on one socket, distinguished without a `type` field (which v2 does not
     send):

     - a control frame carrying `action` or `response` — ack, config, or a `ping` that must be
       answered
     - `{"event":"message","data":{…}}` — a new message, canonical shape
     - anything else with an `event` — a message event (read, archived, …)

     Ordering matters: control frames are checked first, because a `ping` has no `event` and
     would otherwise fall through to a failed message decode and surface as a spurious error.
     */
    private func convertToType(from data: String) {
        let decoder = JSONDecoder()
        let json = data.data(using: .utf8) ?? Data()

        // Control frames first — see note above.
        if let control = try? decoder.decode(ControlFrame.self, from: json) {
            if control.action == "ping" {
                // Mandatory: the server terminates a connection that does not pong in time.
                Task { await self.sendPong(tid: control.tid) }
                return
            }

            // ack / pong / config carry no payload this SDK acts on, but they are not errors.
            if control.response != nil {
                return
            }
        }

        do {
            if let frame = try? decoder.decode(MessageFrame.self, from: json), frame.event == "message" {
                if let iwpv = frame.iwpv, iwpv != InboxSocket.protocolVersion {
                    // A downgrade would otherwise be invisible until tracking silently stopped.
                    options.error("Inbox socket negotiated \(iwpv) but this client expects \(InboxSocket.protocolVersion). Tracking ids may be missing.")
                }
                Task { await state.callReceivedMessage(frame.data) } // Read safely via actor
                return
            }

            let event = try decoder.decode(MessageEvent.self, from: json)
            Task { await state.callReceivedMessageEvent(event) } // Read safely via actor
        } catch {
            options.error(error.localizedDescription)
            self.onError?(error)
        }
    }

    /**
     Answer a server heartbeat, echoing its `tid` — the server matches the pong against the
     ping it is waiting on and ignores a mismatched one.
     */
    private func sendPong(tid: String?) async {
        do {
            try await send([
                "tid": tid ?? UUID().uuidString,
                "action": "pong"
            ])
        } catch {
            options.error("Failed to answer inbox socket heartbeat: \(error.localizedDescription)")
        }
    }

    /**
     `cid` and `iwpv` are both required by the IWP handler — it rejects a connection missing
     either, so they are appended for the client-key path as well as the JWT path.
     */
    internal static func buildUrl(options: CourierClient.Options) -> String {
        var url = options.apiUrls.inboxWebSocket
        if let jwt = options.jwt {
            url += "/?auth=\(jwt)"
        } else if let clientKey = options.clientKey {
            url += "/?clientKey=\(clientKey)"
        } else {
            url += "/?"
        }

        // The server requires a client id; fall back to a generated one so a caller that never
        // set connectionId still gets a valid IWP connection rather than a rejected one.
        let clientId = options.connectionId ?? UUID().uuidString

        url += "&cid=\(clientId)"
        url += "&iwpv=\(InboxSocket.protocolVersion)"
        url += "&userId=\(options.userId)"

        return url
    }
    
}
