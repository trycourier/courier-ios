//
//  ClientBuilder.swift
//
//
//  Created by Michael Miller on 7/22/24.
//

import Courier_iOS

class ClientBuilder {
    
    static func build(useJWT: Bool = true, connectionId: String? = nil, tenantId: String? = nil) async throws -> CourierClient {
        
        var jwt: String? = nil

        if (useJWT) {
            jwt = try await ExampleServer.generateJwt(
                authKey: Env.COURIER_AUTH_KEY,
                userId: Env.COURIER_USER_ID
            )
        }

        return CourierClient(
            jwt: jwt,
            clientKey: Env.COURIER_CLIENT_KEY,
            userId: Env.COURIER_USER_ID,
            connectionId: connectionId,
            tenantId: tenantId,
            showLogs: true
        )
        
    }
    
}
