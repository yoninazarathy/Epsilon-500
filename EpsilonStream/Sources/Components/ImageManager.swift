//
//  ImageManager.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 1/1/17.
//  Copyright © 2017 Yoni Nazarathy. All rights reserved.
//

import Foundation
import UIKit
import CloudKit
import Alamofire
import Toucan

class ImageManager: ManagedObjectContextUserProtocol {
    // MARK: - Propeprties
    private static let bundleImagesURL = Bundle.main.resourceURL!.appendingPathComponent("PreloadedThumbnailImages")
    private static let oldImagesDirectoryURL = IKFileManager.shared.documentsDirectoryURL.appendingPathComponent("imageThumbnails")
    private static let imagesDirectoryURL = IKFileManager.shared.cachesDirectoryURL.appendingPathComponent("Images")
    
    // MARK: - Methods
    
    class func setup() {
        moveImageFilesFromOldDirectory()
        copyThumbImagesFromBundle()
    }
    
    private class func fileURLForImage(withKey key: String) -> URL {
        //QQQQ consider saving JPEG. Consider saving with file extension.
        return imagesDirectoryURL.appendingPathComponent(key).appendingPathExtension("png")
    }
    
    private class func copyThumbImagesFromBundle() {
        //if running for first time copy images from Bundle to directory
        if IKFileManager.shared.fileExists(atURL: imagesDirectoryURL) == false {
            IKFileManager.shared.createDirectory(atURL: imagesDirectoryURL)
            
            let fileNames = IKFileManager.shared.contentsOfDirectory(atPath: bundleImagesURL.relativePath)
            
            for fileName in fileNames {
                let prefix = "PreThumb_"
                let name = fileName.substring(from: prefix.count)

                let targetPath = imagesDirectoryURL.appendingPathComponent(name)
                IKFileManager.shared.copyItem(atURL: bundleImagesURL.appendingPathComponent(fileName), toURL: targetPath)
            }
        }
    }
    
    private class func moveImageFilesFromOldDirectory() {
        if IKFileManager.shared.fileExists(atURL: imagesDirectoryURL) == false &&
            IKFileManager.shared.fileExists(atURL: oldImagesDirectoryURL) == true {
            
            IKFileManager.shared.moveItem(atURL: oldImagesDirectoryURL, toURL: imagesDirectoryURL)
        }
    }
    
    private class func fileExists(forImageKey key: String) -> Bool {
        return IKFileManager.shared.fileExists(atURL: fileURLForImage(withKey: key))
    }
    
    class func image(at url: URL?, forKey key: String, withDefaultName defaultName: String = "eStreamIcon",
                     completion: ( (UIImage?) -> Void)? = nil ) -> UIImage {
        var result: UIImage!
        if url != nil && url?.scheme != nil && url?.host != nil {
            let fileURL = fileURLForImage(withKey: key)
            let fileExists = AssetManager.shared.downloadFile(at: url!, to: fileURL, completion: { (fileURL, error) in
                completion?(IKFileManager.shared.imageWithContentsOfFile(atURL: fileURL))
            })
            
            if fileExists {
                result = IKFileManager.shared.imageWithContentsOfFile(atURL: fileURL)
            }
        }
        
        if result == nil {
            result = UIImage(named: defaultName)
            
        }
        return result
    }
    
    class func deleteAllImageFiles() {
        IKFileManager.shared.removeItem(atURL: imagesDirectoryURL)
        IKFileManager.shared.createDirectoryIfDoesntExist(atURL: imagesDirectoryURL)
    }

    // MARK: - Count images
    
    class func numImagesInBundle() -> Int{
        let result = IKFileManager.shared.contentsOfDirectory(atURL: bundleImagesURL).count
        return result
    }
    
    class func numImagesOnFile() -> Int{
        let result = IKFileManager.shared.contentsOfDirectory(atURL: imagesDirectoryURL).count
        return result
    }
}
