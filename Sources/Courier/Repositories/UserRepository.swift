//
//  UserRepository.swift
//  Messaging
//
//  Created by Michael Miller on 7/7/22.
//

import Foundation

@available(iOS 10.0.0, *)
class UserRepository: Repository {
    
    func updateUser(user: CourierUser) -> URLSessionDataTask? {
        
        guard let authKey = Courier.shared.authorizationKey else {
            print("Courier Authorization Key is missing")
            return nil
        }

        let url = URL(string: "https://api.courier.com/profiles/\(user.id)")!
        
        print(url)
        
        var request = URLRequest(url: url)

        request.setValue(
            "Bearer \(authKey)",
            forHTTPHeaderField: "Authorization"
        )
        
        let body = try? JSONEncoder().encode([
            "profile": [
                "email": "mike@mikemiller.design"
            ]
        ])
        
        if let jsonString = String(data: body!, encoding: .utf8) {
            print(jsonString)
        }

        request.httpMethod = "PUT"
        request.httpBody = body

        // Create the HTTP request
        return session.dataTask(with: request) { (data, response, error) in
            
            let status = (response as! HTTPURLResponse).statusCode
            print(status)
            
            if let error = error {
                // ERROR
                return
            }
            
            guard let data = data else {
                // ERROR
                return
            }
            
            do {
                
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                print(json)
                
//                let user = try JSONDecoder().decode(Test.self, from: data)
//                print(user)
            } catch {
                // ERROR
            }
            
        }

    }
    
}
