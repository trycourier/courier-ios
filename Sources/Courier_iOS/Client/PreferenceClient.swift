//
//  PreferenceClient.swift
//
//
//  Created by https://github.com/mikemilla on 7/22/24.
//

import Foundation

public class PreferenceClient: CourierApiClient {
    
    private let options: CourierClient.Options
        
    init(options: CourierClient.Options) {
        self.options = options
        super.init()
    }
    
    public func getUserPreferences(paginationCursor: String? = nil) async throws -> CourierUserPreferences {
        
        var url = "\(PreferenceClient.BASE_REST)/users/\(options.userId)/preferences"
        
        if let cursor = paginationCursor {
            url += "?cursor=\(cursor)"
        }

        let request = try http(url) {
            
            $0.httpMethod = "GET"
            
            if let jwt = options.jwt {
                $0.addHeader(key: "Authorization", value: "Bearer \(jwt)")
            }
            
        }
        
        return try await request.dispatch(options)
        
    }
    
    public func getUserPreferenceTopic(topicId: String) async throws -> CourierUserPreferencesTopic {
        
        let url = "\(PreferenceClient.BASE_REST)/users/\(options.userId)/preferences/\(topicId)"

        let request = try http(url) {
            
            $0.httpMethod = "GET"
            
            if let jwt = options.jwt {
                $0.addHeader(key: "Authorization", value: "Bearer \(jwt)")
            }
            
        }
        
        let res = try await request.dispatch(options) as CourierUserPreferencesTopicResponse
        return res.topic
        
    }
    
    public func putUserPreferenceTopic(topicId: String, status: CourierUserPreferencesStatus, hasCustomRouting: Bool, customRouting: [CourierUserPreferencesChannel]) async throws {
        
        let url = "\(PreferenceClient.BASE_REST)/users/\(options.userId)/preferences/\(topicId)"

        let request = try http(url) {
            
            $0.httpMethod = "PUT"
            
            if let jwt = options.jwt {
                $0.addHeader(key: "Authorization", value: "Bearer \(jwt)")
            }
            
            $0.httpBody = try? JSONEncoder().encode(
                TopicUpdate(
                    topic: TopicDetails(
                        status: status.rawValue,
                        has_custom_routing: hasCustomRouting,
                        custom_routing: customRouting.map { $0.rawValue }
                    )
                )
            )
            
        }
        
        try await request.dispatch(options)
        
    }
    
}

// MARK: Requst Payloads

internal extension PreferenceClient {
    
    struct TopicDetails: Codable {
        let status: String
        let has_custom_routing: Bool
        let custom_routing: [String]
    }
    
    struct TopicUpdate: Codable {
        let topic: TopicDetails
    }
    
}
