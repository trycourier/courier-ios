//
//  UsersRepository.swift
//
//
//  Created by https://github.com/mikemilla on 7/7/22.
//

import Foundation

internal class UsersRepository: Repository {
    
    // MARK: Tokens
    
    internal func putUserToken(accessToken: String, userId: String, provider: String, token: String) async throws {
        
        let body = try? JSONEncoder().encode(CourierToken(
            provider_key: provider,
            device: CourierDevice()
        ))
        
        try await put(
            accessToken: accessToken,
            url: "\(CourierUrl.baseRest)/users/\(userId)/tokens/\(token)",
            body: body,
            validCodes: [200, 204]
        )
        
    }
    
    internal func deleteToken(accessToken: String, userId: String, token: String) async throws {
        
        try await delete(
            accessToken: accessToken,
            url: "\(CourierUrl.baseRest)/users/\(userId)/tokens/\(token)",
            validCodes: [200, 204]
        )
        
    }
    
    // MARK: Preferences
    
    internal func getUserPreferences(accessToken: String, userId: String, paginationCursor: String? = nil) async throws -> CourierUserPreferences {
        
        var url = "\(CourierUrl.baseRest)/users/\(userId)/preferences"
        
        if let cursor = paginationCursor {
            url += "?cursor=\(cursor)"
        }
        
        let data = try await get(
            accessToken: accessToken,
            url: url
        )
        
        do {
            return try JSONDecoder().decode(CourierUserPreferences.self, from: data ?? Data())
        } catch {
            let e = CourierError(from: error)
            Courier.log(e.message)
            throw e
        }
        
    }
    
    internal struct TopicUpdate: Codable {
        let topic: TopicDetails
    }
    
    internal struct TopicDetails: Codable {
        let status: String
        let has_custom_routing: Bool
        let custom_routing: [String]
    }
    
    internal func putUserPreferencesTopic(accessToken: String, userId: String, topicId: String, status: CourierUserPreferencesStatus, hasCustomRouting: Bool, customRouting: [CourierUserPreferencesChannel]) async throws {
        
        let body = try? JSONEncoder().encode(
            TopicUpdate(
                topic: TopicDetails(
                    status: status.rawValue,
                    has_custom_routing: hasCustomRouting,
                    custom_routing: customRouting.map { $0.rawValue }
                )
            )
        )
        
        try await put(
            accessToken: accessToken,
            url: "\(CourierUrl.baseRest)/users/\(userId)/preferences/\(topicId)",
            body: body
        )
        
    }
    
    internal func getUserPreferencesTopic(accessToken: String, userId: String, topicId: String) async throws -> CourierUserPreferencesTopic {
        
        let data = try await get(
            accessToken: accessToken,
            url: "\(CourierUrl.baseRest)/users/\(userId)/preferences/\(topicId)"
        )
        
        do {
            let res = try JSONDecoder().decode(CourierUserPreferencesTopicResponse.self, from: data ?? Data())
            return res.topic
        } catch {
            let e = CourierError(from: error)
            Courier.log(e.message)
            throw e
        }
        
    }
    
}
