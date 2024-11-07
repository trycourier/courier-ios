//
//  CodableValue.swift
//
//
//  Created by Michael Miller on 8/23/24.
//

import Foundation

struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else if let nestedDict = try? container.decode([String: AnyCodable].self) {
            value = nestedDict.mapValues { $0.value }
        } else if let arrayValue = try? container.decode([AnyCodable].self) {
            value = arrayValue.map { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported type")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case let stringValue as String:
            try container.encode(stringValue)
        case let intValue as Int:
            try container.encode(intValue)
        case let doubleValue as Double:
            try container.encode(doubleValue)
        case let boolValue as Bool:
            try container.encode(boolValue)
        case let dictValue as [String: Any]:
            let encodableDict = dictValue.mapValues { AnyCodable($0) }
            try container.encode(encodableDict)
        case let arrayValue as [Any]:
            let encodableArray = arrayValue.map { AnyCodable($0) }
            try container.encode(encodableArray)
        default:
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Unsupported type"))
        }
    }
}
