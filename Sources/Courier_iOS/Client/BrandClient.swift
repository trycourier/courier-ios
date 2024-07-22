//
//  BrandClient.swift
//
//
//  Created by Michael Miller on 7/22/24.
//

import Foundation

class BrandClient: CourierApiClient {
    
    private let options: CourierClient.Options
        
    init(options: CourierClient.Options) {
        self.options = options
        super.init()
    }
    
    func getBrand(brandId: String) async throws -> CourierBrandResponse {
        
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

        var request = try http(url: BrandClient.BASE_GRAPH_QL)
        
        request.addHeader(key: "x-courier-user-id", value: options.userId)
        
        if let jwt = options.jwt {
            request.addHeader(key: "Authorization", value: "Bearer \(jwt)")
        } else if let clientKey = options.clientKey {
            request.addHeader(key: "x-courier-client-key", value: clientKey)
        }
        
        request.httpMethod = "POST"
        request.httpBody = try query.toGraphQuery()
        
        return try await request.dispatch(options)
        
    }
    
}
