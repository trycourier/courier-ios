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
     * Singleton reference to the SDK
     * Please ensure you use this to maintain state
     */
    @objc public static let shared = Courier()
    
    /**
     * The modules of the SDK
     */
    internal lazy var coreAuth = CoreAuth()
    internal lazy var corePush = CorePush()
    internal lazy var coreInbox = CoreInbox()
    internal lazy var corePreferences = CorePreferences()
    internal let coreLogging = CoreLogging()
    
    // MARK: Init
    
    private override init() {
        
#if DEBUG
        coreLogging.isDebugging = true
#endif
        
        super.init()
        
        NotificationCenter.default.addObserver(self,
           selector: #selector(didEnterBackgroundNotification),
           name: UIApplication.didEnterBackgroundNotification,
           object: nil
        )
        
    }
    
    @objc public static func configure(_ appDelegate: UIApplicationDelegate) {
        
//        NotificationCenter.default.addObserver(appDelegate,
//           selector: #selector(didEnterBackgroundNotification),
//           name: UIApplication.didEnterBackgroundNotification,
//           object: nil
//        )
        
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self,
          name: UIApplication.didEnterBackgroundNotification,
          object: nil
        )
        
    }
    
    @objc func didEnterBackgroundNotification() {
        // Perform actions upon receiving the applicationDidBecomeActive notification
        print("Application did go to background!")
        // Add your logic here
    }
    
    // didRegisterToken
    // didBecomeActive
    // didEnterBackground
    
    /**
     * Versioning
     */
    internal static let version = "2.7.4"
    public static var agent = CourierAgent.native_ios
    
}
