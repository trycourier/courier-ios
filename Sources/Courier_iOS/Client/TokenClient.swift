//
//  TokenClient.swift
//
//
//  Created by https://github.com/mikemilla on 7/22/24.
//

import Foundation

public class TokenClient: CourierApiClient {
    
    private let options: CourierClient.Options
        
    init(options: CourierClient.Options) {
        self.options = options
        super.init()
    }
    
    public func putUserToken(token: String, provider: String, device: CourierDevice = CourierDevice()) async throws {

        let request = try http("\(options.apiUrls.rest)/users/\(options.userId)/tokens/\(token)") {
            
            $0.httpMethod = "PUT"
            
            if let jwt = options.jwt {
                $0.addHeader(key: "Authorization", value: "Bearer \(jwt)")
            }
            
            $0.httpBody = try? JSONEncoder().encode(
                TokenClient.CourierToken(
                    provider_key: provider,
                    device: device
                )
            )
            
        }
        
        try await request.dispatch(options, validCodes: [200, 204])
        
    }
    
    public func deleteUserToken(token: String) async throws {

        let request = try http("\(options.apiUrls.rest)/users/\(options.userId)/tokens/\(token)") {
            
            $0.httpMethod = "DELETE"
            
            if let jwt = options.jwt {
                $0.addHeader(key: "Authorization", value: "Bearer \(jwt)")
            }
            
        }
        
        try await request.dispatch(options, validCodes: [200, 204])
        
    }
    
}

// MARK: Request Payloads

internal extension TokenClient {
    
    struct CourierToken: Codable {
        let provider_key: String
        let device: CourierDevice
    }
    
}
