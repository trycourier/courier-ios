//
//  BrandedInboxViewController.swift
//  Example
//
//  Created by Michael Miller on 2/10/25.
//

import UIKit
import Courier_iOS

class BrandedInboxViewController: UIViewController {
    
    @objc private func readAllClick() {
        Task {
            do {
                try await Courier.shared.readAllInboxMessages()
            } catch {
                await Courier.shared.client?.log(error.localizedDescription)
            }
        }
    }
    
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
        
        title = "Branded"

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
