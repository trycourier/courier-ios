//
//  State.swift
//
//
//  Created by https://github.com/mikemilla on 3/7/24.
//

import Foundation

internal enum State {
    case loading
    case error(_ message: String)
    case content
    case empty
}
