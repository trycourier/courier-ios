//
//  AccessTokenGenerator.swift
//  Courier
//
//  Created by https://github.com/mikemilla on 7/25/22.
//

import Foundation

class ExampleServer {

    private struct Response: Codable {
        let token: String
    }
    
    static func generateJwt(authKey: String, userId: String) async throws -> String {
        
        let url = URL(string: "https://api.courier.com/auth/issue-token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(authKey)", forHTTPHeaderField: "Authorization")
        
        request.httpBody = try JSONEncoder().encode([
            "scope": "user_id:\(userId) write:user-tokens inbox:read:messages inbox:write:events read:preferences write:preferences read:brands",
            "expires_in": "2 days"
        ])
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let res = try JSONDecoder().decode(Response.self, from: data)
        
        return res.token
        
    }
    
    @discardableResult static func sendTest(authKey: String, userId: String, tenantId: String? = nil, channel: String) async throws -> String {
        
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<String, Error>) in
            
            let url = URL(string: "https://api.courier.com/send")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(authKey)", forHTTPHeaderField: "Authorization")
            
            let toField: [String: Any] = {
                if let tenantId = tenantId {
                    return ["tenant_id": tenantId]
                } else {
                    return ["user_id": userId]
                }
            }()
            
            request.httpBody = [
                "message": [
                    "to": toField,
                    "content": [
                        "title": "Test",
                        "body": "Body"
                    ],
                    "routing": [
                        "method": "all",
                        "channels": [channel]
                    ],
                    "data": [
                        "real_name": "Anakin Skywalker",
                        "nickname": "Darth Vader",
                        "category": "villain",
                        "children": [
                            [
                                "id": "asdf",
                                "name": "Dave",
                                "children": [
                                    [
                                        "id": "asdf",
                                        "name": "Tina"
                                    ],
                                    [
                                        "id": "asdf",
                                        "name": "Tiffany"
                                    ]
                                ]
                            ],
                            [
                                "id": "asdf",
                                "name": "Leia",
                                "optional": false,
                            ],
                            [
                                "id": 1,
                                "name": "Chuck",
                                "optional": false,
                            ],
                        ]
                    ]
                ]
            ].toJson()
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                let json = try? JSONSerialization.jsonObject(with: data ?? Data(), options: []) as? [String: Any]
                let requestId = json?["requestId"] as? String ?? "Error"
                continuation.resume(returning: requestId)
            }
            
            task.resume()
            
        })
        
    }
    
    static func sendTemplateTest(authKey: String, userId: String, templateId: String) async throws -> String {
        
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<String, Error>) in
            
            let url = URL(string: "https://api.courier.com/send")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(authKey)", forHTTPHeaderField: "Authorization")
            
            request.httpBody = [
                "message": [
                    "to": [
                        "user_id": userId
                    ],
                    "template": templateId,
                    "data": [
                        "real_name": "Anakin Skywalker",
                        "nickname": "Darth Vader",
                        "category": "villain",
                        "children": [
                            [
                                "id": "asdf",
                                "name": "Dave",
                                "children": [
                                    [
                                        "id": "asdf",
                                        "name": "Tina"
                                    ],
                                    [
                                        "id": "asdf",
                                        "name": "Tiffany"
                                    ]
                                ]
                            ],
                            [
                                "id": "asdf",
                                "name": "Leia",
                                "optional": false,
                            ],
                            [
                                "id": 1,
                                "name": "Chuck",
                                "optional": false,
                            ],
                        ]
                    ]
                ]
            ].toJson()
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                let json = try? JSONSerialization.jsonObject(with: data ?? Data(), options: []) as? [String: Any]
                let requestId = json?["requestId"] as? String ?? "Error"
                continuation.resume(returning: requestId)
            }
            
            task.resume()

        })

    }

    // MARK: - Read-back

    /// A push token as the Courier API has stored it.
    ///
    /// The SDK has no read path for tokens, so tests that want to prove a write actually landed
    /// have to ask the API directly. Without this, `putUserToken` tests only assert "did not
    /// throw", which passes just as happily when nothing was persisted.
    struct StoredToken: Codable {

        let token: String
        let providerKey: String
        let device: StoredDevice?

        enum CodingKeys: String, CodingKey {
            case token
            case providerKey = "provider_key"
            case device
        }

    }

    struct StoredDevice: Codable {

        let appId: String?
        let adId: String?
        let deviceId: String?
        let platform: String?
        let manufacturer: String?
        let model: String?

        enum CodingKeys: String, CodingKey {
            case appId = "app_id"
            case adId = "ad_id"
            case deviceId = "device_id"
            case platform, manufacturer, model
        }

    }

    private struct TokenListResponse: Codable {
        let tokens: [StoredToken]
    }

    static func getUserTokens(authKey: String, userId: String) async throws -> [StoredToken] {

        let encodedUserId = userId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? userId
        let url = URL(string: "https://api.courier.com/users/\(encodedUserId)/tokens")!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(authKey)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(TokenListResponse.self, from: data).tokens

    }

}

extension Dictionary {
    
    func toJson() -> Data? {
        do {
            return try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
}
