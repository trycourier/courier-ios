//
//  SwiftUIAPNSApp.swift
//  SwiftUIAPNS
//
//  Created by Michael Miller on 8/26/22.
//

import SwiftUI
import Courier

enum UserDefaultKey: String, CaseIterable {
    case accessToken = "Courier Access Token JWT"
    case authKey = "Courier Auth Key"
    case userId = "Courier User ID"
}

@main
struct SwiftUI_APNSApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    private func startCourier() {
        
        Task {
            
            try await UIApplication.shared.currentWindow?.rootViewController?.showInputAlert(
                fields: UserDefaultKey.allCases
            )
                
            // To hide debugging logs
//                Courier.shared.isDebugging = false
            
            // Set the access token to your user id
            // You can use a Courier auth key for this
            // but it is recommended that use use a jwt linked to your user
            // More info: https://www.courier.com/docs/reference/auth/issue-token/
            
            // This should be synced with your user's state management to ensure
            // your users tokens don't receive notifications when they are not
            // authenticated to use your app
            try await Courier.shared.setCredentials(
                accessToken: getDefault(key: .accessToken),
                userId: getDefault(key: .userId)
            )
            
            // You should requests this permission in a place that
            // makes most sense for your user's experience
            try await Courier.requestNotificationPermissions()
            
            // To remove the tokens for the current user, call this function.
            // You should call this when your user signs out of your app
//                try await Courier.shared.signOut()
            
        }
        
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView().onAppear {
                startCourier()
            }
        }
    }
    
}
