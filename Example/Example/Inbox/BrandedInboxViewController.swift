//
//  BrandedInboxViewController.swift
//  Example
//
//  Created by Michael Miller on 2/10/25.
//

import UIKit
import Courier_iOS

class BrandedInboxViewController: UIViewController {
    
    private let theme = CourierInboxTheme(brandId: Env.COURIER_BRAND_ID)
    
    private lazy var courierInbox = {
        return CourierInbox(
            lightTheme: theme,
            darkTheme: theme,
            didClickInboxMessageAtIndex: { message, index in
                message.isRead ? message.markAsUnread() : message.markAsRead()
            },
            didLongPressInboxMessageAtIndex: { message, index in
                self.showActionSheet(message: message)
            },
            didClickInboxActionForMessageAtIndex: { action, message, index in
                self.showCodeAlert(title: "Inbox Action Click", code: action.toJson() ?? "")
            }
        )
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        courierInbox.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(courierInbox)
        
        NSLayoutConstraint.activate([
            courierInbox.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            courierInbox.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            courierInbox.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            courierInbox.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
    }

}
