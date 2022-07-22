import UIKit

@available(iOS 10.0.0, *)
open class Courier: NSObject {
    
    // MARK: Courier
    
    /*

     ______  ______  __  __  ______  __  ______  ______
    /\  ___\/\  __ \/\ \/\ \/\  == \/\ \/\  ___\/\  == \
    \ \ \___\ \ \/\ \ \ \_\ \ \  __<\ \ \ \  __\\ \  __<
     \ \_____\ \_____\ \_____\ \_\ \_\ \_\ \_____\ \_\ \_\
      \/_____/\/_____/\/_____/\/_/ /_/\/_/\/_____/\/_/ /_/
     
     
     Before you begin:
     
     1. Generate APNS key (https://developer.apple.com/account/resources/authkeys/add)
     2. Download the key
     3. Enter details of APNS key here (https://app.courier.com/channels/apn)
     
     ---
     
     Enable Push Notifications Entitlement:
     
     1. Open your Xcode project file
     2. Select your Target
     3. Click "Signing & Capabilities"
     4. Click the "+" (found to the left of "All")
     5. Type "Push Notifications"
     6. Press Enter
     
     ---
     
     Follow the docs here to get everything running:
     
     Documentation: https://docs.courier.com/asdf
     
     
     */
    
    // MARK: Init
    
    private override init() {
        super.init()
    }
    
    /**
     * Singleton reference to the SDK
     * Please ensure you use this to maintain state
     */
    public static let shared = Courier()
    
    /**
     * The key required to initialized the SDK
     * This key can be found here
     * https://app.courier.com/settings/api-keys
     */
    public var authorizationKey: String? = nil {
        didSet {
            
            // Clear
            self.user = nil
            
        }
    }
    
    /**
     * Courier APIs
     */
    private lazy var userRepository = UserRepository()
    private lazy var tokenRepository = TokenRepository()
    
    // MARK: Getters
    
    private static var userNotificationCenter: UNUserNotificationCenter {
        get { UNUserNotificationCenter.current() }
    }
    
    // MARK: User Management
    
    private var currentUserId: String? = nil
    
    /**
     * A read only value for the current Courier user
     */
    public private(set) var user: CourierUser? = nil
    
    /**
     * Function used to set the current Courier user
     * You should consider using this in areas where you update your local user's state
     */
    public func setUser(_ user: CourierUser, onSuccess: (() -> Void)? = nil, onFailure: (() -> Void)? = nil) {
        
        debugPrint("⚠️ Updating Courier User")
        debugPrint(user)
        
        // Set the current user id
        currentUserId = user.id
        
        var didFail = false
        let group = DispatchGroup()
        
        // Update the user
        group.enter()
        let update = self.userRepository.updateUser(
            user: user,
            onSuccess: { [weak self] in
                debugPrint("✅ Courier User Updated")
                self?.user = user
                group.leave()
            },
            onFailure: {
                debugPrint("❌ Courier User Update Failed")
                group.leave()
                onFailure?()
            }
        )
        
        // Update apns token
        if let token = self.apnsToken {
            
            group.enter()
            self.setAPNSToken(
                token,
                onSuccess: {
                    group.leave()
                },
                onFailure: {
                    didFail = true
                    group.leave()
                })
            
        }
        
        // Update fcm token
        if let token = self.fcmToken {
            
            group.enter()
            self.setFCMToken(
                token,
                onSuccess: {
                    group.leave()
                },
                onFailure: {
                    didFail = true
                    group.leave()
                })
            
        }
        
        update?.start()
        
        group.notify(queue: DispatchQueue.global()) {
            if (didFail) {
                onFailure?()
            } else {
                onSuccess?()
            }
        }
        
    }
    
    @available(iOS 13.0.0, *)
    public func setUser(_ user: CourierUser) async throws {
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<Void, Error>) in
            setUser(
                user,
                onSuccess: { continuation.resume() },
                onFailure: { continuation.resume(throwing: CourierError.userSetFailed) })
        })
    }
    
    /**
     * Function to sign the current Courier user out
     * You should call this when your user signs out
     * It will remove the current tokens used for this user in Courier so they do not receive pushes they should not get
     */
    public func signOut(onSuccess: (() -> Void)? = nil, onFailure: (() -> Void)? = nil) {
        
        debugPrint("⚠️ Signing Courier User out")
        
        // Delete the existing token
        guard let apnsToken = self.apnsToken else {
            onSuccess?()
            return
        }
        
        var didFail = false
        let group = DispatchGroup()
        
        if let fcmToken = self.fcmToken {
            
            debugPrint("Current Courier FCM Token")
            debugPrint(fcmToken)
            
            // Start a task to complete removing fcm token
            group.enter()
            
            let delete = removeTokenTask(
                fcmToken,
                onSuccess: {
                    group.leave()
                },
                onFailure: {
                    didFail = true
                    group.leave()
                })
            
            delete?.start()
            
        }
        
        debugPrint("Current Courier APNS Token")
        debugPrint(apnsToken)
        
        // Start task to remove apns token
        group.enter()
        let delete = removeTokenTask(
            apnsToken,
            onSuccess: {
                group.leave()
            },
            onFailure: {
                didFail = true
                group.leave()
            })
        
        delete?.start()
        
        user = nil
        
        group.notify(queue: DispatchQueue.global()) {
            if (didFail) {
                onFailure?()
            } else {
                onSuccess?()
            }
        }
        
    }
    
    @available(iOS 13.0.0, *)
    public func signOut() async throws {
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<Void, Error>) in
            signOut(
                onSuccess: { continuation.resume() },
                onFailure: { continuation.resume(throwing: CourierError.userSetFailed) })
        })
    }
    
    // MARK: Token Management
    
    private func removeTokenTask(_ token: String, onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void) -> CourierTask? {
        
        guard let userId = user?.id else {
            return nil
        }
        
        return self.tokenRepository.deleteToken(
            userId: userId,
            deviceToken: token,
            onSuccess: onSuccess,
            onFailure: onFailure
        )
        
    }
    
    /**
     * The token issued by Apple to receive tokens on this device
     * Can only be set by the Courier SDK, but can be read by external packages
     */
    public private(set) var apnsToken: String? = nil
    
    /**
     * Upserts the APN token in Courier for the current user
     */
    internal func setAPNSToken(_ token: String, onSuccess: (() -> Void)? = nil, onFailure: (() -> Void)? = nil) {
        
        // Stash the token for later
        apnsToken = token
        
        debugPrint("📲 Apple Device Token")
        debugPrint(token)
        
        guard let userId = currentUserId else {
            debugPrint("❌ UserId not set. Set a user id to update the push token.")
            onFailure?()
            return
        }
        
        debugPrint("⚠️ Updating Courier Token")
        
        let update = self.tokenRepository.updatePushNotificationToken(
            userId: userId,
            provider: CourierProvider.apns,
            deviceToken: token,
            onSuccess: {
                debugPrint("✅ Courier User Token Updated")
                onSuccess?()
            },
            onFailure: {
                debugPrint("❌ Courier User Token Update Failed")
                onFailure?()
            }
        )
        
        update?.start()
        
    }
    
    /**
     * The current firebase token associated with this user
     */
    public internal(set) var fcmToken: String? = nil
    
    /**
     * Upserts the FCM token in Courier for the current user
     * To get started with FCM, checkout the firebase docs here: https://firebase.google.com/docs/cloud-messaging/ios/client
     */
    public func setFCMToken(_ token: String, onSuccess: (() -> Void)? = nil, onFailure: (() -> Void)? = nil) {
        
        // Stash the token for later
        fcmToken = token
        
        debugPrint("🔥 Firebase Cloud Messaging Token")
        debugPrint(token)
        
        guard let userId = currentUserId else {
            debugPrint("❌ UserId not set. Set a user id to update the push token.")
            onFailure?()
            return
        }
        
        debugPrint("⚠️ Updating Courier Token")
        
        let update = self.tokenRepository.updatePushNotificationToken(
            userId: userId,
            provider: CourierProvider.fcm,
            deviceToken: token,
            onSuccess: {
                debugPrint("✅ Courier User Token Updated")
                onSuccess?()
            },
            onFailure: {
                debugPrint("❌ Courier User Token Update Failed")
                onFailure?()
            }
        )
        
        update?.start()
        
    }
    
    // MARK: Permissions
    
    /**
     * Get the authorization status of the notification permissions
     * Completion returns on main thread
     */
    public static func getNotificationAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        userNotificationCenter.getNotificationSettings(completionHandler: { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        })
    }
    
    /**
     * Get notification permission status with async await
     */
    @available(iOS 13.0.0, *)
    public static func getNotificationAuthorizationStatus() async throws -> UNAuthorizationStatus {
        let settings = await userNotificationCenter.notificationSettings()
        return settings.authorizationStatus
    }
    
    /**
     * Permission authorization options needed to handle pushes nicely
     */
    private static var permissionAuthorizationOptions: UNAuthorizationOptions {
        get {
            return [.alert, .badge, .sound]
        }
    }
    
    /**
     * Request notification permission access with completion handler
     * Completion returns on main thread
     */
    public static func requestNotificationPermissions(completion: @escaping (UNAuthorizationStatus) -> Void) {
        userNotificationCenter.requestAuthorization(
            options: permissionAuthorizationOptions,
            completionHandler: { _, _ in
                
                // Get the full status of the permission
                getNotificationAuthorizationStatus { permission in
                    completion(permission)
                }
                
            }
        )
    }
    
    /**
     * Request notification permission access with async await
     */
    @available(iOS 13.0.0, *)
    public static func requestNotificationPermissions() async throws -> UNAuthorizationStatus {
        try await userNotificationCenter.requestAuthorization(options: permissionAuthorizationOptions)
        return try await getNotificationAuthorizationStatus()
    }
    
    // MARK: Testing
    
    public static func sendTestMessage(userId: String, title: String, message: String, onSuccess: ((String) -> Void)? = nil, onFailure: (() -> Void)? = nil) {
        TestRepository().sendTestPush(
            userId: userId,
            title: title,
            message: message,
            onSuccess: { requestId in
                debugPrint("✅ Test push sent")
                onSuccess?(requestId)
            },
            onFailure: {
                debugPrint("❌ Test push failed")
                onFailure?()
            }
        )?.start()
    }
    
    @available(iOS 13.0.0, *)
    @discardableResult
    public static func sendTestMessage(userId: String, title: String, message: String) async throws -> String {
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<String, Error>) in
            Courier.sendTestMessage(
                userId: userId,
                title: title,
                message: message,
                onSuccess: { requestId in continuation.resume(returning: requestId) },
                onFailure: { continuation.resume(throwing: CourierError.userSetFailed) })
        })
    }
    
}
