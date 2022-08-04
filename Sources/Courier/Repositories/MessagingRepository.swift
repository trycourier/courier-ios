//
//  MessagingRepository.swift
//  
//
//  Created by Michael Miller on 7/21/22.
//

import Foundation

internal class MessagingRepository: Repository {
    
    internal func send(authKey: String, userId: String, title: String, message: String) async throws -> String {
        
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<String, Error>) in
            
            let message = CourierMessage(
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
            )

            let url = URL(string: "\(baseUrl)/send")!
            var request = URLRequest(url: url)
            request.setValue("Bearer \(authKey)", forHTTPHeaderField: "Authorization")
            request.httpMethod = "POST"
            request.httpBody = try? JSONEncoder().encode(message)
            
            let task = CourierTask(with: request, validCodes: [200, 202]) { (validCodes, data, response, error) in
                
                let status = (response as! HTTPURLResponse).statusCode
                if (!validCodes.contains(status)) {
                    continuation.resume(throwing: CourierError.requestError)
                    return
                }
                
                do {
                    let res = try JSONDecoder().decode(MessageResponse.self, from: data ?? Data())
                    Courier.log("New Courier message sent. View logs here:")
                    Courier.log("https://app.courier.com/logs/messages?message=\(res.requestId)")
                    continuation.resume(returning: res.requestId)
                } catch {
                    Courier.log(String(describing: error))
                    continuation.resume(throwing: CourierError.requestError)
                }
                
            }
            
            task.start()
            
        })

    }
    
    internal func postTrackingUrl(url: String, event: CourierPushEvent) async throws {
        
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<Void, Error>) in

            let url = URL(string: url)!
            var request = URLRequest(url: url)
            request.setValue("X-Courier-Client-Key", forHTTPHeaderField: "YWY2MzAzYmUtMGUxZS00MGI1LWJiODAtZTFkOTI5OWNjY2Zm") // TODO: Change me
            request.httpMethod = "POST"
            request.httpBody = try? JSONEncoder().encode([
                "event": event.rawValue
            ])
            
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
