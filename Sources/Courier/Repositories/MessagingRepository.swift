//
//  MessagingRepository.swift
//  
//
//  Created by Michael Miller on 7/21/22.
//

import Foundation

internal class MessagingRepository: Repository {
    
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
    
    internal func send(authKey: String, userId: String, title: String, message: String) async throws -> String {
        
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<String, Error>) in

            let url = URL(string: "\(baseUrl)/send")!
            var request = URLRequest(url: url)
            request.setValue("Bearer \(authKey)", forHTTPHeaderField: "Authorization")
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
            
            let task = CourierTask(with: request, validCodes: [200, 202]) { (validCodes, data, response, error) in
                
                let status = (response as! HTTPURLResponse).statusCode
                if (!validCodes.contains(status)) {
                    continuation.resume(throwing: CourierError.requestError)
                    return
                }
                
                do {
                    let res = try JSONDecoder().decode(MessageResponse.self, from: data ?? Data())
                    debugPrint("New Courier message sent. View logs here:")
                    debugPrint("https://app.courier.com/logs/messages?message=\(res.requestId)")
                    continuation.resume(returning: res.requestId)
                } catch {
                    debugPrint(error)
                    continuation.resume(throwing: CourierError.requestError)
                }
                
            }
            
            task.start()
            
        })

    }
    
}
