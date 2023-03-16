//
//  Repository.swift
//  
//
//  Created by Michael Miller on 7/7/22.
//

import Foundation

class Repository: NSObject {
    
    let baseUrl = "https://api.courier.com"
    let baseGraphQLUrl = "https://api.courier.com/client/q"
    let inboxUrl = "https://fxw3r7gdm9.execute-api.us-east-1.amazonaws.com/production/q"
    let inboxWebSocketUrl = "wss://1x60p1o3h8.execute-api.us-east-1.amazonaws.com/production"
    
    internal func graphQL<T: Codable>(_ type: T.Type, clientKey: String, userId: String, url: String, query: String) async throws -> T {
        
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<T, Error>) in

            let url = URL(string: url)!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(clientKey, forHTTPHeaderField: "x-courier-client-key")
            request.addValue(userId, forHTTPHeaderField: "x-courier-user-id")
            
            let payload = CourierGraphQLQuery(query: query)
            request.httpBody = try! JSONEncoder().encode(payload)
            
            let task = CourierTask(with: request) { (validCodes, data, response, error, status) in
                
                if (!validCodes.contains(status)) {
                    continuation.resume(throwing: CourierError.requestError)
                    return
                }
                
                do {
                    let res = try JSONDecoder().decode(T.self, from: data ?? Data())
                    continuation.resume(returning: res)
                } catch {
                    Courier.log(error.friendlyMessage)
                    continuation.resume(throwing: CourierError.requestError)
                }
                
            }
            
            task.start()
            
        })
        
    }
    
}
