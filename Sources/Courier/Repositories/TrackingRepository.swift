//
//  TrackingRepository.swift
//  
//
//  Created by Michael Miller on 3/2/23.
//

import Foundation

internal class TrackingRepository: Repository {
    
    internal func postTrackingUrl(url: String, event: CourierPushEvent) async throws {
        
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<Void, Error>) in

            let url = URL(string: url)!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = try? JSONEncoder().encode([
                "event": event.rawValue
            ])
            
            let task = CourierTask(with: request, validCodes: [200]) { (validCodes, data, response, error, status) in
                
                if (!validCodes.contains(status)) {
                    continuation.resume(throwing: CourierError.requestError)
                    return
                }
                
                continuation.resume()
                
            }
            
            task.start()
            
        })

    }
    
}
