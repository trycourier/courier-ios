//
//  CourierAuthenticationListener.swift
//
//
//  Created by https://github.com/mikemilla on 4/3/23.
//

import Foundation

// MARK: Public Classes

// The callback is always delivered on the main actor, and that is now part of its type.
public class CourierAuthenticationListener: NSObject, @unchecked Sendable {
    
    let onChange: @MainActor (String?) -> Void
    
    public init(onChange: @escaping @MainActor (String?) -> Void) {
        self.onChange = onChange
    }
    
}

// MARK: Extensions

extension CourierAuthenticationListener {
    
    @objc public func remove() {
        Task {
            await Courier.shared.removeAuthenticationListener(self)
        }
    }
    
}
