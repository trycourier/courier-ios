//
//  Providers.swift
//  Messaging
//
//  Created by https://github.com/mikemilla on 7/7/22.
//

// MARK: Public Classes

import Foundation

@objc public class CourierChannel: NSObject {
    
    let key: String
    let elements: [CourierElement]
    
    internal init(key: String, elements: [CourierElement]) {
        self.key = key
        self.elements = elements
    }
    
    func toOverride() -> [String : Any]? {
        return nil
    }
    
}

@objc public class CourierElement: NSObject {
    
    let type: String
    let content: String
    let data: [String : Any]?
    
    internal init(type: String, content: String, data: [String : Any]?) {
        self.type = type
        self.content = content
        self.data = data
    }
    
    func toMap() -> [String : Any] {
        return [
            "type": type,
            "content": content,
            "data": data ?? [:]
        ]
    }
    
}

@objc public class ApplePushNotificationsServiceChannel: CourierChannel {
    
    let aps: [String : Any]?
    
    public init(aps: [String : Any]? = nil, elements: [CourierElement] = []) {
        self.aps = aps
        super.init(key: "apn", elements: elements)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override func toOverride() -> [String : Any]? {
        return [
            "override": [
                "body": [
                    "aps": aps
                ]
            ]
        ]
    }
    
}

@objc public class FirebaseCloudMessagingChannel: CourierChannel {
    
    let data: [String : String]?
    let aps: [String : Any]?
    
    public init(data: [String : String]? = nil, aps: [String : Any]? = nil, elements: [CourierElement] = []) {
        self.data = data
        self.aps = aps
        super.init(key: "firebase-fcm", elements: elements)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override func toOverride() -> [String : Any]? {
        return [
            "override": [
                "body": [
                    "data": data ?? "",
                    "apns": [
                        "payload": [
                            "aps": aps
                        ]
                    ]
                ]
            ]
        ]
    }
    
}

@objc public class CourierInboxChannel: CourierChannel {
    
    public init(elements: [CourierElement] = []) {
        super.init(key: "inbox", elements: elements)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
}

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
