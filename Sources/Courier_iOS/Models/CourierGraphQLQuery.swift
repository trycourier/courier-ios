//
//  CourierGraphQLQuery.swift
//  
//
//  Created by https://github.com/mikemilla on 2/23/23.
//

import Foundation

// MARK: Internal Classes

internal struct CourierGraphQLQuery: Codable {
    var variables: String = "{}"
    var query: String
}
