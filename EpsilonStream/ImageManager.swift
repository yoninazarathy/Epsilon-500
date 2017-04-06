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

enum ImageStatus{
    case UrgentlyNeeded
    case NormallyNeeded
    case Loaded
}

class ImageManager{
    
    static var imageDBMangedObjects = Dictionary<String,ImageThumbnail>()
    
    class func makeImageUrgent(withKey key: String){
        if let imageThumbnail = imageDBMangedObjects[key]{
            print("Making urgent: \(imageThumbnail)")
            //DispatchQueue.main.sync {
                imageThumbnail.priority = 2
            //}
        }else{
            print("error no such image: \(key)")
        }
    }
    
    class func pushImageToGet(withKey key: String,_ isUrgent: Bool = false){
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        DispatchQueue.main.sync {
                
            let newImage = ImageThumbnail(context: managedObjectContext)
            
            newImage.hasFile = false //QQQQ check if file there
            newImage.priority = isUrgent ? 2 : 0
            newImage.cloudRequestSent = false
            newImage.keyName = key
            newImage.oneOnEpsilonTimeStamp = Date() //QQQQ not clear what here
            
            imageDBMangedObjects[key] = newImage
        }
        // QQQQ EpsilonStreamDataModel.saveViewContext() ????
    }
    
    class func setImageAsStored(withKey key: String){
        imageDBMangedObjects[key]?.hasFile = true
    }
    
    class func setup(){
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataPath = documentsDirectory.appendingPathComponent("imageThumbnails")
        
        do {
            try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("Error creating directory: \(error.localizedDescription)")
        }
        
        DispatchQueue.global(qos: .background).async{
            while dbReadyToGo == false{
                sleep(1)
            }
            
            
            while true{
                let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
                let request = ImageThumbnail.createFetchRequest()
                request.predicate = NSPredicate(format:"hasFile = %@ AND cloudRequestSent = %@", NSNumber(value: false),NSNumber(value: false))
                request.sortDescriptors = [NSSortDescriptor(key: "priority", ascending: false)]
                request.fetchLimit = 20
                do{
                    let imageList = try container.viewContext.fetch(request)
                    
                    var keys: [String] = []
                    
                    for im in imageList{
                        keys.append(im.keyName)
                        DispatchQueue.main.sync(){
                            im.cloudRequestSent = true
                        }
                    }
                    if keys.count > 0{
                        print("Send Cloud Request for images: \(keys)")
                        EpsilonStreamBackgroundFetch.readImageListFromCloud(withKeys: keys)
                    }else{
                        print("no keys for image search")
                    }
                }catch{
                    print("Fetch failed")
                }
                
                sleep(5)//QQQQ!
            }
        }
    }
    
    class func store(_ image: UIImage, withKey key: String){
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
    }
    
    class func storeImage(fromRecord record: CKRecord, withKey key: String){
        if let asset = record["imagePic"] as? CKAsset{
            do{
                let data = try Data(contentsOf: asset.fileURL)
                if let image = UIImage(data: data){
                    //print("storing Image with key: \(key)")
                    ImageManager.store(image, withKey: key)
                    setImageAsStored(withKey: key)
                }else{
                    print("error with image")
                }
            }catch{
                print("err with image")
            }
        }else{
            print("NO ASSET - with image")
            //video.imageURLlocal = nil
        }
    }
    
    class func numImagesOnFile() -> Int{
        let fd = FileManager.default
        let documentsDirectory = fd.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataPath = documentsDirectory.appendingPathComponent("imageThumbnails")

        var numImages = 0
        
        fd.enumerator(at: dataPath, includingPropertiesForKeys: nil)?.forEach({ (e) in
            numImages += 1
        })
        return numImages
    }
    
    class func numImagesInCoreData() -> Int{
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let request = ImageThumbnail.createFetchRequest()
        
        var retVal = -1
        
        do{
            let result = try container.viewContext.fetch(request)
            retVal = result.count
        }catch{
            print("Fetch failed")
        }
        
        return retVal
    }
    
    class func deleteAllImageFiles(){
        let fd = FileManager.default
        let documentsDirectory = fd.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataPath = documentsDirectory.appendingPathComponent("imageThumbnails")
        
        fd.enumerator(at: dataPath, includingPropertiesForKeys: nil)?.forEach({ (e) in
            let url = e as! URL
            do {
                try fd.removeItem(at: url)
            } catch let error as NSError {
                print(error.debugDescription)
            }
        })
    }
    
    class func getImage(forKey key: String) -> UIImage{
        var retVal: UIImage! = nil
        do{
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let url = documentsDirectory.appendingPathComponent("imageThumbnails").appendingPathComponent(key).appendingPathExtension("png")
            
            let data = try Data(contentsOf: url)
            retVal = UIImage(data: data)
        }catch{
            print("Could not find image with key \(key)")
            makeImageUrgent(withKey: key)
        }
        if retVal == nil{
            retVal = UIImage(named: "OneOnEpsilonLogo3") //QQQQ
        }
        return retVal!
    }
    
    class func loadedIndex() -> Double{
        var totalPriority: Int64 = 0
        var totalPriorityLoaded: Int64 = 0
        
        print("loadedIndex()")
        
        for (_,im) in imageDBMangedObjects{
            totalPriority += im.priority
            if im.hasFile{
                totalPriorityLoaded += im.priority
            }
        }
        let loadedIndex = Double(totalPriorityLoaded)/Double(totalPriority)
        print("totalPriority: \(totalPriority), totalPriorityLoaded: \(totalPriorityLoaded),loadedIndex \(loadedIndex)" )
        return 0.3
        //return loadedIndex
    }
    
}
