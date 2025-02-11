//
//  CustomPreferencesViewController.swift
//  Example
//
//  Created by Michael Miller on 2/10/25.
//

import UIKit
import Courier_iOS

class CustomPreferencesViewController: UIViewController {
    
    private lazy var courierPreferences = {
        return CourierPreferences(
            customListItem: { topic, section, index in
                return
            },
            onError: { error in
                self.showCodeAlert(title: "Preferences Error", code: error.localizedDescription)
            }
        )
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        courierPreferences.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(courierPreferences)

        NSLayoutConstraint.activate([
            courierPreferences.topAnchor.constraint(equalTo: view.topAnchor),
            courierPreferences.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            courierPreferences.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            courierPreferences.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

    }

}

class CustomPreferencesListItem: UIView {

    private let onClick: () -> Void

    init(topic: CourierUserPreferencesTopic, section: Int, index: Int, onClick: @escaping () -> Void) {
        self.onClick = onClick
        super.init(frame: .zero)
        isUserInteractionEnabled = true

        let titleLabel = UILabel()
        titleLabel.text = topic.topicName
        titleLabel.font = UIFont.monospacedSystemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .label.withAlphaComponent(alpha)
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let subtitleLabel = UILabel()
        subtitleLabel.text = topic.status.title
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
