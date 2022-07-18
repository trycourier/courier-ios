//
//  ViewController.swift
//  Example
//
//  Created by Michael Miller on 7/7/22.
//

import UIKit
import Courier

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .red
        
        Task.init {
            do {
                
                let status = try await Courier.requestNotificationPermissions()
                print(status.rawValue)
                
            } catch {
                print(error)
            }
        }
        
    }


}

