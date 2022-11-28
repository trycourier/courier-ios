//
//  File.swift
//  
//
//  Created by Fahad Amin on 23/11/22.
//

import Foundation


internal class UserRepository: Repository {
    
    func patchUser(userId: String?) async throws {
        
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<Void, Error>) in
            
            guard let accessToken = Courier.shared.accessToken else {
                Courier.log("Courier Access Token is missing")
                continuation.resume(throwing: CourierError.noAccessTokenFound)
                return
            }
            
            guard let userId = userId else {
                Courier.log("No user id found")
                continuation.resume(throwing: CourierError.noUserIdFound)
                return
            }
            

            let url = URL(string: "\(baseUrl)/profiles/\(userId)")!
            var request = URLRequest(url: url)
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            request.httpMethod = "PATCH"
            request.httpBody = try? JSONEncoder().encode(CourierProfile(userId: userId))
            
            let task = CourierTask(with: request, validCodes: [200]) { (validCodes, data, response, error, status) in
                
                if (!validCodes.contains(status)) {
                    continuation.resume(throwing: CourierError.requestError)
                    return
                }
                
                do {
                    let res = try JSONDecoder().decode(ProfilePatchResponse.self, from: data ?? Data())
                    Courier.log("Profile patch response status: \(res.status)")
                } catch {
                    Courier.log(String(describing: error))
                }
                
                continuation.resume()
                
            }
            
            task.start()
            
        })
        
    }
    
}
