//
//  InboxRepository.swift
//  
//
//  Created by Michael Miller on 2/23/23.
//

import Foundation

internal class InboxRepository: Repository {
    
    internal func getMessages(clientKey: String, userId: String) async throws -> [InboxMessage] {
        
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<[InboxMessage], Error>) in
            
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

            let url = URL(string: inboxUrl)!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(clientKey, forHTTPHeaderField: "x-courier-client-key")
            request.addValue(userId, forHTTPHeaderField: "x-courier-user-id")
            
            let payload = CourierGraphQLQuery(query: query)
            request.httpBody = try! JSONEncoder().encode(payload)
            
            let task = CourierTask(with: request) { (validCodes, data, response, error, status) in
                
                if (!validCodes.contains(status)) {
                    continuation.resume(throwing: CourierError.requestError)
                    return
                }
                
                do {
                    let res = try JSONDecoder().decode(InboxResponse.self, from: data ?? Data())
                    continuation.resume(returning: res.data.messages.nodes)
                } catch {
                    Courier.log(String(describing: error))
                    continuation.resume(throwing: CourierError.requestError)
                }
                
            }
            
            task.start()
            
        })

    }
    
}
