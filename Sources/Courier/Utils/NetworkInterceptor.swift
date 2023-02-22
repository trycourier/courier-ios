//
//  NetworkInterceptor.swift
//  
//
//  Created by Michael Miller on 2/22/23.
//

import Apollo
import ApolloAPI

class CustomInterceptor: ApolloInterceptor {
    
    func interceptAsync<Operation: GraphQLOperation>(chain: RequestChain, request: HTTPRequest<Operation>, response: HTTPResponse<Operation>?, completion: @escaping (Swift.Result<GraphQLResult<Operation.Data>, Error>) -> Void) {
        request.addHeader(name: "Authorization", value: "Bearer <<TOKEN>>")
        print("request :\(request)")
        print("response :\(String(describing: response))")
        chain.proceedAsync(request: request, response: response, completion: completion)
    }
    
}

class NetworkInterceptorProvider: DefaultInterceptorProvider {
    
    override func interceptors<Operation>(for operation: Operation) -> [ApolloInterceptor] where Operation : GraphQLOperation {
        var interceptors = super.interceptors(for: operation)
        interceptors.insert(CustomInterceptor(), at: 0)
        return interceptors
    }
    
}
