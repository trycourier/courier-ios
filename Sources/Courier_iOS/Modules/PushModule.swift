//
//  PushModule.swift
//
//
//  Created by Michael Miller on 7/23/24.
//

import UIKit

internal actor PushModule {
    
    /**
     * The token issued by Apple on this device
     * Can only be set by the Courier SDK, but can be read by external packages
     */
    private(set) var apnsToken: Data? = nil
    
    func setApnsToken(_ token: Data?) {
        apnsToken = token
    }
    
    // Keep a reference to all tokens
    private(set) var tokens: [String: String] = [:]
    
    /**
     Caches a token for a key
     This is used to grab current sessions push tokens
     */
    func cacheToken(key: String, value: String?) {
        
        // Ensure we have a key
        if (key.isEmpty) {
            return
        }
        
        // Check for token value
        guard let token = value else {
            tokens.removeValue(forKey: key)
            return
        }
        
        // Ensure token is not empty
        if (token.isEmpty) {
            return
        }
        
        // Cache the token
        tokens[key] = token
        
    }
    
}

extension Courier {
    
    // MARK: Getters
    
    internal static var userNotificationCenter: UNUserNotificationCenter {
        get { UNUserNotificationCenter.current() }
    }
    
    /**
     * Permission authorization options needed to handle pushes nicely
     */
    internal static var permissionAuthorizationOptions: UNAuthorizationOptions {
        get {
            return [.alert, .badge, .sound]
        }
    }
    
    // MARK: Tokens
    
    /// Returns the current APNS token
    var apnsToken: Data? {
        get async {
            await pushModule.apnsToken
        }
    }
    
    /// Returns all cached tokens
    var tokens: [String: String] {
        get async {
            await pushModule.tokens
        }
    }
    
    // MARK: Token Management
    
    internal func putToken(provider: String, token: String) async throws {
        
        if (!isUserSignedIn) {
            throw CourierError.userNotFound
        }
        
        try await client?.tokens.putUserToken(
            token: token,
            provider: provider
        )
        
    }
    
    internal func deleteToken(_ token: String) async throws {
        
        if (!isUserSignedIn) {
            throw CourierError.userNotFound
        }
        
        // Remove the token in Courier
        try await client?.tokens.deleteUserToken(
            token: token
        )
        
    }
    
    internal func putPushTokens() async {
        
        let tokens = await pushModule.tokens
        
        for (provider, token) in tokens {
            do {
                try await putToken(provider: provider, token: token)
            } catch {
                let e = CourierError(from: error)
                client?.log(e.message)
            }
        }
        
    }
    
    internal func deletePushTokens() async {
        
        let tokens = await pushModule.tokens
        
        for (_, token) in tokens {
            do {
                try await deleteToken(token)
            } catch {
                let e = CourierError(from: error)
                client?.log(e.message)
            }
        }
        
    }
    
    // MARK: APNS
    
    func setAPNSToken(_ rawToken: Data) async throws {
        
        let provider = CourierPushProvider.apn.rawValue
        
        if !isUserSignedIn {
            await pushModule.setApnsToken(rawToken)
            await pushModule.cacheToken(key: provider, value: rawToken.string)
            return
        }
        
        // Delete the existing token
        if let currentToken = await pushModule.tokens[provider] {
            do {
                try await deleteToken(currentToken)
            } catch {
                let e = CourierError(from: error)
                client?.log(e.message)
            }
        }
        
        // Save the local token
        await pushModule.setApnsToken(rawToken)
        await pushModule.cacheToken(key: provider, value: rawToken.string)

        return try await putToken(
            provider: provider,
            token: rawToken.string
        )
        
    }
    
    // MARK: Any Token
    
    func setToken(provider: String, token: String) async throws {
        
        if !isUserSignedIn {
            await pushModule.cacheToken(key: provider, value: token)
            return
        }
        
        // Delete the existing token
        if let currentToken = await pushModule.tokens[provider] {
            do {
                try await deleteToken(currentToken)
            } catch {
                let e = CourierError(from: error)
                client?.log(e.message)
            }
        }
        
        // Save the token locally
        await pushModule.cacheToken(key: provider, value: token)
        
        // Update the token
        return try await putToken(
            provider: provider,
            token: token
        )
        
    }
    
}
