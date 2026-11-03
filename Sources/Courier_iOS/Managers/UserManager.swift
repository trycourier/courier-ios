//
//  UserManager.swift
//  
//
//  Created by https://github.com/mikemilla on 9/2/22.
//

import Foundation

@CourierActor internal class UserManager {
    
    private let credentialsKey = "courier_credentials"
    private let userIdKey = "courier_user_id"
    private let accessTokenKey = "courier_access_token"
    private let clientKeyKey = "courier_client_key"
    private let tenantIdKey = "courier_tenant_id"
    private let restUrlKey = "courier_rest_url"
    private let graphqlUrlKey = "courier_graphql_url"
    private let inboxGraphqlUrlKey = "courier_inbox_graphql_url"
    private let inboxWebSocketUrlKey = "courier_inbox_websocket_url"
    private let showLogsKey = "courier_show_logs"

    private let defaults = UserDefaults.standard
    static internal let shared = UserManager()

    @discardableResult
    func setCredentials(userId: String, accessToken: String, clientKey: String?, tenantId: String?, apiUrls: CourierClient.ApiUrls, showLogs: Bool) -> Dictionary<String, String>? {

        // Create the dictionary
        // The urls and log setting are saved so the client can be rebuilt on the next launch
        var dict = [
            userIdKey: userId,
            accessTokenKey: accessToken,
            restUrlKey: apiUrls.rest,
            graphqlUrlKey: apiUrls.graphql,
            inboxGraphqlUrlKey: apiUrls.inboxGraphql,
            inboxWebSocketUrlKey: apiUrls.inboxWebSocket,
            showLogsKey: String(showLogs)
        ]
        
        // Add client key if possible
        if let key = clientKey {
            dict[clientKeyKey] = key
        }
        
        // Add tenant id if possible
        if let key = tenantId {
            dict[tenantIdKey] = key
        }
        
        // Set the values
        defaults.set(dict, forKey: credentialsKey)
        
        // Return the values
        return getCredentials()
        
    }
    
    func getCredentials() -> Dictionary<String, String>? {
        return defaults.object(forKey: credentialsKey) as? [String : String]
    }
    
    func getUserId() -> String? {
        return getCredentials()?[userIdKey]
    }
    
    func getClientKey() -> String? {
        return getCredentials()?[clientKeyKey]
    }
    
    func getAccessToken() -> String? {
        return getCredentials()?[accessTokenKey]
    }
    
    func getTenantId() -> String? {
        return getCredentials()?[tenantIdKey]
    }

    // Nil for credentials saved before the urls were stored
    func getApiUrls() -> CourierClient.ApiUrls? {

        guard let credentials = getCredentials(),
              let rest = credentials[restUrlKey],
              let graphql = credentials[graphqlUrlKey],
              let inboxGraphql = credentials[inboxGraphqlUrlKey],
              let inboxWebSocket = credentials[inboxWebSocketUrlKey] else {
            return nil
        }

        return CourierClient.ApiUrls(
            rest: rest,
            graphql: graphql,
            inboxGraphql: inboxGraphql,
            inboxWebSocket: inboxWebSocket
        )

    }

    func getShowLogs() -> Bool? {
        return getCredentials()?[showLogsKey].flatMap { Bool($0) }
    }

    func removeCredentials() {
        defaults.removeObject(forKey: credentialsKey)
    }
    
}
