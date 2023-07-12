//
//  PasswordViewController.swift
//  Documents 2.0
//
//  Created by Vadim Vinogradov on 04.07.2023.
//

import UIKit
import KeychainAccess

class PasswordViewController: UIViewController {
    
    enum AuthorizationError: Error {
        case incompleteForm
        case invalidPassword
        case incorrectPasswordLenght
        case repeatPassword
    }
    
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
        
        if keychain[passwordKey] != nil {
                switch Login() {
                case .success:
                    self.performSegue(withIdentifier: "ShowTabBarController", sender: self)
                case .failure(let error):
                    handleError(error)
                }
            } else {
                switch createPassword() {
                case .success:
                    self.performSegue(withIdentifier: "ShowTabBarController", sender: self)
                case .failure(let error):
                    handleError(error)
                }
            }
    }
    
    func handleError(_ error: AuthorizationError) {
        switch error {
        case .incompleteForm:
            Alert.showBasic(title: "Incomplete Form", message: "Please fill out the password filed", on: self)
        case .invalidPassword:
            Alert.showBasic(title: "Invalid Password", message: "Please make sure your password correctly", on: self)
        case .incorrectPasswordLenght:
            Alert.showBasic(title: "Password Too Short", message: "Password should be at least 4 characters", on: self)
        case .repeatPassword:
            Alert.showBasic(title: "Password not same", message: "Please make sure your new passwords the same", on: self)
        }
    }
    
    func Login() -> Result<Void, AuthorizationError> {
        guard let password = passwordTextField.text else {
            return .failure(AuthorizationError.incompleteForm)
        }
            
        if password.isEmpty {
            return .failure(AuthorizationError.incompleteForm)
        }
            
        if password.count < 4 {
            return .failure(AuthorizationError.incorrectPasswordLenght)
        }
            
        if password != keychain[passwordKey] {
            return .failure(AuthorizationError.invalidPassword)
        }
        
        return .success(())
    }

    func createPassword() -> Result<Void, AuthorizationError> {
        guard let password = passwordTextField.text else {
            return .failure(AuthorizationError.incompleteForm)
        }
            
        if password.isEmpty {
            return .failure(AuthorizationError.incompleteForm)
        }
            
        if password.count < 4 {
            return .failure(AuthorizationError.incorrectPasswordLenght)
        }
            
        if isConfirmingPassword {
            if password != passwordTextField.placeholder {
                return .failure(AuthorizationError.repeatPassword)
            } else {
                keychain[passwordKey] = password
                return .success(())
            }
        } else {
            isConfirmingPassword = true
            passwordTextField.placeholder = password
            passwordTextField.text = ""
            passwordActionButton.setTitle("Repeat password", for: .normal)
            return .success(())
        }
    }

}
