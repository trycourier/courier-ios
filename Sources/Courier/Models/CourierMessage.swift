//
//  CourierMessage.swift
//  
//
//  Created by Michael Miller on 8/4/22.
//

import Foundation

internal struct CourierMessage: Codable {
    let message: Message
}

internal struct Message: Codable {
    let to: User
    let content: Content
    let routing: Routing
    let providers: Providers
}

internal struct User: Codable {
    let user_id: String
}

internal struct Content: Codable {
    let title: String
    let body: String
}

internal struct Routing: Codable {
    let method: String
    let channels: [String]
}

internal struct Providers: Codable {
    let apn: APNProvider
    let firebaseFcm: FCMProvider
    private enum CodingKeys: String, CodingKey {
        case apn = "apn"
        case firebaseFcm = "firebase-fcm"
    }
}

internal struct FCMProvider: Codable {
    let override: FCMOverride
}

internal struct FCMOverride: Codable {
    let body: FCMBody
}

internal struct FCMBody: Codable {
    let notification: Content?
    let data: Content
    let apns: FCMAPNSPayload
}

internal struct FCMAPNSPayload: Codable {
    let payload: Payload
}

internal struct Payload: Codable {
    let aps: ApplePayloadBody
}

internal struct ApplePayloadBody: Codable {
    let mutableContent: Int
    let alert: Content
    let sound: String
    private enum CodingKeys: String, CodingKey {
        case mutableContent = "mutable-content"
        case alert = "alert"
        case sound = "sound"
    }
}

internal struct APNProvider: Codable {
    let `override`: Override
}

internal struct Override: Codable {
    let config: Config
    let body: Body
}

internal struct Config: Codable {
    let isProduction: Bool
}

internal struct Body: Codable {
    let mutableContent: Int
    private enum CodingKeys: String, CodingKey {
        case mutableContent = "mutable-content"
    }
}

internal struct MessageResponse: Codable {
    let requestId: String
}

internal struct JwtToken: Codable {
    let token: String
}
