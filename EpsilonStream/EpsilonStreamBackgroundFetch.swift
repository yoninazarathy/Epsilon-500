//
//  EpsilonStreamBackgroundFetch.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 31/12/16.
//  Copyright © 2016 Yoni Nazarathy. All rights reserved.
//

import Foundation
import CloudKit
import CoreData
import UIKit
import Alamofire
import Firebase


//QQQQ need to organize so this class is more for cloud and the other class is more for core data...?

class EpsilonStreamBackgroundFetch{
    
    static var searcherUI: SearcherUI! = nil
    static var needUpdate: Bool? = nil
    static var pullEpsilonStreamInfoInProgress = false
    static var epsilonStreamInfoRecord: CKRecord? = nil
    
    static var isUpdatingNow = false
    static var finishedVideos = false
    static var finishedMathObjects = false
    static var finishedFeaturedURLs = false
    static var finishedImages = false
    static var finishedMathObjectLinks = false

    static var videoNum = 0

    /*
    QQQQ - EpsilonStreamInfo not used now
    class func pullEpsilonStreamInfo(){
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let query = CKQuery(recordType: "EpsilonStreamInfo", predicate: predicate)

        let operation = CKQueryOperation(query: query)
        operation.resultsLimit = 1
        
        operation.recordFetchedBlock = { record in
       //     DispatchQueue.main.async {//In which context to run it?
                updateEpsilonStreamInfoInDB(fromDataSource: record)
       //     }
        }
        
        operation.queryCompletionBlock = { (cursor, error) in
            //print("readVideoMetaDataFromCloud OPERATION COMPLETE BLOCK")
        //    DispatchQueue.main.async{
                if error == nil{
                    //print("no error")
                }
                else{
                    print("\(error!.localizedDescription)")
                }
         //   }
        }
        
        operation.completionBlock = {
       //     DispatchQueue.main.async {
                EpsilonStreamBackgroundFetch.pullEpsilonStreamInfoInProgress = false
                infoReadyToGo = true
         //   }
        }
        
      if EpsilonStreamBackgroundFetch.pullEpsilonStreamInfoInProgress == false{
        EpsilonStreamBackgroundFetch.pullEpsilonStreamInfoInProgress = true
            CKContainer.default().publicCloudDatabase.add(operation)
      }else{
            print("Tried to pull Cloud DB Version info while pull already in progress - aborted")
      }
    }
    
    class func updateEpsilonStreamInfoInDB(fromDataSource cloudSource: CKRecord){
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let request = VersionInfo.createFetchRequest()
        //let otherBuffer = 1-currentDBBuffer
        request.predicate = NSPredicate(format:"TRUEPREDICATE")//NSPredicate(format: "bufferIndex == %@", otherBuffer as NSNumber)
        
        do{
            let results = try container.viewContext.fetch(request)
            if results.count > 0{
                if results.count > 1{
                    print("Bad error: more than 1 VersionInfo object")
                }
                
                for result in results{ //this should loop only once
                    container.viewContext.delete(result)
                }
            }else{
                print("No versionInfo entry to delete in DB")
            }
        }catch{
            print("Fetch failed")
        }
        
        let versionInfo = VersionInfo(context: container.viewContext)
        
        versionInfo.mathObjectCount = cloudSource["mathObjectCount"] as! Int64
        versionInfo.videoCount = cloudSource["videoCount"] as! Int64
        versionInfo.featuredURLCount = cloudSource["featuredURLCount"] as!  Int64
        versionInfo.textMessageToShow = cloudSource["textMessageToShow"] as!  String
        versionInfo.numberOfTimesToShowMessage = cloudSource["numberOfTimesToShowMessage"] as!  Int64
        versionInfo.minimalSoftwareVersion = cloudSource["minimalSoftwareVersion"] as!  String
        versionInfo.contentVersionNumber = cloudSource["contentVersionNumber"] as! Int64
        
        versionInfo.inProgressContentVersionNumber = -1
        
        versionInfo.loaded = false
        
        versionInfo.numberOfTimesLeftToShowMessage = versionInfo.numberOfTimesToShowMessage
        
        //versionInfo.bufferIndex = Int64(otherBuffer)
        
        EpsilonStreamDataModel.saveViewContext()
    }
 */
    
    class func runUpdate(){
        finishedImages = false
        finishedMathObjects = false
        finishedVideos = false
        finishedFeaturedURLs = false

        readAllImagesFromCloud()
        readMathObjectsFromCloud() //QQQQ implement for collection
        readMathObjectLinksFromCloud()
        
        //if not in admin mode only read videos in collection
        //otherwise (inAdminMode) read all videos
        readVideoDataFromCloud(isInAdminMode == false)
        readFeaturedURLsFromCloud()
    }
    
    
    class func onFinish(){
        var isReady = finishedVideos && finishedFeaturedURLs &&  finishedMathObjects && finishedImages && finishedMathObjectLinks
        
        if isReady{
            EpsilonStreamDataModel.saveViewContext()
            
            DispatchQueue.main.sync{
                EpsilonStreamDataModel.setUpAutoCompleteLists()
                EpsilonStreamDataModel.setLatestDates()
                //ImageManager.refreshImageManager()
                //finishedVideos = false
                //readVideoDataFromCloud(false) //read videos not in the collection
            }
            dbReadyToGo = true
        }
    }
    
    class func createDBVideo(fromDataSource cloudSource: CKRecord){
        //unique key
        let videoID = cloudSource["youtubeVideoId"] as! String
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let newVideo = Video(context: container.viewContext)
        newVideo.update(fromCloudRecord: cloudSource)
    }

    class func createOrUpdateDBMathObject(fromDataSource cloudSource: CKRecord){
        
        let hashTag = cloudSource["hashTag"] as! String
        
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let request = MathObject.createFetchRequest()
        request.predicate = NSPredicate(format: "hashTag == %@", hashTag)
        do{
            let mo = try container.viewContext.fetch(request)
            if mo.count == 0{
                let newMathObject = MathObject(context: container.viewContext)
                newMathObject.update(fromCloudRecord: cloudSource)
            }else if mo.count == 1{
                mo[0].update(fromCloudRecord: cloudSource)
            }else{
                print("error - too many MathObjects \(hashTag) -- \(mo.count)")
            }
        }catch{
            print("Fetch failed")
        }
    }
    
    class func createDBFeaturedURL(fromDataSource cloudSource: CKRecord){
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let ourFeaturedURLHashtag = cloudSource["ourFeaturedURLHashtag"] as! String

        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let request = FeaturedURL.createFetchRequest()
        request.predicate = NSPredicate(format: "ourFeaturedURLHashtag == %@", ourFeaturedURLHashtag)
        do{
            let furl = try container.viewContext.fetch(request)
            if furl.count == 0{
                let newFeature = FeaturedURL(context: container.viewContext)
                newFeature.update(fromCloudRecord: cloudSource)
            }else if furl.count == 1{
                furl[0].update(fromCloudRecord: cloudSource)
            }else{
                print("error - too many featuredURLS \(ourFeaturedURLHashtag) -- \(furl.count)")
            }
        }catch{
            print("Fetch failed")
        }
    }
    
    class func createOrUpdateDBMathObjectLinks(fromDataSource cloudSource: CKRecord){
        let ourMathObjectLinkHashTag = cloudSource["ourMathObjectLinkHashTag"] as! String
        
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let request = MathObjectLink.createFetchRequest() //QQQQ name of object is singular or plural?
        request.predicate = NSPredicate(format: "ourMathObjectLinkHashTag == %@", ourMathObjectLinkHashTag)
        do{
            let mol = try container.viewContext.fetch(request)
            if mol.count == 0{
                let newMathObjectLink = MathObjectLink(context: container.viewContext)
                newMathObjectLink.update(fromCloudRecord: cloudSource)
            }else if mol.count == 1{
                mol[0].update(fromCloudRecord: cloudSource)
            }else{
                print("error - too many MathObjectLinks \(ourMathObjectLinkHashTag) -- \(mol.count)")
            }
        }catch{
            print("Fetch failed")
        }
    }
    
    class func readVideoDataFromCloud(_ inCollection: Bool){
        let pred1 = NSPredicate(format: "modificationDate > %@", latestVideoDate! as NSDate)
        let pred2 = NSPredicate(format: "isInVideoCollection = %@", NSNumber(booleanLiteral: inCollection))
        let pred = inCollection ? NSCompoundPredicate(andPredicateWithSubpredicates: [pred1, pred2]) : pred1
        
        let query = CKQuery(recordType: "Video", predicate: pred)
        
        let operation = CKQueryOperation(query: query)
        //operation.qualityOfService = .userInteractive //QQQQ this is maybe abusive - but may speed up
        //operation.resultsLimit = queryOperationResultLimit
        
        videoNum = 0
        operation.recordFetchedBlock = populate(withVideoRecord:)
        
        var gotCursor = false
        
        operation.queryCompletionBlock = { (cursor, error) in
            if error == nil{
                //print("no error")
                if cursor != nil{
                    gotCursor = true
                    fetchVideoRecords(withCursor: cursor!)
                }
            }else{
                print("\(error!.localizedDescription)")
            }
        }
        
        operation.completionBlock = {
//            print("readVideoMetaDataFromCloud COMPLETION BLOCK")
//            DispatchQueue.main.async {
//                EpsilonStreamDataModel.setLatestDates() //QQQQ not clear if best here --
//            }
            if gotCursor == false{
                finishedVideos = true
                onFinish() //QQQQ should this be in a mutex?
            }//otherwise will be set by fetchVideoRecords()
        }
        
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    class func populate(withVideoRecord record: CKRecord){
        print("Video - RECORD FETCHED BLOCK -- \(videoNum)")
        videoNum = videoNum + 1 //QQQQ handle cursurs???
        //print("Got Video with timestamp: \(record["modificationDate"] as! Date)")
        DispatchQueue.main.async{
            createDBVideo(fromDataSource: record)
        }
    }
    
    class func fetchVideoRecords(withCursor cursor: CKQueryCursor){
        let operation = CKQueryOperation(cursor: cursor)
        //operation.qualityOfService = .userInteractive
        operation.recordFetchedBlock = populate(withVideoRecord:)
        
        operation.queryCompletionBlock = { (cursor, error) in
            if error == nil{
                //print("no error")
                if cursor != nil{
                    fetchVideoRecords(withCursor: cursor!)
                }else{
                    finishedVideos = true
                    onFinish() //QQQQ should this be in a mutex?
                }
            }else{
                print("\(error!.localizedDescription)")
            }
        }
        
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    //QQQQ add inCollectionFilter (also to Features and MathObjectLinks)
    class func readMathObjectsFromCloud(){
        let pred = NSPredicate(format: "modificationDate > %@", latestMathObjectDate! as NSDate)
        let query = CKQuery(recordType: "MathObject", predicate: pred)
        
        let operation = CKQueryOperation(query: query)
        operation.resultsLimit = queryOperationResultLimit

        var num = 0
        operation.recordFetchedBlock = { record in
            print("MathObject - RECORD FETCHED BLOCK -- \(num)")
            num = num + 1 //QQQQ handle cursurs???
            //print(record.recordChangeTag)
            //print(record.modificationDate)
            DispatchQueue.main.async{
                createOrUpdateDBMathObject(fromDataSource: record)
            }
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
            finishedMathObjects = true
            onFinish() //QQQQ should this be in a mutex?
        }
        
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    class func readMathObjectLinksFromCloud(){
        let pred = NSPredicate(format: "modificationDate > %@", latestMathObjectDate! as NSDate)
        let query = CKQuery(recordType: "MathObjectLinks", predicate: pred)
        
        let operation = CKQueryOperation(query: query)
        operation.resultsLimit = queryOperationResultLimit
        
        var num = 0
        operation.recordFetchedBlock = { record in
            print("MathObjectLinks - RECORD FETCHED BLOCK -- \(num)")
            num = num + 1 //QQQQ handle cursurs???
            DispatchQueue.main.async{
                createOrUpdateDBMathObjectLinks(fromDataSource: record)
            }
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
            finishedMathObjectLinks = true
            onFinish() //QQQQ should this be in a mutex?
        }
        
        CKContainer.default().publicCloudDatabase.add(operation)
    }

    
    
    //QQQQ currently not used
    class func readAllImagesFromCloud(){
        
        //QQQQ shortcirciut this
        finishedImages = true
        return;
        
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
            finishedImages = true
            onFinish() //QQQQ should this be in a mutex?
        }
        
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    class func readFeaturedURLsFromCloud(){
        let pred = NSPredicate(format: "modificationDate > %@", latestFeatureDate! as NSDate)
        let query = CKQuery(recordType: "FeaturedURL", predicate: pred)
        
        let operation = CKQueryOperation(query: query)
        operation.resultsLimit = queryOperationResultLimit //QQQQ
        
        var num = 0
        operation.recordFetchedBlock = { record in
            print("Featured URL - RECORD FETCHED BLOCK -- \(num)")
            num = num + 1 //QQQQ handle cursurs???
            DispatchQueue.main.async{
                createDBFeaturedURL(fromDataSource: record)
            }
        }
        
        operation.queryCompletionBlock = { (cursor, error) in
            //print("readFeaturedURLsFromCloud OPERATION COMPLETE BLOCK")
            DispatchQueue.main.async{
                if error == nil{
//                    print("no error")
                }
                else{
                    print("\(error!.localizedDescription)")
                }
            }
        }
        
        operation.completionBlock = {
            //print("readFeaturedURLsFromCloud COMPLETION BLOCK")
//            DispatchQueue.main.async {
//                EpsilonStreamDataModel.setLatestDates() //QQQQ not clear if best here --
//            }
            finishedFeaturedURLs = true
            onFinish() //QQQQ should this be in a mutex?
        }
        
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
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
        let pred = NSPredicate(format: "keyName == %@", key)
        let query = CKQuery(recordType: "LightImageThumbNail", predicate: pred)
        
        let operation = CKQueryOperation(query: query)
        operation.resultsLimit = 1
        
        operation.recordFetchedBlock = { record in
                ImageManager.storeImage(fromRecord: record, withKey: key)
        }
        
        operation.queryCompletionBlock = { (cursor, error) in
            if error == nil{
            }else{
                print("\(error!.localizedDescription)")
            }
        }
        operation.completionBlock = {}
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    class func backgroundScan(){
   
        var counter = 0
        
        while true{
            sleep(10)
            switch counter % 9{
            case 0:
                print("refresh images")
             //   DispatchQueue.main.async { //QQQQ this could take some time???
             //   ImageManager.refreshImageManager()
             //   }
                EpsilonStreamDataModel.saveViewContext()
            case 1:
                print("clean videos")
                DispatchQueue.main.async {
                    EpsilonStreamDataModel.videoIntegrityCheck()
                }
            case 2:
                print("clean features")
            case 3:
                print("clean math objects")
            case 3:
                print("clean math math object links")
            case 4:
                print("fetch videos")
            case 5:
                print("fetch math objects")
            case 6:
                print("fetch math object links")
            case 7:
                print("fetch epsilon stream info")
            case 8:
                print("fetch features")
                //readFeaturedURLsFromCloud()
            default:
                break
            }
            counter += 1
            if counter % 100 == 0{
                FIRAnalytics.logEvent(withName: "background_long_cycle", parameters: ["counter" : counter as NSObject])
            }
        }
    }
    
    //QQQQ temp - delete this
    class func mathObjectLinkDummyMake(){
        
        //create a dummy MathObjectLink if one doesn't exist.
        let request = MathObjectLink.createFetchRequest()
        do{
            let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
            let mathObjectLinks = try container.viewContext.fetch(request)
            if mathObjectLinks.count == 0{
                let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
                let mol = MathObjectLink(context: container.viewContext)
                mol.hashTags = "#binary"
                mol.imageKey = "NO IMAGE"
                mol.ourTitle = "Binary on Exploding Dots"
                mol.searchTitle = "ED-Binary" //QQQQ Emoji

               // EpsilonStreamDataModel.saveViewContext()

            }
        
        }catch{
            print("Fetch failed")
        }
    }
}
