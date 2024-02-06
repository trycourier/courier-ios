//
//  AccessTokenGenerator.swift
//  Courier
//
//  Created by https://github.com/mikemilla on 7/25/22.
//

import Foundation

class ExampleServer {

    private struct Response: Codable {
        let token: String
    }

    internal func generateJwt(authKey: String, userId: String) async throws -> String {

        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<String, Error>) in

            let url = URL(string: "https://api.courier.com/auth/issue-token")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(authKey)", forHTTPHeaderField: "Authorization")
            
            request.httpBody = try? JSONEncoder().encode([
                "scope": "user_id:\(userId) write:user-tokens write:preferences read:preferences",
                "expires_in": "2 days"
            ])

            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                do {
                    let res = try JSONDecoder().decode(Response.self, from: data ?? Data())
                    continuation.resume(returning: res.token)
                } catch {
                    continuation.resume(throwing: error)
                }
            }

            task.resume()

        })

    }
    
    internal func sendTest(authKey: String, userId: String, key: String) async throws -> String {
        
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<String, Error>) in
            
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
                        "title": "Test",
                        "body": "Body"
                    ],
                    "routing": [
                        "method": "all",
                        "channels": [key]
                    ]
                ]
            ].toJson()
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                let json = try? JSONSerialization.jsonObject(with: data ?? Data(), options: []) as? [String: Any]
                let requestId = json?["requestId"] as? String ?? "Error"
                continuation.resume(returning: requestId)
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
