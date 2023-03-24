//
//  MessagingRepository.swift
//  
//
//  Created by https://github.com/mikemilla on 7/21/22.
//

import Foundation

internal class MessagingRepository: Repository {
    
    internal func send(authKey: String, userId: String, title: String, message: String, providers: [CourierProvider]) async throws -> String {
        
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
                    channels: providers.map { $0.rawValue }
                )
            )
        )
        
        let response = try await post(
            MessageResponse.self,
            accessToken: authKey,
            userId: userId,
            url: "\(CourierUrl.baseRest)/send",
            body: message,
            validCodes: [200, 202]
        )
        
        let messageId = response.requestId
        
        Courier.log("New Courier message sent. View logs here:")
        Courier.log("https://app.courier.com/logs/messages?message=\(messageId)")
        
        return messageId

    }
    
}
