//
//  PasswordViewController.swift
//  Documents 2.0
//
//  Created by Vadim Vinogradov on 04.07.2023.
//

import UIKit
import KeychainAccess

class PasswordViewController: UIViewController {
    
    enum LoginError: Error {
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
        
        do {
            if keychain[passwordKey] != nil {
                try Login()
                self.performSegue(withIdentifier: "ShowTabBarController", sender: self)
            } else {
                try createPassword()
            }
        } catch LoginError.incompleteForm {
            Alert.showBasic(title: "Incomplete Form", message: "Please fill out the password filed", on: self)
        } catch LoginError.invalidPassword {
            Alert.showBasic(title: "Invalid Password", message: "Please make sure your password correctly", on: self)
        } catch LoginError.incorrectPasswordLenght {
            Alert.showBasic(title: "Password Too Short", message: "Password should be at least 4 characters", on: self)
        } catch {
            Alert.showBasic(title: "Unable To Login", message: "There was an error when attempting to login", on: self)
        }
    }
    
    func Login() throws {
        guard let password = passwordTextField.text else {
            throw LoginError.incompleteForm
        }
        
        if password.isEmpty {
            throw LoginError.incompleteForm
        }
        
        if password.count < 4 {
            throw LoginError.incorrectPasswordLenght
        }
        
        if password != keychain[passwordKey] {
            throw LoginError.invalidPassword
        }
    }
    
    func createPassword() throws {
        guard let password = passwordTextField.text else {
            throw LoginError.incompleteForm
        }
        
        if password.isEmpty {
            throw LoginError.incompleteForm
        }
        
        if password.count < 4 {
            throw LoginError.incorrectPasswordLenght
        }
        
        if isConfirmingPassword {
            if password != passwordTextField.placeholder {
                throw LoginError.invalidPassword
            } else {
                keychain[passwordKey] = password
                self.performSegue(withIdentifier: "ShowTabBarController", sender: self)
            }
        } else {
            isConfirmingPassword = true
            passwordTextField.placeholder = password
            passwordTextField.text = ""
            passwordActionButton.setTitle("Repeat password", for: .normal)
        }
    }
}
