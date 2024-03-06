//
//  Theme.swift
//
//
//  Created by https://github.com/mikemilla on 3/4/24.
//

import UIKit

public enum Theme {
    
    public static let margin: CGFloat = 16.0
    
    public enum Bar {
        static let barHeight: CGFloat = 48.0
    }
    
    public enum Inbox {
        static let loadingIndicatorBottom: CGFloat = 24.0
        static let indicatorDotSize: CGFloat = 12.0
        static let lightBrandColor: UIColor = UIColor("73819B") ?? .black
        static let darkBrandColor: UIColor = .white
        static let actionButtonMaxHeight: CGFloat = 34.33
    }
    
    public enum Preferences {
        static let settingsCellHeight: CGFloat = 64.0
        static let sheetNavBarHeight: CGFloat = 56.0
        public static let sheetCornerRadius: CGFloat = 16.0
    }
    
}
