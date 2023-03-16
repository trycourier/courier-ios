//
//  CourierBrand.swift
//  
//
//  Created by Michael Miller on 3/16/23.
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
    public let secondary: String?
    public let tertiary: String?
    
    public init(
        primary: String?,
        secondary: String?,
        tertiary: String?
    ) {
        self.primary = primary
        self.secondary = secondary
        self.tertiary = tertiary
    }
    
}

@objc public class CourierBrandInApp: NSObject, Codable {
    
    private let borderRadius: String?
    private let disableCourierFooter: Bool?
    
    public init(
        borderRadius: String?,
        disableCourierFooter: Bool?
    ) {
        self.borderRadius = borderRadius
        self.disableCourierFooter = disableCourierFooter
    }
    
    @objc public var cornerRadius: CGFloat {
        get {
            
            // TODO: This needs cleanup
            let cleanPixels = borderRadius?.replacingOccurrences(of: "px", with: "") ?? "8"
            
            if let formattedNumber = NumberFormatter().number(from: cleanPixels) {
                return CGFloat(truncating: formattedNumber)
            }
            
            return 8
            
        }
    }
    
    @objc public var showCourierFooter: Bool {
        get {
            return disableCourierFooter ?? false
        }
    }
    
}
