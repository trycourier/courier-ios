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

@objc public class Courier: NSObject {
    
    /**
     * Versioning
     */
    internal static let version = "5.6.2"
    @objc public static var agent = CourierAgent.nativeIOS(version)
    
    /**
     * Singleton reference to the SDK
     * Please ensure you use this to maintain state
     */
    @CourierActor @objc public static let shared = Courier()
    
    // MARK: Client API
    
    public internal(set) var client: CourierClient? = nil
    
    // MARK: Authentication
    
    public internal(set) var authListeners: [CourierAuthenticationListener] = []
    
    // MARK: Tokens
    
    internal let tokenModule = TokenModule()
    
    // MARK: Inbox
    internal var paginationLimit: Int = InboxRepository.Pagination.default.rawValue
    internal var inboxMutationHandler: InboxMutationHandler?
    @CourierActor internal let inboxModule = InboxModule()
    
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
