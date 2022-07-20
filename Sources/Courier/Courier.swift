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
     * Task Manager
     */
    internal let taskManager = CourierTaskManager()
    
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
    
    /**
     * Updates the current courier user
     * This should be something that you update with your other user managed values
     *
     * When updating this user, it will update all values in Courier.
     * Please be user you have all the values you would like for this user set here.
     */
    public var user: CourierUser? = nil {
        didSet {
            
            // Remove the user if needed
            guard let user = user else {
                return
            }
            
            // Update the user stored in Courier
            updateUser(user)
            
            // Update the current device token in Courier
            if let token = self.apnsToken {
                updateAPNSToken(token)
            }
            
        }
    }
    
    internal func updateUser(_ user: CourierUser) {
        
        debugPrint("⚠️ Updating Courier User")
        debugPrint(user)
        
        let update = self.userRepository.updateUser(
            user: user,
            onSuccess: {
                debugPrint("✅ Courier User Updated")
            },
            onFailure: {
                debugPrint("❌ Courier User Update Failed")
            }
        )
        
        if let task = update {
            taskManager.add(task)
        }
        
    }
    
    public func signOut(completion: @escaping () -> Void) {
        
        debugPrint("⚠️ Signing Courier User out")
        
        // Ensure we have a user id
        guard let userId = self.user?.id else {
            completion()
            return
        }
        
        // Delete the existing token
        if let apnsToken = self.apnsToken {
            
            debugPrint("Current Courier APNS Token")
            debugPrint(apnsToken)
            
            let delete = self.tokenRepository.deleteToken(
                userId: userId,
                deviceToken: apnsToken,
                onSuccess: { [weak self] in
                    
                    debugPrint("✅ Courier User Token Deleted")
                    
                    self?.user = nil
                    completion()
                    
                },
                onFailure: {
                    debugPrint("❌ Courier User Token Delete Failed")
                }
            )
            
            if let task = delete {
                taskManager.add(task)
            }
            
        }
        
    }
    
    @available(iOS 13.0.0, *)
    public func signOut() async throws {
        return await withCheckedContinuation { continuation in
            signOut {
                continuation.resume()
            }
        }
    }
    
    // MARK: Token Management
    
    /**
     * The token issued by Apple to receive tokens on this device
     * Can only be set by the Courier SDK, but can be read by external packages
     */
    public internal(set) var apnsToken: String? = nil {
        didSet {
            
            if let token = apnsToken {
                updateAPNSToken(token)
            }
            
        }
    }
    
    /**
     * Upserts the APN token in Courier for the current user
     */
    internal func updateAPNSToken(_ token: String) {
        
        debugPrint("📲 Apple Device Token")
        debugPrint(token)
        
        // Ensure we have a user id
        guard let userId = self.user?.id else {
            debugPrint("Courier User is missing. Can't update device token. Ensure you have a user set before submitting the token.")
            return
        }
        
        debugPrint("⚠️ Updating Courier Token")
        
        let update = self.tokenRepository.updatePushNotificationToken(
            userId: userId,
            provider: CourierProvider.apns,
            deviceToken: token,
            onSuccess: {
                debugPrint("✅ Courier User Token Updated")
            },
            onFailure: {
                debugPrint("❌ Courier User Token Update Failed")
            }
        )
        
        if let task = update {
            taskManager.add(task)
        }
        
    }
    
    /**
     * Upserts the FCM token in Courier for the current user
     * To get started with FCM, checkout the firebase docs here: https://firebase.google.com/docs/cloud-messaging/ios/client
     */
    public func updateFCMToken(_ token: String) {
        
        debugPrint("🔥 Firebase Cloud Messaging Token")
        debugPrint(token)
        
        // Ensure we have a user id
        guard let userId = self.user?.id else {
            debugPrint("Courier User is missing. Can't update device token. Ensure you have a user set before submitting the token.")
            return
        }
        
        debugPrint("⚠️ Updating Courier Token")
        
        let update = self.tokenRepository.updatePushNotificationToken(
            userId: userId,
            provider: CourierProvider.fcm,
            deviceToken: token,
            onSuccess: {
                debugPrint("✅ Courier User Token Updated")
            },
            onFailure: {
                debugPrint("❌ Courier User Token Update Failed")
            }
        )
        
        if let task = update {
            taskManager.add(task)
        }
        
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
    
}
