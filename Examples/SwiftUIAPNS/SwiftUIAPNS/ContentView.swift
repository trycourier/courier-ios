//
//  ContentView.swift
//  SwiftUIAPNS
//
//  Created by Michael Miller on 8/26/22.
//

import SwiftUI

import SwiftUI
import Courier

struct ContentView: View {
    
    private func sendPush() {
        
        Task {
            do {
                
                try await Courier.shared.sendPush(
                    authKey: getDefault(key: .authKey),
                    userId: getDefault(key: .userId),
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