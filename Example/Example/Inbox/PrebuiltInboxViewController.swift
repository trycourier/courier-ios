//
//  PrebuiltInboxViewController.swift
//  Example
//
//  Created by https://github.com/mikemilla on 3/6/23.
//

import UIKit
import Courier_iOS

class PrebuiltInboxViewController: UIViewController {
    
    private lazy var courierInbox = {
        return CourierInbox(
            didClickInboxMessageAtIndex: { message, index in
                message.isRead ? message.markAsUnread() : message.markAsRead()
                print(message.toJson() ?? "")
            },
            didClickInboxActionForMessageAtIndex: { action, message, index in
                print(action.toJson() ?? "")
            }
        )
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        courierInbox.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(courierInbox)
        
        NSLayoutConstraint.activate([
            courierInbox.topAnchor.constraint(equalTo: view.topAnchor),
            courierInbox.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            courierInbox.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            courierInbox.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
    }

}
