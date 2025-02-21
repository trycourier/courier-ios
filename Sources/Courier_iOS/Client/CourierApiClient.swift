//
//  CourierApiClient.swift
//
//
//  Created by https://github.com/mikemilla on 7/22/24.
//

import Foundation

public class CourierApiClient {
    
    func http(_ url: String, _ configuration: (inout URLRequest) -> Void) throws -> URLRequest {
        
        guard let url = URL(string: url) else {
            throw NSError(domain: "Invalid URL", code: -1, userInfo: nil)
        }
        
        var request = URLRequest(url: url)
        
        configuration(&request)
        
        // Attach agent
        let userAgent = Courier.agent.value
        request.addHeader(key: "User-Agent", value: userAgent)
        
        // Always attach json content type
        request.addHeader(key: "Content-Type", value: "application/json")
        
        return request
        
    }
    
}

internal extension URLResponse {
    
    var code: Int {
        guard let httpResponse = self as? HTTPURLResponse else {
            return 420
        }
        return httpResponse.statusCode
    }
    
}

internal extension CourierClient.Options {
    
    func log(request: URLRequest) {
        
        if (!showLogs) {
            return
        }
        
        // Request
        var message = """
        📡 New Courier API Request
        URL: \(request.url?.absoluteString ?? "")
        Method: \(request.httpMethod ?? "")
        """
        
        // Headers
        if let headers = request.allHTTPHeaderFields {
            let preview = headers.toPreview()
            message += "\nHeaders: \(preview)"
        }
        
        // Body
        if let body = request.httpBody {
            let preview = body.toPreview()
            message += "\nBody: \(preview)"
        }
        
        log(message)
        
    }
    
    func log(response: (Data, URLResponse)) throws {
        
        if (!showLogs) {
            return
        }
        
        let (data, res) = response
        
        let code = res.code
        let body = data.toPreview()
        
        let message = """
        📡 New Courier API Response
        Status Code: \(code)
        Response JSON: \(body.isEmpty ? "Empty" : body)
        """
        
        log(message)
        
    }
    
}

internal extension URLRequest {
    
    @discardableResult
    func dispatch(_ options: CourierClient.Options, validCodes: [Int] = [200]) async throws -> Data {
        
        options.log(request: self)
        
        // Perform the request
        let res = try await URLSession.shared.data(for: self)
        
        try options.log(response: res)
        
        let (data, response) = res
        let code = response.code
        
        // Handle only valid codes
        if !validCodes.contains(code) {
            
            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            let message = json?["message"] as? String ?? "Unknown Error"
            let type = json?["type"] as? String
            
            throw CourierError(code: code, message: message, type: type)
            
        }
        
        return data
        
    }
    
    func dispatch<T: Decodable>(_ options: CourierClient.Options, validCodes: [Int] = [200]) async throws -> T {
        
        // Perform request
        let data = try await dispatch(options, validCodes: validCodes)
        
        // Decode the response
        return try JSONDecoder().decode(T.self, from: data)
        
    }
    
    mutating func addHeader(key: String, value: String) {
        addValue(value, forHTTPHeaderField: key)
    }
    
}

internal extension String {
    
    func toRequestBody() -> Data? {
        return data(using: .utf8)
    }
    
    func toGraphQuery(_ variables: String = "{}") throws -> Data? {
        let query = CourierGraphQLQuery(query: self, variables: variables)
        return try JSONEncoder().encode(query)
    }
    
}
