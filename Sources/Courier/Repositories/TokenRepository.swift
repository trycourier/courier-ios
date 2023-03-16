//
//  TokenRepository.swift
//
//
//  Created by Michael Miller on 7/7/22.
//

import Foundation

internal class TokenRepository: Repository {
    
    internal func putUserToken(accessToken: String, userId: String, provider: CourierProvider, token: String) async throws {
        
        try await put(
            accessToken: accessToken,
            userId: userId,
            url: "\(CourierUrl.baseRest)/users/\(userId)/tokens/\(token)",
            body: CourierToken(
                provider_key: provider.rawValue,
                device: CourierDevice()
            ),
            validCodes: [200, 204]
        )
        
    }
    
    internal func deleteToken(accessToken: String, userId: String, token: String) async throws {
        
        try await delete(
            accessToken: accessToken,
            userId: userId,
            url: "\(CourierUrl.baseRest)/users/\(userId)/tokens/\(token)",
            validCodes: [200, 204]
        )
        
    }
    
}
