//
//  TokenClientTests.swift
//  
//
//  Created by Michael Miller on 7/22/24.
//

import XCTest
@testable import Courier_iOS

class TokenClientTests: XCTestCase {
    
    private let exampleToken = "f371039a5459ee369f7223cf94cc8638"
    
    func testUpsertToken() async throws {

        let client = try await ClientBuilder.build()
        
        try await client.tokens.putUserToken(
            token: exampleToken,
            provider: "apn"
        )

    }
    
    func testUpsertTokenWithCustomDevice() async throws {

        let client = try await ClientBuilder.build()
        
        let device = CourierDevice(
            app_id: "APP_ID",
            ad_id: "AD_ID",
            device_id: "DEVICE_ID",
            platform: "apple",
            manufacturer: "Apple",
            model: "iPhone 99"
        )
        
        try await client.tokens.putUserToken(
            token: exampleToken,
            provider: "apn",
            device: device
        )

    }
    
    func testDeleteToken() async throws {

        let client = try await ClientBuilder.build()
        
        try await client.tokens.deleteUserToken(
            token: exampleToken
        )

    }
    
}
