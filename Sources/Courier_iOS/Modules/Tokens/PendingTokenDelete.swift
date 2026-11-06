//
//  PendingTokenDelete.swift
//  Courier_iOS
//

import Foundation

// A push token delete that failed at sign-out, kept so it can be retried. Without this, signing
// out offline left the device's token on the signed-out user, who kept receiving its pushes.
// It holds the user's JWT, so it's only ever stored in the Keychain.
internal struct PendingTokenDelete: Codable, Equatable, Sendable {

    let userId: String
    let token: String
    let jwt: String
    let restUrl: String
    let createdAt: Date

    // Past this the JWT has almost certainly expired, so the delete can't succeed
    static let maxAge: TimeInterval = 30 * 24 * 60 * 60

    var isExpired: Bool {
        return Date().timeIntervalSince(createdAt) > PendingTokenDelete.maxAge
    }

    var client: CourierClient {
        return CourierClient(
            jwt: jwt,
            userId: userId,
            apiUrls: CourierClient.ApiUrls(rest: restUrl),
            showLogs: false
        )
    }

    // Worth trying again: the request never got an answer, or the server was busy or failing.
    // Any other response (an expired token, a token already gone) won't change on a retry.
    static func isRetryable(_ error: Error) -> Bool {
        if error is URLError {
            return true
        }
        let code = CourierError(from: error).code
        return code == 429 || (500..<600).contains(code)
    }

}
