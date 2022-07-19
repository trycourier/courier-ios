//
//  UserRepository.swift
//  
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
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authKey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "PUT"
        request.httpBody = try? JSONEncoder().encode(user.toProfile)

        return CourierTask(with: request) { (data, response, error) in
            
            do {
                
                let status = (response as! HTTPURLResponse).statusCode
                if (status != 200) {
                    onFailure()
                    return
                }
                
                let res = try JSONDecoder().decode(CourierResponse.self, from: data ?? Data())
                debugPrint(res)
                onSuccess()
                
            } catch {
                
                debugPrint(error)
                onFailure()
                
            }
            
        }

    }
    
}
