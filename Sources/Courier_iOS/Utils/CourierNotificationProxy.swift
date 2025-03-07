//
//  CourierNotificationProxy.swift
//  Courier_iOS
//
//  Created by https://github.com/mikemilla on 12/13/24.
//

import Foundation

internal class CourierNotificationProxy: NSObject {
    
    weak var courier: Courier?
    
    init(courier: Courier) {
        self.courier = courier
        super.init()
    }
    
    @objc func didEnterForeground() {
        
        // Attempt to reconnect the socket when the app enters foreground
        // if the socket is already connected, the tasks will return out
        Task { @MainActor [weak self] in
            await self?.courier?.linkInbox()
        }
        
    }
    
    @objc func didEnterBackground() {
        // iOS will automatically kill off the inbox socket task
    }
    
}
