//
//  File.swift
//  
//
//  Created by Michael Miller on 7/18/22.
//

import Foundation

class CourierTask {
    
    let session = URLSession.shared
    
    var task: URLSessionDataTask? = nil
    
    init(with request: URLRequest, validCodes: [Int] = [200], completionHandler: @escaping ([Int], Data?, URLResponse?, Error?) -> Void) {
        
        task = session.dataTask(with: request) { (data, response, error) in
            
            debugPrint("📡 New Courier API Request")
            debugPrint("URL: \(request.url?.absoluteString ?? "")")
            debugPrint("Method: \(request.httpMethod ?? "")")
            
            if let body = request.httpBody, let json = String(data: body, encoding: .utf8) {
                debugPrint("Body: \(json)")
            }
            
            let status = (response as! HTTPURLResponse).statusCode
            debugPrint("Status: \(status)")
            
            do {
                let json = try JSONSerialization.jsonObject(with: data ?? Data(), options: []) as? [String : Any]
                debugPrint("JSON: \(String(describing: json))")
            } catch {
                // Empty
            }
            
            completionHandler(validCodes, data, response, error)
            
        }
        
    }
    
    func start() {
        task?.resume()
    }
    
}
