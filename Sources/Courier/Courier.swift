import UIKit

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
     * Default pagination limit for messages
     */
    private static let defaultPaginationLimit = 24
    private static let defaultMaxPaginationLimit = 200
    private static let defaultMinPaginationLimit = 1
    private var _inboxPaginationLimit = defaultPaginationLimit
    @objc public var inboxPaginationLimit: Int {
        get {
            return self._inboxPaginationLimit
        }
        set {
            let min = min(Courier.defaultMaxPaginationLimit, newValue)
            self._inboxPaginationLimit = max(Courier.defaultMinPaginationLimit, min)
        }
    }
    
    /**
     * Courier APIs
     */
    private lazy var tokenRepo = TokenRepository()
    private lazy var messagingRepo = MessagingRepository()
    private lazy var inboxRepo = InboxRepository()
    
    // MARK: Getters
    
    private static var userNotificationCenter: UNUserNotificationCenter {
        get { UNUserNotificationCenter.current() }
    }
    
    private static var systemNotificationCenter: NotificationCenter {
        get { NotificationCenter.default }
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
     * A read only value set to the current user client key
     */
    @objc public var clientKey: String? {
        get {
            return userManager.getClientKey()
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
    
    @objc public var isUserSignedIn: Bool {
        get {
            return userId != nil && clientKey != nil && accessToken != nil
        }
    }
    
    /**
     * Function to set the current credentials for the user and their access token
     * You should consider using this in areas where you update your local user's state
     */
    @objc public func signIn(accessToken: String, clientKey: String, userId: String) async throws {
        
        Courier.log("Updating Courier User Profile")
        Courier.log("Access Token: \(accessToken)")
        Courier.log("Client Key: \(clientKey)")
        Courier.log("User Id: \(userId)")
        
        userManager.setCredentials(
            userId: userId,
            accessToken: accessToken,
            clientKey: clientKey
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
            
            // Check if we need to start the inbox pipe
            if (!inboxListeners.isEmpty && inboxRepo.webSocket == nil) {
                
                // Notify all listeners
                runOnMainThread { [weak self] in
                    self?.inboxListeners.forEach {
                        $0.onInitialLoad?()
                    }
                }
                
                // Create the inbox pipe
                startInboxPipe()
                
            }
            
        } catch {
            
            Courier.log(String(describing: error))
            
            try await signOut()
            
            throw error
            
        }
        
    }
    
    @objc public func signIn(accessToken: String, clientKey: String, userId: String, onSuccess: @escaping () -> Void, onFailure: @escaping (Error) -> Void) {
        Task {
            do {
                try await signIn(accessToken: accessToken, clientKey: clientKey, userId: userId)
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
            
            // Close the inbox pipe if needed
            closeInboxPipe()
            
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
    public func sendMessage(authKey: String, userId: String, title: String, message: String, providers: [CourierProvider] = CourierProvider.all) async throws -> String {
        return try await messagingRepo.send(
            authKey: authKey,
            userId: userId,
            title: title,
            message: message,
            providers: providers
        )
    }
    
    public func sendMessage(authKey: String, userId: String, title: String, message: String, providers: [CourierProvider] = CourierProvider.all, onSuccess: @escaping (String) -> Void, onFailure: @escaping (Error) -> Void) {
        Task {
            do {
                let requestId = try await sendMessage(
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
    
    @objc public func sendMessage(authKey: String, userId: String, title: String, message: String, providers: [String] = CourierProvider.allCases, onSuccess: @escaping (String) -> Void, onFailure: @escaping (Error) -> Void) {
        Task {
            do {
                let requestId = try await sendMessage(
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
    
    private var inboxListeners: [CourierInboxListener] = []

    private var inboxData: InboxData? = nil
    
    @objc private(set) public var inboxMessages: [InboxMessage]? = nil
    private var inboxPageFetch: Task<Void, Error>? = nil
    
    private func addDisplayObservers() {
        Courier.systemNotificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        Courier.systemNotificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    private func startInboxPipe() {
        
        inboxPageFetch = Task {
            
            do {
                
                guard let clientKey = self.clientKey, let userId = self.userId else {
                    return
                }
                
                addDisplayObservers()
                
                inboxData = try await inboxRepo.getMessages(
                    clientKey: clientKey,
                    userId: userId,
                    paginationLimit: _inboxPaginationLimit
                )
                
                inboxMessages = inboxData?.messages.nodes ?? []
                
                try await inboxRepo.createWebSocket(
                    clientKey: clientKey,
                    userId: userId,
                    onMessageReceived: { [weak self] message in
                        
                        // Ensure we have data to work with
                        if let self = self, let data = self.inboxData {
                            
                            // Add the new message
                            self.inboxData?.incrementCounts()
                            
                            let totalMessageCount = data.messages.totalCount ?? 0
                            let canPaginate = data.messages.pageInfo.hasNextPage ?? false
                            let previousMessages = self.inboxMessages ?? []
                            
                            // Notify all listeners
                            self.runOnMainThread { [weak self] in
                                self?.inboxListeners.forEach {
                                    $0.callMessageChanged(
                                        newMessage: message,
                                        previousMessages: previousMessages,
                                        nextPageOfMessages: [],
                                        unreadMessageCount: -999,
                                        totalMessageCount: totalMessageCount,
                                        canPaginate: canPaginate
                                    )
                                }
                            }
                            
                            // Add the message to the array
                            self.inboxMessages?.insert(message, at: 0)
                            
                        }
                        
                    },
                    onMessageReceivedError: { [weak self] error in
                        
                        // Notify all listeners
                        self?.runOnMainThread { [weak self] in
                            self?.inboxListeners.forEach {
                                $0.onError?(error)
                            }
                        }
                        
                    }
                )
                
                inboxPageFetch = nil
                
                if let data = inboxData {
                    
                    let totalMessageCount = (data.messages.totalCount ?? 0) + 1
                    let canPaginate = data.messages.pageInfo.hasNextPage ?? false
                    let previousMessages = self.inboxMessages ?? []
                    
                    // Call the listeners
                    runOnMainThread { [weak self] in
                        self?.inboxListeners.forEach {
                            $0.callMessageChanged(
                                newMessage: nil,
                                previousMessages: [],
                                nextPageOfMessages: previousMessages,
                                unreadMessageCount: -999,
                                totalMessageCount: totalMessageCount,
                                canPaginate: canPaginate
                            )
                        }
                    }
                    
                }
                
            } catch {
                
                inboxPageFetch = nil
                
                runOnMainThread { [weak self] in
                    self?.inboxListeners.forEach {
                        $0.onError?(error)
                    }
                }
                
            }
            
        }
        
    }
    
    @objc private func appMovedToBackground() {
        inboxRepo.webSocket?.cancel(with: .goingAway, reason: nil)
    }

    @objc private func appMovedToForeground() {
        inboxRepo.webSocket?.resume()
    }
    
    @objc public func fetchNextPageOfMessages() {
        
        if (inboxPageFetch != nil) {
            return
        }
        
        inboxPageFetch = Task {
            
            do {
                
                guard let clientKey = self.clientKey, let userId = self.userId, let data = self.inboxData else {
                    return
                }
                
                let previousMessages = inboxMessages ?? []
                let cursor = data.messages.pageInfo.startCursor
                
                self.inboxData = try await inboxRepo.getMessages(
                    clientKey: clientKey,
                    userId: userId,
                    paginationLimit: _inboxPaginationLimit,
                    startCursor: cursor
                )
                
                // Set empty array if needed
                if (inboxMessages == nil) {
                    inboxMessages = []
                }
                
                inboxMessages! += self.inboxData?.messages.nodes ?? []
                inboxPageFetch = nil
                
                if let data = inboxData {
                 
                    // Hold previous messages
                    let nextPageOfMessages = data.messages.nodes
                    let totalMessageCount = data.messages.totalCount ?? 0
                    let canPaginate = data.messages.pageInfo.hasNextPage ?? false
                    
                    // Call the listeners
                    runOnMainThread { [weak self] in
                        self?.inboxListeners.forEach {
                            $0.callMessageChanged(
                                newMessage: nil,
                                previousMessages: previousMessages,
                                nextPageOfMessages: nextPageOfMessages,
                                unreadMessageCount: -999,
                                totalMessageCount: totalMessageCount,
                                canPaginate: canPaginate
                            )
                        }
                    }
                    
                }
                
            } catch {
                
                inboxPageFetch = nil
                
                runOnMainThread { [weak self] in
                    self?.inboxListeners.forEach {
                        $0.onError?(error)
                    }
                }
                
            }
            
        }
        
    }
    
    private func runOnMainThread(run: @escaping () -> Void) {
        DispatchQueue.main.async {
            run()
        }
    }
    
    @objc public func readAllMessages() {
        // TODO
    }
    
    @discardableResult @objc public func addInboxListener(onInitialLoad: (() -> Void)? = nil, onError: ((Error) -> Void)? = nil, onMessagesChanged: ((_ newMessage: InboxMessage?, _ previousMessages: [InboxMessage], _ nextPageOfMessages: [InboxMessage], _ unreadMessageCount: Int, _ totalMessageCount: Int, _ canPaginate: Bool) -> Void)? = nil) -> CourierInboxListener {
        
        // Create a new inbox listener
        let listener = CourierInboxListener(
            onInitialLoad: onInitialLoad,
            onError: onError,
            onMessagesChanged: onMessagesChanged
        )
        
        // Keep track of listener
        inboxListeners.append(listener)
        
        // Call initial load
        runOnMainThread {
            listener.onInitialLoad?()
        }
        
        // User is not signed
        if (!isUserSignedIn) {
            Courier.log("User is not signed in. Please sign in to setup the inbox listener.")
            runOnMainThread {
                listener.onError?(CourierError.inboxUserNotFound)
            }
            return listener
        }
        
        if (inboxListeners.count == 1) {
            
            startInboxPipe()
            
        } else if let data = inboxData, let messages = inboxMessages {
            
            let totalMessageCount = (data.messages.totalCount ?? 0) + 1
            let canPaginate = data.messages.pageInfo.hasNextPage ?? false
            
            listener.callMessageChanged(
                newMessage: nil,
                previousMessages: [],
                nextPageOfMessages: messages,
                unreadMessageCount: -999,
                totalMessageCount: totalMessageCount,
                canPaginate: canPaginate
            )
            
        }
        
        return listener
        
    }
    
    @objc public func removeInboxListener(listener: CourierInboxListener) {
        
        // Look for the listener we need to remove
        inboxListeners.removeAll(where: {
            return $0 == listener
        })
        
        // Kill the pipes if nothing is listening
        if (inboxListeners.isEmpty) {
            closeInboxPipe()
        }
        
    }
    
    @objc public func removeAllInboxListeners() {
        inboxListeners.removeAll()
        closeInboxPipe()
    }
    
    private func closeInboxPipe() {
        
        // Remove all inbox details
        // Keep the listeners still registered
        inboxMessages = nil
        inboxRepo.closeWebSocket()
        
        // Tell all the listeners the user is signed out
        runOnMainThread { [weak self] in
            self?.inboxListeners.forEach {
                $0.onError?(CourierError.inboxUserNotFound)
            }
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
    
}
