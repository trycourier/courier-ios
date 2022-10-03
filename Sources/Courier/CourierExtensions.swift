//
//  CourierExtensions.swift
//  
//
//  Created by Michael Miller on 8/5/22.
//

import UIKit

extension Courier {
    
    // MARK: Getters
    
    private static var userNotificationCenter: UNUserNotificationCenter {
        get { UNUserNotificationCenter.current() }
    }
    
    // MARK: Permissions
    
    /**
     * Get the authorization status of the notification permissions
     * Completion returns on main thread
     */
    public static func getNotificationPermissionStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        userNotificationCenter.getNotificationSettings(completionHandler: { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        })
    }
    
    /**
     * Get notification permission status with async await
     */
    public static func getNotificationPermissionStatus() async throws -> UNAuthorizationStatus {
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
    public static func requestNotificationPermission(completion: @escaping (UNAuthorizationStatus) -> Void) {
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
    public static func requestNotificationPermission() async throws -> UNAuthorizationStatus {
        try await userNotificationCenter.requestAuthorization(options: permissionAuthorizationOptions)
        return try await getNotificationPermissionStatus()
    }
    
    // MARK: Settings
    
    public static func openSettingsForApp() {
        if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
            UIApplication.shared.open(appSettings)
        }
    }
    
    // MARK: Analytics
    
    /**
     * Use this function if you are manually handling notifications and not using `CourierDelegate`
     * `CourierDelegate` will automatically track the urls
     */
    public func trackNotification(message: [AnyHashable : Any], event: CourierPushEvent) async throws {
        
        guard let trackingUrl = message["trackingUrl"] as? String else {
            Courier.log("Unable to find tracking url")
            return
        }
        
        Courier.log("Tracking notification event")
        
        return try await MessagingRepository().postTrackingUrl(
            url: trackingUrl,
            event: event
        )
        
    }
    
    public func trackNotification(message: [AnyHashable : Any], event: CourierPushEvent) {
        
        guard let trackingUrl = message["trackingUrl"] as? String else {
            Courier.log("Unable to find tracking url")
            return
        }
        
        Courier.log("Tracking notification event")
        
        Task.init {
            
            do {
                try await MessagingRepository().postTrackingUrl(
                    url: trackingUrl,
                    event: event
                )
            } catch {
                Courier.log(String(describing: error))
            }
            
        }
        
        // Completion is ignored
        
    }
    
    // MARK: Testing

    @discardableResult
    public func sendPush(authKey: String, userId: String, title: String, message: String, providers: [CourierProvider] = CourierProvider.allCases, isProduction: Bool) async throws -> String {
        return try await MessagingRepository().send(
            authKey: authKey,
            userId: userId,
            title: title,
            message: message,
            providers: providers,
            isProduction: isProduction
        )
        
    }
    
    public func sendPush(authKey: String, userId: String, title: String, message: String, isProduction: Bool, providers: [CourierProvider] = CourierProvider.allCases, onSuccess: @escaping (String) -> Void, onFailure: @escaping (Error) -> Void) {
        Task {
            do {
                let requestId = try await sendPush(
                    authKey: authKey,
                    userId: userId,
                    title: title,
                    message: message,
                    providers: providers,
                    isProduction: isProduction
                )
                onSuccess(requestId)
            } catch {
                onFailure(error)
            }
        }
    }
    
    // MARK: Logging
    
    public static func log(_ data: String) {
        
        // Print the log if we are debugging
        if (Courier.shared.isDebugging) {
            print(data)
        }
        
    }
    
}
