//
//  TrackingRepository.swift
//  
//
//  Created by https://github.com/mikemilla on 3/2/23.
//

import Foundation

internal class TrackingRepository: Repository {
    
    internal func postTrackingUrl(url: String, event: CourierTrackingEvent) async throws {
        
        let body = try JSONEncoder().encode([
            "event": event.rawValue
        ])
        
        try await post(url: url, body: body)

    }
    
}
