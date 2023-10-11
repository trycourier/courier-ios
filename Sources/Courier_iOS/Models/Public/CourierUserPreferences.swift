//
//  CourierUserPreferences.swift
//
//
//  Created by Michael Miller on 9/27/23.
//

import Foundation

// MARK: Public Classes

internal class CourierUserPreferencesTopicResponse: NSObject, Codable {
    
    public let topic: CourierUserPreferencesTopic
    
    internal init(topic: CourierUserPreferencesTopic) {
        self.topic = topic
    }
    
}

@objc public class CourierUserPreferences: NSObject, Codable {
    
    public let items: [CourierUserPreferencesTopic]
    public let paging: CourierUserPreferencesPaging
    
    internal init(items: [CourierUserPreferencesTopic], paging: CourierUserPreferencesPaging) {
        self.items = items
        self.paging = paging
    }
    
}



// MARK: Topic

@objc public class CourierUserPreferencesTopic: NSObject, Codable {
    
    @objc public let defaultStatus: CourierUserPreferencesStatus
    @objc public let hasCustomRouting: Bool
    public let customRouting: [CourierUserPreferencesChannel]
    @objc public let status: String
    @objc public let topicId: String
    @objc public let topicName: String
    
    private enum CodingKeys: String, CodingKey {
        case defaultStatus = "default_status"
        case hasCustomRouting = "has_custom_routing"
        case customRouting = "custom_routing"
        case status = "status"
        case topicId = "topic_id"
        case topicName = "topic_name"
    }
    
    @objc internal init(defaultStatus: String, hasCustomRouting: Bool, customRouting: [String], status: String, topicId: String, topicName: String) {
        self.defaultStatus = CourierUserPreferencesStatus(rawValue: defaultStatus) ?? .unknown
        self.hasCustomRouting = hasCustomRouting
        self.customRouting = customRouting.map { CourierUserPreferencesChannel(rawValue: $0) ?? .unknown }
        self.status = status
        self.topicId = topicId
        self.topicName = topicName
    }
    
}

// MARK: Status

@objc public enum CourierUserPreferencesStatus: Int, RawRepresentable, Codable {
    
    case optedIn
    case optedOut
    case required
    case unknown
    
    public typealias RawValue = String

    public var rawValue: RawValue {
        switch self {
        case .optedIn:
            return "OPTED_IN"
        case .optedOut:
            return "OPTED_OUT"
        case .required:
            return "REQUIRED"
        case .unknown:
            return "UNKNOWN"
        }
    }

    public init?(rawValue: RawValue) {
        switch rawValue {
        case "OPTED_IN":
            self = .optedIn
        case "OPTED_OUT":
            self = .optedOut
        case "REQUIRED":
            self = .required
        default:
            self = .unknown
        }
    }
    
}

// MARK: Channel

@objc public enum CourierUserPreferencesChannel: Int, RawRepresentable, Codable {
    
    case directMessage
    case email
    case push
    case sms
    case webhook
    case unknown
    
    public typealias RawValue = String

    public var rawValue: RawValue {
        switch self {
        case .directMessage:
            return "direct_message"
        case .email:
            return "email"
        case .push:
            return "push"
        case .sms:
            return "sms"
        case .webhook:
            return "webhook"
        case .unknown:
            return "unknown"
        }
    }

    public init?(rawValue: RawValue) {
        switch rawValue {
        case "direct_message":
            self = .directMessage
        case "email":
            self = .email
        case "push":
            self = .push
        case "sms":
            self = .sms
        case "webhook":
            self = .webhook
        default:
            self = .unknown
        }
    }
    
}

// MARK: Pagination

@objc public class CourierUserPreferencesPaging: NSObject, Codable {
    
    public let cursor: String?
    public let more: Bool
    
    internal init(cursor: String? = nil, more: Bool) {
        self.cursor = cursor
        self.more = more
    }
    
}
