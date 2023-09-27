//
//  CourierUserPreferences.swift
//
//
//  Created by Michael Miller on 9/27/23.
//

import Foundation

// MARK: Public Classes

@objc public class CourierUserPreferencesTopic: NSObject, Codable {
    
    let topic: CourierUserPreferences.Topic
    
    internal init(topic: CourierUserPreferences.Topic) {
        self.topic = topic
    }
    
}

@objc public class CourierUserPreferences: NSObject, Codable {
    
    let items: [Topic]
    let paging: Paging
    
    internal init(items: [Topic], paging: Paging) {
        self.items = items
        self.paging = paging
    }
    
    // MARK: Topic
    
    @objc public class Topic: NSObject, Codable {
        
        @objc public let defaultStatus: Status
        @objc public let hasCustomRouting: Bool
        let customRouting: [Channel]
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
            self.defaultStatus = Status(rawValue: defaultStatus) ?? .unknown
            self.hasCustomRouting = hasCustomRouting
            self.customRouting = customRouting.map { Channel(rawValue: $0) ?? .unknown }
            self.status = status
            self.topicId = topicId
            self.topicName = topicName
        }
        
        // MARK: Status
        
        @objc public enum Status: Int, RawRepresentable, Codable {
            
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
        
        @objc public enum Channel: Int, RawRepresentable, Codable {
            
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
        
    }
    
    // MARK: Pagination
    
    @objc public class Paging: NSObject, Codable {
        
        let cursor: String?
        let more: Bool
        
        internal init(cursor: String? = nil, more: Bool) {
            self.cursor = cursor
            self.more = more
        }
        
    }
    
}
