//
//  CourierDevice.swift
//  
//
//  Created by https://github.com/mikemilla on 8/3/22.
//

import Foundation
import UIKit

public struct CourierDevice: Codable {

    public let appId: String?
    public let adId: String?
    public let deviceId: String?
    public let platform: String?
    public let manufacturer: String?
    public let model: String?

    public init(
        appId: String? = ID.bundle,
        adId: String? = ID.advertising,
        deviceId: String? = ID.device,
        platform: String? = "ios",
        manufacturer: String? = "apple",
        model: String? = UIDevice.current.localizedModel
    ) {
        self.appId = appId
        self.adId = adId
        self.deviceId = deviceId
        self.platform = platform
        self.manufacturer = manufacturer
        self.model = model
    }

    enum CodingKeys: String, CodingKey {
        case appId = "app_id"
        case adId = "ad_id"
        case deviceId = "device_id"
        case platform
        case manufacturer
        case model
    }
    
}
