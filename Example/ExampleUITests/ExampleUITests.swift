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
        
        // Start from a signed out state
        let signOutButton = app.cells["signOutButton"]
        if signOutButton.waitForExistence(timeout: 5) {
            signOutButton.tap()
        }
        
        // Open the user ID editor
        let userIdRow = app.staticTexts["User ID"]
        XCTAssertTrue(userIdRow.waitForExistence(timeout: 5), "The 'User ID' row should exist")
        userIdRow.tap()

        // Replace whatever was saved before
        let userIdTextField = app.textFields["User ID"]
        XCTAssertTrue(userIdTextField.waitForExistence(timeout: 5), "The 'User ID' text field should appear")
        userIdTextField.tap()
        let existing = userIdTextField.value as? String ?? ""
        let deletes = existing == "User ID" ? "" : String(repeating: XCUIKeyboardKey.delete.rawValue, count: existing.count)
        userIdTextField.typeText(deletes + "mike")

        let doneButton = app.navigationBars["User ID"].buttons["Done"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 5), "The 'Done' button should exist")
        doneButton.tap()
        
        // Sign in
        let signInButton = app.cells["signInButton"]
        XCTAssertTrue(signInButton.waitForExistence(timeout: 5), "The 'Sign In' button should exist")
        signInButton.tap()
        
        XCTAssertTrue(app.cells["signOutButton"].waitForExistence(timeout: 15), "The user should end up signed in")
        
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

