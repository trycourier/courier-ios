//
//  CoreBrand.swift
//
//
//  Created by https://github.com/mikemilla on 3/8/24.
//

import Foundation

internal class CoreBrand {
    
    private lazy var brandsRepo = BrandsRepository()

    internal func getBrand(brandId: String) async throws -> CourierBrand {
        
        guard let userId = Courier.shared.userId else {
            throw CourierError.missingUser
        }
        
        return try await brandsRepo.getBrand(
            clientKey: Courier.shared.clientKey,
            jwt: Courier.shared.jwt,
            userId: userId,
            brandId: brandId
        )
        
    }
    
}

extension Courier {
    
    /**
     * Returns the brand for id
     */
    @objc public func getBrand(brandId: String) async throws -> CourierBrand {
        try await coreBrand.getBrand(brandId: brandId)
    }
    
    @objc public func getBrand(brandId: String, onSuccess: @escaping (CourierBrand) -> Void, onFailure: @escaping (Error) -> Void) {
        Task {
            do {
                let brand = try await coreBrand.getBrand(brandId: brandId)
                onSuccess(brand)
            } catch {
                onFailure(error)
            }
        }
    }
    
}
