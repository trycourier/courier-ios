//
//  File.swift
//  
//
//  Created by Fahad Amin on 23/11/22.
//

import Foundation

internal struct ProfilePatchPayload: Codable {
    let value: String
    let op: String
    let path: String
}

internal struct CourierProfile: Codable {
    let patch: [ProfilePatchPayload]
    
    init(userId: String){
        let patchPayload = ProfilePatchPayload(
            value: userId,
            op: "replace",
            path: "/user_id"
        )
        self.patch = [patchPayload]
    }
}

internal struct ProfilePatchResponse: Codable {
    let status: String
}
