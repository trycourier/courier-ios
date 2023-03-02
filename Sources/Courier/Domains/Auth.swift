//
//  Auth.swift
//  
//
//  Created by Michael Miller on 3/2/23.
//

import Foundation

internal class Auth {
    
    internal let userManager = UserManager()
    
    internal func signIn(accessToken: String, clientKey: String, userId: String, push: Push, inbox: Inbox) async throws {
        
        Courier.log("Updating Courier User Profile")
        Courier.log("Access Token: \(accessToken)")
        Courier.log("Client Key: \(clientKey)")
        Courier.log("User Id: \(userId)")
        
        userManager.setCredentials(
            userId: userId,
            accessToken: accessToken,
            clientKey: clientKey
        )
        
        do {
            
            async let putTokens: () = push.putPushTokens()
            async let connectInbox: () = inbox.connectIfNeeded()
            
            // Batch all functions together
            let _ = try await [putTokens, connectInbox]
            
        } catch {
            
            Courier.log(String(describing: error))
            
            try await signOut(push: push, inbox: inbox)
            
            throw error
            
        }
        
    }
    
    internal func signOut(push: Push, inbox: Inbox) async throws {
        
        Courier.log("Clearing Courier User Credentials")
        
        do {
            
            try await push.deletePushTokens()
            
            inbox.close()
            
        } catch {
            
            Courier.log("Error deleting token")
            Courier.log("\(error)")
            
        }
        
        // Sign out will still work, but will keep
        // existing tokens in Courier if failure
        userManager.removeCredentials()
        
    }
    
}

extension Courier {
    
    /**
     * A read only value set to the current user client key
     */
    internal var clientKey: String? {
        get {
            return auth.userManager.getClientKey()
        }
    }
    
    /**
     * The key required to initialized the SDK
     * https://www.courier.com/docs/reference/auth/issue-token/
     */
    internal var accessToken: String? {
        get {
            return auth.userManager.getAccessToken()
        }
    }
    
    /**
     * A read only value set to the current user id
     */
    @objc public var userId: String? {
        get {
            return auth.userManager.getUserId()
        }
    }
    
    @objc public var isUserSignedIn: Bool {
        get {
            return userId != nil && clientKey != nil && accessToken != nil
        }
    }
    
    /**
     * Set the current credentials for the user and their access token
     * You should consider using this in areas where you update your local user's state
     */
    @objc public func signIn(accessToken: String, clientKey: String, userId: String) async throws {
        try await auth.signIn(accessToken: accessToken, clientKey: clientKey, userId: userId, push: push, inbox: inbox)
    }
    
    @objc public func signIn(accessToken: String, clientKey: String, userId: String, onSuccess: @escaping () -> Void, onFailure: @escaping (Error) -> Void) {
        Task {
            do {
                try await auth.signIn(accessToken: accessToken, clientKey: clientKey, userId: userId, push: push, inbox: inbox)
                onSuccess()
            } catch {
                onFailure(error)
            }
        }
    }
    
    /**
     * Clears the current user id and access token
     * You should call this when your user signs out
     * It will remove the current tokens used for this user in Courier so they do not receive pushes they should not get
     */
    @objc public func signOut() async throws {
        try await auth.signOut(push: push, inbox: inbox)
    }
    
    @objc public func signOut(onSuccess: @escaping () -> Void, onFailure: @escaping (Error) -> Void) {
        Task {
            do {
                try await auth.signOut(push: push, inbox: inbox)
                onSuccess()
            } catch {
                onFailure(error)
            }
        }
    }
    
}
