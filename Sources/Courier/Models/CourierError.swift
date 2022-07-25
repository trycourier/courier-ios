//
//  CourierError.swift
//  
//
//  Created by Michael Miller on 7/21/22.
//

import Foundation

enum CourierError: Error {
    case noAccessTokenFound
    case noUserIdFound
    case requestError
}
