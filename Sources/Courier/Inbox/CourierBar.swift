//
//  Courierbar.swift
//  
//
//  Created by https://github.com/mikemilla on 3/13/23.
//

import UIKit

internal class CourierBar: UIView {
    
    private let border = UIView()
    private let logoButton = UIButton(type: .custom)

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        
        subviews.forEach {
            $0.removeFromSuperview()
        }

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 48),
        ])
        
        // Logo
        
        logoButton.contentMode = .scaleAspectFit
        logoButton.translatesAutoresizingMaskIntoConstraints = false
        logoButton.addTarget(self, action: #selector(showLaunchSheet), for: .touchUpInside)
        
        addSubview(logoButton)
        
        NSLayoutConstraint.activate([
            logoButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            logoButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            logoButton.heightAnchor.constraint(equalToConstant: 16),
        ])
        
        // Border
        
        border.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(border)
        
        NSLayoutConstraint.activate([
            border.heightAnchor.constraint(equalToConstant: 0.5),
            border.topAnchor.constraint(equalTo: topAnchor),
            border.leadingAnchor.constraint(equalTo: leadingAnchor),
            border.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
    }
    
    @objc private func showLaunchSheet() {
        
        print("Test")
        
//        let alert = UIAlertController(title: "Your title", message: nil, preferredStyle: .actionSheet)
//
//        alert.addAction(UIAlertAction(title: "Your action 1", style: .default) { _ in
//            // onAction1()
//        })
//
//        alert.addAction(UIAlertAction(title: "Your action 2", style: .default) { _ in
//            // onAction2()
//        })
//
//        alert.addAction(UIAlertAction(title: "Your cancel action", style: .cancel) { _ in
//            // onCancel
//        })
//
//        if let viewController = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController {
//            viewController.present(alert, animated: true)
//        }
        
    }
    
    internal func setTheme(_ theme: CourierInboxTheme) {
        
        border.backgroundColor = theme.cellStyles.separatorColor ?? .separator
        isHidden = theme.brand?.settings?.inapp?.showCourierFooter ?? false
        
    }
    
    internal func setColors(with color: UIColor) {
        
        // Set background color
        backgroundColor = color
        
        // Set foreground color
        let foregroundColor = color.luminance() < 0.5 ? CourierInboxTheme.darkBrandColor : CourierInboxTheme.lightBrandColor
        let logo = UIImage.footer!.withRenderingMode(.alwaysTemplate).withTintColor(foregroundColor)
        logoButton.setImage(logo, for: .normal)
        
    }

}
