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
        let pats = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return pats[0]
    }
    
    // Save Image to Document Directory
    func saveImage(_ image: UIImage, withName name: String) -> Bool {
        let imagePath = getDocumentsDirectory().appendingPathComponent(name)
        
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
        let fileURL = getDocumentsDirectory().appendingPathComponent(name)
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image : \(error)")
        }
        return nil
    }
    
    // retrieve all image names from Document Directory
    func retrieveAllImageNames() -> [String] {
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: getDocumentsDirectory().path)
            return files.filter { $0.hasSuffix(".jpg") || $0.hasSuffix(".jpeg") }
        } catch {
            print("Error reading contents of directory: \(error)")
            return []
        }
    }
    
    // delete image with name
    func deleteImage(withName name: String) -> Bool {
        let imagePath = getDocumentsDirectory().appendingPathComponent(name)
        
        do {
            try FileManager.default.removeItem(at: imagePath)
            return true
        } catch {
            print("Error deliting image: \(error)")
            return false
        }
    }
}
