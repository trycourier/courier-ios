//
//  CourierBrand.swift
//  
//
//  Created by https://github.com/mikemilla on 3/16/23.
//

import Foundation

// MARK: Internal Classes

internal struct CourierBrandResponse: Codable {
    let data: CourierBrandData
}

internal struct CourierBrandData: Codable {
    let brand: CourierBrand
}

// MARK: Public Classes

@objc public class CourierBrand: NSObject, Codable {
    
    public let settings: CourierBrandSettings?
    
    public init(
        settings: CourierBrandSettings?
    ) {
        self.settings = settings
    }
    
}

@objc public class CourierBrandSettings: NSObject, Codable {
    
    public let colors: CourierBrandColors?
    public let inapp: CourierBrandInApp?
    
    public init(
        colors: CourierBrandColors?,
        inapp: CourierBrandInApp?
    ) {
        self.colors = colors
        self.inapp = inapp
    }
    
}

@objc public class CourierBrandColors: NSObject, Codable {
    
    public let primary: String?
    
    public init(
        primary: String?
    ) {
        self.primary = primary
    }
    
}

@objc public class CourierBrandInApp: NSObject, Codable {
    
    private let disableCourierFooter: Bool?
    
    public init(
        disableCourierFooter: Bool?
    ) {
        self.disableCourierFooter = disableCourierFooter
    }
    
    @objc public var showCourierFooter: Bool {
        get {
            
            if let disabled = disableCourierFooter {
                return !disabled
            }
            
            return true
            
        }
    }
    
}
