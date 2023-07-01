//
//  DocumentsTableViewController.swift
//  Documetns
//
//  Created by Vadim Vinogradov on 28.06.2023.
//

import PhotosUI

class DocumentsTableViewController: UITableViewController {
    
    var items: [String] = []
    
    @IBAction func addPhotoAction(_ sender: Any) {
        setupPickerController()
    }
    
    @IBAction func createNewFolderAction(_ sender: Any) {
        let newFolderName = generateName(for: .folder)
        let folderCreated = FileManagerHelper.shared.creareNewFolder(withName: newFolderName)
        
        if folderCreated {
                items.append(newFolderName)
                tableView.reloadData()
            }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }

    //MARK: - Private
    
    private func setupTableView() {
        title = "Documets"
        let images = FileManagerHelper.shared.retrieveContent(ofType: .image)
        let folders = FileManagerHelper.shared.retrieveContent(ofType: .folder)
        items = images + folders
    }
    
    private func setupPickerController() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true)
    }
    
    private func generateName(for type: ContentType) -> String {
        var counter = 0
        var name: String
        
        repeat {
            switch type {
            case .image:
                name = "image" + (counter == 0 ? "" : "_\(counter)") + ".jpeg"
            case .folder:
                name = "New Folder" + (counter == 0 ? "" : " \(counter)")
            }
            counter += 1
        } while items.contains(name)
        
        return name
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath)
        var contentConfiguration = UIListContentConfiguration.cell()
        
        let imageName = items[indexPath.row]
        
        if let image = FileManagerHelper.shared.retrieveImage(withName: imageName) {
            contentConfiguration.image = image
            contentConfiguration.imageProperties.maximumSize = CGSize(width: 40, height: 40)
            contentConfiguration.imageProperties.cornerRadius = 5
        }
        
        var secondaryText = ""
        
        if let creationDate = FileManagerHelper.shared.retrieveFileCreationDate(withName: imageName) {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            secondaryText += formatter.string(from: creationDate)
        }
        
        if let fileSize = FileManagerHelper.shared.retrieveFileSize(withName: imageName) {
            let fileSizeString = ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
            secondaryText += secondaryText.isEmpty ? fileSizeString : " | \(fileSizeString)"
        }
        
        contentConfiguration.secondaryText = secondaryText
        contentConfiguration.text = imageName

        cell.contentConfiguration = contentConfiguration
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let imageName = items[indexPath.row]
        
        if let image = FileManagerHelper.shared.retrieveImage(withName: imageName) {
            let imageDetailViewController = ImageDetailViewController()
            imageDetailViewController.image = image
            
            navigationController?.pushViewController(imageDetailViewController, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let imageName = items[indexPath.row]
            if FileManagerHelper.shared.deleteImage(withName: imageName) {
                items.remove(at: indexPath.row)
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
                let imageName = self?.generateName(for: .image)
                if let imageName = imageName, FileManagerHelper.shared.saveImage(image, withName: imageName) {
                    DispatchQueue.main.async {
                        self?.items.append(imageName)
                        self?.tableView.reloadData()
                    }
                }
            }
        }
    }
}
