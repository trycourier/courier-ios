//
//  File.swift
//  
//
//  Created by https://github.com/mikemilla on 8/8/22.
//

import Foundation
import UIKit
import AdSupport

internal struct ID {
    
    // THIS MAY NOT BE ACCURATE
    static var advertising: String? {
        
        let manager = ASIdentifierManager.shared()
        
        guard manager.isAdvertisingTrackingEnabled else {
            return nil
        }
        
        return manager.advertisingIdentifier.uuidString
        
    }
    
    static var bundle: String? {
        return Bundle.main.bundleIdentifier
    }
    
    static var device: String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }
    
}
