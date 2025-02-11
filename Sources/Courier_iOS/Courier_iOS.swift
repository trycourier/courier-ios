/*
 
     ,gggg,
   ,88"""Y8b,
  d8"     `Y8
 d8'   8b  d8                                      gg
,8I    "Y88P'                                      ""
I8'             ,ggggg,    gg      gg   ,gggggg,   gg    ,ggg,    ,gggggg,
d8             dP"  "Y8ggg I8      8I   dP""""8I   88   i8" "8i   dP""""8I
Y8,           i8'    ,8I   I8,    ,8I  ,8'    8I   88   I8, ,8I  ,8'    8I
`Yba,,_____, ,d8,   ,d8'  ,d8b,  ,d8b,,dP     Y8,_,88,_ `YbadP' ,dP     Y8,
  `"Y8888888 P"Y8888P"    8P'"Y88P"`Y88P      `Y88P""Y8888P"Y8888P      `Y8
 
===========================================================================
 
 More about Courier: https://courier.com
 iOS Documentation: https://github.com/trycourier/courier-ios
 
===========================================================================
 
*/

import UIKit

@objc public actor Courier: NSObject {
    
    /**
     * Versioning
     */
    internal static let version = "5.6.2"
    @objc public static var agent = CourierAgent.nativeIOS(version)
    
    /**
     * Singleton reference to the SDK
     * Please ensure you use this to maintain state
     */
    @objc public static let shared = Courier()
    
    // MARK: Client API
    
    public internal(set) var client: CourierClient? = nil
    
    // MARK: Authentication
    
    public internal(set) var authListeners: [CourierAuthenticationListener] = []
    
    // MARK: Tokens
    
    internal let tokenModule = TokenModule()
    
    // MARK: Inbox
    internal var paginationLimit: Int = InboxRepository.Pagination.default.rawValue
    internal var inboxMutationHandler: InboxMutationHandler?
    internal let inboxModule = InboxModule()
    
    // MARK: Proxy
    private var notificationProxy: CourierNotificationProxy?
    
    // MARK: Init
    
    private override init() {
        super.init()
        
        // Set up notification proxy
        self.notificationProxy = CourierNotificationProxy(courier: self)
        
        NotificationCenter.default.addObserver(
            self.notificationProxy!,
            selector: #selector(CourierNotificationProxy.didEnterForeground),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self.notificationProxy!,
            selector: #selector(CourierNotificationProxy.didEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        // Attach mutation handler
        inboxMutationHandler = self
        
    }
    
    // MARK: Deinit
    
    deinit {
        if let proxy = notificationProxy {
            NotificationCenter.default.removeObserver(proxy)
        }
    }
    
}

/// A global actor for our SDK that ensures
/// all tasks run on a custom serial `DispatchQueue`.
@globalActor
public struct CourierActor {
    public static let shared = CourierActorImpl()
}

/// The internal actor that will do the scheduling.
public actor CourierActorImpl { }

/// Conform to `SerialExecutor` to guarantee
/// tasks run one-at-a-time on our queue.
extension CourierActorImpl: SerialExecutor {

    // A private serial queue for all SDK operations
    nonisolated static let queue = DispatchQueue(label: "com.example.courier-actor")

    // Required by SerialExecutor:
    // Tells Swift how to schedule tasks for this actor.
    nonisolated public func enqueue(_ job: UnownedJob) {
        Self.queue.async {
            job.runSynchronously(on: self.asUnownedSerialExecutor())
        }
    }
    
    // Also required by SerialExecutor in Swift 5.9
    nonisolated public func asUnownedSerialExecutor() -> UnownedSerialExecutor {
        UnownedSerialExecutor(ordinary: self)
    }
}

@objc public class Courier2: NSObject {
    
    /// A shared singleton instance
    @objc public static let shared = Courier2()
    
    // MARK: Init
    private override init() {
        super.init()
    }
    
    @objc public private(set) var currentUserId: String?
    
    @CourierActor
    public func signIn() async throws {
        try await Task.sleep(nanoseconds: 5_000_000_000)
        currentUserId = UUID().uuidString
    }
    
    @CourierActor
    public func signOut() async throws {
        try await Task.sleep(nanoseconds: 5_000_000_000)
        currentUserId = nil
    }
    
}
