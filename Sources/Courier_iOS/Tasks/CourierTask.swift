//
//  File.swift
//  
//
//  Created by https://github.com/mikemilla on 7/18/22.
//

import Foundation

class CourierTask {
    
    let session = URLSession.shared
    
    var task: URLSessionDataTask? = nil
    
    init(with request: URLRequest, validCodes: [Int] = [200], completionHandler: @escaping ([Int], Data?, URLResponse?, Error?, Int) -> Void) {
        
        // Append the user agent
        var req = request
        let userAgent = "\(Courier.agent.rawValue)/\(Courier.version)"
        req.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        task = session.dataTask(with: req) { (data, response, error) in
            
            // Print the request
            Courier.log("\n📡 New Courier API Request")
            Courier.log("URL: \(request.url?.absoluteString ?? "")")
            Courier.log("Method: \(request.httpMethod ?? "")")
            
            if let headers = request.allHTTPHeaderFields {
                Courier.log("Headers: \(String(describing: headers))")
            }
            
            if let body = request.httpBody {
                let json = body.toPreview()
                Courier.log("Body: \(json)")
            }
            
            if let response = response as? HTTPURLResponse {
                let code = response.statusCode
                Courier.log("Response Status: \(code)")
            }
            
            // Print the response
            if let data = data {
                let json = data.toPreview()
                Courier.log("Response JSON: \(json.isEmpty ? "Empty" : json)\n")
            }
            
            let status = (response as? HTTPURLResponse)?.statusCode ?? 420
            
            completionHandler(validCodes, data, response, error, status)
            
        }
        
    }
    
    func start() {
        task?.resume()
    }
    
}
