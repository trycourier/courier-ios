//
//  ExampleUITests.swift
//  ExampleUITests
//
//  Created by Michael Miller on 2/20/25.
//

import XCTest
import Courier_iOS

class ExampleUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        false
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    @MainActor
    func testFlow() async throws {
        await signIn()
        openInboxTab()
    }

    @MainActor
    func signIn() async {
        
        // Wait up to 5 seconds, but do nothing if the button doesn't exist
        let signOutButton = app.buttons["Sign Out"]
        if signOutButton.waitForExistence(timeout: 5) {
            signOutButton.tap()
        }
        
        // Tap the "Sign In" button on the main screen
        let signInButton = app.buttons["Sign In"]
        XCTAssertTrue(signInButton.waitForExistence(timeout: 5), "The 'Sign In' button should exist")
        signInButton.tap()

        // Locate the alert
        let signInAlert = app.alerts["Sign in"]
        XCTAssertTrue(signInAlert.waitForExistence(timeout: 5), "The 'Sign in' alert should appear")

        // Find the text fields within the alert
        let userIdTextField = signInAlert.textFields.element(boundBy: 0)
        XCTAssertTrue(userIdTextField.waitForExistence(timeout: 5), "The 'Courier User Id' text field should exist")
        userIdTextField.tap()
        userIdTextField.typeText("mike")

        // Tap the "Sign In" button inside the alert
        let confirmSignInButton = signInAlert.buttons["Sign In"]
        XCTAssertTrue(confirmSignInButton.waitForExistence(timeout: 5), "The 'Sign In' button inside the alert should exist")
        confirmSignInButton.tap()
        
    }
    
    func openInboxTab() {
        // Locate the "Inbox" tab button
        let inboxTab = app.tabBars.buttons["Inbox"]

        // Ensure the tab exists before tapping
        XCTAssertTrue(inboxTab.waitForExistence(timeout: 5), "The 'Inbox' tab should exist")

        // Tap the tab to switch to the Inbox view
        inboxTab.tap()
    }
}

