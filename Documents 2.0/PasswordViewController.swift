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
            showAlert(title: "Error", message: "Please enter the password")
            return
        }
        
        guard password.count >= 4 else {
            showAlert(title: "Error", message: "Please enter the password with a minimum of four symbols ")
            return
        }
        
        // If the password already exists in Keychain
        if keychain[passwordKey] != nil {
            if password == keychain[passwordKey] {
                self.performSegue(withIdentifier: "ShowTabBarController", sender: self)
            } else {
                showAlert(title: "Error", message: "Bad Password")
            }
            
            // If the password has not yet been set
        } else {
            
            // If the user has already entered the password once and is now repeating it
            if isConfirmingPassword {
                
                // Check if the password entered matches the password entered for the first time
                if password == passwordTextField.placeholder {
                    keychain[passwordKey] = password
                    self.performSegue(withIdentifier: "ShowTabBarController", sender: self)
                } else {
                    showAlert(title: "Error", message: "New password not the same")
                }
                
                // If you are entering a new password for the first time
            } else {
                isConfirmingPassword = true
                passwordTextField.placeholder = password
                passwordTextField.text = ""
                passwordActionButton.setTitle("Repeat password", for: .normal)
            }
        }
    }
}
