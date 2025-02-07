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
        Task { @MainActor [weak self] in
            await self?.courier?.linkInbox()
        }
    }
    
    @objc func didEnterBackground() {
        Task { @MainActor [weak self] in
            await self?.courier?.unlinkInbox()
        }
    }
    
}
