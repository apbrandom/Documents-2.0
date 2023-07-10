//
//  DocumentsTableViewController.swift
//  Documetns
//
//  Created by Vadim Vinogradov on 28.06.2023.
//

import PhotosUI

class DocumentsTableViewController: UITableViewController {
    
    @IBAction func addPhotoAction(_ sender: Any) {
        setupPickerController()
    }
    
    @IBAction func createNewFolderAction(_ sender: Any) {
        let newFolderName = FileManagerHelper.shared.generateName(for: .folder)
        let folderCreated = FileManagerHelper.shared.createNewFolder(withName: newFolderName)
        if folderCreated {
            FileManagerHelper.shared.addItem(newFolderName)
            apdateTableView()

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        apdateTableView()
        updateNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FileManagerHelper.shared.items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var contentConfiguration = UIListContentConfiguration.cell()
        
        let itemName = FileManagerHelper.shared.items[indexPath.row]
        
        switch FileManagerHelper.shared.contentType(ofItemWithName: itemName) {
        case .image:
            if let image = FileManagerHelper.shared.retrieveImage(withName: itemName) {
                contentConfiguration.image = image
                configureImageContent(&contentConfiguration, with: image)
            }
        case .folder:
            let folderConfig = UIImage.SymbolConfiguration(pointSize: 23)
            contentConfiguration.image = UIImage(systemName: "folder", withConfiguration: folderConfig)
        }
        
        let secondaryText = createSecondaryText(for: itemName)
        contentConfiguration.secondaryText = secondaryText
        contentConfiguration.text = itemName
        
        cell.contentConfiguration = contentConfiguration
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = FileManagerHelper.shared.items[indexPath.row]
        
        switch FileManagerHelper.shared.contentType(ofItemWithName: selectedItem) {
        
        case .folder:
            
            // open folder
            FileManagerHelper.shared.changeCurrentDirectory(to: selectedItem)
            FileManagerHelper.shared.contentsOfCurrentDirectory()
            title = FileManagerHelper.shared.getCurrentDirectoryName()
            updateNavigationBar()
            tableView.reloadData()
            
        case .image:
            
            // open image
            if let image = FileManagerHelper.shared.retrieveImage(withName: selectedItem) {
                let imageDetailViewController = ImageDetailViewController()
                imageDetailViewController.image = image
                navigationController?.pushViewController(imageDetailViewController, animated: true)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let imageName = FileManagerHelper.shared.items[indexPath.row]
            if FileManagerHelper.shared.deleteImage(withName: imageName) {
                FileManagerHelper.shared.removeItem(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    
    //MARK: - Private
    
    private func setupPickerController() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true)
    }
    
    private func configureImageContent(_ contentConfiguration: inout UIListContentConfiguration, with image: UIImage) {
        contentConfiguration.image = image
        contentConfiguration.imageProperties.maximumSize = CGSize(width: 40, height: 40)
        contentConfiguration.imageProperties.cornerRadius = 5
    }
    
    private func createSecondaryText(for itemName: String) -> String {
        var secondaryText = ""
        
        if let creationDate = FileManagerHelper.shared.retrieveFileAttribute(.creationDate, withName: itemName) as? Date {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            secondaryText += formatter.string(from: creationDate)
        }
        
        if let fileSize = FileManagerHelper.shared.retrieveFileAttribute(.size, withName: itemName) as? NSNumber {
            let fileSizeString = ByteCountFormatter.string(fromByteCount: fileSize.int64Value, countStyle: .file)
            secondaryText += secondaryText.isEmpty ? fileSizeString : " | \(fileSizeString)"
        }
        
        return secondaryText
    }
    
    private func updateNavigationBar() {
        if FileManagerHelper.shared.isInRootDirectory() {
            title = "Documents"
            navigationItem.leftBarButtonItem = nil
        } else {
            title = FileManagerHelper.shared.getCurrentDirectoryName()
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(goBack))
        }
    }
    
    private func apdateTableView() {
        FileManagerHelper.shared.contentsOfCurrentDirectory()
        tableView.reloadData()
    }
    
    @objc func goBack() {
        if FileManagerHelper.shared.goBackToParentDirectory() {
            FileManagerHelper.shared.contentsOfCurrentDirectory()
            updateNavigationBar()
            tableView.reloadData()
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
                let imageName = FileManagerHelper.shared.generateName(for: .image)
                if FileManagerHelper.shared.saveImage(image, withName: imageName) {
                    DispatchQueue.main.async {
                        FileManagerHelper.shared.addItem(imageName)
                        self?.tableView.reloadData()
                    }
                }
            }
        }
    }
}
