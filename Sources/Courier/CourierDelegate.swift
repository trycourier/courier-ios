//
//  CourierDelegate.swift
//
//
//  Created by Michael Miller on 7/5/22.
//

import UIKit

open class CourierDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    // MARK: Init
    
    override init() {
        super.init()
        
        // Register to ensure device token can be fetched
        app.registerForRemoteNotifications()
        UNUserNotificationCenter.current().delegate = self
        
    }
    
    // MARK: Getters
    
    private var app: UIApplication {
        get { return UIApplication.shared }
    }
    
    // MARK: Messaging
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let message = notification.request.content.userInfo
        pushNotificationReceivedInForeground(message: message, presentAs: completionHandler)
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let message = response.notification.request.content.userInfo
        pushNotificationOpened(message: message)
        completionHandler()
    }
    
    // MARK: Token Management

    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint("Unable to register for remote notifications: \(error.localizedDescription)")
    }

    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) async {
        Task.init {
            do {
                try await Courier.shared.setPushToken(
                    provider: .apns,
                    token: deviceToken.string
                )
            } catch {
                debugPrint(error)
            }
        }
    }
    
    // MARK: Functions

    open func pushNotificationReceivedInForeground(message: [AnyHashable : Any], presentAs presentForegroundNotificationOptions: @escaping (UNNotificationPresentationOptions) -> Void) {}
    
    open func pushNotificationOpened(message: [AnyHashable : Any]) {}
    
}
