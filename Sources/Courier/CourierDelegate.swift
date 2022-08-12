//
//  CourierDelegate.swift
//
//
//  Created by Michael Miller on 7/5/22.
//

import UIKit

open class CourierDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    // MARK: Getters
    
    private var app: UIApplication {
        get {
            return UIApplication.shared
        }
    }
    
    private var notificationCenter: UNUserNotificationCenter {
        get {
            return UNUserNotificationCenter.current()
        }
    }
    
    // MARK: Init
    
    override init() {
        super.init()
        
        // Register to ensure device token can be fetched
        app.registerForRemoteNotifications()
        notificationCenter.delegate = self
        
    }
    
    // MARK: Messaging
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let message = notification.request.content.userInfo
        
        // Try and track
        Task.init {
            
            do {
                try await Courier.trackNotification(message: message, event: .delivered)
            } catch {
                Courier.log(String(describing: error))
            }
            
        }
        
        // Complete
        let presentationOptions = pushNotificationDeliveredInForeground(message: message)
        completionHandler(presentationOptions)
        
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let message = response.notification.request.content.userInfo
        
        // Try and track
        Courier.trackNotification(message: message, event: .clicked)
        
        // Complete
        pushNotificationClicked(message: message)
        completionHandler()
        
    }
    
    // MARK: Token Management

    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Courier.log("Unable to register for remote notifications: \(error.localizedDescription)")
    }

    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Task {
            do {
                
                // Allows a developer to know if the app is in debugging mode
                // This is helpful for a developer to know if the app is using
                // Sandbox or Production tokens
                deviceTokenDidChange(rawApnsToken: deviceToken, isDebugging: isDebuggerAttached)
                
                // Sync token to Courier
                try await Courier.shared.setAPNSToken(deviceToken)
                
            } catch {
                Courier.log(String(describing: error))
            }
        }
    }
    
    // MARK: Functions
    
    open func deviceTokenDidChange(rawApnsToken: Data, isDebugging: Bool) {}
    
    open func pushNotificationDeliveredInForeground(message: [AnyHashable : Any]) -> UNNotificationPresentationOptions { return [] }
    
    open func pushNotificationClicked(message: [AnyHashable : Any]) {}
    
}
