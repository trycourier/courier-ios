//
//  UserRepository.swift
//  
//
//  Created by Michael Miller on 7/7/22.
//

import Foundation

class UserRepository: Repository {
    
    func putUserProfile(user: CourierUserProfile) async throws {
        
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<Void, Error>) in
            
            guard let accessToken = Courier.shared.accessToken else {
                print("Courier Access Token is missing")
                continuation.resume(throwing: CourierError.noAccessTokenFound)
                return
            }

            let url = URL(string: "\(baseUrl)/profiles/\(user.id)")!
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            request.httpMethod = "PUT"
            request.httpBody = try? JSONEncoder().encode(user.toProfile)
            
            let task = CourierTask(with: request, validCodes: [200]) { (validCodes, data, response, error) in
                
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
