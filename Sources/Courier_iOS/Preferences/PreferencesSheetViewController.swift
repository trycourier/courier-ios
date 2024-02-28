//
//  PreferencesSheetViewController.swift
//  
//
//  Created by https://github.com/mikemilla on 2/28/24.
//

import UIKit

@available(iOS 15.0, *)
internal class PreferencesSheetViewController: UIViewController, UISheetPresentationControllerDelegate {
    
    let topic: CourierUserPreferencesTopic
    let items: [CourierSheetItem]
        
    init(topic: CourierUserPreferencesTopic, items: [CourierSheetItem]) {
        self.topic = topic
        self.items = items
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the view
        view.backgroundColor = .white
        
        // Create the sheet controller
        let sheetPresentationController = sheetPresentationController
        sheetPresentationController?.delegate = self
        sheetPresentationController?.prefersGrabberVisible = true
        sheetPresentationController?.preferredCornerRadius = 16
        
        // Create a map of the values
//        var switches = [CourierUserPreferencesChannel: CourierUserPreferencesStatus]()
        
        // Handle all cases
        // If required prevent usage
        // If "IN" default to on or do custom routing
        // If "OUT" default to off or do custom routing
        // Loop through availableChannels and set switches
        
        // Create the sheet
        let sheet = CourierPreferencesSheet(
            title: self.topic.topicName,
            items: self.items,
            onSheetClose: {
                // Handle on close actions if needed
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
                self.getSheetHeight(sheet: sheet, items: self.items)
            }
            sheetPresentationController?.detents = [customDetent, .large()]
        } else {
            sheetPresentationController?.detents = [.medium(), .large()]
        }
        
    }
    
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        
//        // Get the view controller
//        let viewController = presentationController.presentedViewController as? PreferencesSheetViewController
//        
//        // Get the topic of the view controller
//        if let topic = viewController?.topic {
//            savePreferences(newTopic: topic)
//        }
        
    }
    
    private func getSheetHeight(sheet: CourierPreferencesSheet, items: [CourierSheetItem]) -> CGFloat {
        
        let margins = CourierPreferencesSheet.marginTop + CourierPreferencesSheet.marginBottom
        
        let navBarHeight = sheet.navigationBar.frame.height == 0 ? 56 : sheet.navigationBar.frame.height
        
        let itemHeight = CourierPreferencesSheet.cellHeight * CGFloat(items.count)
        
        return margins + navBarHeight + itemHeight
        
    }
    
}
