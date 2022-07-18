import UIKit

@available(iOS 10.0.0, *)
open class Courier: NSObject {
    
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
    
    private override init() {
        super.init()
    }
    
    /**
     * Operation queue
     */
//    public lazy var queue = SimultaneousOperationsQueue(
//        numberOfSimultaneousActions: 1,
//        dispatchQueueLabel: "CourierQueue"
//    )
    
    internal let taskManager = CourierTaskManager()
    
    /**
     * Courier APIs
     */
    private lazy var userRepository = UserRepository()
    private lazy var tokenRepository = TokenRepository()
    
    /**
     * Updates the current courier user
     * This should be something that you update with your other user objects
     */
    public var user: CourierUser? = nil {
        didSet {
            
            // Remove the user if needed
            guard let user = user else {
                return
            }
            
            // Update the user stored in Courier
            updateUser(user: user)
            
            // Update the current device token in Courier
            if let token = self.apnsToken {
                updateDeviceToken(token: token)
            }
            
        }
    }
    
    internal func updateUser(user: CourierUser) {
        
        debugPrint("Updating Courier User")
        debugPrint(user)
        
        let update = self.userRepository.updateUser(user: user) {
            debugPrint("Courier User Updated")
        }
        
        taskManager.add(task: update!)
        
//        update?.start()
        
    }
    
    /**
     * The token issued by Apple to receive tokens on this device
     * Can only be set by the Courier SDK, but can be read by external packages
     */
    public internal(set) var apnsToken: String? = nil {
        didSet {
            
            // Remove the token if needed
            guard let token = apnsToken else {
                return
            }
            
            // Update the token on the user
            updateDeviceToken(token: token)
            
        }
    }
    
    /**
     * Upserts the new token to Courier
     */
    internal func updateDeviceToken(token: String) {
        
        debugPrint("📲 Apple Device Token")
        debugPrint(token)
        
        // Ensure we have a user id
        guard let userId = self.user?.id else {
            debugPrint("User missing. Can't update token.")
            return
        }
        
        debugPrint("Updating Courier Token")
        
        let update = self.tokenRepository.refreshDeviceToken(userId: userId, provider: CourierProvider.apns, deviceToken: token) {
            debugPrint("Updated Courier Token")
        }
        
        update?.resume()
        
    }
    
    // MARK: Auth
    
    public func signOut(completion: @escaping () -> Void) {
        
        // Ensure we have a user id
        guard let userId = self.user?.id else {
            return
        }
        
        // Delete the existing token
        if let apnsToken = self.apnsToken {
            
            let delete = self.tokenRepository.deleteToken(userId: userId, deviceToken: apnsToken) {
                print("Token deleted")
            }
            
            delete?.resume()
            
        }
        
        // Clear user
        self.user = nil
        
    }
    
    @available(iOS 13.0.0, *)
    public func signOut() async throws {
        // TODO: Handle this
    }
    
    // MARK: Getters
    
    private static var userNotificationCenter: UNUserNotificationCenter {
        get { return UNUserNotificationCenter.current() }
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
