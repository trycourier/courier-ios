//
//  AccessTokenGenerator.swift
//  Courier
//
//  Created by https://github.com/mikemilla on 7/25/22.
//

import Foundation

class ExampleServer {
    
    internal func sendTest(authKey: String, userId: String, providers: [String], title: String, body: String) async throws -> Data? {
        
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<Data?, Error>) in
            
            let url = URL(string: "https://api.courier.com/send")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(authKey)", forHTTPHeaderField: "Authorization")
            
            request.httpBody = [
                "message": [
                    "to": [
                        "user_id": userId
                    ],
                    "content": [
                        "title": title,
                        "body": body
                    ],
                    "routing": [
                        "method": "all",
                        "channels": providers
                    ]
                ]
            ].toJson()
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                continuation.resume(returning: data)
            }
            
            task.resume()
            
        })
        
    }
    
}

extension Dictionary {
    
    func toJson() -> Data? {
        do {
            return try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
}
