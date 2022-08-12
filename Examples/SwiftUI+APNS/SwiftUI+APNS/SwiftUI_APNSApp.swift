//
//  SwiftUI_APNSApp.swift
//  SwiftUI+APNS
//
//  Created by Michael Miller on 8/12/22.
//

import SwiftUI
import Courier

let accessToken = "<YOUR_ACCESS_TOKEN>"
let userId = "example_user"

@main
struct SwiftUI_APNSApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    private func startCourier() {
        
        Task {
            
            do {
                
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
                    accessToken: accessToken,
                    userId: userId
                )
                
                // You should requests this permission in a place that
                // makes most sense for your user's experience
                try await Courier.requestNotificationPermissions()
                
                // To remove the tokens for the current user, call this function.
                // You should call this when your user signs out of your app
//                try await Courier.shared.signOut()
                
            } catch {
                
                print(error)
                
            }
            
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
