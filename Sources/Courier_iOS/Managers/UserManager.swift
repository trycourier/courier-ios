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
    
    private let defaults = UserDefaults.standard
    static internal let shared = UserManager()
    
    @discardableResult
    func setCredentials(userId: String, accessToken: String, clientKey: String?, tenantId: String?) -> Dictionary<String, String>? {
        
        // Create the dictionary
        var dict = [
            userIdKey: userId,
            accessTokenKey: accessToken
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
    
    func removeCredentials() {
        defaults.removeObject(forKey: credentialsKey)
    }
    
}
