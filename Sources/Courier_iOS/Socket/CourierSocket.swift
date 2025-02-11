//
//  CourierSocket.swift
//
//
//  Created by https://github.com/mikemilla on 6/10/24.
//

import Foundation

public class CourierSocket: NSObject, URLSessionWebSocketDelegate {
    
    internal var webSocketTask: URLSessionWebSocketTask?
    internal var urlSession: URLSession?
    
    var onMessageReceived: ((String) -> Void)?
    
    internal var onOpen: (() -> Void)?
    internal var onClose: ((URLSessionWebSocketTask.CloseCode, Data?) -> Void)?
    internal var onError: ((Error) -> Void)?
    
    private let url: String
    private var pingTimer: Timer?
    
    init(url: String) {
        self.url = url
        super.init()
        setup()
    }

    private func setup() {
        let sessionConfiguration = URLSessionConfiguration.default
        urlSession = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
    }
    
    public func connect() async throws {
        
        // Ensure any previous connection is terminated
        disconnect()
        
        // Start a new connection
        return try await withCheckedThrowingContinuation { continuation in
            
            DispatchQueue.main.async { [weak self] in
                
                guard let self = self else {
                    return
                }
                
                guard let url = URL(string: self.url) else {
                    continuation.resume(throwing: URLError(.badURL))
                    return
                }
                
                // Initialize and start the WebSocket task
                self.webSocketTask = urlSession?.webSocketTask(with: url)
                self.webSocketTask?.resume()
                
                // Register receiver
                self.receiveData()
                
                // Continue
                continuation.resume()
                
            }
            
        }
        
    }
    
    public func disconnect() {
        
        DispatchQueue.main.async { [weak self] in
            
            guard let self = self else {
                return
            }
            
            // Stop the ping timer
            self.pingTimer?.invalidate()
            self.pingTimer = nil
            
            // Cancel the WebSocket task
            self.webSocketTask?.cancel(with: .normalClosure, reason: nil)
            self.webSocketTask = nil
            
        }
        
    }
    
    public func send(_ message: [String: Any]) async throws {
        
        // Convert the map to JSON
        let jsonData = try JSONSerialization.data(withJSONObject: message, options: [])
        guard let jsonString = String(data: jsonData, encoding: .utf8) else { return }
        let message = URLSessionWebSocketTask.Message.string(jsonString)
        
        // Send message to socket
        try await webSocketTask?.send(message)
        
    }
    
    // Pings keep alive. Will ping every 5 minutes by default
    public func keepAlive(interval: TimeInterval = 300) {
        
        // Ensure any existing timer is invalidated
        pingTimer?.invalidate()
        
        // Create and schedule a new timer
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.pingTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
                Task {
                    do {
                        try await self.send([
                            "action": "keepAlive"
                        ])
                    } catch {
                        Courier.shared.client?.log(error.localizedDescription)
                    }
                }
            }
            // Ensure the timer runs in the common run loop mode
            RunLoop.main.add(self.pingTimer!, forMode: .common)
        }
        
    }
    
    func receiveData() {
        webSocketTask?.receive { result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self.onMessageReceived?(text)
                case .data(let data):
                    if let str = String(data: data, encoding: .utf8) {
                        self.onMessageReceived?(str)
                    }
                @unknown default:
                    fatalError()
                }
                self.receiveData()
            case .failure(let error):
                
                let e = error as NSError
                
                // Handle closing socket
                if e.domain == NSPOSIXErrorDomain && e.code == 57 {
                    Courier.shared.client?.log("WebSocket closed")
                    return
                }
                
                self.onError?(e)
                
            }
        }
    }
    
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        self.onOpen?()
    }
    
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        self.onClose?(closeCode, reason)
    }
    
}
