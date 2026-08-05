//
//  InboxSocketProtocolUnitTests.swift
//  Courier_iOS
//
//  Inbox wire protocol v2 (iwpv=v2).
//
//  These cover the two things that make v2 work and are otherwise invisible when they
//  break: the connection URL must carry `cid` and `iwpv` (the server rejects an IWP
//  connection missing either, and silently downgrades an unknown version to `legacy`),
//  and `clickTrackingId` must read the root-level `trackingIds` that v2 publishes.
//

import Foundation
import XCTest
@testable import Courier_iOS

class InboxSocketProtocolUnitTests: XCTestCase {

    private func options(
        jwt: String? = "test-jwt",
        clientKey: String? = nil,
        connectionId: String? = "conn-123",
        tenantId: String? = nil
    ) -> CourierClient.Options {
        return CourierClient.Options(
            jwt: jwt,
            clientKey: clientKey,
            userId: "user-1",
            connectionId: connectionId,
            tenantId: tenantId,
            showLogs: false,
            apiUrls: CourierClient.ApiUrls()
        )
    }

    /// Parses the connection URL rather than opening a socket, so these stay pure unit tests.
    private func queryItems(for options: CourierClient.Options) -> [String: String] {
        guard let components = URLComponents(string: InboxSocket.buildUrl(options: options)) else {
            return [:]
        }
        var items: [String: String] = [:]
        for item in components.queryItems ?? [] {
            items[item.name] = item.value
        }
        return items
    }

    // MARK: Connection URL

    func testUrlDeclaresProtocolVersionV2() {
        let items = queryItems(for: options())
        XCTAssertEqual(items["iwpv"], "v2")
        XCTAssertEqual(InboxSocket.protocolVersion, "v2")
    }

    func testUrlCarriesClientIdWhichTheServerRequires() {
        let items = queryItems(for: options(connectionId: "conn-123"))
        XCTAssertEqual(items["cid"], "conn-123")
    }

    // Without a cid the IWP handler closes the connection, so a caller that never set
    // connectionId must still get a usable socket rather than a rejected one.
    func testUrlGeneratesAClientIdWhenNoneWasProvided() {
        let items = queryItems(for: options(connectionId: nil))
        XCTAssertNotNil(items["cid"])
        XCTAssertFalse(items["cid"]?.isEmpty ?? true)
    }

    func testUrlKeepsJwtAuth() {
        let items = queryItems(for: options(jwt: "test-jwt"))
        XCTAssertEqual(items["auth"], "test-jwt")
    }

    // The client-key path previously returned before any IWP params were appended.
    func testUrlCarriesProtocolParamsOnTheClientKeyPath() {
        let items = queryItems(for: options(jwt: nil, clientKey: "ck-1"))
        XCTAssertEqual(items["clientKey"], "ck-1")
        XCTAssertEqual(items["iwpv"], "v2")
        XCTAssertNotNil(items["cid"])
    }

    // MARK: Tracking ids

    /**
     v2 publishes `trackingIds` at the root. The nested `data["trackingIds"]` branch that
     used to be consulted first is gone — it only existed because the `legacy` socket nested
     them while GraphQL returned them at the root.
     */
    func testClickTrackingIdReadsTheRootLevelValue() throws {
        let json = """
        {
          "messageId": "msg-1",
          "title": "Welcome",
          "trackingIds": { "clickTrackingId": "click-root" },
          "data": { "orderId": "ord_1" }
        }
        """
        let message = try JSONDecoder().decode(InboxMessage.self, from: Data(json.utf8))

        XCTAssertEqual(message.clickTrackingId, "click-root")
    }

    func testClickTrackingIdIsNilWhenAbsent() throws {
        let json = """
        { "messageId": "msg-1", "title": "Welcome" }
        """
        let message = try JSONDecoder().decode(InboxMessage.self, from: Data(json.utf8))

        XCTAssertNil(message.clickTrackingId)
    }

    /**
     A nested-only copy is what a `legacy` frame looks like. v2 never sends it, and reading it
     would mask a silent downgrade — so this asserts the fallback really is gone.
     */
    func testClickTrackingIdIgnoresANestedOnlyCopy() throws {
        let json = """
        {
          "messageId": "msg-1",
          "data": { "trackingIds": { "clickTrackingId": "click-nested" } }
        }
        """
        let message = try JSONDecoder().decode(InboxMessage.self, from: Data(json.utf8))

        XCTAssertNil(message.clickTrackingId)
    }

    // MARK: Frame decoding

    func testMessageFrameDecodesTheCanonicalMessageFromData() throws {
        let json = """
        {
          "event": "message",
          "iwpv": "v2",
          "data": {
            "messageId": "msg-1",
            "title": "Welcome",
            "preview": "Preview",
            "created": "2026-08-05T12:00:00.000Z",
            "trackingIds": { "clickTrackingId": "click-1", "readTrackingId": "read-1" },
            "data": { "orderId": "ord_1" }
          }
        }
        """
        let frame = try JSONDecoder().decode(InboxSocket.MessageFrame.self, from: Data(json.utf8))

        XCTAssertEqual(frame.event, "message")
        XCTAssertEqual(frame.iwpv, "v2")
        XCTAssertEqual(frame.data.messageId, "msg-1")
        XCTAssertEqual(frame.data.title, "Welcome")
        XCTAssertEqual(frame.data.clickTrackingId, "click-1")
        XCTAssertEqual(frame.data.trackingIds?.readTrackingId, "read-1")
        // `data` keeps only non-promoted keys under v2.
        XCTAssertEqual(frame.data.data?["orderId"] as? String, "ord_1")
    }

    /**
     A heartbeat must be recognized as a control frame. It has no `event`, so if it fell
     through to the message decode it would surface as a spurious error every ping interval —
     and an unanswered ping gets the connection terminated by the server.
     */
    func testPingDecodesAsAControlFrame() throws {
        let json = """
        { "iwpv": "v2", "tid": "tid-1", "action": "ping" }
        """
        let control = try JSONDecoder().decode(InboxSocket.ControlFrame.self, from: Data(json.utf8))

        XCTAssertEqual(control.action, "ping")
        XCTAssertEqual(control.tid, "tid-1")
        XCTAssertNil(control.response)
    }

    func testAckDecodesAsAControlFrame() throws {
        let json = """
        { "tid": "tid-1", "response": "ack" }
        """
        let control = try JSONDecoder().decode(InboxSocket.ControlFrame.self, from: Data(json.utf8))

        XCTAssertEqual(control.response, "ack")
        XCTAssertNil(control.action)
    }
}
