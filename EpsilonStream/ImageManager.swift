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

class ImageManager: ManagedObjectContextUserProtocol {
    
    // The data model of the image manager is now the hashtables associated with image Keys.
    // Image keys are eitehr 10 characters (youtube style) or 6 characters for features.
    // Images can be on the:
    // 1) The bundle - then they are copied to the document directory on (first) startup.
    // 2) In the cloudkit environment - this is for 6 char images of features.
    // 3) In the youtube servers (using urls).
    
    // MARK: - Propeprties
    
    // Indicates the status of images (urgent, normal, loaded - or not there if hash empty).
    private static var statusHash = [String: ImageStatus]()
    
    // Records the url of the image (if such a thing exists)
    private static var urlHash = [String: String]()
    
    // Records true if an image is in the cloud. Youtube images can be both in cloud and in url (in future versions)
    // currently youtube
    private static var inCloudHash = [String: Bool]()
    
    // Indicates if an image is needed by the delagate. This would come with urgent and then once delegate would be activated.
    private static var neededByDelegate = [String: Bool]()

    static var imageLoadedDelegate: ImageLoadedDelegate? = nil
    
    static var backgroundImageOn = true

    private static var numURLLoads = 0
    private static var numCloudLoads = 0
    
    private static let maxURLLoads = 150
    private static let maxCloudLoads = 30
    
    private static let bundleImagesURL = Bundle.main.resourceURL!.appendingPathComponent("PreloadedThumbnailImages")
    private static let oldImagesDirectoryURL = IKFileManager.shared.documentsDirectoryURL.appendingPathComponent("imageThumbnails")
    private static let imagesDirectoryURL = IKFileManager.shared.cachesDirectoryURL.appendingPathComponent("Images")
    
    // MARK: - Methods
    
    class func setup() {
        moveImageFilesFromOldDirectory()
        copyThumbImagesFromBundle()
        
//        if isInAdminMode == false{
//            Timer.every(20.seconds){ (timer: Timer) in
//                for (id,url) in urlHash{
//                    if numURLLoads > maxURLLoads{
//                        break;
//                    }
//                    if statusHash[id] != ImageStatus.Loaded{
//                        loadImage(forKey: id, fromUrl: url)
//                    }
//                }
//            }
//
//            Timer.every(30.seconds){ (timer: Timer) in
//                for (key,b) in inCloudHash{
//                    if numCloudLoads > maxCloudLoads{
//                        break
//                    }
//                    if b{
//                        if statusHash[key] != ImageStatus.Loaded{
//                            //QQQQ maybe problem here? --- yes there is problem - probably sending requests to same ones again and again.
//                            //print("ok for cloud queue -- \(numCloudLoads)")
//                            readImageFromCloud(withKey: key)
//                        }
//                    }
//                }
//            }
//        }
    }
    
    class func refreshImageManager() {
        
        EpsilonStreamBackgroundFetch.setActionStart()
        
        let request = Video.createFetchRequest()
        do {
            //iterate over all videos
            let videos = try mainContext.fetch(request)
            for video in videos {
                let youtubeVideoId = video.youtubeVideoId
                inCloudHash[youtubeVideoId] = false //all youtubes are currently from youtube url (not cloud)
                urlHash[youtubeVideoId] = video.imageURL

                if !haveFile(forImageKey: video.youtubeVideoId) { //if no file
                    if let status = statusHash[youtubeVideoId] {
                        switch status {
                        case ImageStatus.Loaded:
                            DLog("QQQQ - error - how can it be loaded???")
                        case ImageStatus.NormallyNeeded: //QQQQ just leave it
                            break
                        case ImageStatus.Unknown:
                            statusHash[youtubeVideoId] = ImageStatus.NormallyNeeded
                        case ImageStatus.UrgentlyNeeded: //QQQQ just leave it
                            break
                        }
                    } else { //no status hash
                        statusHash[youtubeVideoId] = ImageStatus.NormallyNeeded
                    }
                } else { //have file
                    statusHash[youtubeVideoId] = ImageStatus.Loaded
                }
            }
        } catch {
            DLog("Video fetch failed")
        }
        
        let request2 = FeaturedURL.createFetchRequest()
        do {
            let featuredURLs = try mainContext.fetch(request2)
            for featuredURL in featuredURLs {
                //QQQQ forcefully unwrapping imageKey (why is it optional???)
                let imageKey = featuredURL.imageKey!
                inCloudHash[imageKey] = true //all features are currently from cloud
                
                //QQQQ this is a bit of copy from above (factor it)
                if !haveFile(forImageKey: imageKey) { //if no file
                    if let status = statusHash[imageKey] {
                        switch status {
                        case ImageStatus.Loaded:
                            print("QQQQ - error -how can it be loaded???")
                        case ImageStatus.NormallyNeeded: //QQQQ just leave it
                            break
                        case ImageStatus.Unknown:
                            statusHash[imageKey] = ImageStatus.NormallyNeeded
                        case ImageStatus.UrgentlyNeeded: //QQQQ just leave it
                            break
                        }
                    } else { //no status hash
                        statusHash[imageKey] = ImageStatus.NormallyNeeded
                    }
                } else {//have file
                    statusHash[imageKey] = ImageStatus.Loaded
                }
            }
        } catch {
            DLog("FeaturedURL fetch failed")
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
    
    private class func fileURLForImage(withKey key: String) -> URL {
        //QQQQ consider saving JPEG.
        //QQQQ consider saving with file extension
        return imagesDirectoryURL.appendingPathComponent(key).appendingPathExtension("png")
    }
    
    class func makeImageUrgent(withKey key: String){
       
        //QQQQ this is so not to have mulitple loads.... consider having a timeout instead
        if statusHash[key] == ImageStatus.UrgentlyNeeded{
            //print("image \(key) already urgently needed - returning")
            return
        }
        
        statusHash[key] = ImageStatus.UrgentlyNeeded
        neededByDelegate[key] = true
        
        if let url = urlHash[key]{
            loadImage(forKey: key, fromUrl: url)
        }else if let b = inCloudHash[key]{
            if b{
                //QQQQ can make more efficient with list
                readImageFromCloud(withKey: key)
            }
        }
    }
    
    class func loadImage(forKey key: String, fromUrl url: String) {
        numURLLoads += 1
        
        //QQQQ - this is for another day
//        var newUrl = url
//        let ul = URL(fileURLWithPath: url)
//        if ul.lastPathComponent.hasPrefix("default"){
//            newUrl = ul.absoluteString.replacingOccurrences(of: "default", with: "hqdefault")
//        }
        
        Alamofire.request(url).responseData { response in
            DispatchQueue.main.async {
                numURLLoads -= 1
                //print("NUM URL LOADS: \(numURLLoads)")
                if numURLLoads < 0 {
                    DLog("error")
                }
                switch response.result {
                case .success(let data):
                    //print("SIZE OF IMAGE IS : \(data)")
                    if let img = UIImage(data: data) {
                        //print("DOWNLOADED SIZE: \(img.size)") //QQQQ image sizes
                        //let image = Toucan(image: img).resize(CGSize(width: 240, height: 180), fitMode: Toucan.Resize.FitMode.crop).image
                        store(img, withKey: key)
                    }else{
                        DLog("nil in image")
                    }
                case .failure(let error):
                    DLog("Request failed with error: \(error)")
                }
            }
        }
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
    
    class func store(_ image: UIImage, withKey key: String) {
        if let data = UIImagePNGRepresentation(image) {
            do {
                try data.write(to: fileURLForImage(withKey: key) )
                print("saving image with key \(key)")// to \(dataPath)")
                statusHash[key] = ImageStatus.Loaded
                if let nk = neededByDelegate[key] {
                    if nk == true {
                        neededByDelegate[key] = false
                        DispatchQueue.main.async {
                            self.imageLoadedDelegate?.imagesUpdate()
                        }
                    }
                }
                
            } catch let error as NSError {
                print(error)
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
    private class func updateHashesFromFiles() {
        FileManager.default.enumerator(at: imagesDirectoryURL, includingPropertiesForKeys: nil)?.forEach({ (url) in
            print(url)
        })
    }
    
    class func deleteAllImageFiles() {
        IKFileManager.shared.removeItem(atURL: imagesDirectoryURL)
        IKFileManager.shared.createDirectoryIfDoesntExist(atURL: imagesDirectoryURL)
    }
    
    class func haveFile(forImageKey key: String) -> Bool {
        return IKFileManager.shared.fileExists(atURL: fileURLForImage(withKey: key))
    }
    
    class func getImage(forKey key: String, withDefault defaultName: String = "eStreamIcon") -> UIImage {
        var retVal: UIImage! = nil
        do {
            let data = try Data(contentsOf: fileURLForImage(withKey: key) )
            retVal = UIImage(data: data)
        } catch {
            //print("Could not find image with key \(key)")
            makeImageUrgent(withKey: key)
        }
        if retVal == nil {
            retVal = UIImage(named: defaultName)
            makeImageUrgent(withKey: key)
        }
        return retVal!
    }
    
    
    // MARK: - Cloud images
    
    private class func readImageFromCloud(withKey key: String){
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

    

    // MARK: - Count images
    
    class func numImagesInBundle() -> Int{
        let result = IKFileManager.shared.contentsOfDirectory(atURL: bundleImagesURL).count
        return result
    }
    
    class func numImagesOnFile() -> Int{
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataPath = documentsDirectory.appendingPathComponent("imageThumbnails")
        
        var numImages = 0
        
        fileManager.enumerator(at: dataPath, includingPropertiesForKeys: nil)?.forEach({ (e) in
            numImages += 1
        })
        return numImages
    }
    
    class func numImagesInCoreData() -> Int{
        let request = ImageThumbnail.createFetchRequest()
        
        var retVal = -1
        
        do{
            let result = try mainContext.fetch(request)
            retVal = result.count
        }catch{
            print("Fetch failed")
        }
        
        return retVal
    }
    
    // MARK: - Currently not used
    
    //generate a random 6 char (image) key
    //QQQQ need to check for clashes and improve - STILL NOT USED
    private class func generateKey() -> String{
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
    
    private class func readImageListFromCloud(withKeys keyArray: [String]){
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
    
    private class func readAllImagesFromCloud(){
        
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
