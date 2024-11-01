//
//  CourierAgent.swift
//  
//
//  Created by https://github.com/mikemilla on 8/31/22.
//

import Foundation

@objc public class CourierAgent: NSObject {
    
    private var agentType: String
    private var version: String
    
    private init(agentType: String, version: String) {
        self.agentType = agentType
        self.version = version
    }
    
    @objc public static func nativeIOS(_ version: String) -> CourierAgent {
        return CourierAgent(agentType: "courier-ios", version: version)
    }
    
    @objc public static func reactNativeIOS(_ version: String) -> CourierAgent {
        return CourierAgent(agentType: "courier-react-native-ios", version: version)
    }
    
    @objc public static func flutterIOS(_ version: String) -> CourierAgent {
        return CourierAgent(agentType: "courier-flutter-ios", version: version)
    }
    
    public var value: String {
        return "\(agentType)/\(version)"
    }
    
    @objc public func isReactNative() -> Bool {
        return agentType == "courier-react-native-ios"
    }
    
}
