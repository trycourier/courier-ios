//
//  UserRepository.swift
//  Messaging
//
//  Created by Michael Miller on 7/7/22.
//

import Foundation

@available(iOS 10.0.0, *)
class UserRepository: Repository {
    
    func updateUser(user: CourierUser, onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void) -> CourierTask? {
        
        guard let authKey = Courier.shared.authorizationKey else {
            print("Courier Authorization Key is missing")
            return nil
        }

        let url = URL(string: "\(baseUrl)/profiles/\(user.id)")!
        
        print(url)
        
        var request = URLRequest(url: url)

        request.setValue(
            "Bearer \(authKey)",
            forHTTPHeaderField: "Authorization"
        )

        request.httpMethod = "PUT"
        request.httpBody = try? JSONEncoder().encode(user.toProfile)
        
        if let jsonString = String(data: request.httpBody!, encoding: .utf8) {
            print(jsonString)
        }

        // Create the HTTP request
        return CourierTask(with: request) { (data, response, error) in
            
            let status = (response as! HTTPURLResponse).statusCode
            print("Status Code: \(status)")
            
            guard let data = data else {
                onFailure()
                return
            }
            
            do {
                
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                print(json)
                
                if (status != 200) {
                    
                    if let error = error {
                        onFailure()
                        return
                    }
                    
                    onFailure()
                    return
                    
                }
                
                onSuccess()
                
//                let user = try JSONDecoder().decode(Test.self, from: data)
//                print(user)
            } catch {
                debugPrint(error)
                onFailure()
            }
            
        }

    }
    
}
