//
//  Courierbar.swift
//  
//
//  Created by https://github.com/mikemilla on 3/13/23.
//

import UIKit

internal class CourierBar: UIView {
    
    private let border = UIView()
    private let logo = UIImageView()

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
        
        logo.image = UIImage.wordmark!.withRenderingMode(.alwaysTemplate)
        logo.contentMode = .scaleAspectFit
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.backgroundColor = .green
        
        addSubview(logo)
        
        NSLayoutConstraint.activate([
            logo.centerXAnchor.constraint(equalTo: centerXAnchor),
            logo.centerYAnchor.constraint(equalTo: centerYAnchor),
            logo.heightAnchor.constraint(equalToConstant: 16),
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
    
    internal func setTheme(_ theme: CourierInboxTheme) {
        
        border.backgroundColor = theme.cellStyles.separatorColor ?? .separator
        isHidden = theme.brand?.settings?.inapp?.showCourierFooter ?? false
        
    }
    
    internal func setColors(with color: UIColor) {
        
        // Set background color
        backgroundColor = color
        
        let lumen = color.luminance()
        print(lumen)
        
        // Set foreground color
        logo.tintColor = lumen > 0.5 ? .white : .black
        
    }

}
