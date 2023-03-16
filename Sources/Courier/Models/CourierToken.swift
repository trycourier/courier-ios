//
//  CourierToken.swift
//  
//
//  Created by Michael Miller on 8/8/22.
//

import Foundation

// MARK: Internal Classes

internal struct CourierToken: Codable {
    let provider_key: String
    let device: CourierDevice
}
