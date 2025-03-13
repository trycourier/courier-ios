//
//  CourierNotificationProxy.swift
//  Courier_iOS
//
//  Created by https://github.com/mikemilla on 12/13/24.
//

import UIKit

internal class CourierNotificationProxy: NSObject {
    
    weak var courier: Courier?
    
    init(courier: Courier) {
        self.courier = courier
        super.init()
    }
    
    /// Sets up observers for app lifecycle notifications
    func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didEnterForeground),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didTerminate),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
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
        
        // Attempt to reconnect the socket when the app enters foreground
        Task { @MainActor [weak self] in
            await self?.courier?.linkInbox()
        }
    }
    
    @objc func didEnterBackground() {
        // Nothing for now
    }
    
    @objc func didTerminate() {
        cleanup()
    }
    
    @objc func handleMemoryWarning() {
        cleanup()
    }
    
    private func cleanup() {
        Task { @MainActor [weak self] in
            await self?.courier?.unlinkInbox()
        }
    }
    
}
