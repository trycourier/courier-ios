//
//  BrandClient.swift
//
//
//  Created by https://github.com/mikemilla on 7/22/24.
//

import Foundation

public class BrandClient: CourierApiClient {
    
    private let options: CourierClient.Options
        
    init(options: CourierClient.Options) {
        self.options = options
        super.init()
    }
    
    public func getBrand(brandId: String) async throws -> CourierBrandResponse {
        
        let query = """
            query GetBrand {
                brand(brandId: "\(brandId)") {
                    settings {
                        colors {
                            primary
                            secondary
                            tertiary
                        }
                        inapp {
                            borderRadius
                            disableCourierFooter
                        }
                    }
                }
            }
        """

        let request = try http(options.apiUrls.graphql) {
            
            $0.httpMethod = "POST"
            
            $0.addHeader(key: "x-courier-user-id", value: options.userId)
            
            if let jwt = options.jwt {
                $0.addHeader(key: "Authorization", value: "Bearer \(jwt)")
            } else if let clientKey = options.clientKey {
                $0.addHeader(key: "x-courier-client-key", value: clientKey)
            }
            
            $0.httpBody = try? query.toGraphQuery()
            
        }
        
        return try await request.dispatch(options)
        
    }
    
}
