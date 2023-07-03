//
//  ImageDetailViewController.swift
//  Documents 2.0
//
//  Created by Vadim Vinogradov on 29.06.2023.
//

import UIKit

class ImageDetailViewController: UIViewController {
    var image: UIImage?
    var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.image = self.image
        view.addSubview(imageView)
    }
}

