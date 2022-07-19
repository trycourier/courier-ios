//
//  Repository.swift
//  Messaging
//
//  Created by Michael Miller on 7/7/22.
//

import Foundation

class Repository {
    
    var baseUrl: String {
        get { "https://api.courier.com" }
    }
    
    var session: URLSession {
        get { URLSession.shared }
    }
    
}
