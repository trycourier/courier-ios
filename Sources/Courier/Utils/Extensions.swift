//
//  File.swift
//  
//
//  Created by Michael Miller on 7/8/22.
//

import Foundation

extension Data {
    
    // Converts the object to a string
    var string: String {
       return map { String(format: "%02.2hhx", $0) }.joined()
    }
    
}

