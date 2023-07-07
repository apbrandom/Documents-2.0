//
//  PasswordViewController.swift
//  Documents 2.0
//
//  Created by Vadim Vinogradov on 04.07.2023.
//

import UIKit
import KeychainAccess

class PasswordViewController: UIViewController {
    
    @IBOutlet weak var passwordActionButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let keychain = Keychain(service: "ru.apbrandom.Documents-2-0")
    let passwordKey = "userPassword"
    var isConfirmingPassword = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if keychain[passwordKey] != nil {
            passwordActionButton.setTitle("Enter password", for: .normal)
        } else {
            passwordActionButton.setTitle("Create password", for: .normal)
        }
    }
    
    @IBAction func passwordActionButtonTapped(_ sender: UIButton) {
        guard let password = passwordTextField.text, !password.isEmpty else {
            return
        }
        
        if keychain[passwordKey] != nil {
            
            //check the password
            if password == keychain[passwordKey] {
                
                // go to Documents
                self.performSegue(withIdentifier: "ShowTabBarController", sender: self)
            } else {
               
                // show error
            }
        } else {
            if isConfirmingPassword {
                
                // проверяем совпадение паролей
                if password == passwordTextField.placeholder {
                    keychain[passwordKey] = password
                    
                    // go to Documents
                    self.performSegue(withIdentifier: "ShowDocuments", sender: self)
                } else {
                    //show error "password is not the same"
                }
                
            } else {
                isConfirmingPassword = true
                passwordTextField.placeholder = password
                passwordTextField.text = ""
                passwordActionButton.setTitle("Repeat password", for: .normal)
            }
        }
    }
}
