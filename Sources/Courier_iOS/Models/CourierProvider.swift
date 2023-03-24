//
//  Providers.swift
//  Messaging
//
//  Created by https://github.com/mikemilla on 7/7/22.
//

// MARK: Public Classes

@objc public enum CourierProvider: Int, RawRepresentable {
    
    case inbox
    case apns
    case fcm
    case unknown
    
    public typealias RawValue = String
    
    public var rawValue: RawValue {
        switch self {
        case .inbox:
            return "inbox"
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
        case "inbox":
            self = .inbox
        case "apn":
            self = .apns
        case "firebase-fcm":
            self = .fcm
        default:
            return nil
        }
    }
    
    public static var all: [CourierProvider] {
        return [.inbox, .apns, .fcm]
    }
    
    public static var allCases: [RawValue] {
        get {
            return ["inbox", "apn", "firebase-fcm"]
        }
    }
    
}
