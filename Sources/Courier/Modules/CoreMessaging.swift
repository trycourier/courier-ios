//
//  CoreMessaging.swift
//  
//
//  Created by Michael Miller on 3/2/23.
//

import Foundation

internal class CoreMessaging {
    
    private lazy var messagingRepo = MessagingRepository()
    
    // MARK: Testing
    
    internal func sendMessage(authKey: String, userId: String, title: String, message: String, providers: [CourierProvider] = CourierProvider.all) async throws -> String {
        return try await messagingRepo.send(
            authKey: authKey,
            userId: userId,
            title: title,
            message: message,
            providers: providers
        )
    }
    
}

extension Courier {
    
    /**
     * Sends a message via the Courier /send api to the user id you provide
     * More info: https://www.courier.com/docs/reference/send/message/
     */
    @discardableResult public func sendMessage(authKey: String, userId: String, title: String, message: String, providers: [CourierProvider] = CourierProvider.all) async throws -> String {
        return try await messaging.sendMessage(
            authKey: authKey,
            userId: userId,
            title: title,
            message: message,
            providers: providers
        )
    }
    
    // Support for native swift enums
    public func sendMessage(authKey: String, userId: String, title: String, message: String, providers: [CourierProvider] = CourierProvider.all, onSuccess: @escaping (String) -> Void, onFailure: @escaping (Error) -> Void) {
        Task {
            do {
                let requestId = try await messaging.sendMessage(
                    authKey: authKey,
                    userId: userId,
                    title: title,
                    message: message,
                    providers: providers
                )
                onSuccess(requestId)
            } catch {
                onFailure(error)
            }
        }
    }

    // Support for objc enums
    @objc public func sendMessage(authKey: String, userId: String, title: String, message: String, providers: [String] = CourierProvider.allCases, onSuccess: @escaping (String) -> Void, onFailure: @escaping (Error) -> Void) {
        Task {
            do {
                let requestId = try await messaging.sendMessage(
                    authKey: authKey,
                    userId: userId,
                    title: title,
                    message: message,
                    providers: providers.map { CourierProvider(rawValue: $0) ?? .unknown }
                )
                onSuccess(requestId)
            } catch {
                onFailure(error)
            }
        }
    }
    
}
