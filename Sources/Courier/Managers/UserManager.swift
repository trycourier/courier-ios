//
//  UserManager.swift
//  
//
//  Created by Michael Miller on 9/2/22.
//

import Foundation

internal class UserManager {
    
    private let credentialsKey = "courier_credentials"
    private let userIdKey = "courier_user_id"
    private let accessTokenKey = "courier_access_token"
    
    private let defaults = UserDefaults.standard
    static internal let shared = UserManager()
    
    @discardableResult
    func setCredentials(userId: String, accessToken: String) -> Dictionary<String, String>? {
        
        let dict = [
            userIdKey: userId,
            accessTokenKey: accessToken
        ]
        
        defaults.set(dict, forKey: credentialsKey)
        return getCredentials()
        
    }
    
    func getCredentials() -> Dictionary<String, String>? {
        return defaults.object(forKey: credentialsKey) as? [String : String]
    }
    
    func getUserId() -> String? {
        return getCredentials()?[userIdKey]
    }
    
    func getAccessToken() -> String? {
        return getCredentials()?[accessTokenKey]
    }
    
    func removeCredentials() {
        defaults.removeObject(forKey: credentialsKey)
    }
    
}
