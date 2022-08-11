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

var firebaseGoogleAppId: String  {
    get {
        return LocalStorage.googleAppId ?? "1:694725526129:ios:2faeb9504bca610e8811d0"
    }
    set {
        LocalStorage.googleAppId = newValue
    }
}

var firebaseGcmSenderId: String  {
    get {
        return LocalStorage.gcmSenderId ?? "694725526129"
    }
    set {
        LocalStorage.gcmSenderId = newValue
    }
}

var firebaseProjectId: String  {
    get {
        return LocalStorage.projectId ?? "test-fcm-e7ddc"
    }
    set {
        LocalStorage.projectId = newValue
    }
}

var firebaseApiKey: String  {
    get {
        return LocalStorage.apiKey ?? "AIzaSyBNrs37yi9iJb5d8d27CBF8ViRo4_TNhs4"
    }
    set {
        LocalStorage.apiKey = newValue
    }
}
