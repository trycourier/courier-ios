//
//  CourierNotificationProxy.swift
//  Courier_iOS
//
//  Created by https://github.com/mikemilla on 12/13/24.
//

import UIKit

internal class CourierNotificationProxy: NSObject {
    
    weak var courier: Courier?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var cleanupTimer: Timer?
    
    init(courier: Courier) {
        self.courier = courier
        super.init()
    }
    
    /// Sets up observers for app lifecycle notifications
    func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self.courier as Any,
            selector: #selector(didEnterForeground),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self.courier as Any,
            selector: #selector(didEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self.courier as Any,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }
    
    /// Removes observers to prevent memory leaks
    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func didEnterForeground() {
        // Invalidate the timer if the user returns to the foreground
        cleanupTimer?.invalidate()
        cleanupTimer = nil
        
        // Attempt to reconnect the socket when the app enters foreground
        Task { @MainActor [weak self] in
            await self?.courier?.linkInbox()
        }
    }
    
    @objc func didEnterBackground() {
        
        // Begin background task to ensure we can run cleanup if time permits
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            // End the background task if time expires
            self?.endBackgroundTask()
        }
        
        // Schedule a 15-minute timer to call backgroundCleanup
        cleanupTimer?.invalidate()
        cleanupTimer = Timer.scheduledTimer(
            timeInterval: 1 * 60,
            target: self.courier as Any,
            selector: #selector(backgroundCleanup),
            userInfo: nil,
            repeats: false
        )
    }
    
    @objc func handleMemoryWarning() {
        
        // Kill the inbox socket
        Task { @MainActor [weak self] in
            await self?.courier?.unlinkInbox()
        }
    }
    
    /// Called after 15 minutes in the background
    @objc private func backgroundCleanup() {
        
        // Kill the inbox socket
        Task { @MainActor [weak self] in
            await self?.courier?.unlinkInbox()
        }
        
        // Clean up background task if it's still active
        endBackgroundTask()
    }
    
    private func endBackgroundTask() {
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }
    
}
