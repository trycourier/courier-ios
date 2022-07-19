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
    
    init(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        task = session.dataTask(with: request) { (data, response, error) in
            completionHandler(data, response, error)
            self.onComplete?()
        }
    }
    
    func start() {
        task?.resume()
    }
    
}
