//
//  CourierDevice.swift
//  
//
//  Created by Michael Miller on 8/3/22.
//

import Foundation
import UIKit

public enum CourierPlatform: String {
    case ios = "ios"
    case android = "android"
}

internal struct CourierDevice: Codable {
    
    let app_id: String?
    let ad_id: String?
    let device_id: String?
    let platform: String?
    let manufacturer: String?
    let model: String?
    
    init() {
        self.app_id = ID.bundle
        self.ad_id = ID.advertising
        self.device_id = ID.device
        self.platform = CourierPlatform.ios.rawValue
        self.manufacturer = "apple"
        self.model = UIDevice.current.localizedModel
    }
    
}
