//
//  File.swift
//  
//
//  Created by Michael Miller on 7/18/22.
//

import Foundation

class CourierTask {
    
    let session = URLSession.shared
    
    var onComplete: (() -> Void)? = nil
    var task: URLSessionDataTask? = nil
    
    init(with request: URLRequest, validCodes: [Int] = [200], completionHandler: @escaping ([Int], Data?, URLResponse?, Error?) -> Void) {
        
        debugPrint("📡 New Request")
        debugPrint("URL: \(request.url?.absoluteString ?? "")")
        debugPrint("Method: \(request.httpMethod ?? "")")
        
        if let json = String(data: request.httpBody ?? Data(), encoding: .utf8) {
            debugPrint("Body: \(json)")
        }
        
        task = session.dataTask(with: request) { (data, response, error) in
            
            // Display status
            let status = (response as! HTTPURLResponse).statusCode
            debugPrint("Status: \(status)")
            
            do {
                let json = try JSONSerialization.jsonObject(with: data ?? Data(), options: []) as? [String : Any]
                debugPrint("JSON: \(String(describing: json))")
            } catch {
                debugPrint(error)
            }
            
            // Handle completion
            completionHandler(validCodes, data, response, error)
            
            self.onComplete?()
            
        }
        
    }
    
    func start() {
        task?.resume()
    }
    
}
