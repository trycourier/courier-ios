//
//  CoreAuth.swift
//  
//
//  Created by https://github.com/mikemilla on 3/2/23.
//

import Foundation

@CourierActor internal class AuthenticationModule {
    
    private let courier: Courier
    
    init(courier: Courier) {
        self.courier = courier
    }
    
    var authListeners: [CourierAuthenticationListener] = []
    
    // MARK: User Registration
    
    func signIn(userId: String, tenantId: String?, accessToken: String, clientKey: String?, apiUrls: CourierClient.ApiUrls, showLogs: Bool) async {
        
        // Check if the current user exists
        if (courier.isUserSignedIn) {
            await signOut()
        }
        
        // Generate a new connection id
        // Used for inbox socket
        let connectionId = UUID().uuidString
        
        // Create the client
        courier.client = CourierClient(
            jwt: accessToken,
            clientKey: clientKey,
            userId: userId,
            connectionId: connectionId,
            tenantId: tenantId,
            apiUrls: apiUrls,
            showLogs: showLogs
        )
        
        courier.client?.log("""
        Signing user in
        User Id: \(userId)
        Tenant Id: \(tenantId ?? "Not set")
        Access Token: <redacted>
        Client Key: \(clientKey == nil ? "Not set" : "<redacted>")
        """)
        
        UserManager.shared.setCredentials(
            userId: userId,
            accessToken: accessToken,
            clientKey: clientKey,
            tenantId: tenantId,
            apiUrls: apiUrls,
            showLogs: showLogs
        )

        // Finish removing tokens from earlier sign-outs, but not ones about to be registered here
        await courier.tokenModule.retryPendingDeletes()
        courier.tokenModule.forgetPendingDeletes(for: Array(courier.tokenModule.tokens.values))

        // Refresh SDK
        await courier.putPushTokens()
        await courier.restartInbox()
        
        await notifyListeners(userId)
        
    }
    
    func signOut() async {
        
        // Check if the current user exists
        if (!courier.isUserSignedIn) {
            courier.client?.log("No user signed into Courier. A user must be signed in on order to sign out.")
            courier.client = nil
            return
        }
        
        courier.client?.log("Signing user out")

        // The token deletes go through the client, so it has to outlive them
        await courier.deletePushTokens()
        await courier.closeInbox()

        courier.client = nil
        
        // Sign out will still work, but will keep
        // existing tokens in Courier if failure
        UserManager.shared.removeCredentials()
        
        await notifyListeners(nil)

    }

    // Credentials outlive the process but the client does not, so without this a relaunched
    // app reports a signed in user while every request is skipped until signIn runs again.
    func restoreClient() -> CourierClient? {

        let user = UserManager.shared

        // Sessions saved before the urls were stored are left alone. Falling back to the
        // default urls would send a token issued in another region to the wrong API.
        guard let userId = user.getUserId(),
              let accessToken = user.getAccessToken(),
              let apiUrls = user.getApiUrls(),
              let showLogs = user.getShowLogs() else {
            return nil
        }

        let client = CourierClient(
            jwt: accessToken,
            clientKey: user.getClientKey(),
            userId: userId,
            connectionId: UUID().uuidString,
            tenantId: user.getTenantId(),
            apiUrls: apiUrls,
            showLogs: showLogs
        )

        client.log("Restored signed in user: \(userId)")

        return client

    }

    // MARK: Listeners
    
    @discardableResult
    public func addAuthenticationListener(onChange: @escaping @MainActor (String?) -> Void) -> CourierAuthenticationListener {
        let listener = CourierAuthenticationListener(onChange: onChange)
        self.authListeners.append(listener)
        self.courier.client?.log("Courier Authentication Listener Registered. Total Listeners: \(self.authListeners.count)")
        return listener
    }

    public func removeAuthenticationListener(_ listener: CourierAuthenticationListener) {
        self.authListeners.removeAll(where: { return $0 == listener })
        self.courier.client?.log("Courier Authentication Listener Unregistered. Total Listeners: \(self.authListeners.count)")
    }
    
    public func removeAllAuthenticationListeners() {
        self.authListeners.removeAll()
        self.courier.client?.log("Courier Authentication Listeners Removed. Total Listeners: \(self.authListeners.count)")
    }
    
    // MARK: Notifications

    internal func notifyListeners(_ userId: String?) async {
        let listeners = self.authListeners
        await MainActor.run {
            listeners.forEach { listener in
                listener.onChange(userId)
            }
        }
    }
    
}

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
    
    public var authListeners: [CourierAuthenticationListener] {
        get {
            return authenticationModule.authListeners
        }
    }
    
    public func signIn(userId: String, tenantId: String? = nil, accessToken: String, clientKey: String? = nil, apiUrls: CourierClient.ApiUrls = CourierClient.ApiUrls(), showLogs: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()) async
    {
        await authenticationModule.signIn(userId: userId, tenantId: tenantId, accessToken: accessToken, clientKey: clientKey, apiUrls: apiUrls, showLogs: showLogs)
    }
    
    public func signOut() async {
        await authenticationModule.signOut()
    }
    
    @discardableResult
    public func addAuthenticationListener(onChange: @escaping @MainActor (String?) -> Void) -> CourierAuthenticationListener {
        return self.authenticationModule.addAuthenticationListener(onChange: onChange)
    }

    public func removeAuthenticationListener(_ listener: CourierAuthenticationListener) {
        return self.authenticationModule.removeAuthenticationListener(listener)
    }
    
    public func removeAllAuthenticationListeners() {
        return self.authenticationModule.removeAllAuthenticationListeners()
    }
    
}
