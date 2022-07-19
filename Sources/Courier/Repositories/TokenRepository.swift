//
//  TokenRepository.swift
//
//
//  Created by Michael Miller on 7/7/22.
//

import Foundation

struct Test: Decodable {
    let userId: Int
    let id: Int
    let title: String
    let completed: Bool
}

@available(iOS 10.0.0, *)
class TokenRepository: Repository {
    
    func refreshDeviceToken(userId: String, provider: CourierProvider, deviceToken: String, onSuccess: @escaping () -> Void) -> URLSessionDataTask? {
        
        guard let authKey = Courier.shared.authorizationKey else {
            print("Courier Authorization Key is missing")
            return nil
        }

        let url = URL(string: "https://api.courier.com/users/\(userId)/tokens/\(deviceToken)")!
         
        print(url)
        
        var request = URLRequest(url: url)

        // Configure request authentication
        request.setValue(
            "Bearer \(authKey)",
            forHTTPHeaderField: "Authorization"
        )

//        let body = try? JSONSerialization.data(
//            withJSONObject: [
//                "token": deviceToken,
//                "provider_key": provider.rawValue
//            ]
//        )
        
        let body = try? JSONEncoder().encode([
//            "token": deviceToken,
            "provider_key": provider.rawValue
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
                
                onSuccess()
                
//                let user = try JSONDecoder().decode(Test.self, from: data)
//                print(user)
            } catch {
                // ERROR
            }
            
        }

    }
    
    func deleteToken(userId: String, deviceToken: String, onSuccess: @escaping () -> Void) -> URLSessionDataTask? {
        
        guard let authKey = Courier.shared.authorizationKey else {
            print("Courier Authorization Key is missing")
            return nil
        }

        let url = URL(string: "https://api.courier.com/users/\(userId)/tokens/\(deviceToken)")!
         
        print(url)
        
        var request = URLRequest(url: url)

        // Configure request authentication
        request.setValue(
            "Bearer \(authKey)",
            forHTTPHeaderField: "Authorization"
        )

//        let body = try? JSONSerialization.data(
//            withJSONObject: [
//                "token": deviceToken,
//                "provider_key": provider.rawValue
//            ]
//        )
        
//        let body = try? JSONEncoder().encode([
////            "token": deviceToken,
////            "provider_key": provider.rawValue
//        ])
//
//        if let jsonString = String(data: body!, encoding: .utf8) {
//            print(jsonString)
//        }

        request.httpMethod = "DELETE"
//        request.httpBody = body

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
                
                onSuccess()
                
//                let user = try JSONDecoder().decode(Test.self, from: data)
//                print(user)
            } catch {
                // ERROR
            }
            
        }

    }
    
}
