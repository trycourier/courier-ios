//
//  SemanticProperty.swift
//  Courier_iOS
//
//  Created by Uldis Zingis on 12/05/2025.
//

import Foundation

struct SemanticProperty: Codable {
    let name: String
    let value: String
}

struct SemanticProperties: Codable {
    let properties: [SemanticProperty]

    func toJsonString() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let jsonData = try encoder.encode(self)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            print("Failed to encode SemanticProperties: \(error)")
            return nil
        }
    }
}
