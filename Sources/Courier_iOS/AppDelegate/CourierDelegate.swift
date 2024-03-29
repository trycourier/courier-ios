//
//  CourierDelegate.swift
//
//
//  Created by https://github.com/mikemilla on 7/5/22.
//

import UIKit

@available(iOSApplicationExtension, unavailable)
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
    
    // MARK: Launching
    
    open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    
    // MARK: Messaging
    
    open func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let message = notification.request.content.userInfo
        
        // Track the message in Courier
        Courier.shared.trackNotification(message: message, event: .delivered)
        
        let presentationOptions = pushNotificationDeliveredInForeground(message: message)
        completionHandler(presentationOptions)
        
    }
    
    open func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let message = response.notification.request.content.userInfo
        
        // Track the message in Courier
        Courier.shared.trackNotification(message: message, event: .clicked)
        
        pushNotificationClicked(message: message)
        completionHandler()
        
    }
    
    // MARK: Token Management

    open func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Courier.log("Unable to register for remote notifications: \(error.localizedDescription)")
    }

    open func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Task {
            do {
                
                // Allows a developer to know if the app is in debugging mode
                // This is helpful for a developer to know if the app is using
                // Sandbox or Production tokens
                deviceTokenDidChange(rawApnsToken: deviceToken, isDebugging: isDebuggerAttached)
                
                // Sync token to Courier
                try await Courier.shared.setAPNSToken(deviceToken)
                
            } catch {
                Courier.log(error.localizedDescription)
            }
        }
    }
    
    // MARK: Functions
    
    open func deviceTokenDidChange(rawApnsToken: Data, isDebugging: Bool) {}
    
    open func pushNotificationDeliveredInForeground(message: [AnyHashable : Any]) -> UNNotificationPresentationOptions { return [] }
    
    open func pushNotificationClicked(message: [AnyHashable : Any]) {}
    
}
