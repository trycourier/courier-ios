//
//  TrackingClient.swift
//
//
//  Created by https://github.com/mikemilla on 7/22/24.
//

import Foundation

public class TrackingClient: CourierApiClient, @unchecked Sendable {
    
    private let options: CourierClient.Options
        
    init(options: CourierClient.Options) {
        self.options = options
        super.init()
    }
    
    // Tracking URLs come from push payloads. Custom tracking domains are a documented feature, so any
    // host is allowed, but only over https. A short timeout keeps a slow host from holding up the
    // notification handlers that wait on this.
    static let timeout: TimeInterval = 10

    public func postTrackingUrl(url: String, event: CourierTrackingEvent) async throws {

        guard URL(string: url)?.scheme?.lowercased() == "https" else {
            throw CourierError(code: -1, message: "Tracking URL must use https", type: "invalid_request_error")
        }

        let request = try http(url) {
            
            $0.httpMethod = "POST"
            $0.timeoutInterval = TrackingClient.timeout
            
            $0.httpBody = try? JSONEncoder().encode([
                "event": event.rawValue
            ])
            
        }
        
        try await request.dispatch(options)
        
    }
    
}
