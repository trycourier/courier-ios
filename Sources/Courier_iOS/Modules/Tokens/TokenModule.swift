//
//  TokenModule.swift
//
//
//  Created by https://github.com/mikemilla on 7/23/24.
//

import UIKit

@CourierActor internal class TokenModule {
    
    let courier: Courier

    // Tokens outlive the process, so the one a provider replaces can still be removed from
    // Courier after a relaunch. Without this every rotated token stayed on the user.
    private let tokensKey = "courier_push_tokens"
    private let defaults = UserDefaults.standard

    init(courier: Courier) {
        self.courier = courier
        self.tokens = defaults.object(forKey: tokensKey) as? [String: String] ?? [:]
    }
    
    /**
     * The token issued by Apple on this device
     * Can only be set by the Courier SDK, but can be read by external packages
     */
    private(set) var apnsToken: Data? = nil
    
    func setApnsToken(_ token: Data?) {
        apnsToken = token
    }
    
    // Keep a reference to all tokens
    private(set) var tokens: [String: String] = [:] {
        didSet {
            defaults.set(tokens, forKey: tokensKey)
        }
    }

    /**
     The token Courier still holds for a provider that the new token replaces.
     Nil when there is none, or when the provider issued the same token again.
     */
    func replacedToken(for provider: String, with token: String) -> String? {
        guard let current = tokens[provider], current != token else { return nil }
        return current
    }

    /**
     Caches a token for a key
     This is used to grab current sessions push tokens
     */
    func cacheToken(key: String, value: String?) {
        
        // Ensure we have a key
        if (key.isEmpty) {
            return
        }
        
        // Check for token value
        guard let token = value else {
            tokens.removeValue(forKey: key)
            return
        }
        
        // Ensure token is not empty
        if (token.isEmpty) {
            return
        }
        
        // Cache the token
        tokens[key] = token
        
    }
    
    func dispose() {
        self.apnsToken = nil
        self.tokens = [:]
    }

    // MARK: Pending deletes

    private let pendingDeletesKey = "courier_pending_token_deletes"

    var pendingDeletes: [PendingTokenDelete] {
        get {
            guard case .found(let json) = UserManager.shared.secrets.read(pendingDeletesKey),
                  let deletes = try? JSONDecoder().decode([PendingTokenDelete].self, from: Data(json.utf8)) else {
                return []
            }
            return deletes
        }
        set {
            let secrets = UserManager.shared.secrets
            guard !newValue.isEmpty,
                  let data = try? JSONEncoder().encode(newValue),
                  let json = String(data: data, encoding: .utf8) else {
                secrets.delete(pendingDeletesKey)
                return
            }
            secrets.write(json, for: pendingDeletesKey)
        }
    }

    // Replaceable so unit tests can run without the network
    lazy var sendPendingDelete: @CourierActor (PendingTokenDelete) async throws -> Void = { delete in
        try await delete.client.tokens.deleteUserToken(token: delete.token)
    }

    private var retrying: Task<Void, Never>?

    func rememberFailedDelete(_ token: String, client: CourierClient?, error: Error) {
        guard PendingTokenDelete.isRetryable(error), let client, let jwt = client.options.jwt else {
            return
        }
        let delete = PendingTokenDelete(
            userId: client.options.userId,
            token: token,
            jwt: jwt,
            restUrl: client.options.apiUrls.rest,
            createdAt: Date()
        )
        pendingDeletes = pendingDeletes.filter { $0.token != token || $0.userId != delete.userId } + [delete]
    }

    // The server moves a token to whoever registers it, so a late delete for the previous user
    // could take it away from the next one. Called before a token is registered again.
    func forgetPendingDeletes(for tokens: [String]) {
        let deletes = pendingDeletes
        let kept = deletes.filter { !tokens.contains($0.token) }
        if kept.count != deletes.count {
            pendingDeletes = kept
        }
    }

    // Launch and sign-in can both ask at once; they share one pass
    func retryPendingDeletes() async {
        if let retrying {
            return await retrying.value
        }
        let task = Task { await sendPendingDeletes() }
        retrying = task
        await task.value
        retrying = nil
    }

    private func sendPendingDeletes() async {

        let deletes = pendingDeletes
        if deletes.isEmpty {
            return
        }

        var remaining: [PendingTokenDelete] = []
        for delete in deletes where !delete.isExpired {
            do {
                try await sendPendingDelete(delete)
            } catch let error where PendingTokenDelete.isRetryable(error) {
                remaining.append(delete)
            } catch {
                continue
            }
        }

        // Keep what was added or forgotten while these were in flight
        let current = pendingDeletes
        let added = current.filter { !deletes.contains($0) }
        pendingDeletes = remaining.filter { current.contains($0) } + added

    }
    
}

extension Courier {
    
    // MARK: Getters
    
    internal static var userNotificationCenter: UNUserNotificationCenter {
        get { UNUserNotificationCenter.current() }
    }
    
    /**
     * Permission authorization options needed to handle pushes nicely
     */
    internal static var permissionAuthorizationOptions: UNAuthorizationOptions {
        get {
            return [.alert, .badge, .sound]
        }
    }
    
}

@CourierActor extension Courier {
    
    // MARK: Tokens
    
    /// Returns the current APNS token
    public var apnsToken: Data? {
        get {
            return tokenModule.apnsToken
        }
    }
    
    /// Returns all cached tokens
    public var tokens: [String: String] {
        get {
            return tokenModule.tokens
        }
    }
    
    // MARK: Token Management
    
    internal func putToken(provider: String, token: String) async throws {
        
        if (!isUserSignedIn) {
            throw CourierError.userNotFound
        }
        
        try await client?.tokens.putUserToken(
            token: token,
            provider: provider
        )
        
    }
    
    internal func deleteToken(_ token: String) async throws {
        
        if (!isUserSignedIn) {
            throw CourierError.userNotFound
        }
        
        // Remove the token in Courier
        try await client?.tokens.deleteUserToken(
            token: token
        )
        
    }
    
    internal func putPushTokens() async {
        for (provider, token) in tokenModule.tokens {
            do {
                try await putToken(provider: provider, token: token)
            } catch {
                let e = CourierError(from: error)
                client?.log(e.message)
            }
        }
    }
    
    internal func deletePushTokens() async {
        for (_, token) in tokenModule.tokens {
            do {
                try await deleteToken(token)
            } catch {
                let e = CourierError(from: error)
                client?.log(e.message)
                tokenModule.rememberFailedDelete(token, client: client, error: error)
            }
        }
    }
    
    // MARK: APNS
    
    public func setAPNSToken(_ rawToken: Data) async throws {
        
        let provider = CourierPushProvider.apn.rawValue
        
        if !isUserSignedIn {
            tokenModule.setApnsToken(rawToken)
            tokenModule.cacheToken(key: provider, value: rawToken.string)
            return
        }
        
        // Delete the token this one replaces. An unchanged token is only put again, which keeps
        // it fresh without briefly removing it from Courier.
        if let replacedToken = tokenModule.replacedToken(for: provider, with: rawToken.string) {
            do {
                try await deleteToken(replacedToken)
            } catch {
                let e = CourierError(from: error)
                client?.log(e.message)
            }
        }
        
        // Save the local token
        tokenModule.setApnsToken(rawToken)
        tokenModule.cacheToken(key: provider, value: rawToken.string)

        return try await putToken(
            provider: provider,
            token: rawToken.string
        )
        
    }
    
    @objc public func setAPNSToken(rawToken: Data, completion: @escaping @MainActor (Error?) -> Void) async {
        do {
            try await setAPNSToken(rawToken)
            await MainActor.run {
                completion(nil)
            }
        } catch {
            client?.error(error.localizedDescription)
            await MainActor.run {
                completion(error)
            }
        }
    }
    
    @objc public static func setAPNSToken(_ rawToken: Data) {
        Task {
            do {
                try await Courier.shared.setAPNSToken(rawToken)
            } catch let error as NSError {
                Courier.shared.client?.log(error.localizedDescription)
            }
        }
    }
    
    // MARK: Any Token
    
    public func setToken(for provider: CourierPushProvider, token: String) async throws {
        try await setToken(
            for: provider.rawValue,
            token: token
        )
    }
    
    public func setToken(for provider: String, token: String) async throws {
        
        if !isUserSignedIn {
            tokenModule.cacheToken(key: provider, value: token)
            return
        }
        
        // Delete the token this one replaces. An unchanged token is only put again, which keeps
        // it fresh without briefly removing it from Courier.
        if let replacedToken = tokenModule.replacedToken(for: provider, with: token) {
            do {
                try await deleteToken(replacedToken)
            } catch {
                let e = CourierError(from: error)
                client?.log(e.message)
            }
        }
        
        // Save the token locally
        tokenModule.cacheToken(key: provider, value: token)
        
        // Update the token
        return try await putToken(
            provider: provider,
            token: token
        )
        
    }
    
    public func getToken(for provider: CourierPushProvider) async -> String? {
        return getToken(for: provider.rawValue)
    }
    
    public func getToken(for provider: String) -> String? {
        return tokenModule.tokens[provider]
    }
    
}
