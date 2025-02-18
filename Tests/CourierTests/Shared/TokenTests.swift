//
//  TokenTests.swift
//
//
//  Created by https://github.com/mikemilla on 7/25/24.
//

import Foundation

import XCTest
@testable import Courier_iOS

class TokenTests: XCTestCase {
    
    private let token = TokenTests.generateAPNSToken()
    
    static func generateAPNSToken() -> Data {
        var tokenData = Data(count: 32)
        _ = tokenData.withUnsafeMutableBytes { bytes in
            SecRandomCopyBytes(kSecRandomDefault, 32, bytes.baseAddress!)
        }
        return tokenData
    }
    
    func testDefaultDeviceToken() {
        let device = CourierDevice()
        XCTAssertTrue(device.appId == "com.apple.dt.xctest.tool")
    }
    
    func testCustomDeviceToken() {
        let device = CourierDevice(appId: "Example")
        XCTAssertTrue(device.appId == "Example")
    }

    func testAddExampleTokenForProvider() async throws {

        try await UserBuilder.authenticate()
        
        let provider = CourierPushProvider.firebaseFcm
        
        try await Courier.shared.setToken(
            for: provider,
            token: token.string
        )
        
        let token = await Courier.shared.getToken(
            for: provider
        )
        
        XCTAssertTrue(token == self.token.string)

    }
    
    func testAddApnsToken() async throws {

        try await UserBuilder.authenticate()
        
        try await Courier.shared.setAPNSToken(token)
        
        let token = await Courier.shared.apnsToken
        
        XCTAssertTrue(token == self.token)

    }
    
    func testAddExampleTokenForKey() async throws {

        try await UserBuilder.authenticate()
        
        let key = CourierPushProvider.expo.rawValue
        
        try await Courier.shared.setToken(
            for: key,
            token: token.string
        )
        
        let token = await Courier.shared.getToken(
            for: key
        )
        
        XCTAssertTrue(token == self.token.string)

    }
    
    func testSignOut() async throws {

        try await UserBuilder.authenticate()
        
        // Add APNS
        try await Courier.shared.setAPNSToken(token)
        
        // Add example
        let key = CourierPushProvider.expo.rawValue
        
        try await Courier.shared.setToken(
            for: key,
            token: token.string
        )
        
        // Remove user
        await Courier.shared.signOut()
        
        let apnsToken = await Courier.shared.apnsToken
        let expoToken = await Courier.shared.getToken(for: key)
        
        XCTAssertTrue(apnsToken == token)
        XCTAssertTrue(expoToken == token.string)

    }
    
    func testSpamTokens() async throws {
        
        try await UserBuilder.authenticate()
        
        let tokens = try await withThrowingTaskGroup(of: String.self) { group in
            
            for _ in 1...25 {
                group.addTask { [self] in
                    try await Courier.shared.setAPNSToken(token)
                    try await Courier.shared.setToken(for: .firebaseFcm, token: token.string)
                    return ""
                }
            }

            try await group.waitForAll()
            print("All tasks have completed")
            
            let apnsToken = await Courier.shared.apnsToken
            let fcmToken = await Courier.shared.getToken(for: .firebaseFcm)
            
            return (apnsToken?.string, fcmToken)
            
        }
        
        XCTAssertTrue(tokens.0 == token.string)
        XCTAssertTrue(tokens.1 == token.string)
        
    }
    
}
