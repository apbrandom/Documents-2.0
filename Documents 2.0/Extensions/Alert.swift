//
//  Show Alert.swift
//  Documents 2.0
//
//  Created by Vadim Vinogradov on 09.07.2023.
//

import Foundation
import UIKit

class Alert {
    static func showBasic(title: String, message: String, on vc: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
}
