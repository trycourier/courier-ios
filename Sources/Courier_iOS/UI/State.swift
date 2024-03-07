//
//  State.swift
//
//
//  Created by https://github.com/mikemilla on 3/7/24.
//

import Foundation

internal enum State {
    
    case loading
    case error(_ error: Error)
    case content
    case empty
    
    func error() -> Error? {
        switch self {
        case .error(let value):
            return value
        default:
            return nil
        }
    }
    
}
