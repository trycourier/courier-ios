//
//  CourierAuthenticationListener.swift
//
//
//  Created by https://github.com/mikemilla on 4/3/23.
//

import Foundation

// MARK: Public Classes

@objc public class CourierAuthenticationListener: NSObject {
    
    let onChange: (String?) -> Void
    
    public init(onChange: @escaping (String?) -> Void) {
        self.onChange = onChange
    }
    
}

// MARK: Extensions

extension CourierAuthenticationListener {
    
    @objc public func remove() {
        Courier.shared.coreAuth.removeAuthenticationListener(listener: self)
    }
    
}
