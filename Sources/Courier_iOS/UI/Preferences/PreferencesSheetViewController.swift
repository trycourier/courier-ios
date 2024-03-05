//
//  PreferencesSheetViewController.swift
//  
//
//  Created by https://github.com/mikemilla on 2/28/24.
//

import UIKit

@available(iOS 15.0, *)
internal class PreferencesSheetViewController: UIViewController, UISheetPresentationControllerDelegate {
    
    static var items: [CourierSheetItem] = []
    let theme: CourierPreferencesTheme
    let topic: CourierUserPreferencesTopic
    let onDismiss: ([CourierSheetItem]) -> Void
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the view
        view.backgroundColor = .systemBackground
        
        // Create the sheet controller
        sheetPresentationController?.delegate = self
        sheetPresentationController?.prefersGrabberVisible = true
        sheetPresentationController?.preferredCornerRadius = Theme.Preferences.sheetCornerRadius
        
        // Create the sheet
        let sheet = CourierPreferencesSheet(
            theme: self.theme,
            title: self.topic.topicName,
            onSheetClose: {
                
                // Call delegate function on close
                if let vc = self.sheetPresentationController {
                    self.presentingViewController?.dismiss(animated: true) {
                        self.presentationControllerDidDismiss(vc)
                    }
                }
                
            }
        )
        
        // Add the sheet to the view
        sheet.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sheet)
        NSLayoutConstraint.activate([
            sheet.topAnchor.constraint(equalTo: view.topAnchor),
            sheet.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sheet.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sheet.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        sheet.layoutIfNeeded()
        
        // Set up sheet presentation controller
        if #available(iOS 16.0, *) {
            let customDetent = UISheetPresentationController.Detent.custom { context in
                self.getSheetHeight(sheet: sheet, items: PreferencesSheetViewController.items)
            }
            sheetPresentationController?.detents = [customDetent, .large()]
        } else {
            sheetPresentationController?.detents = [.medium(), .large()]
        }
        
    }
    
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.onDismiss(PreferencesSheetViewController.items)
    }
    
    private func getSheetHeight(sheet: CourierPreferencesSheet, items: [CourierSheetItem]) -> CGFloat {
        
        let margins = (Theme.margin / 2) + Theme.margin
        
        let navBarHeight = sheet.navigationBar.frame.height == 0 ? Theme.Preferences.sheetNavBarHeight : sheet.navigationBar.frame.height
        
        let itemHeight = Theme.Preferences.settingsCellHeight * CGFloat(items.count)
        
        return margins + navBarHeight + itemHeight
        
    }
    
}
