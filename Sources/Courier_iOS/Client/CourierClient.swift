//
//  CourierClient.swift
//
//
//  Created by https://github.com/mikemilla on 7/22/24.
//

import Foundation

public class CourierClient {
    
    struct Options: Equatable {
        let jwt: String?
        let clientKey: String?
        let userId: String
        let connectionId: String?
        let tenantId: String?
        let showLogs: Bool
        
        static func == (lhs: Options, rhs: Options) -> Bool {
            return lhs.jwt == rhs.jwt &&
                lhs.clientKey == rhs.clientKey &&
                lhs.userId == rhs.userId &&
                lhs.connectionId == rhs.connectionId &&
                lhs.tenantId == rhs.tenantId &&
                lhs.showLogs == rhs.showLogs
        }
    }
    
    let options: Options
    
    lazy var tokens = { TokenClient(options: self.options) }()
    lazy var brands = { BrandClient(options: self.options) }()
    lazy var inbox = { InboxClient(options: self.options) }()
    lazy var preferences = { PreferenceClient(options: self.options) }()
    lazy var tracking = { TrackingClient(options: self.options) }()
    
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
