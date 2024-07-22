//
//  CourierClient.swift
//
//
//  Created by Michael Miller on 7/22/24.
//

import Foundation

public class CourierClient {
    
    struct Options {
        let jwt: String?
        let clientKey: String?
        let userId: String
        let connectionId: String?
        let tenantId: String?
        let showLogs: Bool
    }
    
    let options: Options
    
//    lazy var tokens: TokenClient = { TokenClient(options: self.options) }()
    lazy var brands: BrandClient = { BrandClient(options: self.options) }()
//    lazy var inbox: InboxClient = { InboxClient(options: self.options) }()
//    lazy var preferences: PreferenceClient = { PreferenceClient(options: self.options) }()
//    lazy var tracking: TrackingClient = { TrackingClient(options: self.options) }()
    
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
        self.options = Options(
            jwt: jwt,
            clientKey: clientKey,
            userId: userId,
            connectionId: connectionId,
            tenantId: tenantId,
            showLogs: showLogs
        )
    }
}

//class TokenClient {
//    init(options: CourierClient.Options) {}
//}

//class InboxClient {
//    init(options: CourierClient.Options) {}
//}
//
//class PreferenceClient {
//    init(options: CourierClient.Options) {}
//}
//
//class TrackingClient {
//    init(options: CourierClient.Options) {}
//}
