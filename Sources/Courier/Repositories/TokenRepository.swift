//
//  TokenRepository.swift
//
//
//  Created by Michael Miller on 7/7/22.
//

import Foundation

@available(iOS 10.0.0, *)
class TokenRepository: Repository {
    
    func updatePushNotificationToken(userId: String, provider: CourierProvider, deviceToken: String, onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void) -> CourierTask? {
        
        guard let authKey = Courier.shared.authorizationKey else {
            print("Courier Authorization Key is missing")
            return nil
        }

        let url = URL(string: "\(baseUrl)/users/\(userId)/tokens/\(deviceToken)")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authKey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "PUT"
        request.httpBody = try? JSONEncoder().encode([
            "provider_key": provider.rawValue
        ])
        
        return CourierTask(with: request, validCodes: [200, 204]) { (validCodes, data, response, error) in
            
            let status = (response as! HTTPURLResponse).statusCode
            if (!validCodes.contains(status)) {
                onFailure()
                return
            }
            
            onSuccess()
            
        }

    }
    
    func deleteToken(userId: String, deviceToken: String, onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void) -> CourierTask? {
        
        guard let authKey = Courier.shared.authorizationKey else {
            print("Courier Authorization Key is missing")
            return nil
        }

        let url = URL(string: "\(baseUrl)/users/\(userId)/tokens/\(deviceToken)")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authKey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "DELETE"

        return CourierTask(with: request, validCodes: [200, 204]) { (validCodes, data, response, error) in
            
            let status = (response as! HTTPURLResponse).statusCode
            if (!validCodes.contains(status)) {
                onFailure()
                return
            }
            
            onSuccess()
            
        }

    }
    
}
