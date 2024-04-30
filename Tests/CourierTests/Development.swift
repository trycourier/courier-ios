//
//  File.swift
//  
//
//  Created by Michael Miller on 12/21/23.
//

import XCTest
@testable import Courier_iOS

final class Development: XCTestCase {
    
    let rawApnsToken = Data([110, 157, 218, 189])
    
    func testTokenSync() async throws {
        
        print("\n🔬 Testing Concurrency")
        
        try await Courier.shared.signOut()
        
        try await Courier.shared.signIn(
            accessToken: Env.COURIER_AUTH_KEY,
            clientKey: Env.COURIER_CLIENT_KEY,
            userId: "example_1"
        )
        
        let token = try await spamTokens()
        
        print(token)

    }
    
    func spamTokens() async throws -> String {
        
        return try await withThrowingTaskGroup(of: String.self) { group in
            
            for _ in 1...100 {
                group.addTask { [self] in
                    try await Courier.shared.setAPNSToken(rawApnsToken)
                    return ""
                }
            }

            try await group.waitForAll()
            print("All tasks have completed")
            
            return (await Courier.shared.getAPNSToken())?.string ?? "Missing"
            
        }
        
    }
    
    func testInboxListener() async throws {
        
        print("\n🔬 Testing Inbox Listener")
        
        var hold1 = true
        var hold2 = true
        var hold3 = true
        
        Courier.shared.isDebugging = false
        
        try await Courier.shared.signOut()
        
        print(Courier.shared.isUserSignedIn)
        
        let listener1 = Courier.shared.addInboxListener(
            onInitialLoad: {
                print("Loading 1")
            },
            onError: { error in
                print("Error 1")
                print(error)
            },
            onMessagesChanged: { messages, unreadMessageCount, totalMessageCount, canPaginate in
                print("Messages 1")
                print(messages.count)
                hold1 = false
            }
        )
        
        try await Courier.shared.signOut()
        
        let userId = "asdf"
        
        try await Courier.shared.signIn(
            accessToken: Env.COURIER_AUTH_KEY,
            clientKey: Env.COURIER_CLIENT_KEY,
            userId: userId
        )
        
        let listener2 = Courier.shared.addInboxListener(
            onInitialLoad: {
                print("Loading 2")
            },
            onError: { error in
                print("Error 2")
                print(error)
            },
            onMessagesChanged: { messages, unreadMessageCount, totalMessageCount, canPaginate in
                
                print("Messages 2")
                print(messages.count)
                hold2 = false
                
                // Trigger a refresh
                Courier.shared.refreshInbox {
                    hold3 = false
                }
                
            }
        )
        
        while (hold1 || hold2 || hold3) {
            // Empty
        }
        
        listener1.remove()
        listener2.remove()

    }
    
    func spamMessages(userId: String) async throws -> String {
        
        return try await withThrowingTaskGroup(of: String.self) { group in
            
            for _ in 1...100 {
                group.addTask {
                    let messageId = try await ExampleServer().sendTest(authKey: Env.COURIER_AUTH_KEY, userId: userId, key: "inbox")
                    print(messageId)
                    return messageId
                }
            }

            try await group.waitForAll()
            print("All tasks have completed")
            
            return "Missing"
            
        }
        
    }
    
    func testUrlEncoding() async throws {
            
        let providerKey = "expo"
        let deviceId = "0FDA6273-B7B2-42A4-9B2E-C458B80E41AD"
        let parameters = """
            {
                "provider_key": "\(providerKey)",
                "device": {
                    "device_id": "\(deviceId)"
                }
            }
        """
        
        let token = "NEW_EXPO[\(UUID().uuidString)]"
        
        var url: URL
        
        // Check if the device is running iOS 16 or below
        if #available(iOS 17, *) {
            // For iOS 17 and up, use the original URL without manual encoding
            url = URL(string: "https://api.courier.com/users/mike@courier.com/tokens/\(token)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        } else {
            // For iOS 16 and below, manually encode the URL parameters
            url = URL(string: "https://api.courier.com/users/mike@courier.com/tokens/\(token)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        }
        
        let postData = parameters.data(using: .utf8)
        
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        request.addValue("Bearer \(Env.COURIER_AUTH_KEY)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = "PUT"
        request.httpBody = postData
        
        print(request.url ?? "")
        print(request.allHTTPHeaderFields ?? [:])
        print(request.httpMethod ?? "")
        
        let (data, response) = try await URLSession.shared.data(for: request)
            
        guard let httpResponse = response as? HTTPURLResponse else {
            print("Invalid HTTP response")
            return
        }
        
        print("Response code: \(httpResponse.statusCode)")
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Response data: \(jsonString)")
        } else {
            print("Failed to decode response data.")
        }
        
    }

    
}
