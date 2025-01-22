//
//  CourierClient.swift
//
//
//  Created by https://github.com/mikemilla on 7/22/24.
//

import Foundation

public class CourierClient {
    
    public struct Options {
        public let jwt: String?
        public let clientKey: String?
        public let userId: String
        public let connectionId: String?
        public let tenantId: String?
        public let showLogs: Bool
    }
    
    public let options: Options
    
    public let tokens: TokenClient
    public let brands: BrandClient
    public let inbox: InboxClient
    public let preferences: PreferenceClient
    public let tracking: TrackingClient
    
    public init(
        jwt: String? = nil,
        clientKey: String? = nil,
        userId: String,
        connectionId: String? = nil,
        tenantId: String? = nil,
        showLogs: Bool = {
            #if DEBUG
            return true
            #else
            return false
            #endif
        }()
    ) {
        
        // Setup options
        self.options = Options(
            jwt: jwt,
            clientKey: clientKey,
            userId: userId,
            connectionId: connectionId,
            tenantId: tenantId,
            showLogs: showLogs
        )
        
        // Create subclients
        self.tokens = TokenClient(options: options)
        self.brands = BrandClient(options: options)
        self.inbox = InboxClient(options: options)
        self.preferences = PreferenceClient(options: options)
        self.tracking = TrackingClient(options: options)
        
    }
    
    public static var `default`: CourierClient {
        get {
            return CourierClient(userId: "default")
        }
    }
    
}
