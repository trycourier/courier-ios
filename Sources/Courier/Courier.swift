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
     
     
     Full Documentation: https://github.com/trycourier/courier-ios
     
     
     */
    
    public static var agent = CourierAgent.native_ios
    internal static let version = "1.0.9"
    
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
     * Manages basic user state
     */
    private let userManager = UserManager()
    
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
    
    // MARK: User Management
    
    /**
     * A read only value set to the current user id
     */
    public var userId: String? {
        get {
            return userManager.getUserId()
        }
    }
    
    /**
     * The key required to initialized the SDK
     * https://www.courier.com/docs/reference/auth/issue-token/
     */
    internal var accessToken: String? {
        get {
            return userManager.getAccessToken()
        }
    }
    
    /**
     * Function to set the current credentials for the user and their access token
     * You should consider using this in areas where you update your local user's state
     */
    public func signIn(accessToken: String, userId: String) async throws {
        
        Courier.log("Updating Courier User Profile")
        Courier.log("Access Token: \(accessToken)")
        Courier.log("User Id: \(userId)")
        
        userManager.setCredentials(
            userId: userId,
            accessToken: accessToken
        )

        // Attempt to put the users tokens
        // If we have them
        async let putAPNS: () = tokenRepo.putUserToken(
            userId: userId,
            provider: .apns,
            deviceToken: apnsToken
        )

        async let putFCM: () = tokenRepo.putUserToken(
            userId: userId,
            provider: .fcm,
            deviceToken: fcmToken
        )
        
        let _ = try await [putAPNS, putFCM]
        
    }
    
    public func signIn(accessToken: String, userId: String, onSuccess: @escaping () -> Void, onFailure: @escaping (Error) -> Void) {
        Task {
            do {
                try await signIn(accessToken: accessToken, userId: userId)
                onSuccess()
            } catch {
                onFailure(error)
            }
        }
    }
    
    /**
     * Function that clears the current user id and access token
     * You should call this when your user signs out
     * It will remove the current tokens used for this user in Courier so they do not receive pushes they should not get
     */
    public func signOut() async throws {
        
        Courier.log("Clearing Courier User Credentials")
        
        do {
            
            async let deleteAPNS: () = tokenRepo.deleteToken(
                userId: userId,
                deviceToken: apnsToken
            )

            async let deleteFCM: () = tokenRepo.deleteToken(
                userId: userId,
                deviceToken: fcmToken
            )
            
            let _ = try await [deleteAPNS, deleteFCM]
            
        } catch {
            
            Courier.log("Error deleting token")
            Courier.log("\(error)")
            
        }
        
        userManager.removeCredentials()
        
    }
    
    public func signOut(onSuccess: @escaping () -> Void, onFailure: @escaping (Error) -> Void) {
        Task {
            do {
                try await signOut()
                onSuccess()
            } catch {
                onFailure(error)
            }
        }
    }
    
     // MARK: Token Management
    
    /**
     * The token issued by Apple to receive tokens on this device
     * Can only be set by the Courier SDK, but can be read by external packages
     */
    public private(set) var rawApnsToken: Data? = nil
    
    // Returns the apns token as a string
    public var apnsToken: String? {
        get {
            return rawApnsToken?.string
        }
    }
    
    /**
     * Upserts the APNS token in Courier for the current user
     * If you implement `CourierDelegate`, this will get set automattically
     * If you are not using `CourierDelegate`, please add this to `didRegisterForRemoteNotificationsWithDeviceToken`
     * This function requires a `Data` value as the token.
     */
    public func setAPNSToken(_ rawToken: Data) async throws {
        
        // Delete the current apns token
        do {
            try await tokenRepo.deleteToken(
                userId: userId,
                deviceToken: apnsToken
            )
        } catch {
            Courier.log(String(describing: error))
        }

        // We save the raw apns token here
        rawApnsToken = rawToken

        Courier.log("Apple Push Notification Service Token")
        Courier.log(rawToken.string)

        return try await tokenRepo.putUserToken(
            userId: userId,
            provider: .apns,
            deviceToken: rawToken.string
        )

    }
    
    public func setAPNSToken(_ rawToken: Data, onSuccess: @escaping () -> Void, onFailure: @escaping (Error) -> Void) {
        Task {
            do {
                try await setAPNSToken(rawToken)
                onSuccess()
            } catch {
                onFailure(error)
            }
        }
    }
    
    /**
     * The current firebase token associated with this user
     */
    public private(set) var fcmToken: String? = nil
    
    /**
     * Upserts the FCM token in Courier for the current user
     * To get started with FCM, checkout the firebase docs here: https://firebase.google.com/docs/cloud-messaging/ios/client
     */
    public func setFCMToken(_ token: String) async throws {
        
        // Delete the current fcm token
        do {
            try await tokenRepo.deleteToken(
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
            userId: userId,
            provider: .fcm,
            deviceToken: token
        )

    }
    
    public func setFCMToken(_ token: String, onSuccess: @escaping () -> Void, onFailure: @escaping (Error) -> Void) {
        Task {
            do {
                try await setFCMToken(token)
                onSuccess()
            } catch {
                onFailure(error)
            }
        }
    }
    
}
