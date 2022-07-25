//
//  AccessTokenGenerator.swift
//  Courier
//
//  Created by Michael Miller on 7/25/22.
//

import Foundation

class ExampleServer {
    
    private struct Body: Codable {
        let user_id: String
    }

    private struct Response: Codable {
        let token: String
    }

    class func generateJwt(userId: String) async throws -> String {
        
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<String, Error>) in
            
            let url = URL(string: "http://localhost:5001/courier-demo-bf7e7/us-central1/generateJwt")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONEncoder().encode([
                "user_id": userId
            ])

            debugPrint("URL: \(request.url?.absoluteString ?? "")")
            debugPrint("Method: \(request.httpMethod ?? "")")
            
            if let json = String(data: request.httpBody ?? Data(), encoding: .utf8) {
                debugPrint("Body: \(json)")
            }
            
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
    
}
