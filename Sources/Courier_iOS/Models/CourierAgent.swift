//
//  CourierAgent.swift
//  
//
//  Created by https://github.com/mikemilla on 8/31/22.
//

public enum CourierAgent {
    
    case nativeIOS(_ version: String)
    case reactNativeIOS(_ version: String)
    case flutterIOS(_ version: String)
    
    var value: String {
        switch self {
        case .nativeIOS(let version):
            return "courier-ios/\(version)"
        case .reactNativeIOS(let version):
            return "courier-react-native-ios/\(version)"
        case .flutterIOS(let version):
            return "courier-flutter-ios/\(version)"
        }
    }
    
}
