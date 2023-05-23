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
    let data: [String : Any]?
    let elements: [CourierElement]
    
    internal init(key: String, data: [String : Any]? = nil, elements: [CourierElement]) {
        self.key = key
        self.data = data
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
    
    public init(type: String, content: String, data: [String : Any]?) {
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
    
    public init(elements: [CourierElement] = [], data: [String : Any]? = nil, aps: [String : Any]? = nil) {
        self.aps = aps
        super.init(key: "apn", data: data, elements: elements)
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
    
    let aps: [String : Any]?
    let fcmData: [String : String]?
    
    public init(elements: [CourierElement] = [], data: [String : Any]? = nil, fcmData: [String : String]? = nil, aps: [String : Any]? = nil) {
        self.fcmData = fcmData
        self.aps = aps
        super.init(key: "firebase-fcm", data: data, elements: elements)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override func toOverride() -> [String : Any]? {
        return [
            "override": [
                "body": [
                    "data": fcmData ?? "",
                    "apns": [
                        "payload": [
                            "aps": aps
                        ]
                    ]
                ] as [String : Any]
            ]
        ]
    }
    
}

@objc public class CourierInboxChannel: CourierChannel {
    
    public init(elements: [CourierElement] = [], data: [String : Any]? = nil) {
        super.init(key: "inbox", data: data, elements: elements)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
}
