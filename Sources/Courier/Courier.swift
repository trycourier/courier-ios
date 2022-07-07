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

import UIKit

@available(iOS 10.0.0, *)
open class Courier: NSObject {
    
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
    public var authorizationKey: String? = nil
    
    private override init() {
        super.init()
    }
    
    /**
     * Courier APIs
     */
    private lazy var userRepository = UserRepository()
    private lazy var tokenRepository = TokenRepository()
    
    /**
     * Sets the user to one you have in Courier Studio
     */
    public func updateUser(user: CourierUser) {
        userRepository.updateUser(user: user)?.resume()
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
    
    /**
     * Upserts the new token to Courier
     */
    internal func updateDeviceToken(deviceToken: Data) {
        
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("📲 Apple Device Token: \(token)")
        
        tokenRepository.refreshDeviceToken(
            userId: "test_user_from_swift",
            provider: CourierProvider.apns,
            deviceToken: token
        )?.resume()
        
    }
    
}
