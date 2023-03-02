//
//  Helpers.swift
//  
//
//  Created by Michael Miller on 3/2/23.
//

import Foundation

internal class Helpers {
    
    static internal func runOnMainThread(run: @escaping () -> Void) {
        DispatchQueue.main.async {
            run()
        }
    }
    
}
