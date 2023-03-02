//
//  Push.swift
//  
//
//  Created by Michael Miller on 3/2/23.
//

import UIKit

internal class Push {
    
    private lazy var tokenRepo = TokenRepository()
    private lazy var trackingRepo = TrackingRepository()
    
    // MARK: Getters
    
    internal static var userNotificationCenter: UNUserNotificationCenter {
        get { UNUserNotificationCenter.current() }
    }
    
    // MARK: Token Management
    
    /**
     * The token issued by Apple to receive tokens on this device
     * Can only be set by the Courier SDK, but can be read by external packages
     */
    public private(set) var rawApnsToken: Data? = nil
    
    internal func putPushTokens() async throws {
        
        guard let accessToken = Courier.shared.accessToken, let userId = Courier.shared.userId else {
            return
        }
        
        // Attempt to put the users tokens
        // If we have them
        async let putAPNS: () = tokenRepo.putUserToken(
            accessToken: accessToken,
            userId: userId,
            provider: .apns,
            deviceToken: Courier.shared.apnsToken
        )
        
        async let putFCM: () = tokenRepo.putUserToken(
            accessToken: accessToken,
            userId: userId,
            provider: .fcm,
            deviceToken: fcmToken
        )
        
        let _ = try await [putAPNS, putFCM]
        
    }
    
    internal func deletePushTokens() async throws {
        
        guard let accessToken = Courier.shared.accessToken, let userId = Courier.shared.userId else {
            return
        }
        
        async let deleteAPNS: () = tokenRepo.deleteToken(
            accessToken: accessToken,
            userId: userId,
            deviceToken: Courier.shared.apnsToken
        )
        
        async let deleteFCM: () = tokenRepo.deleteToken(
            accessToken: accessToken,
            userId: userId,
            deviceToken: Courier.shared.fcmToken
        )
        
        let _ = try await [deleteAPNS, deleteFCM]
        
    }
    
    internal func setAPNSToken(_ rawToken: Data) async throws {
        
        guard let accessToken = Courier.shared.accessToken, let userId = Courier.shared.userId else {
            return
        }
        
        // Delete the current apns token
        do {
            try await tokenRepo.deleteToken(
                accessToken: accessToken,
                userId: userId,
                deviceToken: Courier.shared.apnsToken
            )
        } catch {
            Courier.log(String(describing: error))
        }
        
        // We save the raw apns token here
        rawApnsToken = rawToken
        
        Courier.log("Apple Push Notification Service Token")
        Courier.log(rawToken.string)
        
        return try await tokenRepo.putUserToken(
            accessToken: accessToken,
            userId: userId,
            provider: .apns,
            deviceToken: rawToken.string
        )
        
    }
    
    internal private(set) var fcmToken: String? = nil
    
    internal func setFCMToken(_ token: String) async throws {
        
        guard let accessToken = Courier.shared.accessToken, let userId = Courier.shared.userId else {
            return
        }
        
        // Delete the current fcm token
        do {
            try await tokenRepo.deleteToken(
                accessToken: accessToken,
                userId: userId,
                deviceToken: fcmToken
            )
        } catch {
            Courier.log(String(describing: error))
        }
        
        fcmToken = token
        
        Courier.log("Firebase Cloud Messaging Token")
        Courier.log(token)
        
        return try await tokenRepo.putUserToken(
            accessToken: accessToken,
            userId: userId,
            provider: .fcm,
            deviceToken: token
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
     * The current apns token for the device
     */
    @objc public var apnsToken: String? {
        get {
            return push.rawApnsToken?.string
        }
    }
    
    /**
     * The current firebase cloud messaging token for the device
     */
    @objc public var fcmToken: String? {
        get {
            return push.fcmToken
        }
    }
    
    /**
     * Get the authorization status of the notification permissions
     * Completion returns on main thread
     */
    @objc public static func getNotificationPermissionStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        Push.userNotificationCenter.getNotificationSettings(completionHandler: { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        })
    }
    
    /**
     * Get notification permission status with async await
     */
    @objc public static func getNotificationPermissionStatus() async throws -> UNAuthorizationStatus {
        let settings = await Push.userNotificationCenter.notificationSettings()
        return settings.authorizationStatus
    }
    
    /**
     * Request notification permission access with completion handler
     * Completion returns on main thread
     */
    @objc public static func requestNotificationPermission(completion: @escaping (UNAuthorizationStatus) -> Void) {
        Push.userNotificationCenter.requestAuthorization(
            options: Push.permissionAuthorizationOptions,
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
        try await Push.userNotificationCenter.requestAuthorization(options: Push.permissionAuthorizationOptions)
        return try await Courier.getNotificationPermissionStatus()
    }
    
    /**
     * Use this function if you are manually handling notifications and not using `CourierDelegate`
     * `CourierDelegate` will automatically track the urls
     */
    @objc public func trackNotification(message: [AnyHashable : Any], event: CourierPushEvent) async throws {
        try await push.trackNotification(message: message, event: event)
    }
    
    @objc public func trackNotification(message: [AnyHashable : Any], event: CourierPushEvent, onSuccess: (() -> Void)? = nil, onFailure: ((Error) -> Void)? = nil) {
        Task {
            do {
                try await push.trackNotification(message: message, event: event)
                onSuccess?()
            } catch {
                Courier.log(String(describing: error))
                onFailure?(error)
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
        try await push.setAPNSToken(rawToken)
    }
    
    @objc public func setAPNSToken(_ rawToken: Data, onSuccess: @escaping () -> Void, onFailure: @escaping (Error) -> Void) {
        Task {
            do {
                try await push.setAPNSToken(rawToken)
                onSuccess()
            } catch {
                onFailure(error)
            }
        }
    }
    
    /**
     * Upserts the FCM token in Courier for the current user
     * To get started with FCM, checkout the firebase docs here: https://firebase.google.com/docs/cloud-messaging/ios/client
     */
    @objc public func setFCMToken(_ token: String) async throws {
        try await push.setFCMToken(token)
    }
    
    @objc public func setFCMToken(_ token: String, onSuccess: @escaping () -> Void, onFailure: @escaping (Error) -> Void) {
        Task {
            do {
                try await push.setFCMToken(token)
                onSuccess()
            } catch {
                onFailure(error)
            }
        }
    }
    
}
