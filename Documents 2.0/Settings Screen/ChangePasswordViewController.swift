//
//  ChangePasswordViewController.swift
//  Documents 2.0
//
//  Created by Vadim Vinogradov on 09.07.2023.
//

import UIKit
import KeychainAccess

class ChangePasswordViewController: UIViewController {
    
    
    @IBOutlet weak var currentPasswordTextField: UITextField!
    
    @IBOutlet weak var newPasswordTextField: UITextField!
    
    @IBOutlet weak var repeatNewPasswordTextField: UITextField!
    
    
    
    let keychain = Keychain(service: "ru.apbrandom.Documents-2-0")
    let passwordKey = "userPassword"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func changePasswordButtonTapped(_ sender: Any) {
        guard let currentPassword = currentPasswordTextField.text,
              let newPassword = newPasswordTextField.text,
              let repeatNewPassword = repeatNewPasswordTextField.text,
              !currentPassword.isEmpty,
              !newPassword.isEmpty,
              !repeatNewPassword.isEmpty else {
            showAlert(title: "Error", message: "Please enter all fields")
            return
        }
        
        if currentPassword == keychain[passwordKey] {
            if newPassword == repeatNewPassword {
                keychain[passwordKey] = newPassword
                showAlert(title: "Success", message: "Your password has been changed successfully")
            } else {
                showAlert(title: "Error", message: "The new password is not a match")
            }
        } else {
            showAlert(title: "Error", message: "Bad curruent password")
        }
    }
    
    @IBAction func deletePasswordButtonTapped(_ sender: Any) {
        do {
            try keychain.remove(passwordKey)
            showAlert(title: "Success", message: "Your password has been deleted successfully")
        } catch let error {
            print("Error deleting password: \(error)")
        }
    }
}
