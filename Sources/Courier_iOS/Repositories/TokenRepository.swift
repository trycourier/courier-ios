//
//  TokenRepository.swift
//
//
//  Created by https://github.com/mikemilla on 7/7/22.
//

import Foundation

internal class TokenRepository: Repository {
    
    internal func putUserToken(accessToken: String, userId: String, provider: CourierChannel, token: String) async throws {
        
        let body = try? JSONEncoder().encode(CourierToken(
            provider_key: provider.key,
            device: CourierDevice()
        ))
        
        try await put(
            accessToken: accessToken,
            url: "\(CourierUrl.baseRest)/users/\(userId)/tokens/\(token)",
            body: body,
            validCodes: [200, 204]
        )
        
    }
    
    internal func deleteToken(accessToken: String, userId: String, token: String) async throws {
        
        try await delete(
            accessToken: accessToken,
            url: "\(CourierUrl.baseRest)/users/\(userId)/tokens/\(token)",
            validCodes: [200, 204]
        )
        
    }
    
}
