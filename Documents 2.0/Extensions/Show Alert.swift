//
//  Show Alert.swift
//  Documents 2.0
//
//  Created by Vadim Vinogradov on 09.07.2023.
//

import UIKit

extension UIViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        let action = UIAlertAction(
            title: "OK",
            style: .default)
        alert.addAction(action)
        self.present(alert, animated: true)
    }
}
