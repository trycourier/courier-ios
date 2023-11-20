//
//  CorePush.swift
//  
//
//  Created by https://github.com/mikemilla on 3/2/23.
//

import UIKit

internal class CorePush {
    
    private lazy var usersRepo = UsersRepository()
    private lazy var trackingRepo = TrackingRepository()
    
    // Keep a reference to all tokens
    internal var tokens: [String: String] = [:]
    
    /**
     * The token issued by Apple on this device
     * Can only be set by the Courier SDK, but can be read by external packages
     */
    public private(set) var apnsToken: Data? = nil {
        didSet {
            
            let key = CourierPushProvider.apn.rawValue
            
            // Save or remove the token
            if let token = apnsToken?.string {
                tokens[key] = token
            } else {
                tokens.removeValue(forKey: key)
            }
            
        }
    }
    
    // MARK: Getters
    
    internal static var userNotificationCenter: UNUserNotificationCenter {
        get { UNUserNotificationCenter.current() }
    }
    
    // MARK: Token Management
    
    internal func putToken(provider: String, token: String) async throws {
        
        guard let accessToken = Courier.shared.accessToken, let userId = Courier.shared.userId else {
            throw CourierError.noAccessTokenFound
        }
        
        Courier.log("Putting \(provider) Token: \(token)")
        
        return try await usersRepo.putUserToken(
            accessToken: accessToken,
            userId: userId,
            provider: provider,
            token: token
        )
        
    }
    
    internal func putTokenIfNeeded(provider: String, token: String?) async {
        
        guard let _ = Courier.shared.accessToken, let _ = Courier.shared.userId, let newToken = token else {
            return
        }
        
        do {
            try await putToken(provider: provider, token: newToken)
        } catch {
            Courier.log(error.friendlyMessage)
        }
        
    }
    
    internal func deleteToken(token: String) async throws {
        
        guard let accessToken = Courier.shared.accessToken, let userId = Courier.shared.userId else {
            throw CourierError.noAccessTokenFound
        }
        
        Courier.log("Deleting Token: \(token)")
        
        // Remove the token in Courier
        try await usersRepo.deleteToken(
            accessToken: accessToken,
            userId: userId,
            token: token
        )
        
    }
    
    internal func deleteTokenIfNeeded(token: String?) async {
        
        guard let _ = Courier.shared.accessToken, let _ = Courier.shared.userId, let prevToken = token else {
            return
        }
        
        do {
            try await deleteToken(token: prevToken)
        } catch {
            Courier.log(error.friendlyMessage)
        }
        
    }
    
    // Attempt to put the users tokens if we have them
    internal func putPushTokens() async {
        for (key, value) in tokens {
            await putTokenIfNeeded(provider: key, token: value)
        }
    }
    
    internal func deletePushTokens() async {
        for (_, value) in tokens {
            await deleteTokenIfNeeded(token: value)
        }
    }
    
    // MARK: APNS
    
    internal func setAPNSToken(_ rawToken: Data) async throws {
        
        guard let _ = Courier.shared.accessToken, let _ = Courier.shared.userId else {
            apnsToken = rawToken
            return
        }
        
        // APNS key
        let provider = CourierPushProvider.apn.rawValue
        
        // Delete the existing token
        await deleteTokenIfNeeded(
            token: tokens[provider]
        )
        
        // Save the local token
        apnsToken = rawToken

        return try await putToken(
            provider: provider,
            token: rawToken.string
        )
        
    }
    
    internal func setToken(provider: String, token: String) async throws {
        
        guard let _ = Courier.shared.accessToken, let _ = Courier.shared.userId else {
            tokens[provider] = token
            return
        }
        
        // Delete the existing token
        await deleteTokenIfNeeded(
            token: tokens[provider]
        )
        
        // Save the token locally
        tokens[provider] = token
        
        // Update the token
        return try await putToken(
            provider: provider,
            token: token
        )
        
    }
    
    /**
     * Permission authorization options needed to handle pushes nicely
     */
    internal static var permissionAuthorizationOptions: UNAuthorizationOptions {
        get {
            return [.alert, .badge, .sound]
        }
    }
    
    // MARK: Analytics
    
    internal func trackNotification(message: [AnyHashable : Any], event: CourierPushEvent) async throws {
        
        guard let trackingUrl = message["trackingUrl"] as? String else {
            Courier.log("Unable to find tracking url")
            return
        }
        
        Courier.log("Tracking notification event")
        
        return try await trackingRepo.postTrackingUrl(
            url: trackingUrl,
            event: event
        )
        
    }
    
}

extension Courier {
    
    /**
     * The current APNS token for the device
     */
    @objc public var apnsToken: Data? {
        get {
            return corePush.apnsToken
        }
    }
    
    /**
     * Gets the current token for a provider
     */
    public func getToken(provider: CourierPushProvider) -> String? {
        return corePush.tokens[provider.rawValue]
    }
    
    @objc public func getToken(providerKey: String) -> String? {
        return corePush.tokens[providerKey]
    }
    
    /**
     * Sets the current token for a provider
     */
    public func setToken(provider: CourierPushProvider, token: String) async throws {
        try await corePush.setToken(provider: provider.rawValue, token: token)
    }
    
    public func setToken(provider: CourierPushProvider, token: String, onSuccess: @escaping () -> Void, onFailure: @escaping (Error) -> Void) {
        Task {
            do {
                try await corePush.setToken(provider: provider.rawValue, token: token)
                onSuccess()
            } catch {
                Courier.log(error.friendlyMessage)
                onFailure(error)
            }
        }
    }
    
    @objc public func setToken(providerKey: String, token: String) async throws {
        try await corePush.setToken(provider: providerKey, token: token)
    }
    
    @objc public func setToken(providerKey: String, token: String, onSuccess: @escaping () -> Void, onFailure: @escaping (Error) -> Void) {
        Task {
            do {
                try await corePush.setToken(provider: providerKey, token: token)
                onSuccess()
            } catch {
                Courier.log(error.friendlyMessage)
                onFailure(error)
            }
        }
    }
    
    /**
     * Upserts the APNS token in Courier for the current user
     * If you implement `CourierDelegate`, this will get set automattically
     * If you are not using `CourierDelegate`, please add this to `didRegisterForRemoteNotificationsWithDeviceToken`
     * This function requires a `Data` value as the token.
     */
    @objc public func setAPNSToken(_ rawToken: Data) async throws {
        try await corePush.setAPNSToken(rawToken)
    }
    
    @objc public func setAPNSToken(_ rawToken: Data, onSuccess: @escaping () -> Void, onFailure: @escaping (Error) -> Void) {
        Task {
            do {
                try await corePush.setAPNSToken(rawToken)
                onSuccess()
            } catch {
                onFailure(error)
            }
        }
    }
    
    /**
     * Get the authorization status of the notification permissions
     * Completion returns on main thread
     */
    @objc public static func getNotificationPermissionStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        CorePush.userNotificationCenter.getNotificationSettings(completionHandler: { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        })
    }
    
    /**
     * Get notification permission status with async await
     */
    @objc public static func getNotificationPermissionStatus() async throws -> UNAuthorizationStatus {
        let settings = await CorePush.userNotificationCenter.notificationSettings()
        return settings.authorizationStatus
    }
    
    /**
     * Request notification permission access with completion handler
     * Completion returns on main thread
     */
    @objc public static func requestNotificationPermission(completion: @escaping (UNAuthorizationStatus) -> Void) {
        CorePush.userNotificationCenter.requestAuthorization(
            options: CorePush.permissionAuthorizationOptions,
            completionHandler: { _, _ in
                
                // Get the full status of the permission
                getNotificationPermissionStatus { permission in
                    completion(permission)
                }
                
            }
        )
    }
    
    /**
     * Request notification permission access with async await
     */
    @discardableResult @objc public static func requestNotificationPermission() async throws -> UNAuthorizationStatus {
        try await CorePush.userNotificationCenter.requestAuthorization(options: CorePush.permissionAuthorizationOptions)
        return try await Courier.getNotificationPermissionStatus()
    }
    
    /**
     * Use this function if you are manually handling notifications and not using `CourierDelegate`
     * `CourierDelegate` will automatically track the urls
     */
    @objc public func trackNotification(message: [AnyHashable : Any], event: CourierPushEvent) async throws {
        try await corePush.trackNotification(message: message, event: event)
    }
    
    @objc public func trackNotification(message: [AnyHashable : Any], event: CourierPushEvent, onSuccess: (() -> Void)? = nil, onFailure: ((Error) -> Void)? = nil) {
        Task {
            do {
                try await corePush.trackNotification(message: message, event: event)
                onSuccess?()
            } catch {
                Courier.log(error.friendlyMessage)
                onFailure?(error)
            }
        }
    }
    
}
