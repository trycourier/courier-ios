//
//  Utils.swift
//  
//
//  Created by https://github.com/mikemilla on 3/2/23.
//

import Foundation

internal class Utils {
    
    static internal func runOnMainThread(run: @escaping () -> Void) {
        DispatchQueue.main.async {
            run()
        }
    }
    
}
