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
}

internal struct APNProvider: Codable {
    let `override`: Override
}

internal struct Override: Codable {
    let config: Config
}

internal struct Config: Codable {
    let isProduction: Bool
}

internal struct MessageResponse: Codable {
    let requestId: String
}

internal struct JwtToken: Codable {
    let token: String
}
