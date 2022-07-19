//
//  File.swift
//  
//
//  Created by Michael Miller on 7/19/22.
//

import Foundation

struct CourierResponse: Codable {
    
    public let status: String
    
    public init(status: String) {
        self.status = status
    }
    
}
