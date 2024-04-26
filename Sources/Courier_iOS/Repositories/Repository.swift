//
//  Repository.swift
//  
//
//  Created by https://github.com/mikemilla on 7/7/22.
//

import Foundation

internal class Repository: NSObject {
    
    internal struct CourierUrl {
        internal static let baseRest = "https://api.courier.com"
        internal static let baseGraphQL = "https://api.courier.com/client/q"
        internal static let inboxGraphQL = "https://fxw3r7gdm9.execute-api.us-east-1.amazonaws.com/production/q"
        internal static let inboxWebSocket = "wss://1x60p1o3h8.execute-api.us-east-1.amazonaws.com/production"
    }
    
    private func http(accessToken: String?, url: String, method: String, body: Data? = nil, validCodes: [Int] = [200]) async throws -> Data? {
        
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<Data?, Error>) in

            let u = URL(string: url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
            var request = URLRequest(url: u)
            request.httpMethod = method
            
            if let accessToken = accessToken {
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
            
            if let body = body {
                request.httpBody = body
            }
            
            let task = CourierTask(with: request, validCodes: validCodes) { (validCodes, data, response, error, status) in
                
                if (!validCodes.contains(status)) {
                    
                    let json = try? JSONSerialization.jsonObject(with: data ?? Data(), options: []) as? [String: Any]
                    let message = json?["message"] as? String ?? "Missing"
                    let type = json?["type"] as? String
                    
                    let e = CourierError(code: status, message: message, type: type)
                    continuation.resume(throwing: e)
                    
                    return
                    
                }
                
                // Return the raw data
                continuation.resume(returning: data)
                
            }
            
            task.start()
            
        })
        
    }
    
    private func graphQL(jwt: String?, clientKey: String?, userId: String, url: String, query: String) async throws -> Data? {
        
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<Data?, Error>) in

            let u = URL(string: url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
            var request = URLRequest(url: u)
            request.httpMethod = "POST"
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(userId, forHTTPHeaderField: "x-courier-user-id")
            
            if let jwt = jwt {
                request.addValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
            } else if let clientKey = clientKey {
                request.addValue(clientKey, forHTTPHeaderField: "x-courier-client-key")
            }
            
            let payload = CourierGraphQLQuery(query: query)
            request.httpBody = try! JSONEncoder().encode(payload)
            
            let task = CourierTask(with: request) { (validCodes, data, response, error, status) in
                
                if (!validCodes.contains(status)) {
                    
                    let json = try? JSONSerialization.jsonObject(with: data ?? Data(), options: []) as? [String: Any]
                    let message = json?["message"] as? String ?? "Missing"
                    let type = json?["type"] as? String
                    
                    let e = CourierError(code: status, message: message, type: type)
                    continuation.resume(throwing: e)
                    
                    return
                    
                }
                
                continuation.resume(returning: data)
                
            }
            
            task.start()
            
        })
        
    }
    
}

extension Repository {
    
    // MARK: Query
    
    @discardableResult internal func graphQLQuery(jwt: String?, clientKey: String?, userId: String, url: String, query: String) async throws -> Data? {
        return try await graphQL(jwt: jwt, clientKey: clientKey, userId: userId, url: url, query: query)
    }
    
    // MARK: GET
    
    @discardableResult internal func get(accessToken: String, url: String, validCodes: [Int] = [200]) async throws -> Data? {
        return try await http(accessToken: accessToken, url: url, method: "GET", body: nil, validCodes: validCodes)
    }
    
    // MARK: POST
    
    @discardableResult internal func post(accessToken: String? = nil, url: String, body: Data?, validCodes: [Int] = [200]) async throws -> Data? {
        return try await http(accessToken: accessToken, url: url, method: "POST", body: body, validCodes: validCodes)
    }
    
    // MARK: DELETE
    
    @discardableResult internal func delete(accessToken: String? = nil, url: String, validCodes: [Int] = [200]) async throws -> Data? {
        return try await http(accessToken: accessToken, url: url, method: "DELETE", body: nil, validCodes: validCodes)
    }
    
    // MARK: PUT
    
    @discardableResult internal func put(accessToken: String? = nil, url: String, body: Data?, validCodes: [Int] = [200]) async throws -> Data? {
        return try await http(accessToken: accessToken, url: url, method: "PUT", body: body, validCodes: validCodes)
    }
    
    // MARK: PATCH
    
    @discardableResult internal func patch(accessToken: String? = nil, url: String, body: Data?, validCodes: [Int] = [200]) async throws -> Data? {
        return try await http(accessToken: accessToken, url: url, method: "PATCH", body: body, validCodes: validCodes)
    }
    
}
