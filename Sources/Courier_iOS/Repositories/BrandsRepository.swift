//
//  BrandsRepository.swift
//  
//
//  Created by https://github.com/mikemilla on 3/16/23.
//

import Foundation

internal class BrandsRepository: Repository {
    
    internal func getBrand(clientKey: String? = nil, jwt: String? = nil, userId: String, brandId: String) async throws -> CourierBrand {
        
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
        
        let data = try await graphQLQuery(
            jwt: jwt,
            clientKey: clientKey, 
            clientSourceId: nil,
            userId: userId,
            url: CourierUrl.baseGraphQL,
            query: query
        )
        
        do {
            let res = try JSONDecoder().decode(CourierBrandResponse.self, from: data ?? Data())
            return res.data.brand
        } catch {
            let e = CourierError(from: error)
            Courier.log(e.message)
            throw e
        }
        
    }
    
}
