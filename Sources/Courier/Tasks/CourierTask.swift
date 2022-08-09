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
    
    init(with request: URLRequest, validCodes: [Int] = [200], completionHandler: @escaping ([Int], Data?, URLResponse?, Error?, Int) -> Void) {
        
        task = session.dataTask(with: request) { (data, response, error) in
            
            do {
             
                Courier.log("📡 New Courier API Request")
                Courier.log("URL: \(request.url?.absoluteString ?? "")")
                Courier.log("Method: \(request.httpMethod ?? "")")
                
                if let body = request.httpBody, let json = String(data: body, encoding: .utf8) {
                    if (!json.isEmpty) {
                        Courier.log("Body: \(json)")
                    }
                }
                
                if let response = response as? HTTPURLResponse {
                    let code = response.statusCode
                    Courier.log("Status: \(code)")
                }
                
                if let data = data, let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                    if (!json.isEmpty) {
                        Courier.log("Response: \(String(describing: json))")
                    } else {
                        Courier.log("Response: Empty")
                    }
                }
                
            } catch {
                
                Courier.log(String(describing: error))
                
            }
            
            let status = (response as? HTTPURLResponse)?.statusCode ?? 420
            
            completionHandler(validCodes, data, response, error, status)
            
        }
        
    }
    
    func start() {
        task?.resume()
    }
    
}
