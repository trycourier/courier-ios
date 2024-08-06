//
//  CourierDevice.swift
//  
//
//  Created by https://github.com/mikemilla on 8/3/22.
//

import Foundation
import UIKit

// MARK: Internal Classes

public struct CourierDevice: Codable {
    
    public let app_id: String?
    public let ad_id: String?
    public let device_id: String?
    public let platform: String?
    public let manufacturer: String?
    public let model: String?
    
    public init(
        app_id: String? = ID.bundle,
        ad_id: String? = ID.advertising,
        device_id: String? = ID.device,
        platform: String? = CourierPlatform.ios.rawValue,
        manufacturer: String? = "apple",
        model: String? = UIDevice.current.localizedModel
    ) {
        self.app_id = app_id
        self.ad_id = ad_id
        self.device_id = device_id
        self.platform = platform
        self.manufacturer = manufacturer
        self.model = model
    }
    
}

// MARK: Public Classes

public enum CourierPlatform: String {
    case ios = "ios"
    case android = "android"
}
