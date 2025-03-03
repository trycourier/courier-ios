//
//  UserManager.swift
//  Example
//
//  Created by Michael Miller on 3/3/25.
//

import Foundation
import Courier_iOS

class UserManager {
    
    private let credentialsKey = "example_credentials"
    private let defaults = UserDefaults.standard
    static let shared = UserManager()
    
    private init() {}
    
    @discardableResult
    func setCredential(key: String, value: String) -> [String: String]? {
        var currentCredentials = getCredentials()
        currentCredentials[key] = value
        defaults.set(currentCredentials, forKey: credentialsKey)
        return currentCredentials
    }
    
    func getCredentials() -> [String: String] {
        let defaultUrls = CourierClient.ApiUrls()
        return defaults.object(forKey: credentialsKey) as? [String: String] ?? [
            "restUrl": defaultUrls.rest,
            "graphqlUrl": defaultUrls.graphql,
            "inboxGraphqlUrl": defaultUrls.inboxGraphql,
            "inboxWebsocketUrl": defaultUrls.inboxWebSocket
        ]
    }
    
    func getCredential(forKey key: String) -> String? {
        return getCredentials()[key]
    }
    
    func removeCredentials() {
        defaults.removeObject(forKey: credentialsKey)
    }
}

