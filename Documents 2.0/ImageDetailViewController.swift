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
        view.addSubview(imageView)
        
        // Download image 
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let strongSelf = self else { return }
            
            // space for image filter
            
            DispatchQueue.main.async {
                // Updating the user interface in the main thread
                strongSelf.imageView.image = strongSelf.image
            }
        }
    }
}
