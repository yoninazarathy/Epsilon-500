//
//  ImageManager.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 1/1/17.
//  Copyright © 2017 Yoni Nazarathy. All rights reserved.
//

import Foundation
import UIKit

class ImageManager{
    
    class func setup(){
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataPath = documentsDirectory.appendingPathComponent("imageThumbnails")
        
        do {
            try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("Error creating directory: \(error.localizedDescription)")
        }
        
        //QQQQ no need for this now - maybe yes if we need to manage memory
        DispatchQueue.global(qos: .background).async{
            while true{
                //Here update any images that we don't have
                sleep(sleepTimeImageRetrieve)
            }
        }
    }
    
    class func store(_ image: UIImage, withKey key: String) -> String{
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataPath = documentsDirectory.appendingPathComponent("imageThumbnails").appendingPathComponent(key).appendingPathExtension("png")

        //QQQQ consider saving JPEG.
        //QQQQ consider saving with file extension
        
        if let data = UIImagePNGRepresentation(image) {
            do{
                try data.write(to: dataPath)
            }catch let error as NSError{
                print(error)
            }
        }
        print("saving image with key \(key) to \(dataPath)")
    
        return dataPath.path
        
    }
}
