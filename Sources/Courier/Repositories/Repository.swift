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
    
    private func http<T: Codable>(_ type: T.Type, accessToken: String?, userId: String?, url: String, method: String, body: Codable? = nil, validCodes: [Int] = [200]) async throws -> T {
        
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<T, Error>) in

            let u = URL(string: url)!
            var request = URLRequest(url: u)
            request.httpMethod = method
            
            if let accessToken = accessToken {
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
            
            if let body = body {
                request.httpBody = try? JSONEncoder().encode(body)
            }
            
            let task = CourierTask(with: request, validCodes: validCodes) { (validCodes, data, response, error, status) in
                
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
    
    private func http(accessToken: String?, userId: String?, url: String, method: String, body: Codable? = nil, validCodes: [Int] = [200]) async throws {
        
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<Void, Error>) in

            let u = URL(string: url)!
            var request = URLRequest(url: u)
            request.httpMethod = method
            
            if let accessToken = accessToken {
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
            
            if let body = body {
                request.httpBody = try? JSONEncoder().encode(body)
            }
            
            let task = CourierTask(with: request, validCodes: validCodes) { (validCodes, data, response, error, status) in
                
                if (!validCodes.contains(status)) {
                    continuation.resume(throwing: CourierError.requestError)
                    return
                }
                
                continuation.resume()
                
            }
            
            task.start()
            
        })
        
    }
    
    private func graphQL<T: Codable>(_ type: T.Type, clientKey: String, userId: String, url: String, query: String) async throws -> T {
        
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<T, Error>) in

            let u = URL(string: url)!
            var request = URLRequest(url: u)
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
    
    private func graphQL(clientKey: String, userId: String, url: String, query: String) async throws {
        
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<Void, Error>) in

            let u = URL(string: url)!
            var request = URLRequest(url: u)
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
                
                continuation.resume()
                
            }
            
            task.start()
            
        })
        
    }
    
}

extension Repository {
    
    // MARK: Query
    
    internal func graphQLQuery<T: Codable>(_ type: T.Type, clientKey: String, userId: String, url: String, query: String) async throws -> T {
        return try await graphQL(type, clientKey: clientKey, userId: userId, url: url, query: query)
    }
    
    internal func graphQLQuery(clientKey: String, userId: String, url: String, query: String) async throws {
        return try await graphQL(clientKey: clientKey, userId: userId, url: url, query: query)
    }
    
    // MARK: GET
    
    internal func get<T: Codable>(_ type: T.Type, accessToken: String, userId: String, url: String, validCodes: [Int] = [200]) async throws -> T {
        return try await http(type, accessToken: accessToken, userId: userId, url: url, method: "GET", body: nil, validCodes: validCodes)
    }
    
    internal func get(accessToken: String, userId: String, url: String, validCodes: [Int] = [200]) async throws {
        return try await http(accessToken: accessToken, userId: userId, url: url, method: "GET", body: nil, validCodes: validCodes)
    }
    
    // MARK: POST
    
    internal func post<T: Codable>(_ type: T.Type, accessToken: String, userId: String, url: String, body: Codable, validCodes: [Int] = [200]) async throws -> T {
        return try await http(type, accessToken: accessToken, userId: userId, url: url, method: "POST", body: body, validCodes: validCodes)
    }
    
    internal func post(accessToken: String? = nil, userId: String? = nil, url: String, body: Codable, validCodes: [Int] = [200]) async throws {
        return try await http(accessToken: accessToken, userId: userId, url: url, method: "POST", body: body, validCodes: validCodes)
    }
    
    // MARK: DELETE
    
    internal func delete<T: Codable>(_ type: T.Type, accessToken: String, userId: String, url: String, validCodes: [Int] = [200]) async throws -> T {
        return try await http(type, accessToken: accessToken, userId: userId, url: url, method: "DELETE", body: nil, validCodes: validCodes)
    }
    
    internal func delete(accessToken: String? = nil, userId: String? = nil, url: String, validCodes: [Int] = [200]) async throws {
        return try await http(accessToken: accessToken, userId: userId, url: url, method: "DELETE", body: nil, validCodes: validCodes)
    }
    
    // MARK: PUT
    
    internal func put<T: Codable>(_ type: T.Type, accessToken: String, userId: String, url: String, body: Codable, validCodes: [Int] = [200]) async throws -> T {
        return try await http(type, accessToken: accessToken, userId: userId, url: url, method: "PUT", body: body, validCodes: validCodes)
    }
    
    internal func put(accessToken: String? = nil, userId: String? = nil, url: String, body: Codable, validCodes: [Int] = [200]) async throws {
        return try await http(accessToken: accessToken, userId: userId, url: url, method: "PUT", body: body, validCodes: validCodes)
    }
    
}
