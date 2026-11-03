//
//  CodeViewController.swift
//  Example
//
//  Created by Michael Miller on 11/3/26.
//

import UIKit

// Shows JSON and other raw values in a sheet, where long payloads can scroll and be copied
class CodeViewController: UIViewController {

    private let code: String

    private let textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.font = UIFont.monospacedSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize, weight: .regular)
        textView.adjustsFontForContentSizeCategory = true
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 12, bottom: 16, right: 12)
        textView.backgroundColor = .clear
        return textView
    }()

    init(title: String, code: String) {
        self.code = code
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never

        textView.text = code
        view.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.topAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Copy",
            image: UIImage(systemName: "doc.on.doc"),
            primaryAction: UIAction { [weak self] _ in
                guard let self else { return }
                UIPasteboard.general.string = self.code
                self.showToast("Copied")
            }
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .done,
            primaryAction: UIAction { [weak self] _ in
                self?.dismiss(animated: true)
            }
        )

    }

}
