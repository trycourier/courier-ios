//
//  CourierGraphQLQuery.swift
//  
//
//  Created by Michael Miller on 2/23/23.
//

import Foundation

internal struct CourierGraphQLQuery: Codable {
    var variables: String = "{}"
    var query: String
}
