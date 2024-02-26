//
//  CourierPreferences.swift
//  
//
//  Created by https://github.com/mikemilla on 2/26/24.
//

import UIKit

@available(iOS 15.0, *)
@available(iOSApplicationExtension, unavailable)
@objc open class CourierPreferences: UIView {
    
    @objc public init() {
        super.init(frame: .zero)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        
        backgroundColor = .green
        
        let button = UIButton(type: .system)
        button.setTitle("Click Me", for: .normal)
        
        button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        
        addSubview(button)
        
        button.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
    }
    
    @objc func buttonClicked() {
        
        guard let parentViewController = parentViewController else {
            fatalError("CourierPreferences must be added to a view hierarchy with a view controller.")
        }
        
        let contentVC = UIViewController()
        contentVC.view.backgroundColor = .white // Set your desired background color
        
        // Customize your content view controller here
        let label = UILabel()
        label.text = "This is a sheet"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        contentVC.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentVC.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentVC.view.centerYAnchor)
        ])
        
        let sheetPresentationController = contentVC.sheetPresentationController
        sheetPresentationController?.detents = [.medium(), .large()] // Define the possible sizes of the sheet
        sheetPresentationController?.preferredCornerRadius = 16 // Set corner radius
        
        // Present the view controller as a sheet
        parentViewController.present(contentVC, animated: true, completion: nil)
        
    }
    
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while let responder = parentResponder {
            if let viewController = responder as? UIViewController {
                return viewController
            }
            parentResponder = responder.next
        }
        return nil
    }
}
