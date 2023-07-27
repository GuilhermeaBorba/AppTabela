//
//  LoginViewController.swift
//  app_firebase
//
//  Created by Hermando Thiago Costa Fernandes on 10/02/23.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var EmailTextView: UITextField!
    @IBOutlet weak var PasswordTextView: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginUser(_ sender: UIButton) {
        if let email = EmailTextView.text, let password = PasswordTextView.text {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    print(error)
                } else {
                    if let mainVc = self.storyboard?.instantiateViewController(withIdentifier: "main") as? MainViewController {
                        self.navigationController?.pushViewController(mainVc, animated: true)
                    }
                }
            }
        }
    }
    
}
