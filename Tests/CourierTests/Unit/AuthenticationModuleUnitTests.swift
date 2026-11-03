//
//  AuthenticationModuleUnitTests.swift
//  Courier_iOS
//
//  Created by Michael Miller on 11/3/26.
//

import Foundation
import XCTest
@testable import Courier_iOS

class AuthenticationModuleUnitTests: XCTestCase {

    override func tearDown() async throws {
        await UserManager.shared.removeCredentials()
        try await super.tearDown()
    }

    func testRestoreClientFromSavedCredentials() async throws {

        await UserManager.shared.setCredentials(
            userId: "example_user",
            accessToken: "example_token",
            clientKey: "example_client_key",
            tenantId: "example_tenant",
            apiUrls: .eu,
            showLogs: false
        )

        let restored = await Courier.shared.authenticationModule.restoreClient()
        let client = try XCTUnwrap(restored)

        XCTAssertEqual(client.options.userId, "example_user")
        XCTAssertEqual(client.options.jwt, "example_token")
        XCTAssertEqual(client.options.clientKey, "example_client_key")
        XCTAssertEqual(client.options.tenantId, "example_tenant")
        XCTAssertNotNil(client.options.connectionId)
        XCTAssertFalse(client.options.showLogs)

        // The region has to survive the relaunch, not fall back to the defaults
        XCTAssertEqual(client.options.apiUrls.rest, CourierClient.ApiUrls.eu.rest)
        XCTAssertEqual(client.options.apiUrls.graphql, CourierClient.ApiUrls.eu.graphql)
        XCTAssertEqual(client.options.apiUrls.inboxGraphql, CourierClient.ApiUrls.eu.inboxGraphql)
        XCTAssertEqual(client.options.apiUrls.inboxWebSocket, CourierClient.ApiUrls.eu.inboxWebSocket)

    }

    func testRestoreClientWithoutCredentials() async {
        await UserManager.shared.removeCredentials()
        let restored = await Courier.shared.authenticationModule.restoreClient()
        XCTAssertNil(restored)
    }

    func testRestoreClientSkipsCredentialsWithoutUrls() async {

        // The shape saved before the urls were stored
        UserDefaults.standard.set([
            "courier_user_id": "example_user",
            "courier_access_token": "example_token"
        ], forKey: "courier_credentials")

        let restored = await Courier.shared.authenticationModule.restoreClient()
        XCTAssertNil(restored)

        // The user still reads as signed in, as it did before
        let isUserSignedIn = await Courier.shared.isUserSignedIn
        XCTAssertTrue(isUserSignedIn)

    }

}
