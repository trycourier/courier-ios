//
//  File.swift
//  
//
//  Created by https://github.com/mikemilla on 8/8/22.
//

import Foundation
import UIKit
import AdSupport

public struct ID {
    
    // NOTE: THIS MAY NOT BE ACCURATE
    public static var advertising: String? {
        
        let manager = ASIdentifierManager.shared()
        
        guard manager.isAdvertisingTrackingEnabled else {
            return nil
        }
        
        return manager.advertisingIdentifier.uuidString
        
    }
    
    public static var bundle: String? {
        return Bundle.main.bundleIdentifier
    }
    
    public static var device: String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }
    
}
