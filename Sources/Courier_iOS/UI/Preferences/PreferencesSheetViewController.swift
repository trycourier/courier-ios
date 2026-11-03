//
//  PreferencesSheetViewController.swift
//
//
//  Created by https://github.com/mikemilla on 2/28/24.
//

import UIKit

@available(iOS 15.0, *)
@available(iOSApplicationExtension, unavailable)
internal class PreferencesSheetViewController: UIViewController, UISheetPresentationControllerDelegate {

    @MainActor static var items: [CourierSheetItem] = []
    private(set) var theme: CourierPreferencesTheme
    let topic: CourierUserPreferencesTopic
    let onDismiss: ([CourierSheetItem]) -> Void

    lazy var sheet: CourierPreferencesSheet = {
        let sheet = CourierPreferencesSheet(theme: self.theme)
        sheet.translatesAutoresizingMaskIntoConstraints = false
        return sheet
    }()

    init(theme: CourierPreferencesTheme, topic: CourierUserPreferencesTopic, items: [CourierSheetItem], onDismiss: @escaping ([CourierSheetItem]) -> Void) {
        self.theme = theme
        self.topic = topic
        PreferencesSheetViewController.items = items
        self.onDismiss = onDismiss
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /**
     The controller to present. A navigation controller lets iOS place the title and close button
     the way it does in its own sheets. On iOS 26 that puts the button concentric with the corner.
     */
    func makeNavigationController() -> UINavigationController {

        let navigationController = UINavigationController(rootViewController: self)

        // Set up sheet presentation controller
        if let sheetController = navigationController.sheetPresentationController {

            sheetController.delegate = self
            sheetController.prefersGrabberVisible = true
            sheetController.preferredCornerRadius = theme.preferredSheetCornerRadius

            if #available(iOS 16.0, *) {
                let customDetent = UISheetPresentationController.Detent.custom { [weak self] context in
                    self?.getSheetHeight(items: PreferencesSheetViewController.items)
                }
                sheetController.detents = [customDetent, .large()]
            } else {
                sheetController.detents = [.medium(), .large()]
            }

        }

        return navigationController

    }

    func setTheme(theme: CourierPreferencesTheme) {
        self.theme = theme
        self.view.backgroundColor = theme.sheetBackgroundColor
        self.sheet.setTheme(theme: theme)
        self.setNavigationTheme()
        navigationController?.sheetPresentationController?.preferredCornerRadius = theme.preferredSheetCornerRadius
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the view
        view.backgroundColor = theme.sheetBackgroundColor

        // Title and close button
        navigationItem.title = topic.topicName
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeButtonClick))
        setNavigationTheme()

        // Add the sheet to the view
        view.addSubview(sheet)
        NSLayoutConstraint.activate([
            sheet.topAnchor.constraint(equalTo: view.topAnchor),
            sheet.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sheet.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sheet.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

    }

    // A transparent bar matches the rows below it. The default bar drew a band under the title.
    private func setNavigationTheme() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [
            .font: theme.sheetTitleFont.font,
            .foregroundColor: theme.sheetTitleFont.color
        ]
        navigationItem.standardAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
    }

    @objc private func closeButtonClick() {

        // Call delegate function on close
        guard let presentationController = navigationController?.presentationController else { return }
        dismiss(animated: true) {
            self.presentationControllerDidDismiss(presentationController)
        }

    }

    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.onDismiss(PreferencesSheetViewController.items)
    }

    private func getSheetHeight(items: [CourierSheetItem]) -> CGFloat {

        let navBarHeight = navigationController?.navigationBar.frame.height ?? 0

        let itemHeight = Theme.Preferences.settingsCellHeight * CGFloat(items.count)

        return (navBarHeight == 0 ? Theme.Preferences.sheetNavBarHeight : navBarHeight) + itemHeight + (Theme.margin / 2)

    }

}
