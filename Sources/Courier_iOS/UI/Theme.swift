//
//  Theme.swift
//
//
//  Created by https://github.com/mikemilla on 3/4/24.
//

import UIKit

internal enum Theme {
    
    static let margin: CGFloat = 16.0
    
    enum Bar {
        static let barHeight: CGFloat = 48.0
    }
    
    enum Inbox {
        static let loadingIndicatorBottom: CGFloat = 24.0
        static let indicatorDotSize: CGFloat = 16.0
        static let lightBrandColor: UIColor = UIColor("73819B") ?? .black
        static let darkBrandColor: UIColor = .white
        static let actionButtonMaxHeight: CGFloat = 34.33
    }
    
    enum Preferences {
        static let settingsCellHeight: CGFloat = 64.0
        static let sheetNavBarHeight: CGFloat = 56.0
        static let sheetCornerRadius: CGFloat = 16.0
    }
    
}
