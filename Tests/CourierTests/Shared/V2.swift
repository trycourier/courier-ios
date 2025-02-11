//
//  V2.swift
//  Courier_iOS
//
//  Created by Michael Miller on 2/11/25.
//

import XCTest
@testable import Courier_iOS

class V2: XCTestCase {
    
    func testAuth() async throws {
        
        try await Courier2.shared.signIn()
        
        print(Courier2.shared.currentUserId ?? "No user found")
        
        try await Courier2.shared.signOut()
        
    }
    
}
