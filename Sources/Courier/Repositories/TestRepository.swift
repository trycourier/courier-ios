//
//  TestRepository.swift
//  
//
//  Created by Michael Miller on 7/21/22.
//

import Foundation

@available(iOS 10.0.0, *)
internal class TestRepository: Repository {
    
    private struct MessageBody: Codable {
        let message: Message
    }

    private struct Message: Codable {
        let to: User
        let content: Content
        let routing: Routing
        let providers: Providers
    }
    
    private struct User: Codable {
        let user_id: String
    }
    
    private struct Content: Codable {
        let title: String
        let body: String
    }
    
    private struct Routing: Codable {
        let method: String
        let channels: [String]
    }
    
    private struct Providers: Codable {
        let apn: APNProvider
    }
    
    private struct APNProvider: Codable {
        let `override`: Override
    }
    
    private struct Override: Codable {
        let config: Config
    }
    
    private struct Config: Codable {
        let isProduction: Bool
    }
    
    private struct MessageResponse: Codable {
        let requestId: String
    }
    
    private struct JwtToken: Codable {
        let token: String
    }
    
    internal func sendTestPush(userId: String, title: String, message: String, onSuccess: @escaping (String) -> Void, onFailure: @escaping () -> Void) -> CourierTask? {
        
        guard let accessToken = Courier.shared.accessToken else {
            print("Courier Access Token is missing")
            return nil
        }

        let url = URL(string: "\(baseUrl)/send")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(MessageBody(
            message: Message(
                to: User(
                    user_id: userId
                ),
                content: Content(
                    title: title,
                    body: message
                ),
                routing: Routing(
                    method: "all",
                    channels: [
                        CourierProvider.fcm.rawValue,
                        CourierProvider.apns.rawValue
                    ]
                ),
                providers: Providers(
                    apn: APNProvider(
                        override: Override(
                            config: Config(
                                isProduction: false
                            )
                        )
                    )
                )
            )
        ))

        return CourierTask(with: request, validCodes: [202]) { (validCodes, data, response, error) in
            
            let status = (response as! HTTPURLResponse).statusCode
            if (!validCodes.contains(status)) {
                onFailure()
                return
            }
            
            do {
                let res = try JSONDecoder().decode(MessageResponse.self, from: data ?? Data())
                debugPrint("New Courier message sent. View logs here:")
                debugPrint("https://app.courier.com/logs/messages?message=\(res.requestId)")
                onSuccess(res.requestId)
            } catch {
                debugPrint(error)
                onFailure()
            }
            
        }

    }
    
}
