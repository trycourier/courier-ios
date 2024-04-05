//
//  CourierStyles.swift
//
//
//  Created by https://github.com/mikemilla on 3/5/24.
//

import UIKit

public enum CourierStyles {
    
    // MARK: Inbox
    
    public enum Inbox {
     
        public class TextStyle: NSObject {
            
            internal let unread: CourierStyles.Font
            internal let read: CourierStyles.Font
            
            public init(unread: CourierStyles.Font, read: CourierStyles.Font) {
                self.unread = unread
                self.read = read
            }
            
        }
        
        public class ButtonStyle: NSObject {
            
            internal let unread: CourierStyles.Button
            internal let read: CourierStyles.Button
            
            public init(
                unread: CourierStyles.Button = CourierStyles.Button(
                    font: CourierStyles.Font(font: UIFont.systemFont(ofSize: UIFont.labelFontSize), color: .white)
                ),
                read: CourierStyles.Button = CourierStyles.Button(
                    font:  CourierStyles.Font(font: UIFont.systemFont(ofSize: UIFont.labelFontSize), color: .white)
                )
            ) {
                self.unread = unread
                self.read = read
            }
            
        }
        
        // MARK: Indicator
        
        public enum UnreadIndicator {
            case line
            case dot
        }

        public class UnreadIndicatorStyle: NSObject {
            
            internal let indicator: UnreadIndicator
            internal let color: UIColor?
            
            public init(indicator: UnreadIndicator = .line, color: UIColor? = nil) {
                self.indicator = indicator
                self.color = color
            }
            
        }
        
    }
    
    // MARK: Preferences
    
    public enum Preferences {
        
        public class SettingStyles: NSObject {
            
            internal let font: CourierStyles.Font?
            internal let toggleColor: UIColor?
            
            public init(font: CourierStyles.Font? = nil, toggleColor: UIColor? = nil) {
                self.font = font
                self.toggleColor = toggleColor
            }
            
        }
        
    }
    
    // MARK: InfoView
    
    public class InfoViewStyle: NSObject {
        
        internal let font: CourierStyles.Font
        internal let button: CourierStyles.Button
        
        public init(font: CourierStyles.Font, button: CourierStyles.Button) {
            self.font = font
            self.button = button
        }
        
    }
    
    // MARK: Cell
    
    public class Cell: NSObject {
        
        internal let separatorStyle: UITableViewCell.SeparatorStyle
        internal let separatorInsets: UIEdgeInsets
        internal let separatorColor: UIColor?
        internal let selectionStyle: UITableViewCell.SelectionStyle
        
        public init(separatorStyle: UITableViewCell.SeparatorStyle = .singleLine, separatorInsets: UIEdgeInsets = .init(top: 0, left: 16, bottom: 0, right: 0), separatorColor: UIColor? = nil, selectionStyle: UITableViewCell.SelectionStyle = .default) {
            self.separatorStyle = separatorStyle
            self.separatorInsets = separatorInsets
            self.separatorColor = separatorColor
            self.selectionStyle = selectionStyle
        }
        
    }
    
    // MARK: Button
    
    public class Button: NSObject {
        
        internal let font: CourierStyles.Font
        internal let backgroundColor: UIColor?
        internal let cornerRadius: CGFloat
        
        public init(font: CourierStyles.Font, backgroundColor: UIColor? = nil, cornerRadius: CGFloat = 8) {
            
            self.font = font
            self.backgroundColor = backgroundColor
            
            // This is the value of the container height / 2
            // This will create a perfect rounded corner
            let fullRoundedCorner = Theme.Inbox.actionButtonMaxHeight / 2
            
            self.cornerRadius = max(0, min(fullRoundedCorner, cornerRadius))
            
        }
        
    }
    
    // MARK: Font
    
    public class Font: NSObject {
        
        internal let font: UIFont
        internal let color: UIColor
        
        public init(font: UIFont, color: UIColor) {
            self.font = font
            self.color = color
        }
        
    }
    
}
