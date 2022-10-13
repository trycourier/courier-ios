//
//  Providers.swift
//  Messaging
//
//  Created by Michael Miller on 7/7/22.
//

@objc public enum CourierProvider: Int, RawRepresentable {
    
    case apns
    case fcm
    //    case expo
    //    case oneSignal
    case unknown
    
    public typealias RawValue = String
    
    public var rawValue: RawValue {
        switch self {
        case .apns:
            return "apn"
        case .fcm:
            return "firebase-fcm"
        case .unknown:
            return "unknown"
        }
    }
    
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "apn":
            self = .apns
        case "firebase-fcm":
            self = .fcm
        default:
            return nil
        }
    }
    
    public static var all: [CourierProvider] {
        return [.apns, .fcm]
    }
    
    public static var allCases: [RawValue] {
        get {
            return ["apn", "firebase-fcm"]
        }
    }
    
}
