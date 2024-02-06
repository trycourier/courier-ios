//
//  CorePreferences.swift
//
//
//  Created by Michael Miller on 10/2/23.
//

import Foundation

internal class CorePreferences {
    
    private lazy var usersRepo = UsersRepository()
    
    internal func getUserPreferences(paginationCursor: String? = nil) async throws -> CourierUserPreferences {
        
        guard let accessToken = Courier.shared.accessToken, let userId = Courier.shared.userId else {
            throw CourierError.missingUser
        }
        
        return try await usersRepo.getUserPreferences(
            accessToken: accessToken,
            userId: userId,
            paginationCursor: paginationCursor
        )
        
    }
    
    internal func putUserPreferencesTopic(topicId: String, status: CourierUserPreferencesStatus, hasCustomRouting: Bool, customRouting: [CourierUserPreferencesChannel]) async throws {
        
        guard let accessToken = Courier.shared.accessToken, let userId = Courier.shared.userId else {
            throw CourierError.missingUser
        }
        
        return try await usersRepo.putUserPreferencesTopic(
            accessToken: accessToken,
            userId: userId,
            topicId: topicId,
            status: status,
            hasCustomRouting: hasCustomRouting,
            customRouting: customRouting
        )
        
    }
    
    internal func getUserPreferencesTopic(topicId: String) async throws -> CourierUserPreferencesTopic {
        
        guard let accessToken = Courier.shared.accessToken, let userId = Courier.shared.userId else {
            throw CourierError.missingUser
        }
        
        return try await usersRepo.getUserPreferencesTopic(
            accessToken: accessToken,
            userId: userId,
            topicId: topicId
        )
        
    }
    
}

extension Courier {
    
    /**
     * Returns all the user's preferences
     */
    @objc public func getUserPreferences(paginationCursor: String? = nil) async throws -> CourierUserPreferences {
        try await corePreferences.getUserPreferences(paginationCursor: paginationCursor)
    }
    
    @objc public func getUserPreferences(paginationCursor: String? = nil, onSuccess: @escaping (CourierUserPreferences) -> Void, onFailure: @escaping (Error) -> Void) {
        Task {
            do {
                let preferences = try await corePreferences.getUserPreferences(paginationCursor: paginationCursor)
                onSuccess(preferences)
            } catch {
                onFailure(error)
            }
        }
    }
    
    /**
     * Updates a user's preference topic  
     */
    public func putUserPreferencesTopic(topicId: String, status: CourierUserPreferencesStatus, hasCustomRouting: Bool, customRouting: [CourierUserPreferencesChannel]) async throws {
        try await corePreferences.putUserPreferencesTopic(topicId: topicId, status: status, hasCustomRouting: hasCustomRouting, customRouting: customRouting)
    }
    
    public func putUserPreferencesTopic(topicId: String, status: CourierUserPreferencesStatus, hasCustomRouting: Bool, customRouting: [CourierUserPreferencesChannel], onSuccess: @escaping () -> Void, onFailure: @escaping (Error) -> Void) {
        Task {
            do {
                try await corePreferences.putUserPreferencesTopic(topicId: topicId, status: status, hasCustomRouting: hasCustomRouting, customRouting: customRouting)
                onSuccess()
            } catch {
                onFailure(error)
            }
        }
    }
    
    @objc public func putUserPreferencesTopic(topicId: String, status: CourierUserPreferencesStatus, hasCustomRouting: Bool, customRouting: [String], onSuccess: @escaping () -> Void, onFailure: @escaping (Error) -> Void) {
        Task {
            do {
                let routing = customRouting.map { CourierUserPreferencesChannel(rawValue: $0) ?? .unknown }
                try await corePreferences.putUserPreferencesTopic(topicId: topicId, status: status, hasCustomRouting: hasCustomRouting, customRouting: routing)
                onSuccess()
            } catch {
                onFailure(error)
            }
        }
    }
    
    /**
     * Gets a user's preference topic
     */
    @objc public func getUserPreferencesTopic(topicId: String) async throws -> CourierUserPreferencesTopic {
        return try await corePreferences.getUserPreferencesTopic(topicId: topicId)
    }
    
    @objc public func getUserPreferencesTopic(topicId: String, onSuccess: @escaping (CourierUserPreferencesTopic) -> Void, onFailure: @escaping (Error) -> Void) {
        Task {
            do {
                let topic = try await corePreferences.getUserPreferencesTopic(topicId: topicId)
                onSuccess(topic)
            } catch {
                onFailure(error)
            }
        }
    }
    
}
