//
//  CourierDevice.swift
//  
//
//  Created by https://github.com/mikemilla on 8/3/22.
//

import Foundation
import UIKit

public struct CourierDevice: Codable, Sendable {

    public let appId: String?
    public let adId: String?
    public let deviceId: String?
    public let platform: String?
    public let manufacturer: String?
    public let model: String?

    /// Builds a device from explicit values. Safe to call from any context.
    public init(
        appId: String? = ID.bundle,
        adId: String? = ID.advertising,
        deviceId: String?,
        platform: String? = "ios",
        manufacturer: String? = "apple",
        model: String?
    ) {
        self.appId = appId
        self.adId = adId
        self.deviceId = deviceId
        self.platform = platform
        self.manufacturer = manufacturer
        self.model = model
    }

    /// Builds a device describing the current hardware. Reads UIDevice, so it runs on the main actor.
    @MainActor public init(
        appId: String? = ID.bundle,
        adId: String? = ID.advertising,
        platform: String? = "ios",
        manufacturer: String? = "apple"
    ) {
        self.init(
            appId: appId,
            adId: adId,
            deviceId: ID.device,
            platform: platform,
            manufacturer: manufacturer,
            model: UIDevice.current.localizedModel
        )
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
