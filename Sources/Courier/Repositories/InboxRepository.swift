//
//  InboxRepository.swift
//  
//
//  Created by Michael Miller on 2/23/23.
//

import Foundation

struct GraphQLQuery: Codable {
    var variables: String = "{}"
    var query: String
}

internal class InboxRepository: Repository {
    
    internal func getMessages(url: String, clientKey: String, userId: String) async throws {
        
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<Void, Error>) in
            
            let query = """
            query GetMessages(
                $params: FilterParamsInput
                $limit: Int = 10
                $after: String
            ) {
                count(params: $params)
                messages(params: $params, limit: $limit, after: $after) {
                    totalCount
                    pageInfo {
                        startCursor
                        hasNextPage
                    }
                    nodes {
                        messageId
                        read
                        archived
                        created
                        tags
                        title
                        preview
                        actions {
                            content
                            href
                            style
                            background_color
                        }
                    }
                }
            }
            """

            let url = URL(string: url)!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue(clientKey, forHTTPHeaderField: "x-courier-client-key")
            request.addValue(userId, forHTTPHeaderField: "x-courier-user-id")
            
            let payload = GraphQLQuery(query: query)
            request.httpBody = try! JSONEncoder().encode(payload)
            
            let task = CourierTask(with: request) { (validCodes, data, response, error, status) in
                
                if (!validCodes.contains(status)) {
                    continuation.resume(throwing: CourierError.requestError)
                    return
                }
                
                continuation.resume()
                
            }
            
            task.start()
            
        })

    }
    
}
