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

    // The access token and client key go to the Keychain; everything else stays in UserDefaults.
    // Replaceable so unit tests can run where the Keychain isn't available.
    var secrets: SecretStore = KeychainSecretStore()

    @discardableResult
    func setCredentials(userId: String, accessToken: String, clientKey: String?, tenantId: String?, apiUrls: CourierClient.ApiUrls, showLogs: Bool) -> Dictionary<String, String>? {

        // Create the dictionary
        // The urls and log setting are saved so the client can be rebuilt on the next launch
        var dict = [
            userIdKey: userId,
            restUrlKey: apiUrls.rest,
            graphqlUrlKey: apiUrls.graphql,
            inboxGraphqlUrlKey: apiUrls.inboxGraphql,
            inboxWebSocketUrlKey: apiUrls.inboxWebSocket,
            showLogsKey: String(showLogs)
        ]
        
        // The secrets go to the Keychain. If it can't be written, they stay in UserDefaults as
        // before, so signing in never fails because of it.
        if !secrets.write(accessToken, for: accessTokenKey) {
            dict[accessTokenKey] = accessToken
        }

        secrets.delete(clientKeyKey)
        if let key = clientKey, !secrets.write(key, for: clientKeyKey) {
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
        guard getCredentials() != nil else { return nil }
        return secret(clientKeyKey)
    }
    
    func getAccessToken() -> String? {
        guard getCredentials() != nil else { return nil }
        let token = secret(accessTokenKey)

        // A saved session with no token: restored from a backup to a new device, where the Keychain
        // item didn't come along. Sign out, rather than report a user with no client.
        if token == nil, case .missing = secrets.read(accessTokenKey) {
            removeCredentials()
        }

        return token
    }

    // Reads a secret, moving one saved by an earlier version from UserDefaults into the Keychain
    private func secret(_ key: String) -> String? {

        if var credentials = getCredentials(), let legacy = credentials[key] {
            if secrets.write(legacy, for: key) {
                credentials[key] = nil
                defaults.set(credentials, forKey: credentialsKey)
            }
            return legacy
        }

        if case .found(let value) = secrets.read(key) {
            return value
        }

        return nil

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
        secrets.delete(accessTokenKey)
        secrets.delete(clientKeyKey)
    }
    
}
