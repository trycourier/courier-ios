//
//  Config.swift
//  Swift+Storyboard+APNS
//
//  Created by Michael Miller on 8/8/22.
//

import Foundation

var currentAccessToken: String {
    get {
        return LocalStorage.accessToken ?? ""
    }
    set {
        LocalStorage.accessToken = newValue
    }
}

var currentUserId: String  {
    get {
        return LocalStorage.userId ?? "example_user"
    }
    set {
        LocalStorage.userId = newValue
    }
}
