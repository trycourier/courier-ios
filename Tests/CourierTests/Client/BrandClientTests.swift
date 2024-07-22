//
//  BrandClientTests.swift
//
//
//  Created by Michael Miller on 7/22/24.
//

import XCTest
@testable import Courier_iOS

class BrandClientTests: XCTestCase {
    
    func testGetBrand() async throws {

        let client = try await ClientBuilder.build()
        
        let res = try await client.brands.getBrand(
            brandId: Env.COURIER_BRAND_ID
        )
        
        print(res)

    }
    
}

