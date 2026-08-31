//
//  UITestsMode.swift
//
//  Flag and helpers gating the parallel "UI tests" UI flow used by the
//  Behave/Appium suite in /e2e. Activated by passing `-UITests` as a process
//  argument at launch (see SceneDelegate). When inactive, the rest of the
//  Example app behaves exactly as before.
//

import UIKit

enum UITestsMode {

    static let launchArgument = "-UITests"

    static var isActive: Bool {
        CommandLine.arguments.contains(launchArgument)
    }

    static func makeRootViewController() -> UIViewController {
        let auth = UITestsAuthViewController()
        let nav = UINavigationController(rootViewController: auth)
        nav.navigationBar.prefersLargeTitles = false
        return nav
    }
}
