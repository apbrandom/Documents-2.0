//
//  FileMangerHelper.swift
//  Documents 2.0
//
//  Created by Vadim Vinogradov on 29.06.2023.
//

import UIKit

class FileManagerHelper {
    
    // Singleton instance to access the FileManager
    static let shared = FileManagerHelper()
    
    private init() { }
    
    // Get Document Directory
    func getDocumentsDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0]
    }
    
    // save a new folder to Documents Directory
    func creareNewFolder(withName name: String) -> Bool {
        let folderURL = getDocumentsDirectory().appendingPathComponent(name, isDirectory: true)
        
        do {
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
            return true
        } catch {
            print("Error creating folder: \(error)")
            return false
        }
    }
    
    // Save Image to Document Directory
    func saveImage(_ image: UIImage, withName name: String) -> Bool {
        let imagePath = getDocumentsDirectory().appending(component: name)
        
        guard let jpegData = image.jpegData(compressionQuality: 0.8) else { return false }
        
        do {
            try jpegData.write(to: imagePath)
            return true
        } catch {
            print("Error savig image: \(error)")
            return false
        }
    }
    
    // Retrieve Image from Document Directory
    func retrieveImage(withName name: String) -> UIImage? {
        let fileURL = getDocumentsDirectory().appending(component: name)
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image : \(error)")
        }
        return nil
    }
    
    func retrieveContent(ofType type: ContentType) -> [String] {
            do {
                let files = try FileManager.default.contentsOfDirectory(atPath: getDocumentsDirectory().path)
                
                switch type {
                case .image:
                    return files.filter { $0.hasSuffix(".jpg") || $0.hasSuffix(".jpeg") }
                    
                case .folder:
                    return files.filter { file in
                        var isDir : ObjCBool = false
                        let fullPath = getDocumentsDirectory().appendingPathComponent(file).path
                        FileManager.default.fileExists(atPath: fullPath, isDirectory: &isDir)
                        return isDir.boolValue
                    }
                }
            } catch {
                print("Error reading contents of directory: \(error)")
                return []
            }
        }

    
    // delete image with name
    func deleteImage(withName name: String) -> Bool {
        let imagePath = getDocumentsDirectory().appending(component: name)
        do {
            try FileManager.default.removeItem(at: imagePath)
            return true
        } catch {
            print("Error deliting image: \(error)")
            return false
        }
    }
    
    // retrieve creation date of the file with given name
    func retrieveFileCreationDate(withName name: String) -> Date? {
        let fileURL = getDocumentsDirectory().appending(component: name)
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.relativePath)
            return attributes[FileAttributeKey.creationDate] as? Date
        } catch {
            print("Error retrieving file creation date: \(error)")
            return nil
        }
    }
    
    // retrieve file size
    func retrieveFileSize(withName name: String) -> UInt64? {
        let fileURL = getDocumentsDirectory().appending(component: name)
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.relativePath)
            return attributes[FileAttributeKey.size] as? UInt64
        } catch {
            print("Error retrieving file size: \(error)")
            return nil
        }
    }
}
