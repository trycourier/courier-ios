//
//  TokenRepository.swift
//
//
//  Created by Michael Miller on 7/7/22.
//

import Foundation

class TokenRepository: Repository {
    
    func putUserToken(userId: String?, provider: CourierProvider, deviceToken: String?) async throws {
        
        debugPrint("Putting Messaging Token")
        
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<Void, Error>) in
            
            guard let accessToken = Courier.shared.accessToken else {
                print("Courier Access Token is missing")
                continuation.resume(throwing: CourierError.noAccessTokenFound)
                return
            }
            
            guard let userId = userId else {
                print("No user id found")
                continuation.resume(throwing: CourierError.noUserIdFound)
                return
            }
            
            guard let messagingToken = deviceToken else {
                print("\(provider.rawValue) token is nil")
                continuation.resume()
                return
            }

            let url = URL(string: "\(baseUrl)/users/\(userId)/tokens/\(messagingToken)")!
            var request = URLRequest(url: url)
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            request.httpMethod = "PUT"
            request.httpBody = try? JSONEncoder().encode([
                "provider_key": provider.rawValue
            ])
            
            let task = CourierTask(with: request, validCodes: [200, 204]) { (validCodes, data, response, error) in
                
                let status = (response as! HTTPURLResponse).statusCode
                if (!validCodes.contains(status)) {
                    continuation.resume(throwing: CourierError.requestError)
                    return
                }
                
                continuation.resume()
                
            }
            
            task.start()
            
        })
        
    }
    
    func deleteToken(userId: String?, deviceToken: String?) async throws {
        
        debugPrint("Deleting Messaging Token")
        
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<Void, Error>) in
            
            guard let accessToken = Courier.shared.accessToken else {
                print("Courier Access Token is missing")
                continuation.resume(throwing: CourierError.noAccessTokenFound)
                return
            }
            
            guard let userId = userId else {
                print("No user id found")
                continuation.resume(throwing: CourierError.noUserIdFound)
                return
            }
            
            guard let messagingToken = deviceToken else {
                print("Device token is nil")
                continuation.resume()
                return
            }

            let url = URL(string: "\(baseUrl)/users/\(userId)/tokens/\(messagingToken)")!
            var request = URLRequest(url: url)
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            request.httpMethod = "DELETE"
            
            let task = CourierTask(with: request, validCodes: [200, 204]) { (validCodes, data, response, error) in
                
                let status = (response as! HTTPURLResponse).statusCode
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
