//
//  CustomInboxViewController.swift
//  Example
//
//  Created by https://github.com/mikemilla on 2/28/23.
//

import UIKit
import Courier_iOS

class CustomInboxViewController: UIViewController {
    
    func makeListItem(_ index: Int, _ message: InboxMessage, onClick: @escaping () -> Void) -> UIView {
        
        // Create a container view
        let container = UIView()
        container.backgroundColor = message.isRead ? .systemBackground : .red
        container.isUserInteractionEnabled = true
        
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
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16)
        ])
        
        // Add Tap Gesture Recognizer with closure
        let tapGesture = UITapGestureRecognizer(target: nil, action: nil)
        tapGesture.addTargetClosure { _ in
            onClick() // Trigger the onClick closure when tapped
        }
        container.addGestureRecognizer(tapGesture)
        
        return container
        
    }
    
    private lazy var courierInbox = {
        return CourierInbox(
            customListItem: { index, message in
                return self.makeListItem(index, message) {
                    message.isRead ? message.markAsUnread() : message.markAsRead()
                }
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

extension UIGestureRecognizer {
    private struct AssociatedKeys {
        static var actionKey = "actionKey"
    }

    public class ActionWrapper {
        let action: (UIGestureRecognizer) -> Void
        init(action: @escaping (UIGestureRecognizer) -> Void) {
            self.action = action
        }
    }

    func addTargetClosure(_ closure: @escaping (UIGestureRecognizer) -> Void) {
        let wrapper = ActionWrapper(action: closure)
        addTarget(wrapper, action: #selector(wrapper.invoke(_:)))
        objc_setAssociatedObject(self, &AssociatedKeys.actionKey, wrapper, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

private extension UIGestureRecognizer.ActionWrapper {
    @objc func invoke(_ sender: UIGestureRecognizer) {
        action(sender)
    }
}
