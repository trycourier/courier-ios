//
//  CustomInboxViewController.swift
//  Example
//
//  Created by https://github.com/mikemilla on 2/28/23.
//

import UIKit
import Courier_iOS

class CustomInboxViewController: UIViewController {
    
    func makeListItem(_ index: Int, _ message: InboxMessage) -> UIView {
        // Create a container view
        let container = UIView()
        container.backgroundColor = message.isRead ? .systemBackground : .red
        
        // Create a label
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "\(message.title ?? "Title") — \(message.subtitle ?? "Subtitle")"
        label.textAlignment = .left
        
        // Enable Auto Layout
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // Add label to container
        container.addSubview(label)
        
        // Make the label fill the container with padding
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16)
        ])
        
        return container
    }
    
    private lazy var courierInbox = {
        return CourierInbox(
            customListItem: { index, message in
                return self.makeListItem(index, message)
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
