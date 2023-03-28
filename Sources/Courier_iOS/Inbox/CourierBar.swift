//
//  Courierbar.swift
//  
//
//  Created by https://github.com/mikemilla on 3/13/23.
//

import UIKit

@available(iOSApplicationExtension, unavailable)
internal class CourierBar: UIView {
    
    internal static let height: CGFloat = 48
    
    private let border = UIView()
    private let logoContainer = UIView()
    private let logoButton = UIButton(type: .custom)
    
    internal var bottomConstraint: NSLayoutConstraint? = nil

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
        
        [border, logoContainer, logoButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        subviews.forEach {
            $0.removeFromSuperview()
        }
        
        addSubview(logoContainer)
        
        logoContainer.backgroundColor = .green
        
        bottomConstraint = logoContainer.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: 0)

        NSLayoutConstraint.activate([
            logoContainer.topAnchor.constraint(equalTo: topAnchor),
            bottomConstraint!,
            logoContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            logoContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            logoContainer.heightAnchor.constraint(equalToConstant: CourierBar.height),
        ])
        
        // Logo
        
        logoButton.contentMode = .scaleAspectFit
        logoButton.translatesAutoresizingMaskIntoConstraints = false
        logoButton.addTarget(self, action: #selector(showLaunchSheet), for: .touchUpInside)
        
        logoContainer.addSubview(logoButton)
        
        NSLayoutConstraint.activate([
            logoButton.centerXAnchor.constraint(equalTo: logoContainer.centerXAnchor),
            logoButton.centerYAnchor.constraint(equalTo: logoContainer.centerYAnchor),
            logoButton.heightAnchor.constraint(equalToConstant: 40),
            logoButton.widthAnchor.constraint(equalToConstant: 134),
        ])
        
        // Border
        
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
    
    internal func setColors(with color: UIColor?) {
        
        let superViewBackground = color ?? .systemBackground
        
        // Set background color
        backgroundColor = superViewBackground
        
        // Set foreground color
        let foregroundColor = superViewBackground.luminance() < 0.5 ? CourierInboxTheme.darkBrandColor : CourierInboxTheme.lightBrandColor
        let logo = footerImage?.withRenderingMode(.alwaysTemplate).withTintColor(foregroundColor)
        logoButton.setImage(logo, for: .normal)
        logoButton.tintColor = foregroundColor
        
    }

}
