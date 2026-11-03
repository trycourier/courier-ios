//
//  SceneDelegate.swift
//  Example
//
//  Created by https://github.com/mikemilla on 11/17/22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = RootTabBarController()
        window.makeKeyAndVisible()
        self.window = window
    }

}
