//
//  ContentView.swift
//  SwiftUI+APNS
//
//  Created by Michael Miller on 8/12/22.
//

import SwiftUI
import Courier

struct ContentView: View {
    
    private func sendPush() {
        
        Task {
            do {
                
                try await Courier.sendPush(
                    authKey: accessToken,
                    userId: userId,
                    title: "Test Push Notification",
                    message: "Hello from Courier! 🐣",
                    providers: [.apns]
                )
                
            } catch {
                print(error)
            }
        }
        
    }
    
    var body: some View {
        Button("Send Push") {
            sendPush()
        }
        .buttonStyle(BorderedProminentButtonStyle())
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
