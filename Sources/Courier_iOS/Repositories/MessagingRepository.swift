//
//  MessagingRepository.swift
//  
//
//  Created by https://github.com/mikemilla on 7/21/22.
//

import Foundation

internal class MessagingRepository: Repository {
    
    internal struct CourierMessage: Codable {
        var message: Message
    }
    
    internal struct Message: Codable {
        let to: User
        let content: Content
        let routing: Routing
        var providers: Providers?
    }
    
    internal struct User: Codable {
        let user_id: String
    }
    
    internal struct Content: Codable {
        let title: String
        let body: String
    }
    
    internal struct Routing: Codable {
        let method: String
        let channels: [String]
    }
    
    internal struct Providers: Codable {
        let firebaseFcm: FirebaseFcm?
        enum CodingKeys: String, CodingKey {
            case firebaseFcm = "firebase-fcm"
        }
    }
    
    internal struct FirebaseFcm: Codable {
        let override: Override
    }
    
    internal struct Override: Codable {
        let body: Body
    }
    
    internal struct Body: Codable {
        let apns: Apns?
    }
    
    internal struct Apns: Codable {
        let payload: Payload
    }
    
    internal struct Payload: Codable {
        let aps: Aps
    }
    
    internal struct Aps: Codable {
        let sound: String?
        let badge: Int?
    }
    
    internal func send(authKey: String, userIds: [String], title: String, body: String, channels: [CourierChannel]) async throws -> String {
        
        let json = [
            
            "message": [
                "to": userIds.map { [ "user_id": $0 ] }, // Map all user ids,
                "content": [
                    "title": title,
                    "body": body,
                    "version": "2020-01-01",
                    "elements": channels.flatMap { $0.elements }.map { $0.toMap() } // Get the elements
                ],
                "routing": [
                    "method": "all",
                    "channels": channels.map { $0.key } // Get the keys
                ],
                "providers": channels.reduce(into: [:]) { result, channel in
                    result[channel.key] = channel.toOverride() // Map the provider
                }
            ]
            
        ].toJson()
        
        let data = try await post(
            accessToken: authKey,
            url: "\(CourierUrl.baseRest)/send",
            body: json,
            validCodes: [200, 202]
        )
        
        do {
            
            let res = try JSONDecoder().decode(MessageResponse.self, from: data ?? Data())
            let messageId = res.requestId
            
            Courier.log("\nNew Courier message sent. View logs here:")
            Courier.log("https://app.courier.com/logs/messages?message=\(messageId)\n")
            
            return messageId
            
        } catch {
            Courier.log(error.friendlyMessage)
            throw CourierError.requestParsingError
        }

    }
    
}
