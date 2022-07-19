//
//  CourierAddress.swift
//  
//
//  Created by Michael Miller on 7/19/22.
//

import Foundation

public struct CourierAddress: Codable {
    
    public let formatted: String?
    public let street_address: String?
    public let locality: String?
    public let region: String?
    public let postal_code: String?
    public let country: String?
    
    public init(formatted: String? = nil, street_address: String? = nil, locality: String? = nil, region: String? = nil, postal_code: String? = nil, country: String? = nil) {
        self.formatted = formatted
        self.street_address = street_address
        self.locality = locality
        self.region = region
        self.postal_code = postal_code
        self.country = country
    }
    
}
