//
//  UserBuilder.swift
//
//
//  Created by https://github.com/mikemilla on 7/25/24.
//

import Courier_iOS

class UserBuilder {
    
    static func authenticate(useJWT: Bool = true, userId: String = Env.COURIER_USER_ID, connectionId: String? = nil, tenantId: String? = nil) async throws {
        
        Courier.shared.removeAllAuthenticationListeners()
        
        let listener = Courier.shared.addAuthenticationListener { uid in
            print(uid ?? "No userId found")
        }
        
        await Courier.shared.signOut()
        
        var jwt: String? = nil

        if (useJWT) {
            jwt = try await ExampleServer.generateJwt(
                authKey: Env.COURIER_AUTH_KEY,
                userId: userId
            )
        }
        
        let accessToken = jwt ?? Env.COURIER_AUTH_KEY
        
        await Courier.shared.signIn(
            userId: userId, 
            tenantId: tenantId, 
            accessToken: accessToken,
            clientKey: Env.COURIER_CLIENT_KEY
        )
        
        // Remove the listener
        listener.remove()
        
    }
    
}
