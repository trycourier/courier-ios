//
//  CourierBrand.swift
//  
//
//  Created by https://github.com/mikemilla on 3/16/23.
//

import Foundation

// MARK: Internal Classes

public struct CourierBrandResponse: Codable, Sendable {
    public let data: CourierBrandData
}

public struct CourierBrandData: Codable, Sendable {
    public let brand: CourierBrand
}

// MARK: Public Classes

public final class CourierBrand: NSObject, Codable, @unchecked Sendable {
    
    public let settings: CourierBrandSettings?
    
    public init(
        settings: CourierBrandSettings?
    ) {
        self.settings = settings
    }
    
}

public final class CourierBrandSettings: NSObject, Codable, @unchecked Sendable {
    
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

public final class CourierBrandColors: NSObject, Codable, @unchecked Sendable {
    
    public let primary: String?
    
    public init(
        primary: String?
    ) {
        self.primary = primary
    }
    
}

public final class CourierBrandInApp: NSObject, Codable, @unchecked Sendable {
    
    private let disableCourierFooter: Bool?
    
    public init(
        disableCourierFooter: Bool?
    ) {
        self.disableCourierFooter = disableCourierFooter
    }
    
    public var showCourierFooter: Bool {
        get {
            
            if let disabled = disableCourierFooter {
                return !disabled
            }
            
            return true
            
        }
    }
    
}
