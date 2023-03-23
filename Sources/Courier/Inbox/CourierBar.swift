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
            logoButton.heightAnchor.constraint(equalToConstant: 40),
            logoButton.widthAnchor.constraint(equalToConstant: 134),
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
        
        if let viewController = topViewController(), let url = URL(string: "https://www.courier.com/") {
            
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
            alert.addAction(UIAlertAction(title: "Go to Courier", style: .default) { _ in
                UIApplication.shared.open(url)
            })
    
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                // onCancel
            })
    
            viewController.present(alert, animated: true)
            
        }
        
    }
    
    private func topViewController() -> UIViewController? {
        
        let keyWindow = UIApplication.shared.windows.filter { $0.isKeyWindow }.first

        if var topController = keyWindow?.rootViewController {
            
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            return topController
            
        } else {
            
            return nil
            
        }
        
    }
    
    private var footerImage: UIImage? {
        get {
            return UIImage(
                named: "footer",
                in: Bundle.current(for: CourierBar.self),
                compatibleWith: nil
            )
            
        }
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
//        let logo = footerImage?.withRenderingMode(.alwaysTemplate).withTintColor(foregroundColor)
//        logoButton.setImage(logo, for: .normal)
        logoButton.tintColor = foregroundColor
        
    }

}
