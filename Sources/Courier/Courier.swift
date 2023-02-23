import UIKit
import GraphQLite

@available(iOS 13.0.0, *)
@objc open class Courier: NSObject {
    
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
    internal static let version = "1.1.1"
    
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
    @objc public static let shared = Courier()
    
    /**
     * Manages basic user state
     */
    private let userManager = UserManager()
    
    /**
     * Determines if the SDK should show logs or other debugging data
     * Set to find debug mode by default
     */
    @objc public var isDebugging = false
    
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
    @objc public var userId: String? {
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
    @objc public func signIn(accessToken: String, userId: String) async throws {
        
        Courier.log("Updating Courier User Profile")
        Courier.log("Access Token: \(accessToken)")
        Courier.log("User Id: \(userId)")
        
        userManager.setCredentials(
            userId: userId,
            accessToken: accessToken
        )
        
        do {
            
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
            
        } catch {
            
            Courier.log(String(describing: error))
            
            try await signOut()
            
            throw error
            
        }
        
    }
    
    @objc public func signIn(accessToken: String, userId: String, onSuccess: @escaping () -> Void, onFailure: @escaping (Error) -> Void) {
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
    @objc public func signOut() async throws {
        
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
        
        // Sign out will still work, but will keep
        // existing tokens in Courier if failure
        userManager.removeCredentials()
        
    }
    
    @objc public func signOut(onSuccess: @escaping () -> Void, onFailure: @escaping (Error) -> Void) {
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
    @objc public var apnsToken: String? {
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
    @objc public func setAPNSToken(_ rawToken: Data) async throws {
        
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
    
    @objc public func setAPNSToken(_ rawToken: Data, onSuccess: @escaping () -> Void, onFailure: @escaping (Error) -> Void) {
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
    @objc public private(set) var fcmToken: String? = nil
    
    /**
     * Upserts the FCM token in Courier for the current user
     * To get started with FCM, checkout the firebase docs here: https://firebase.google.com/docs/cloud-messaging/ios/client
     */
    @objc public func setFCMToken(_ token: String) async throws {
        
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
    
    @objc public func setFCMToken(_ token: String, onSuccess: @escaping () -> Void, onFailure: @escaping (Error) -> Void) {
        Task {
            do {
                try await setFCMToken(token)
                onSuccess()
            } catch {
                onFailure(error)
            }
        }
    }
    
    // MARK: Permissions
    
    /**
     * Get the authorization status of the notification permissions
     * Completion returns on main thread
     */
    @objc public static func getNotificationPermissionStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        userNotificationCenter.getNotificationSettings(completionHandler: { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        })
    }
    
    /**
     * Get notification permission status with async await
     */
    @objc public static func getNotificationPermissionStatus() async throws -> UNAuthorizationStatus {
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
    @objc public static func requestNotificationPermission(completion: @escaping (UNAuthorizationStatus) -> Void) {
        userNotificationCenter.requestAuthorization(
            options: permissionAuthorizationOptions,
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
    @discardableResult
    @objc public static func requestNotificationPermission() async throws -> UNAuthorizationStatus {
        try await userNotificationCenter.requestAuthorization(options: permissionAuthorizationOptions)
        return try await getNotificationPermissionStatus()
    }
    
    // MARK: Analytics
    
    /**
     * Use this function if you are manually handling notifications and not using `CourierDelegate`
     * `CourierDelegate` will automatically track the urls
     */
    @objc public func trackNotification(message: [AnyHashable : Any], event: CourierPushEvent) async throws {
        
        guard let trackingUrl = message["trackingUrl"] as? String else {
            Courier.log("Unable to find tracking url")
            return
        }
        
        Courier.log("Tracking notification event")
        
        return try await messagingRepo.postTrackingUrl(
            url: trackingUrl,
            event: event
        )
        
    }
    
    @objc public func trackNotification(message: [AnyHashable : Any], event: CourierPushEvent, onSuccess: (() -> Void)? = nil, onFailure: ((Error) -> Void)? = nil) {
        
        guard let trackingUrl = message["trackingUrl"] as? String else {
            Courier.log("Unable to find tracking url")
            return
        }
        
        Courier.log("Tracking notification event")
        
        Task.init {
            
            do {
                try await messagingRepo.postTrackingUrl(
                    url: trackingUrl,
                    event: event
                )
                onSuccess?()
            } catch {
                Courier.log(String(describing: error))
                onFailure?(error)
            }
            
        }
        
    }
    
    // MARK: Testing

    @discardableResult
    public func sendPush(authKey: String, userId: String, title: String, message: String, providers: [CourierProvider] = CourierProvider.all) async throws -> String {
        return try await messagingRepo.send(
            authKey: authKey,
            userId: userId,
            title: title,
            message: message,
            providers: providers
        )
    }
    
    public func sendPush(authKey: String, userId: String, title: String, message: String, providers: [CourierProvider] = CourierProvider.all, onSuccess: @escaping (String) -> Void, onFailure: @escaping (Error) -> Void) {
        Task {
            do {
                let requestId = try await sendPush(
                    authKey: authKey,
                    userId: userId,
                    title: title,
                    message: message,
                    providers: providers
                )
                onSuccess(requestId)
            } catch {
                onFailure(error)
            }
        }
    }
    
    @objc public func sendPush(authKey: String, userId: String, title: String, message: String, providers: [String] = CourierProvider.allCases, onSuccess: @escaping (String) -> Void, onFailure: @escaping (Error) -> Void) {
        Task {
            do {
                let requestId = try await sendPush(
                    authKey: authKey,
                    userId: userId,
                    title: title,
                    message: message,
                    providers: providers.map { CourierProvider(rawValue: $0) ?? .unknown }
                )
                onSuccess(requestId)
            } catch {
                onFailure(error)
            }
        }
    }
    
    // MARK: Inbox
    
    private var timer: Timer? = nil
    private var counter = 0
    
    private var inboxListeners: [CourierInboxListener] = []
    
    private func startInboxPipe(listener: CourierInboxListener) {
     
        // Start the timer if needed
        if (timer == nil) {
            
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                
                self.counter += 1
                
                print("Root pipe counter: \(self.counter)")
                
                // Call every listener that is attached
                self.inboxListeners.forEach { listener in
                    listener.onMessagesChanged?(self.counter)
                }
                
            }
            
        }
        
    }
    
    @discardableResult @objc public func addInboxListener(onInitialLoad: (() -> Void)? = nil, onError: (() -> Void)? = nil, onMessagesChanged: ((Int) -> Void)? = nil) -> CourierInboxListener {
        
        // Create a new inbox listener
        let listener = CourierInboxListener(
            onInitialLoad: onInitialLoad,
            onError: onError,
            onMessagesChanged: onMessagesChanged
        )
        
        // Add the new listener
        inboxListeners.append(listener)
        
        // Start the pipe
        startInboxPipe(listener: listener)
        
        // Return the listener
        return listener
        
    }
    
    @objc public func removeInboxListener(listener: CourierInboxListener) {
        
        // Look for the listener we need to remove
        inboxListeners.removeAll(where: {
            return $0 == listener
        })
        
        // Kill the timer if nothing is listening
        closeInboxPipe()
        
    }
    
    @objc public func removeAllInboxListeners() {
        inboxListeners.removeAll()
        closeInboxPipe()
    }
    
    private func closeInboxPipe() {
        if (inboxListeners.isEmpty) {
            timer?.invalidate()
        }
    }
    
    // MARK: Logging
    
    // Called when logs are performed
    // Used for React Native and Flutter SDKs
    @objc public var logListener: ((String) -> Void)? = nil
    
    @objc public static func log(_ data: String) {
        
        // Print the log if we are debugging
        if (Courier.shared.isDebugging) {
            print(data)
            Courier.shared.logListener?(data)
        }
        
    }
    
    // MARK: Helpers
    
    @objc public static func formatPushNotification(content: UNNotificationContent) -> Dictionary<AnyHashable, Any> {
        
        // Initial payload
        var payload: Dictionary<AnyHashable, Any> = [
            "title": content.title,
            "body": content.body
        ]
        
        if let badge = content.badge {
            payload["badge"] = badge
        }
        
        // Do not add subtitle if it's empty
        if (!content.subtitle.isEmpty) {
            payload["subtitle"] = content.subtitle
        }
        
        // Add sound as a string
        if let aps = content.userInfo["aps"] as? [AnyHashable : Any?], let sound = aps["sound"] {
            payload["sound"] = sound
        }
        
        // Merge the payload data
        // This appends all custom attributes
        var data = content.userInfo
        data.removeValue(forKey: "aps")
        data.forEach { payload[$0] = $1 }
        
        // Add the raw data
        payload["raw"] = content.userInfo
        
        return payload
        
    }
    
    // Shortcut to open the settings app for the current app
    @available(iOSApplicationExtension, unavailable)
    @objc public static func openSettingsForApp() {
        if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
            UIApplication.shared.open(appSettings)
        }
    }
    
    @objc public func getMessages(clientKey: String, userId: String) {
    
        let url = "https://fxw3r7gdm9.execute-api.us-east-1.amazonaws.com/production/q"
        let headers = [
            "x-courier-client-key": clientKey,
            "x-courier-user-id": userId
        ]
        
        let server = GQLServer(HTTP: url, headers: headers)
        
        let query = """
        query GetMessages(
            $params: FilterParamsInput
            $limit: Int = 10
            $after: String
        ) {
            count(params: $params)
            messages(params: $params, limit: $limit, after: $after) {
                totalCount
                pageInfo {
                    startCursor
                    hasNextPage
                }
                nodes {
                    messageId
                    read
                    archived
                    created
                    tags
                    title
                    preview
                    actions {
                        content
                        href
                        style
                        background_color
                    }
                }
            }
        }
        """

        server.query(query, [:]) { result, error in
            print(error ?? "No error")
            print(result)
        }
        
    }
    
}
