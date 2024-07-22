//
//  CourierApiClient.swift
//
//
//  Created by Michael Miller on 7/22/24.
//

import Foundation

class CourierApiClient {
    
    internal static let BASE_REST = "https://api.courier.com"
    internal static let BASE_GRAPH_QL = "https://api.courier.com/client/q"
    internal static let inboxGraphQL = "https://fxw3r7gdm9.execute-api.us-east-1.amazonaws.com/production/q"
    internal static let inboxWebSocket = "wss://1x60p1o3h8.execute-api.us-east-1.amazonaws.com/production"
    
    internal func http(url: String) throws -> URLRequest {
        
        guard let url = URL(string: url) else {
            throw NSError(domain: "Invalid URL", code: -1, userInfo: nil)
        }
        
        return URLRequest(url: url)
        
    }
    
}

extension CourierClient.Options {
    
    internal func log(request: URLRequest) {
        
        // Request
        var message = """
        📡 New Courier API Request
        URL: \(request.url?.absoluteString ?? "")
        Method: \(request.httpMethod ?? "")
        """
        
        // Headers
        if let headers = request.allHTTPHeaderFields {
            message += "\nHeaders: \(String(describing: headers))"
        }
        
        // Body
        if let body = request.httpBody {
            let json = body.toPreview()
            message += "\nBody: \(json)"
        }
        
        log(message)
        
    }
    
    internal func log(response: (Data, URLResponse)) throws {
        
        guard let httpResponse = response.1 as? HTTPURLResponse else {
            throw NSError(domain: "Invalid response", code: -1, userInfo: nil)
        }

        let code = httpResponse.statusCode
        let responseBody = response.0.toPreview()
        
        let message = """
        📡 New Courier API Response
        Status Code: \(code)
        Response JSON: \(responseBody.isEmpty ? "Empty" : responseBody)
        """
        
        log(message)
        
    }
    
}

extension URLRequest {
    
    internal func dispatch<T: Decodable>(_ options: CourierClient.Options) async throws -> T {
        options.log(request: self)
        let res = try await URLSession.shared.data(for: self)
        try options.log(response: res)
        return try JSONDecoder().decode(T.self, from: res.0)
    }
    
    internal mutating func addHeader(key: String, value: String) {
        addValue(value, forHTTPHeaderField: key)
    }
    
}

extension String {
    
    internal func toRequestBody() -> Data? {
        return data(using: .utf8)
    }
    
    internal func toGraphQuery() throws -> Data? {
        let query = CourierGraphQLQuery(query: self)
        return try JSONEncoder().encode(query)
    }
    
}
