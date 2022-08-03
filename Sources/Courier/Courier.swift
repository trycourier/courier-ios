import UIKit

@available(iOS 13.0.0, *)
open class Courier: NSObject {
    
    // MARK: Courier
    
    /*

     ______  ______  __  __  ______  __  ______  ______
    /\  ___\/\  __ \/\ \/\ \/\  == \/\ \/\  ___\/\  == \
    \ \ \___\ \ \/\ \ \ \_\ \ \  __<\ \ \ \  __\\ \  __<
     \ \_____\ \_____\ \_____\ \_\ \_\ \_\ \_____\ \_\ \_\
      \/_____/\/_____/\/_____/\/_/ /_/\/_/\/_____/\/_/ /_/
     
     
     Follow the docs here to get everything running:
     Documentation: https://github.com/trycourier/courier-ios/blob/master/README.md
     
     
     */
    
    // MARK: Init
    
    private override init() {
        
        #if DEBUG
        isDebugging = true
        #endif
        
        super.init()
    }
    
    /**
     * Singleton reference to the SDK
     * Please ensure you use this to maintain state
     */
    public static let shared = Courier()
    
    /**
     * The key required to initialized the SDK
     * https://www.courier.com/docs/reference/auth/issue-token/
     */
    internal var accessToken: String? = nil
    
    /**
     * Determines if the SDK should show logs or other debugging data
     * Set to find debug mode by default
     */
    public var isDebugging = false
    
    /**
     * Courier APIs
     */
    private lazy var tokenRepo = TokenRepository()
    private lazy var messagingRepo = MessagingRepository()
    
    // MARK: Getters
    
    private static var userNotificationCenter: UNUserNotificationCenter {
        get { UNUserNotificationCenter.current() }
    }
    
    // MARK: User Management
    
    /**
     * A read only value set to the current user id
     */
    public private(set) var userId: String? = nil
    
    /**
     * Function to set the current credentials for the user and their access token
     * You should consider using this in areas where you update your local user's state
     */
    public func setCredentials(accessToken: String, userId: String) async throws {
        
        Courier.log("Updating Courier User Profile")
        Courier.log("Access Token: \(accessToken)")
        Courier.log("User Id: \(userId)")
        
        // Set the user's current credentials
        self.accessToken = accessToken
        self.userId = userId

        // Attempt to put the users tokens
        // If we have them
        async let putAPNS: () = tokenRepo.putUserToken(
            userId: userId,
            provider: CourierProvider.apns,
            deviceToken: apnsToken
        )

        async let putFCM: () = tokenRepo.putUserToken(
            userId: userId,
            provider: CourierProvider.fcm,
            deviceToken: fcmToken
        )
        
        let _ = try await [putAPNS, putFCM]
        
    }
    
    /**
     * Function that clears the current user id and access token
     * You should call this when your user signs out
     * It will remove the current tokens used for this user in Courier so they do not receive pushes they should not get
     */
    public func signOut() async throws {
        
        Courier.log("Clearing Courier User Credentials")
        
        async let deleteAPNS: () = tokenRepo.deleteToken(
            userId: userId,
            deviceToken: apnsToken
        )

        async let deleteFCM: () = tokenRepo.deleteToken(
            userId: userId,
            deviceToken: fcmToken
        )
        
        let _ = try await [deleteAPNS, deleteFCM]
        
        accessToken = nil
        userId = nil
        
    }
    
     // MARK: Token Management
    
    /**
     * The token issued by Apple to receive tokens on this device
     * Can only be set by the Courier SDK, but can be read by external packages
     */
    public private(set) var apnsToken: String? = nil
    
    /**
     * Upserts the APNS token in Courier for the current user
     * If you implement `CourierDelegate`, this will get set automattically
     * If you are not using `CourierDelegate`, please add this to `didRegisterForRemoteNotificationsWithDeviceToken`
     */
    internal func setAPNSToken(_ token: String) async throws {

        apnsToken = token

        Courier.log("Apple Push Notification Service Token")
        Courier.log(token)

        return try await tokenRepo.putUserToken(
            userId: userId,
            provider: CourierProvider.apns,
            deviceToken: token
        )

    }
    
    /**
     * The current firebase token associated with this user
     */
    public private(set) var fcmToken: String? = nil
    
    /**
     * Upserts the FCM token in Courier for the current user
     * To get started with FCM, checkout the firebase docs here: https://firebase.google.com/docs/cloud-messaging/ios/client
     */
    internal func setFCMToken(_ token: String) async throws {

        fcmToken = token

        Courier.log("Firebase Cloud Messaging Token")
        Courier.log(token)

        return try await tokenRepo.putUserToken(
            userId: userId,
            provider: CourierProvider.fcm,
            deviceToken: token
        )

    }
    
    /**
     * Manually saves a token into Courier based on the provider supported
     * This function should be used to set a device token manually
     */
    public func setPushToken(provider: CourierProvider, token: String) async throws {
        switch (provider) {
        case .apns:
            return try await Courier.shared.setAPNSToken(token)
        case .fcm:
            return try await Courier.shared.setFCMToken(token)
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
    @discardableResult
    public static func requestNotificationPermissions() async throws -> UNAuthorizationStatus {
        try await userNotificationCenter.requestAuthorization(options: permissionAuthorizationOptions)
        return try await getNotificationAuthorizationStatus()
    }
    
    // MARK: Testing

    @discardableResult
    public func sendPush(authKey: String, userId: String, title: String, message: String) async throws -> String {
        return try await messagingRepo.send(
            authKey: authKey,
            userId: userId,
            title: title,
            message: message
        )
    }
    
    // MARK: Logging
    
    public static func log(_ data: String) {
        
        // Print the log if we are debugging
        if (Courier.shared.isDebugging) {
            print(data)
        }
        
    }
    
}
