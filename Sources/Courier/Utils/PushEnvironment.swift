//
//  PushEnvironment.swift
//  
//
//  Created by Michael Miller on 8/10/22.
//

import UIKit

internal extension UIDevice {
    
    enum PushEnvironment: String {
        case development
        case production
    }

    var pushEnvironment: PushEnvironment {
        
        guard let provisioningProfile = try? provisioningProfile(),
              let entitlements = provisioningProfile["Entitlements"] as? [String: Any],
              let environment = entitlements["aps-environment"] as? String
        else {
            return .development
        }

        return PushEnvironment(rawValue: environment) ?? .development
        
    }

    private func provisioningProfile() throws -> [String: Any]? {
        
        guard let url = Bundle.main.url(forResource: "embedded", withExtension: "mobileprovision") else {
            return nil
        }

        let binaryString = try String(contentsOf: url, encoding: .isoLatin1)

        let scanner = Scanner(string: binaryString)
        guard scanner.scanUpToString("<plist") != nil, let plistString = scanner.scanUpToString("</plist>"),
              let data = (plistString + "</plist>").data(using: .isoLatin1)
        else {
            return nil
        }

        return try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any]
        
    }
    
}
