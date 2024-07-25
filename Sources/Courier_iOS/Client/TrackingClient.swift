//
//  TrackingClient.swift
//
//
//  Created by https://github.com/mikemilla on 7/22/24.
//

import Foundation

class TrackingClient: CourierApiClient {
    
    private let options: CourierClient.Options
        
    init(options: CourierClient.Options) {
        self.options = options
        super.init()
    }
    
    func postTrackingUrl(url: String, event: CourierTrackingEvent) async throws {

        let request = try http(url) {
            
            $0.httpMethod = "POST"
            
            $0.httpBody = try? JSONEncoder().encode([
                "event": event.rawValue
            ])
            
        }
        
        try await request.dispatch(options)
        
    }
    
}
