//
//  CourierNotificationProxy.swift
//  Courier_iOS
//
//  Created by Michael Miller on 12/13/24.
//

import Foundation

internal class CourierNotificationProxy: NSObject {
    
    weak var courier: Courier?
    
    init(courier: Courier) {
        self.courier = courier
        super.init()
    }
    
    @objc func didEnterForeground() {
        Task { [weak self] in
            await self?.courier?.linkInbox()
        }
    }
    
    @objc func didEnterBackground() {
        Task { [weak self] in
            await self?.courier?.unlinkInbox()
        }
    }
    
}
