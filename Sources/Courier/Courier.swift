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
    internal static let version = "2.0.0"
    
    /**
     * Singleton reference to the SDK
     * Please ensure you use this to maintain state
     */
    @objc public static let shared = Courier()
    
    /**
     * Courier Channels
     */
    internal lazy var auth = Auth()
    internal lazy var push = Push()
    internal lazy var inbox = Inbox()
    internal lazy var messaging = Messaging()
    internal let logging = Logging()
    
    // MARK: Init
    
    private override init() {
        
#if DEBUG
        logging.isDebugging = true
#endif
        
        super.init()
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
