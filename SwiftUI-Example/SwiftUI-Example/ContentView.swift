//
//  ContentView.swift
//  SwiftUI-Example
//
//  Created by Michael Miller on 3/27/23.
//

import SwiftUI
import Courier_iOS

struct ContentView: View {
    
    init() {
        
        Task {
            
            let COURIER_ACCESS_TOKEN = "pk_prod_H48Y2E9VV94YP5K60JAYPGY3M3NH"
            let COURIER_CLIENT_KEY = "YWQxN2M2ZmMtNDU5OS00ZThlLWE4NTktZDQ4YzVlYjkxM2Mx"
            
            try await Courier.shared.signIn(
                accessToken: COURIER_ACCESS_TOKEN,
                clientKey: COURIER_CLIENT_KEY,
                userId: "mike"
            )
            
        }
        
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                CourierInboxView(
                    didClickInboxMessageAtIndex: { message, index in
                        print(message, index)
                    },
                    didClickInboxActionForMessageAtIndex: { action, message, index in
                        print(action, message, index)
                    },
                    didScrollInbox: { scrollview in
                        print(scrollview.contentOffset.y)
                    }
                )
            }
            .navigationTitle("Courier Inbox")
            .ignoresSafeArea()
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
