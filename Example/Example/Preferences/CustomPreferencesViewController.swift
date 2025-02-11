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
            customListItem: { view, topic, section, index in
                return CustomPreferencesListItem(topic: topic, section: section, index: index, onClick: {
                    view.showSheet(topic: topic)
                })
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
    private let alphaValue: CGFloat = 1.0 // Assuming full opacity

    init(topic: CourierUserPreferencesTopic, section: Int, index: Int, onClick: @escaping () -> Void) {
        self.onClick = onClick
        super.init(frame: .zero)
        isUserInteractionEnabled = true

        let titleLabel = UILabel()
        titleLabel.text = topic.topicName
        titleLabel.font = UIFont.monospacedSystemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .label.withAlphaComponent(alphaValue)
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let subtitleLabel = UILabel()
        subtitleLabel.text = topic.status == .optedOut ? "Off" : "On"
        subtitleLabel.font = UIFont.monospacedSystemFont(ofSize: 16, weight: .regular)
        subtitleLabel.textColor = .darkGray.withAlphaComponent(alphaValue)
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(titleLabel)
        addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16), // Adjusted constraint

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
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = .identity
        }) { _ in
            self.onClick()
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
    }
}

