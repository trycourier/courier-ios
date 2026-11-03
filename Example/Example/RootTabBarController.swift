//
//  RootTabBarController.swift
//  Example
//
//  Created by https://github.com/mikemilla on 3/3/23.
//

import UIKit
import Courier_iOS

class RootTabBarController: UITabBarController {

    private var inboxListener: CourierInboxListener? = nil

    private let inboxTab = UITab(title: "Inbox", image: UIImage(systemName: "tray"), identifier: "inbox") { _ in
        RootTabBarController.navigationController(for: InboxViewController())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tabs = [
            UITab(title: "Auth", image: UIImage(systemName: "person.crop.circle"), identifier: "auth") { _ in
                Self.navigationController(for: AuthViewController())
            },
            UITab(title: "Push", image: UIImage(systemName: "bell.badge"), identifier: "push") { _ in
                Self.navigationController(for: PushViewController())
            },
            inboxTab,
            UITab(title: "Preferences", image: UIImage(systemName: "slider.horizontal.3"), identifier: "preferences") { _ in
                Self.navigationController(for: PreferencesViewController())
            }
        ]

        // Keep the tab bar in view while lists scroll, so every example is one tap away
        if #available(iOS 26.0, *) {
            tabBarMinimizeBehavior = .never
        }

        Task {

            self.inboxListener = await Courier.shared.addInboxListener(
                onUnreadCountChanged: { count in
                    self.setBadge(count)
                }
            )

        }

    }

    private static func navigationController(for rootViewController: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.navigationBar.prefersLargeTitles = true
        return navigationController
    }

    private func setBadge(_ count: Int) {
        inboxTab.badgeValue = count <= 0 ? nil : "\(count)"

        // The app icon badge needs notification permission. Only set it once the user has allowed
        // notifications, so the permission prompt stays on the Push tab instead of appearing at launch.
        Courier.getNotificationPermissionStatus { status in
            guard status == .authorized || status == .provisional || status == .ephemeral else { return }
            UNUserNotificationCenter.current().setBadgeCount(count)
        }
    }

    deinit {
        inboxListener?.remove()
    }

}
