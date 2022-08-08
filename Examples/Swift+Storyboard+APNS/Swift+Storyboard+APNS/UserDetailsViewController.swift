//
//  UserDetailsViewController.swift
//  Swift+Storyboard+APNS
//
//  Created by Michael Miller on 8/8/22.
//

import UIKit

class UserDetailsViewController: UIViewController {

    @IBOutlet weak var userIdTextField: UITextField!
    @IBAction func userIdTextFieldChanged(_ sender: Any) {
//        print(userIdTextField.text)
        currentUserId = userIdTextField.text ?? ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        userIdTextField.text = currentUserId ?? ""
        userIdTextField.becomeFirstResponder()
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
