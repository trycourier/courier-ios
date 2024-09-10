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

import Foundation
import UIKit

@available(iOS 13.0.0, *)
@objc open class Courier: NSObject {
    
    /**
     * Versioning
     */
    internal static let version = "4.4.2"
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
    
    internal lazy var tokenModule = { TokenModule() }()
    
    // MARK: Inbox
    
    internal var paginationLimit: Int = InboxModule.Pagination.default.rawValue
    public internal(set) var inboxListeners: [CourierInboxListener] = []
    internal weak var inboxDelegate: InboxModuleDelegate?
    internal lazy var inboxModule = {
        self.inboxDelegate = self
        return InboxModule()
    }()
    
    // MARK: Init
    
    private override init() {
        super.init()
        
        // Register Lifecycle Listeners
        NotificationCenter.default.addObserver(self,
           selector: #selector(didEnterForeground),
           name: UIApplication.didBecomeActiveNotification,
           object: nil
        )
        
        NotificationCenter.default.addObserver(self,
           selector: #selector(didEnterBackground),
           name: UIApplication.didEnterBackgroundNotification,
           object: nil
        )
        
    }
    
    deinit {
        
        // Remove listeners
        NotificationCenter.default.removeObserver(self,
          name: UIApplication.didBecomeActiveNotification,
          object: nil
        )
        
        NotificationCenter.default.removeObserver(self,
          name: UIApplication.didEnterBackgroundNotification,
          object: nil
        )
        
    }
    
    @objc private func didEnterForeground() {
        Task { await linkInbox() }
    }
    
    @objc private func didEnterBackground() {
        Task { await unlinkInbox() }
    }
    
}
