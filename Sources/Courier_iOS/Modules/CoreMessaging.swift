//
//  CoreMessaging.swift
//  
//
//  Created by https://github.com/mikemilla on 3/2/23.
//

import Foundation

internal class CoreMessaging {
    
    private lazy var messagingRepo = MessagingRepository()
    
    // MARK: Testing
    
    internal func sendMessage(authKey: String, userIds: [String], title: String, body: String, channels: [CourierChannel]) async throws -> String {
        return try await messagingRepo.send(
            authKey: authKey,
            userIds: userIds,
            title: title,
            body: body,
            channels: channels
        )
    }
    
}

extension Courier {
    
    /**
     * Sends a message via the Courier /send api to the user id you provide
     * More info: https://www.courier.com/docs/reference/send/message/
     */
    @discardableResult public func sendMessage(authKey: String, userIds: [String], title: String, body: String, channels: [CourierChannel]) async throws -> String {
        return try await coreMessaging.sendMessage(
            authKey: authKey,
            userIds: userIds,
            title: title,
            body: body,
            channels: channels
        )
    }
    
    @objc public func sendMessage(authKey: String, userIds: [String], title: String, body: String, channels: [CourierChannel], onSuccess: @escaping (String) -> Void, onFailure: @escaping (Error) -> Void) {
        Task {
            do {
                let requestId = try await coreMessaging.sendMessage(
                    authKey: authKey,
                    userIds: userIds,
                    title: title,
                    body: body,
                    channels: channels
                )
                onSuccess(requestId)
            } catch {
                onFailure(error)
            }
        }
    }
    
}
