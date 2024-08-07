//
//  TokenClientTests.swift
//  
//
//  Created by https://github.com/mikemilla on 7/22/24.
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
            appId: "APP_ID",
            adId: "AD_ID",
            deviceId: "DEVICE_ID",
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
