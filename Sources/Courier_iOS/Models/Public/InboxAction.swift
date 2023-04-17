//
//  InboxAction.swift
//  
//
//  Created by https://github.com/mikemilla on 3/16/23.
//

import Foundation

@objc public class InboxAction: NSObject, Codable {
    
    // MARK: Properties
    
    @objc public let content: String?
    @objc public let href: String?
    @objc public let style: String?
    @objc public let backgroundColor: String?

    private var jsonData: String?
    
    @objc public var data: [String: Any]? {
        get {
            
            if let data = jsonData?.data(using: .utf8) {
                do {
                    if let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        return dictionary
                    }
                } catch {
                    print("Error converting JSON string to dictionary: \(error.localizedDescription)")
                }
            }
            
            return nil
            
        }
    }
    
    public init(content: String?, href: String?, style: String?, backgroundColor: String?, data: [String: Any]?) {
        
        self.content = content
        self.href = href
        self.style = style
        self.backgroundColor = backgroundColor
        
        // Get JSON string from data
        if let data = data {
            do {
                let json = try JSONSerialization.data(withJSONObject: data, options: [])
                self.jsonData = String(data: json, encoding: .utf8)
            } catch {
                print("Error converting dictionary to string: \(error.localizedDescription)")
            }
        }
        
    }
    
    enum CodingKeys: String, CodingKey {
        case content
        case href
        case style
        case backgroundColor = "background_color"
        case data
    }
    
}
