//
//  CourierAuthenticationListener.swift
//
//
//  Created by https://github.com/mikemilla on 4/3/23.
//

import Foundation

// MARK: Public Classes

public class CourierAuthenticationListener: NSObject {
    
    let onChange: (String?) -> Void
    
    public init(onChange: @escaping (String?) -> Void) {
        self.onChange = onChange
    }
    
}

// MARK: Extensions

extension CourierAuthenticationListener {
    
    // Unregisters a listener on a background task
    @objc public func remove() {
        Task {
            await Courier.shared.removeAuthenticationListener(self)
        }
    }
    
}
