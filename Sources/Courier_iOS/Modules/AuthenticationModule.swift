//
//  CoreAuth.swift
//  
//
//  Created by https://github.com/mikemilla on 3/2/23.
//

import Foundation

@CourierActor extension Courier {
    
    /**
     * A read only value set to the current user id
     */
    public var userId: String? {
        get {
            return UserManager.shared.getUserId()
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
            return UserManager.shared.getAccessToken()
        }
    }
    
    /**
     * A read only value set to the current user client key
     * https://app.courier.com/channels/courier
     */
    internal var clientKey: String? {
        get {
            return UserManager.shared.getClientKey()
        }
    }
    
    /**
     * Token needed to authenticate with JWTs for GraphQL requests
     */
    internal var jwt: String? {
        get {
            if let _ = clientKey { return nil }
            return accessToken
        }
    }
    
    public var tenantId: String? {
        get {
            return UserManager.shared.getTenantId()
        }
    }
    
    public var isUserSignedIn: Bool {
        get {
            return userId != nil
        }
    }
    
    // MARK: User Registration
    
    public func signIn(userId: String, tenantId: String? = nil, accessToken: String, clientKey: String? = nil, showLogs: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()) async {
        
        // Check if the current user exists
        if (isUserSignedIn) {
            await signOut()
        }
        
        // Generate a new connection id
        // Used for inbox socket
        let connectionId = UUID().uuidString
        
        // Create the client
        self.client = CourierClient(
            jwt: accessToken,
            clientKey: clientKey,
            userId: userId,
            connectionId: connectionId,
            tenantId: tenantId,
            showLogs: showLogs
        )
        
        self.client?.log("""
        Signing user in
        User Id: \(userId)
        Tenant Id: \(tenantId ?? "Not set")
        Access Token: \(accessToken)
        Client Key: \(clientKey ?? "Not set")
        """)
        
        UserManager.shared.setCredentials(
            userId: userId,
            accessToken: accessToken,
            clientKey: clientKey,
            tenantId: tenantId
        )
        
        // Refresh SDK
        await putPushTokens()
        await restartInbox()
        
        await notifyListeners(userId)
        
    }
    
    public func signOut() async {
        
        // Check if the current user exists
        if (!isUserSignedIn) {
            self.client?.log("No user signed into Courier. A user must be signed in on order to sign out.")
            self.client = nil
            return
        }
        
        self.client?.log("Signing user out")
        self.client = nil
        
        await deletePushTokens()
        await closeInbox()
        
        // Sign out will still work, but will keep
        // existing tokens in Courier if failure
        UserManager.shared.removeCredentials()
        
        await notifyListeners(nil)
        
    }
    
    // MARK: Listeners
    
    @discardableResult
    public func addAuthenticationListener(onChange: @escaping (String?) -> Void) -> CourierAuthenticationListener {
        let listener = CourierAuthenticationListener(onChange: onChange)
        self.authListeners.append(listener)
        print("Courier Authentication Listener Registered. Total Listeners: \(self.authListeners.count)")
        return listener
    }

    public func removeAuthenticationListener(_ listener: CourierAuthenticationListener) {
        self.authListeners.removeAll(where: { return $0 == listener })
        print("Courier Authentication Listener Unregistered. Total Listeners: \(self.authListeners.count)")
    }
    
    public func removeAllAuthenticationListeners() {
        self.authListeners.removeAll()
        print("Courier Authentication Listeners Removed. Total Listeners: \(self.authListeners.count)")
    }
    
    // MARK: Notifications

    private func notifyListeners(_ userId: String?) async {
        let listeners = self.authListeners
        await MainActor.run {
            listeners.forEach { listener in
                listener.onChange(userId)
            }
        }
    }
    
}
