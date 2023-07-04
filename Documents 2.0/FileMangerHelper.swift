//
//  FileMangerHelper.swift
//  Documents 2.0
//
//  Created by Vadim Vinogradov on 29.06.2023.
//

import UIKit

class FileManagerHelper {
    
    static let shared = FileManagerHelper()
    private var rootDirectory: URL!
    private var currentDirectory: URL!
    
    private init() {
        self.rootDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        self.currentDirectory = rootDirectory
    }
    
    func isInRootDirectory() -> Bool {
        return currentDirectory.path == rootDirectory.path
    }
    
    private func fileURL(forName name: String) -> URL {
        return currentDirectory.appendingPathComponent(name)
    }
    
    func contentsOfCurrentDirectory() -> [String] {
        do {
            return try FileManager.default.contentsOfDirectory(atPath: currentDirectory.path)
        } catch {
            print("Error reading contents of directory: \(error)")
            return []
        }
    }
    
    func createNewFolder(withName name: String) -> Bool {
        let folderPath = fileURL(forName: name)
        do {
            try FileManager.default.createDirectory(at: folderPath, withIntermediateDirectories: true)
            return true
        } catch {
            print("Error creating folder: \(error)")
            return false
        }
    }
    
    func saveImage(_ image: UIImage, withName name: String) -> Bool {
        let imagePath = fileURL(forName: name)
        
        guard let jpegData = image.jpegData(compressionQuality: 0.8) else { return false }
        do {
            try jpegData.write(to: imagePath)
            return true
        } catch {
            print("Error saving image: \(error)")
            return false
        }
    }
    
    func retrieveImage(withName name: String) -> UIImage? {
        let fileURL = fileURL(forName: name)
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image: \(error)")
            return nil
        }
    }
    
    func retrieveContent(ofType type: ContentType) -> [String] {
        do {
            let files = self.contentsOfCurrentDirectory()
            switch type {
            case .image:
                return files.filter { $0.hasSuffix(".jpg") || $0.hasSuffix(".jpeg") }
            case .folder:
                return files.filter { file in
                    var isDir: ObjCBool = false
                    let fullPath = fileURL(forName: file).path
                    FileManager.default.fileExists(atPath: fullPath, isDirectory: &isDir)
                    return isDir.boolValue
                }
            }
        }
    }

    
    func contentType(ofItemWithName itemName: String) -> ContentType {
        if isDirectory(itemName: itemName) {
            return .folder
        } else if itemName.hasSuffix(".jpg") || itemName.hasSuffix(".jpeg") {
            return .image
        } else {
            return .image
        }
    }
    
    func deleteImage(withName name: String) -> Bool {
        let imagePath = fileURL(forName: name)
        do {
            try FileManager.default.removeItem(at: imagePath)
            return true
        } catch {
            print("Error deleting image: \(error)")
            return false
        }
    }
    
    func retrieveFileAttribute(_ attribute: FileAttributeKey, withName name: String) -> Any? {
        let fileURL = fileURL(forName: name)
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            return attributes[attribute]
        } catch {
            print("Error retrieving file attribute: \(error)")
            return nil
        }
    }
    
    func generateName(for type: ContentType) -> String {
        let existingItems = self.contentsOfCurrentDirectory()
        var counter = 0
        var name: String
        
        repeat {
            switch type {
            case .image:
                name = "image" + (counter == 0 ? "" : "_\(counter)") + ".jpeg"
            case .folder:
                name = "New Folder" + (counter == 0 ? "" : "_\(counter)")
            }
            counter += 1
        } while existingItems.contains(name)
        return name
    }
    
    //MARK: - Navigation
    
    func isDirectory(itemName: String) -> Bool {
        let fileURL = fileURL(forName: itemName)
        let resourceValues = try? fileURL.resourceValues(forKeys: [.isDirectoryKey])
        return resourceValues?.isDirectory ?? false
    }
    
    func getCurrentDirectoryName() -> String {
        return currentDirectory.lastPathComponent
    }
    
    func changeCurrentDirectory(to subdirectory: String) {
        let newDirectory = currentDirectory.appendingPathComponent(subdirectory, isDirectory: true)
        
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: newDirectory.path, isDirectory: &isDir), isDir.boolValue {
            currentDirectory = newDirectory
        } else {
            print("Subdirectory does not exist or is not a directory")
        }
    }
    
    func goBackToParentDirectory() -> Bool {
        let parentDirectory = currentDirectory.deletingLastPathComponent()
        if parentDirectory.path >= rootDirectory.path {
            currentDirectory = parentDirectory
            return true
        }
        return false
    }
}
