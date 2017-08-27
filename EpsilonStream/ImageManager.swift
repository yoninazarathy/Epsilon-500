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

protocol ImageLoadedDelegate{
    func imagesUpdate()
}

enum ImageStatus{
    case UrgentlyNeeded
    case NormallyNeeded
    case Loaded
}

//taken from: https://stackoverflow.com/questions/39677330/how-does-string-substring-work-in-swift-3
extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }

    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }

    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return substring(to: toIndex)
    }

    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }
}

class ImageManager{
    
    //The data model of the image manager is now the hashtables associated with image Keys.
    //Image keys are eitehr 10 characters (youtube style) or 6 characters for features.
    //Images can be on the:
    // 1) The bundle - then they are copied to the document directory on (first) startup.
    // 2) In the cloudkit envionrment - this is for 6 char images of features.
    // 3) In the youtube severs (using urls).
    
    //Indicates the status of images (urgent, normal, loaded - or not there if hash empty).
    static var statusHash:[String:ImageStatus] = [:]
    
    //records the url of the image (if such a thing exists)
    static var urlHash:[String:String] = [:]
    
    //records (by use redundantly true) that an image is in the cloud. Youtube images can be both in cloud and in url.
    static var inCloudHash:[String:Bool] = [:]
    
    //indicates if an image is needed by the delagate. This would come with urgent and then once delegate would be activated.
    static var neededByDelagate:[String:Bool] = [:]

    static var imageLoadedDelegate: ImageLoadedDelegate? = nil
    
    class func updateImageMetaDBFromVideos(){
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let request = Video.createFetchRequest()
        
        do{
            let result = try container.viewContext.fetch(request)
            for v in result{
                urlHash[v.youtubeVideoId] = v.imageURL
            }
        }catch{
            print("Fetch failed")
        }
        
        let request2 = FeaturedURL.createFetchRequest()
        
        do{
            let result = try container.viewContext.fetch(request2)
            for f in result{
                inCloudHash[f.imageKey!] = true
            }
        }catch{
            print("Fetch failed")
        }

        
    }

    class func updateImageMetaDBFromFeatures(){
        
    }
    
    class func updateImageMetaDBFromMathObjectLinks(){
        //QQQQ implement
    }
    
    
    
    /*
    class func refreshImageManager(){
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let videoRequset = Video.createFetchRequest()
        videoRequset.predicate = NSPredicate(value: true)
        videoRequset.fetchLimit = 10000 //QQQQ
        do{
            let videoList = try container.viewContext.fetch(videoRequset)
            for v in videoList{
                refreshImage(withKey: v.youtubeVideoId,withURL: v.imageURL,primarySourceIsCloud: false)
                //QQQQ make this imageKey (inDB)
            }
        }catch{
            print("Fetch failed")
        }

        let featureRequset = FeaturedURL.createFetchRequest()
        featureRequset.predicate = NSPredicate(value: true)
        featureRequset.fetchLimit = 100000
        do{
            let featureList = try container.viewContext.fetch(featureRequset)
            for f in featureList{
                refreshImage(withKey: f.imageKey!, withURL: "",primarySourceIsCloud: true)//QQQQ note features don't have imageURL yet in cloud
            }
        }catch{
            print("Fetch failed")
        }
        
        EpsilonStreamDataModel.saveViewContext()
        
        //QQQQ
        return
        
        let request = ImageThumbnail.createFetchRequest()
        request.predicate = NSPredicate(value: true)
        request.fetchLimit = 100000
        do{
            let imageList = try container.viewContext.fetch(request)
            print(imageList.count)
        }catch{
            print("Fetch failed")
        }

    }
 */
    
    /*
    class func refreshImage(withKey imageKey: String,withURL urlString: String,primarySourceIsCloud pCloud: Bool){
        //print("DISCOVER IMAGE \(imageKey)")
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let imageRequest = ImageThumbnail.createFetchRequest()
        imageRequest.predicate = NSPredicate(format: "keyName == %@", imageKey)
        imageRequest.fetchLimit = 2
        
        
        do{
            let imageList = try container.viewContext.fetch(imageRequest)
            switch imageList.count{
            case 0:
                print("ADDING IMAGE \(imageKey) to DB")
                let newImage = ImageThumbnail(context: container.viewContext)
                
                newImage.hasFile = false //QQQQ check if file there
                newImage.priority = 0//QQQQQ
                newImage.cloudRequestSent = false
                newImage.keyName = imageKey
                newImage.oneOnEpsilonTimeStamp = Date() //QQQQ not clear what here
                newImage.imageURL = urlString
                newImage.primarySourceIsCloud = pCloud
                newImage.webRequestSent = false
            case 1:
                let image = imageList[0]
                if haveFile(forImageKey: image.keyName) == false{
                    image.hasFile = false
                    image.cloudRequestSent = false
                    image.webRequestSent = false
                    print("reseting image \(image.keyName)")
                }
            default:
                print("error - too many images with key \(imageKey). There are \(imageList.count).")
            }
        }catch{
            print("Fetch failed")
        }
    }
    */
    
    //QQQQ not implemented
    class func makeImageUrgent(withKey key: String){
        print("makeImageUrgent \(key)")
       
        //QQQQ this is so not to have mulitple loads.... consider
        if statusHash[key] == ImageStatus.UrgentlyNeeded{
            print("image \(key) already urgently needed - returning")
            return
        }
        
        statusHash[key] = ImageStatus.UrgentlyNeeded
        neededByDelagate[key] = true
        if let url = urlHash[key]{
            loadImage(forKey: key, fromUrl: url)
        }
        
        if let _ = inCloudHash[key]{
            //QQQQ can make more efficient with list
            EpsilonStreamBackgroundFetch.readImageFromCloud(withKey: key)
        }
    }
    
    class func numImagesInBundle() -> Int{
        let bundlePath = Bundle.main.resourcePath!
        let fileManager = FileManager.default
        var retVal = 0
        do {
            let filesFromBundle = try fileManager.contentsOfDirectory(atPath: bundlePath)
            
            for f in filesFromBundle{
                if f.hasPrefix("PreThumb_"){
                    retVal += 1
                }
            }
        } catch {
            print("Error with searching images in bundle")
        }
        return retVal
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
    

    class func setup(){

        if numImagesOnFile() == 0{
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let dataPath = documentsDirectory.appendingPathComponent("imageThumbnails")
            
            do {
                try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                print("Error creating directory: \(error.localizedDescription)")
            }
           
            let bundlePath = Bundle.main.resourcePath!
            let fileManager = FileManager.default
            do {
                let filesFromBundle = try fileManager.contentsOfDirectory(atPath: bundlePath)
                
                for f in filesFromBundle{
                    if f.hasPrefix("PreThumb_"){
                        let name = f.substring(from:9)
                        //print("FOUND IMAGE IN BUNDLE: \(name)")
                        moveImageFromBundleToDocuments(withKey: name)
                        statusHash[name] = ImageStatus.Loaded
                        neededByDelagate[name] = false
                    }
                }
            } catch {
                print("Error with searching images in bundle")
            }
        }
   
        updateImageMetaDBFromVideos()
        
        
        /*
        
        DispatchQueue.global(qos: .background).async{
            while dbReadyToGo == false{
                sleep(1)
            }
         
            DispatchQueue.global(qos: .background).async{
                backgroundImageLoadCloud()
            }
            DispatchQueue.global(qos: .background).async{
                backgroundImageLoadWeb()
            }
        }
        */
    }
   
    static var backgroundImageOn = true
    
    
    /*
     //QQQQ - currently not used
    class func backgroundImageLoadCloud(){
        
        return //QQQQ ignore
        
        while true{
            sleep(1)
            if backgroundImageOn == false{
                continue
            }
            DispatchQueue.main.sync{
                let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
                let request = ImageThumbnail.createFetchRequest()
                request.predicate = NSPredicate(format:"hasFile = %@ AND primarySourceIsCloud == %@ AND cloudRequestSent = %@", NSNumber(value: false),NSNumber(value: true),NSNumber(value:false))
                request.sortDescriptors = [NSSortDescriptor(key: "priority", ascending: false)]
                request.fetchLimit = 50
                do{
                    let imageList = try container.viewContext.fetch(request)
                    
                    var keys: [String] = []
                    
                    for im in imageList{
                        keys.append(im.keyName)
                        im.cloudRequestSent = true //QQQQ may crash???
                    }
                    
                    if keys.count > 0{
                        print("Send Cloud Request for images: \(keys)")
                        EpsilonStreamBackgroundFetch.readImageListFromCloud(withKeys: keys)
                    }
                }catch{
                    print("Fetch failed")
                }
            }
        }
    }
 */
    
    
    class func loadImage(forKey key: String, fromUrl url: String){
        Alamofire.request(url).responseData{
            response in
            DispatchQueue.main.async {
                switch response.result {
                case .success(let data):
                    //print("SIZE OF IMAGE IS : \(data)")
                    if let img = UIImage(data: data){
                        //print("DOWNLOADED SIZE: \(img.size)") //QQQQ image sizes
                        //let image = Toucan(image: img).resize(CGSize(width: 240, height: 180), fitMode: Toucan.Resize.FitMode.crop).image
                        store(img, withKey: key)
                        DispatchQueue.main.async { //QQQQ maybe only do if needed by Delagate
                            self.imageLoadedDelegate?.imagesUpdate()
                        }
                    }else{
                        print("nil in image")
                    }
                case .failure(let error):
                    print("Request failed with error: \(error)")
                }
            }
        }
    }
    
    /*
     QQQQ - currently not used
    class func backgroundImageLoadWeb(){
        
        return //QQQQ
        
        while true{
            sleep(5)
            if backgroundImageOn == false{
                continue
            }
            
            DispatchQueue.main.sync{
                let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
                let request = ImageThumbnail.createFetchRequest()
                request.predicate = NSPredicate(format:"hasFile = %@ AND primarySourceIsCloud == %@ AND webRequestSent = %@", NSNumber(value: false),NSNumber(value: false),NSNumber(value:false))
                request.sortDescriptors = [NSSortDescriptor(key: "priority", ascending: false)]
                request.fetchLimit = 50
                do{
                    let imageList = try container.viewContext.fetch(request)
                    
                    for im in imageList{
                        im.webRequestSent = true //QQQQ may crash???
                    }

                    for im in imageList{
                        Alamofire.request(im.imageURL).responseData{
                            response in
                            DispatchQueue.main.async {
                                switch response.result {
                                case .success(let data):
                                    //print("SIZE OF IMAGE IS : \(data)")
                                    if let img = UIImage(data: data){
                                        //print("DOWNLOADED SIZE: \(img.size)") //QQQQ image sizes
                                        //let image = Toucan(image: img).resize(CGSize(width: 240, height: 180), fitMode: Toucan.Resize.FitMode.crop).image
                                        store(img, withKey: im.keyName)
                                    }else{
                                        print("nil in image")
                                    }
                                case .failure(let error):
                                    print("Request failed with error: \(error)")
                                    im.webRequestSent = false //QQQQ may crash???
                                }
                            }
                        }
                    }
                }catch{
                    print("Fetch failed")
                }
            }
        }
    }
    */
    
    
    class func moveImageFromBundleToDocuments(withKey key: String){
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataPath = documentsDirectory.appendingPathComponent("imageThumbnails").appendingPathComponent(key)
        
        var bundlePath = Bundle.main.url(forResource: "PreThumb_\(key)", withExtension: nil)

        do{
            let source = bundlePath!.path
            let dest = dataPath.path
            //print("COPYING: \(source) TO \(dest)")
            try FileManager.default.copyItem(atPath: source, toPath: dest)
        }catch{
            print("\n")
            print(error)
        }
    }
    
    class func store(_ image: UIImage, withKey key: String){
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataPath = documentsDirectory.appendingPathComponent("imageThumbnails").appendingPathComponent(key).appendingPathExtension("png")

        //QQQQ consider saving JPEG.
        //QQQQ consider saving with file extension
        
        var imageWriteOK = true
        
        if let data = UIImagePNGRepresentation(image) {
            do{
                try data.write(to: dataPath)
                print("saving image with key \(key)")// to \(dataPath)")
                statusHash[key] = ImageStatus.Loaded
                if let nk = neededByDelagate[key]{
                    if nk == true{
                        //QQQQ imageLoadedDelegate?.imagesUpdate()
                        neededByDelagate[key] = false
                    }
                }
                
            }catch let error as NSError{
                print(error)
                imageWriteOK = false
            }
        }
        
        /*
        if imageWriteOK{
            DispatchQueue.main.async {
                let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
                let imageRequest = ImageThumbnail.createFetchRequest()
                imageRequest.predicate = NSPredicate(format: "keyName == %@", key)
                imageRequest.fetchLimit = 2
                        
                do{
                    let imageList = try container.viewContext.fetch(imageRequest)
                    if imageList.count == 1{
                        imageList[0].hasFile = true
                    }else{
                        print("error - bad number of  images in db with key \(key) -- \(imageList.count)")
                    }
                    
                }catch{
                    print("Fetch failed")
                }
            }
        }
         */
    }
    
    class func storeImage(fromRecord record: CKRecord, withKey key: String){
        if let asset = record["imagePic"] as? CKAsset{
            do{
                let data = try Data(contentsOf: asset.fileURL)
                if let image = UIImage(data: data){
                    ImageManager.store(image, withKey: key)
                    DispatchQueue.main.async { //QQQQ maybe only do if needed by Delagate
                        self.imageLoadedDelegate?.imagesUpdate()
                    }
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
    
    class func haveFile(forImageKey key: String) -> Bool{
        do{
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let url = documentsDirectory.appendingPathComponent("imageThumbnails").appendingPathComponent(key).appendingPathExtension("png")
            
            let _ = try Data(contentsOf: url)
            return true
        }catch{
            return false
        }
    }
    
    class func getImage(forKey key: String, withDefault defaultName:String = "eStreamIcon") -> UIImage{
        var retVal: UIImage! = nil
        do{
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let url = documentsDirectory.appendingPathComponent("imageThumbnails").appendingPathComponent(key).appendingPathExtension("png")
            
            let data = try Data(contentsOf: url)
            retVal = UIImage(data: data)
        }catch{
            //print("Could not find image with key \(key)")
            makeImageUrgent(withKey: key)
        }
        if retVal == nil{
            retVal = UIImage(named: defaultName)
            makeImageUrgent(withKey: key)
        }
        return retVal!
    }
    

    /*
    //This one is used in admin mode 
    //QQQQ - turned off for now
    class func refreshAllImagesFromURL(){
 
        //QQQQ need spinner for action....

        DispatchQueue.main.async{
            ImageManager.backgroundImageOn = false //QQQQ stop background image
            
            let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
            let request = ImageThumbnail.createFetchRequest()
            request.predicate = NSPredicate(value: true)
            request.fetchLimit = 100000
            var alamoFires = 0
            do{
                let imageList = try container.viewContext.fetch(request)
                
                for im in imageList{
    //                if(alamoFires % 100 == 0 ){
    //                    sleep(1)
    //                }
                    //print("Gonna get \(im.imageURL)")
                    if im.imageURL != ""{
                        alamoFires += 1
                        
                        Alamofire.request(im.imageURL).responseData{
                            response in
                            DispatchQueue.main.async {
                                switch response.result {
                                case .success(let data):
                                    print("SIZE OF IMAGE IS : \(data)")
                                    if let image = UIImage(data: data){
                                        store(image, withKey: im.keyName)
                                    }else{
                                        print("nil in image")
                                    }
                                case .failure(let error):
                                    print("Request failed with error: \(error)")
                                }
                            }
                        }
                    }

                    
                    
                }
                
            }catch{
                print("Fetch failed")
            }
        }
    }
    */
 
 
    //generate a random 6 char (image) key 
    //QQQQ need to check for clashes and improve - STILL NOT USED
    class func generateKey() -> String{
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        var randomString = ""
        
        for _ in 0 ..< 6 {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
}
