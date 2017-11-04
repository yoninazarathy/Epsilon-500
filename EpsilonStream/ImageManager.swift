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
    case Unknown
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

class ImageManager: ManagedObjectContextUserProtocol {
    
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
    
    //records true if an image is in the cloud. Youtube images can be both in cloud and in url (in future versions)
    //currently youtube
    static var inCloudHash:[String:Bool] = [:]
    
    //indicates if an image is needed by the delagate. This would come with urgent and then once delegate would be activated.
    static var neededByDelagate:[String:Bool] = [:]

    static var imageLoadedDelegate: ImageLoadedDelegate? = nil
    
    static var backgroundImageOn = true

    static var numURLLoads = 0
    static var numCloudLoads = 0
    
    static let maxURLLoads = 150
    static let maxCloudLoads = 30
    
    class func setup(){
        //if running for first time copy images from Bundle to directory
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
                        moveImageFromBundleToDocuments(withKey: name)
                    }
                }
            } catch {
                print("Error with searching images in bundle")
            }
        }
        
        if isInAdminMode == false{
            Timer.every(20.seconds){ (timer: Timer) in
                for (id,url) in urlHash{
                    if numURLLoads > maxURLLoads{
                        break;
                    }
                    if statusHash[id] != ImageStatus.Loaded{
                        loadImage(forKey: id, fromUrl: url)
                    }
                }
            }
            
            Timer.every(30.seconds){ (timer: Timer) in
                for (key,b) in inCloudHash{
                    if numCloudLoads > maxCloudLoads{
                        break
                    }
                    if b{
                        if statusHash[key] != ImageStatus.Loaded{
                            //QQQQ maybe problem here? --- yes there is problem - probably sending requests to same ones again and again.
                            //print("ok for cloud queue -- \(numCloudLoads)")
                            readImageFromCloud(withKey: key)
                        }
                    }
                }
            }
        }
    }
    
    class func refreshImageManager(){
        
        EpsilonStreamBackgroundFetch.setActionStart()
        
        let request = Video.createFetchRequest()
        
        do{
            //iterate over all videos
            let result = try managedObjectContext.fetch(request)
            for v in result{
                inCloudHash[v.youtubeVideoId] = false //all youtubes are currently from youtube url (not cloud)
                urlHash[v.youtubeVideoId] = v.imageURL

                if !haveFile(forImageKey: v.youtubeVideoId){ //if no file
                    if let st = statusHash[v.youtubeVideoId]{
                        switch st{
                        case ImageStatus.Loaded:
                            print("QQQQ - error -how can it be loaded???")
                        case ImageStatus.NormallyNeeded: //QQQQ just leave it
                            break
                        case ImageStatus.Unknown:
                            statusHash[v.youtubeVideoId] = ImageStatus.NormallyNeeded
                        case ImageStatus.UrgentlyNeeded: //QQQQ just leave it
                            break
                        }
                    }else{ //no status hash
                        statusHash[v.youtubeVideoId] = ImageStatus.NormallyNeeded
                    }
                }else{//have file
                    statusHash[v.youtubeVideoId] = ImageStatus.Loaded
                }
            }
        }catch{
            print("Fetch failed")
        }
        
        let request2 = FeaturedURL.createFetchRequest()
        
        do{
            let result = try managedObjectContext.fetch(request2)
            for f in result{
                //QQQQ forcefully unwrapping imageKey (why is it optional???)
                inCloudHash[f.imageKey!] = true //all features are currently from cloud
                
                //QQQQ this is a bit of copy from above (factor it)
                if !haveFile(forImageKey: f.imageKey!){ //if no file
                    if let st = statusHash[f.imageKey!]{
                        switch st{
                        case ImageStatus.Loaded:
                            print("QQQQ - error -how can it be loaded???")
                        case ImageStatus.NormallyNeeded: //QQQQ just leave it
                            break
                        case ImageStatus.Unknown:
                            statusHash[f.imageKey!] = ImageStatus.NormallyNeeded
                        case ImageStatus.UrgentlyNeeded: //QQQQ just leave it
                            break
                        }
                    }else{ //no status hash
                        statusHash[f.imageKey!] = ImageStatus.NormallyNeeded
                    }
                }else{//have file
                    statusHash[f.imageKey!] = ImageStatus.Loaded
                }
            }
        }catch{
            print("Fetch failed")
        }

        /*
        //This whole chunk below just prints a summary for debug
        let inCloud = inCloudHash.values.filter{$0}
        let numInCloud = inCloud.count
        let loaded = statusHash.values.filter(){$0 == ImageStatus.Loaded}
        let numLoaded = loaded.count
        let normallyNeeded = statusHash.values.filter(){$0 == ImageStatus.NormallyNeeded}
        let numNormallyNeeded = normallyNeeded.count
        let unknown = statusHash.values.filter(){$0 == ImageStatus.Unknown}
        let numUnknown = unknown.count
        let urgentlyNeeded = statusHash.values.filter(){$0 == ImageStatus.UrgentlyNeeded}
        let numUrgentlyNeeded = urgentlyNeeded.count
        print("inCloudHash.count: \(inCloudHash.count) (inCloud: \(numInCloud)), statusHash.count: \(statusHash.count), urlHash.count: \(urlHash.count),neededByDelagate.count: \(neededByDelagate.count)")
        print("numLoaded: \(numLoaded), numNormallyNeeded: \(numNormallyNeeded), numUnknown: \(numUnknown), numUrgentlyNeeded: \(numUrgentlyNeeded),")
     */
        
    EpsilonStreamBackgroundFetch.setActionFinish()

    }
    

    class func makeImageUrgent(withKey key: String){
       
        //QQQQ this is so not to have mulitple loads.... consider having a timeout instead
        if statusHash[key] == ImageStatus.UrgentlyNeeded{
            //print("image \(key) already urgently needed - returning")
            return
        }
        
        statusHash[key] = ImageStatus.UrgentlyNeeded
        neededByDelagate[key] = true
        
        if let url = urlHash[key]{
            loadImage(forKey: key, fromUrl: url)
        }else if let b = inCloudHash[key]{
            if b{
                //QQQQ can make more efficient with list
                readImageFromCloud(withKey: key)
            }
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
        let request = ImageThumbnail.createFetchRequest()
        
        var retVal = -1
        
        do{
            let result = try managedObjectContext.fetch(request)
            retVal = result.count
        }catch{
            print("Fetch failed")
        }
        
        return retVal
    }
    
    
    class func loadImage(forKey key: String, fromUrl url: String){
        numURLLoads += 1
        
        //QQQQ - this is for another day
//        var newUrl = url
//        let ul = URL(fileURLWithPath: url)
//        if ul.lastPathComponent.hasPrefix("default"){
//            newUrl = ul.absoluteString.replacingOccurrences(of: "default", with: "hqdefault")
//        }
        
        Alamofire.request(url).responseData{
            response in
            DispatchQueue.main.async {
                numURLLoads -= 1
                //print("NUM URL LOADS: \(numURLLoads)")
                if numURLLoads < 0{
                    print("error")
                }
                switch response.result {
                case .success(let data):
                    //print("SIZE OF IMAGE IS : \(data)")
                    if let img = UIImage(data: data){
                        //print("DOWNLOADED SIZE: \(img.size)") //QQQQ image sizes
                        //let image = Toucan(image: img).resize(CGSize(width: 240, height: 180), fitMode: Toucan.Resize.FitMode.crop).image
                        store(img, withKey: key)
                    }else{
                        print("nil in image")
                    }
                case .failure(let error):
                    print("Request failed with error: \(error)")
                }
            }
        }
    }
    
    class func moveImageFromBundleToDocuments(withKey key: String){
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataPath = documentsDirectory.appendingPathComponent("imageThumbnails").appendingPathComponent(key)
        
        let bundlePath = Bundle.main.url(forResource: "PreThumb_\(key)", withExtension: nil)

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
        
        //var imageWriteOK = true
        
        if let data = UIImagePNGRepresentation(image) {
            do{
                try data.write(to: dataPath)
                print("saving image with key \(key)")// to \(dataPath)")
                statusHash[key] = ImageStatus.Loaded
                if let nk = neededByDelagate[key]{
                    if nk == true{
                        neededByDelagate[key] = false
                        DispatchQueue.main.async{
                            self.imageLoadedDelegate?.imagesUpdate()
                        }
                    }
                }
                
            }catch let error as NSError{
                print(error)
                //imageWriteOK = false
            }
        }
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
    
    
    //QQQQ incomplete
    class func updateHashesFromFiles(){
        let fd = FileManager.default
        let documentsDirectory = fd.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataPath = documentsDirectory.appendingPathComponent("imageThumbnails")
        
        fd.enumerator(at: dataPath, includingPropertiesForKeys: nil)?.forEach({ (e) in
            let url = e as! URL
            print(url)
        })

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
    
    //QQQQ currently not used
    class func readImageListFromCloud(withKeys keyArray: [String]){
        var arr:[Any] = []
        for i in 0..<keyArray.count{
            arr.append(keyArray[i])
        }
        let pred = NSPredicate(format: "keyName IN %@",  arr )
        let query = CKQuery(recordType: "LightImageThumbNail", predicate: pred)
        
        print("SENDING PREDICATE TO CLOUD FOR IMAGES: \(pred)")
        
        let operation = CKQueryOperation(query: query)
        operation.resultsLimit = keyArray.count
        
        operation.recordFetchedBlock = { record in
            let obtainedKey = record["keyName"] as! String
            //print("GOT IMAGE: ----- \(obtainedKey)")
            ImageManager.storeImage(fromRecord: record, withKey: obtainedKey)
        }
        
        operation.queryCompletionBlock = { (cursor, error) in
            if error == nil{
            }else{
                print("\(error!.localizedDescription)")
            }
        }
        
        operation.completionBlock = {
        }
        
        CKContainer.default().publicCloudDatabase.add(operation)
    }

    class func readImageFromCloud(withKey key: String){
        numCloudLoads += 1
        let pred = NSPredicate(format: "keyName == %@", key)
        let query = CKQuery(recordType: "LightImageThumbNail", predicate: pred)
        
        let operation = CKQueryOperation(query: query)
        operation.resultsLimit = 1
        
        operation.recordFetchedBlock = { record in
            ImageManager.storeImage(fromRecord: record, withKey: key)
        }
        
        operation.queryCompletionBlock = { (cursor, error) in
            numCloudLoads -= 1
            if numCloudLoads < 0{
                print("error")
            }
            if error == nil{
            }else{
                print("\(error!.localizedDescription)")
            }
        }
        operation.completionBlock = {}
        CKContainer.default().publicCloudDatabase.add(operation)
    }

    //QQQQ currently not used
    class func readAllImagesFromCloud(){
        
        let pred = NSPredicate(format: "TRUEPREDICATE")// "modificationDate > %@", latestMathObjectDate! as NSDate)
        let query = CKQuery(recordType: "LightImageThumbNail", predicate: pred)
        
        let operation = CKQueryOperation(query: query)
        operation.resultsLimit = queryOperationResultLimit
        
        var num = 0
        operation.recordFetchedBlock = { record in
            print("LightImageThumbNail - RECORD FETCHED BLOCK -- \(num)")
            num = num + 1 //QQQQ handle cursurs???
            //print(record.recordChangeTag)
            let obtainedKey = record["keyName"] as! String
            
            ImageManager.storeImage(fromRecord: record, withKey: obtainedKey)
        }
        
        operation.queryCompletionBlock = { (cursor, error) in
            DispatchQueue.main.async{
                if error == nil{
                }
                else{
                    print("\(error!.localizedDescription)")
                }
            }
        }
        
        operation.completionBlock = {
            //onFinish() //QQQQ should this be in a mutex?
        }
        
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    
}
