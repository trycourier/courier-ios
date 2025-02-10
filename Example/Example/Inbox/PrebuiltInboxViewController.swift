//
//  PrebuiltInboxViewController.swift
//  Example
//
//  Created by https://github.com/mikemilla on 3/6/23.
//

import UIKit
import Courier_iOS

class PrebuiltInboxViewController: UIViewController {
    
    @objc private func readAllClick() {
        Task {
            do {
                try await Courier.shared.readAllInboxMessages()
            } catch {
                await Courier.shared.client?.log(error.localizedDescription)
            }
        }
    }
    
    private lazy var courierInbox = {
        return CourierInbox(
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
        
        title = "Default"

        courierInbox.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(courierInbox)
        
        NSLayoutConstraint.activate([
            courierInbox.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            courierInbox.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            courierInbox.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            courierInbox.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        let readAllButton = UIBarButtonItem(title: "Read All", style: .plain, target: self, action: #selector(readAllClick))
        navigationItem.rightBarButtonItem = readAllButton
        
    }

}
