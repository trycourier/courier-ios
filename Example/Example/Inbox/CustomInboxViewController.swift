//
//  CustomInboxViewController.swift
//  Example
//
//  Created by https://github.com/mikemilla on 2/28/23.
//

import UIKit
import Courier_iOS

class CustomInboxViewController: UIViewController {

    private lazy var courierInbox = CourierInbox(
        customListItem: { message, index in
            return CustomInboxListItem(message: message, index: index) {
                message.isRead ? message.markAsUnread() : message.markAsRead()
            }
        }
    )

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

class CustomInboxListItem: UIView {

    private let onClick: () -> Void

    init(message: InboxMessage, index: Int, onClick: @escaping () -> Void) {
        self.onClick = onClick
        super.init(frame: .zero)
        isUserInteractionEnabled = true
        
        let alpha = !message.isRead ? 1 : 0.5

        let titleLabel = UILabel()
        titleLabel.text = message.title ?? "Title"
        titleLabel.font = UIFont.monospacedSystemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .label.withAlphaComponent(alpha)
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let subtitleLabel = UILabel()
        subtitleLabel.text = message.subtitle ?? "Subtitle"
        subtitleLabel.font = UIFont.monospacedSystemFont(ofSize: 16, weight: .regular)
        subtitleLabel.textColor = .darkGray.withAlphaComponent(alpha)
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        let imageContainer = UIView()
        imageContainer.alpha = alpha
        imageContainer.backgroundColor = .lightGray
        imageContainer.clipsToBounds = true
        imageContainer.translatesAutoresizingMaskIntoConstraints = false

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageContainer.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: imageContainer.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor)
        ])

        if let imageUrlString = message.data?["image"] as? String, let imageUrl = URL(string: imageUrlString) {
            let session = URLSession.shared
            let task = session.dataTask(with: imageUrl) { data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        imageView.image = image
                    }
                } else {
                    DispatchQueue.main.async {
                        imageView.image = UIImage(systemName: "person.crop.circle")
                    }
                }
            }
            task.resume()
        } else {
            imageView.image = UIImage(systemName: "person.crop.circle")
        }

        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(imageContainer)

        NSLayoutConstraint.activate([
            imageContainer.widthAnchor.constraint(equalToConstant: 48),
            imageContainer.heightAnchor.constraint(equalToConstant: 64),
            imageContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            imageContainer.centerYAnchor.constraint(equalTo: centerYAnchor),

            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: imageContainer.leadingAnchor, constant: -16),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.onClick()
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = .identity
        })
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
    }
}
