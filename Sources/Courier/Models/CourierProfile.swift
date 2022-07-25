//
//  CourierProfile.swift
//
//
//  Created by Michael Miller on 7/19/22.
//

import Foundation

public struct CourierProfile: Codable {
    
    public let profile: CourierUserProfile
    
    public init(profile: CourierUserProfile) {
        self.profile = profile
    }
    
}
