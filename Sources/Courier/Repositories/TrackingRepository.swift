//
//  TrackingRepository.swift
//  
//
//  Created by https://github.com/mikemilla on 3/2/23.
//

import Foundation

internal class TrackingRepository: Repository {
    
    internal func postTrackingUrl(url: String, event: CourierPushEvent) async throws -> Void {
        
        return try await post(url: url, body: [
            "event": event.rawValue
        ])

    }
    
}
