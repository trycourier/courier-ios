//
//  CoreAuth.swift
//  
//
//  Created by https://github.com/mikemilla on 3/2/23.
//

import Foundation

internal class CoreAuth {
    
    internal let userManager = UserManager()
    
    private var listeners: [CourierAuthenticationListener] = []
    
    internal func signIn(accessToken: String, clientKey: String?, userId: String, push: CorePush, inbox: CoreInbox) async throws {
        
        Courier.log("Signing user in")
        Courier.log("Access Token: \(accessToken)")
        Courier.log("Client Key: \(clientKey ?? "Not set")")
        Courier.log("User Id: \(userId)")
        
        userManager.setCredentials(
            userId: userId,
            accessToken: accessToken,
            clientKey: clientKey
        )
        
        do {
            
            async let putTokens: () = push.putPushTokens()
            async let connectInbox: () = inbox.restartInboxIfNeeded()
            
            // Batch all functions together
            let _ = try await [putTokens, connectInbox]
            
            // Notify
            notifyListeners()
            
        } catch {
            
            Courier.log(error.friendlyMessage)
            
            try await signOut(push: push, inbox: inbox)
            
            throw error
            
        }
        
    }
    
    internal func signOut(push: CorePush, inbox: CoreInbox) async throws {
        
        Courier.log("Signing user out")
        
        await push.deletePushTokens()
        
        inbox.close()
        
        // Sign out will still work, but will keep
        // existing tokens in Courier if failure
        userManager.removeCredentials()
        
        // Notify
        notifyListeners()
        
    }
    
    private func notifyListeners() {
        Utils.runOnMainThread { [weak self] in
            self?.listeners.forEach {
                $0.onChange(Courier.shared.userId)
            }
        }
    }
    
    internal func addAuthChangeListener(onChange: @escaping (String?) -> Void) -> CourierAuthenticationListener {
        
        // Create a new authentication listener
        let listener = CourierAuthenticationListener(
            onChange: onChange
        )
        
        // Keep track of listener
        listeners.append(listener)
        
        return listener
        
    }
    
    internal func removeAuthenticationListener(listener: CourierAuthenticationListener) {
        listeners.removeAll(where: {
            return $0 == listener
        })
    }
    
}

extension Courier {
    
    /**
     * A read only value set to the current user client key
     * https://app.courier.com/channels/courier
     */
    internal var clientKey: String? {
        get {
            return auth.userManager.getClientKey()
        }
    }
    
    /**
     * The key required to initialized the SDK
     * https://app.courier.com/settings/api-keys
     * or
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
            return userId != nil && accessToken != nil
        }
    }
    
    /**
     Set the current credentials for the user and their access token
     You should consider using this in areas where you update your local user's state
     */
    @objc public func signIn(accessToken: String, clientKey: String? = nil, userId: String) async throws {
        try await auth.signIn(accessToken: accessToken, clientKey: clientKey, userId: userId, push: push, inbox: inbox)
    }
    
    @objc public func signIn(accessToken: String, clientKey: String? = nil, userId: String, onSuccess: @escaping () -> Void, onFailure: @escaping (Error) -> Void) {
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
     Clears the current user id and access token
     You should call this when your user signs out
     It will remove the current tokens used for this user in Courier so they do not receive pushes they should not get
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
    
    /**
     Gets called when the Authentication state for the current user changes in Courier
     */
    @discardableResult @objc public func addAuthenticationListener(_ onChange: @escaping (String?) -> Void) -> CourierAuthenticationListener {
        return auth.addAuthChangeListener(onChange: onChange)
    }
    
}
