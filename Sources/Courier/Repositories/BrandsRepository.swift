//
//  File.swift
//  
//
//  Created by Michael Miller on 3/16/23.
//

import Foundation

internal class BrandsRepository: Repository {
    
    internal func getBrand(clientKey: String, userId: String, brandId: String) async throws -> CourierBrand {
        
        let query = """
        query GetBrand($brandId: String = "\(brandId)") {
            brand(brandId: $brandId) {
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
        
        let response = try await graphQL(
            CourierBrandResponse.self,
            clientKey: clientKey,
            userId: userId,
            url: baseGraphQLUrl,
            query: query
        )
        
        return response.data.brand
        
    }
    
}
