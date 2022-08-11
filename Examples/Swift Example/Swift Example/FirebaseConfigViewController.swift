//
//  FirebaseConfigViewController.swift
//  Swift+Storyboard+APNS
//
//  Created by Michael Miller on 8/9/22.
//

import UIKit
import Courier
import FirebaseCore
import FirebaseMessaging

class FirebaseConfigViewController: UIViewController {
    
    @IBOutlet weak var appIdField: UITextField!
    @IBOutlet weak var gcmSenderIdField: UITextField!
    @IBOutlet weak var apiKeyField: UITextField!
    @IBOutlet weak var projectIdField: UITextField!
    @IBOutlet weak var clientIdField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Firebase Configuration"
        
//        let options = FirebaseOptions(
//            googleAppID: "1:694725526129:ios:2faeb9504bca610e8811d0",
//            gcmSenderID: "694725526129"
//        )
//        options.bundleID = "com.courier.example-swift"
//        options.apiKey = "AIzaSyBNrs37yi9iJb5d8d27CBF8ViRo4_TNhs4"
//        options.clientID = "694725526129-c1qo4ua5r9nc3q2619pmsjjhj9ddgrvm.apps.googleusercontent.com"
//        options.trackingID = "correct_tracking_id"
//        options.projectID = "test-fcm-e7ddc"
//        options.databaseURL = "https://abc-xyz-123.firebaseio.com"
//        options.storageBucket = "test-fcm-e7ddc.appspot.com"
//        options.appGroupID = nil
//
//        FirebaseApp.configure(options: options)
        
//        let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")
//        guard let fileopts = FirebaseOptions(contentsOfFile: filePath!) else {
//            assert(false, "Couldn't load config file")
//        }
        
        let fileManager = FileManager.default

        let newPlist = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("GoogleService-Info.plist")
        let path = newPlist.path

        let plist : [String: Any] = [
            "API_KEY": "AIzaSyBNrs37yi9iJb5d8d27CBF8ViRo4_TNhs4",
            "IS_SIGNIN_ENABLED": true,
            "GOOGLE_APP_ID": "1:694725526129:ios:2faeb9504bca610e8811d0",
            "IS_GCM_ENABLED": true,
            "REVERSED_CLIENT_ID": "com.googleusercontent.apps.694725526129-c1qo4ua5r9nc3q2619pmsjjhj9ddgrvm",
            "GCM_SENDER_ID": "694725526129",
            "BUNDLE_ID": "com.courier.example-swift",
            "IS_APPINVITE_ENABLED": true,
            "IS_ANALYTICS_ENABLED": false,
            "PROJECT_ID": "test-fcm-e7ddc",
            "IS_ADS_ENABLED": false,
            "PLIST_VERSION": "1",
            "STORAGE_BUCKET": "test-fcm-e7ddc.appspot.com",
            "CLIENT_ID": "694725526129-c1qo4ua5r9nc3q2619pmsjjhj9ddgrvm.apps.googleusercontent.com"
        ]
        
        let data = NSDictionary(dictionary: plist)
        
        let isWritten = data.write(toFile: path, atomically: true)
        print("File created: \(isWritten)")
        
//        print(path)
//
//        let filePath = Bundle.main.path(forResource: "Documents/GoogleService-Info", ofType: "plist")
        
//        print(filePath)
        
        guard let fileopts = FirebaseOptions(contentsOfFile: path) else {
            assert(false, "Couldn't load config file")
        }
        
        FirebaseApp.configure(options: fileopts)
        
        let app = FirebaseApp.app()
        
        guard let options = app?.options else {
            return
        }
        
        if let token = Courier.shared.rawApnsToken {
            Messaging.messaging().setAPNSToken(token, type: .sandbox)
        }
        
        appIdField.text = options.googleAppID
        gcmSenderIdField.text = options.gcmSenderID
        apiKeyField.text = options.apiKey
        projectIdField.text = options.projectID
        clientIdField.text = options.clientID
        
        refresh()
        
    }

}

extension FirebaseConfigViewController {
    
    private func refresh() {
        
        let fields = [appIdField, gcmSenderIdField, apiKeyField, projectIdField, clientIdField]
        fields.forEach { field in
            field?.isEnabled = false
            field?.alpha = 0.5
        }
        
    }
    
}
