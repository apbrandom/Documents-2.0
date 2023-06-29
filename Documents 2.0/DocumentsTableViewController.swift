//
//  DocumentsTableViewController.swift
//  Documetns
//
//  Created by Vadim Vinogradov on 28.06.2023.
//

import PhotosUI

class DocumentsTableViewController: UITableViewController {
    
    var imageNames: [String] = []
    
    @IBAction func addPhotoAction(_ sender: Any) {
        setupPickerController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }
    
    //MARK: - Private
    
    func setupTableView() {
        title = "Documets"
        imageNames = FileManagerHelper.shared.retrieveAllImageNames()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PhotoCell")
    }
    
    func setupPickerController() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageNames.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath)
        var contentConfiguration = UIListContentConfiguration.cell()
        
        let imageName = imageNames[indexPath.row]
        contentConfiguration.text = imageName
        
        if let image = FileManagerHelper.shared.retrieveImage(withName: imageName) {
            contentConfiguration.image = image
            contentConfiguration.imageProperties.maximumSize = CGSize(width: 40, height: 40)
            contentConfiguration.imageProperties.cornerRadius = 5
        }
        
        cell.contentConfiguration = contentConfiguration
        
        return cell
    }

    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let imageName = imageNames[indexPath.row]
            if FileManagerHelper.shared.deleteImage(withName: imageName) {
                imageNames.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

extension DocumentsTableViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        dismiss(animated: true)
        
        guard let itemProvider = results.first?.itemProvider,
              itemProvider.canLoadObject(ofClass: UIImage.self) else { return }
        
        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            if let image = image as? UIImage {
                let imageName = "\(UUID().uuidString).jpg"
                if FileManagerHelper.shared.saveImage(image, withName: imageName) {
                    DispatchQueue.main.async {
                        self?.imageNames.append(imageName)
                        self?.tableView.reloadData()
                    }
                }
            }
        }
    }
}
