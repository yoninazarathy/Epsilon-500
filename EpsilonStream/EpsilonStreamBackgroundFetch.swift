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

class EpsilonStreamBackgroundFetch: ManagedObjectContextUserProtocol {
    
    static var searcherUI: SearcherUI! = nil
    static var needUpdate: Bool? = nil
    static var pullEpsilonStreamInfoInProgress = false
    static var epsilonStreamInfoRecord: CKRecord? = nil
    
    static var isUpdatingNow = false
    static var finishedVideos = false
    static var finishedMathObjects = false
    static var finishedFeaturedURLs = false
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
        
        let versionInfo = VersionInfo(inContext: container.viewContext)
        
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
        finishedMathObjects = false
        finishedVideos = false
        finishedFeaturedURLs = false

        //QQQQ delete readAllImagesFromCloud()
        readMathObjectsFromCloud() //QQQQ implement for collection
        readMathObjectLinksFromCloud()
        
        //if not in admin mode only read videos in collection
        //otherwise (inAdminMode) read all videos
        readVideoDataFromCloud(isInAdminMode == false)
        readFeaturedURLsFromCloud()
    }
    
    //QQQQ This is a patch to make onFinish run only once.
    static var didItOnce = false
    
    class func onFinish(){
        if didItOnce{
            return
        }
        let isReady = finishedVideos && finishedFeaturedURLs &&  finishedMathObjects && finishedMathObjectLinks
        
        if isReady{
            didItOnce = true
            EpsilonStreamDataModel.saveViewContext()
            
            DispatchQueue.main.async{
                EpsilonStreamDataModel.setUpAutoCompleteLists()
                EpsilonStreamDataModel.setLatestDates()
                ImageManager.refreshImageManager()
                ImageManager.setup()
                
                DispatchQueue.global(qos: .background).async{
                    EpsilonStreamBackgroundFetch.backgroundScan()
                }
                
                UserDataManager.lastDatabaseUpdateDate = Date()
                dbReadyToGo = true
            }
        }
    }
    
    class func createOrUpdateDBMathObject(fromDataSource cloudSource: CKRecord){
        
        let hashTag = cloudSource["hashTag"] as! String
        
        let request = MathObject.createFetchRequest()
        request.predicate = NSPredicate(format: "hashTag == %@", hashTag)
        do{
            let mo = try managedObjectContext.fetch(request)
            if mo.count == 0{
                let newMathObject = MathObject(inContext: managedObjectContext)
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
        //let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let ourFeaturedURLHashtag = cloudSource["ourFeaturedURLHashtag"] as! String

        let request = FeaturedURL.createFetchRequest()
        request.predicate = NSPredicate(format: "ourFeaturedURLHashtag == %@", ourFeaturedURLHashtag)
        do{
            let furl = try managedObjectContext.fetch(request)
            if furl.count == 0{
                let newFeature = FeaturedURL(inContext: managedObjectContext)
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
        
        let request = MathObjectLink.createFetchRequest() //QQQQ name of object is singular or plural?
        request.predicate = NSPredicate(format: "ourMathObjectLinkHashTag == %@", ourMathObjectLinkHashTag)
        do{
            let mol = try managedObjectContext.fetch(request)
            if mol.count == 0{
                let newMathObjectLink = MathObjectLink(inContext: managedObjectContext)
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
        
        EpsilonStreamBackgroundFetch.setActionStart()

        let pred1 = NSPredicate(format: "modificationDate > %@", latestVideoDate! as NSDate)
        let pred2 = NSPredicate(format: "isInVideoCollection = %@", NSNumber(booleanLiteral: inCollection))
        let pred = inCollection ? NSCompoundPredicate(andPredicateWithSubpredicates: [pred1, pred2]) : pred1
        
        let query = CKQuery(recordType: "Video", predicate: pred)
        query.sortDescriptors = [NSSortDescriptor(key: "modificationDate", ascending: true)]

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
                //QQQQ is this really called after the last fetchVideoRecords??? Could be a problem.
                EpsilonStreamBackgroundFetch.setActionFinish()
            }//otherwise will be set by fetchVideoRecords()
        }
        
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    class func populate(withVideoRecord record: CKRecord){
        if let videoID = record["youtubeVideoId"] as? String{
            print("Video - RECORD FETCHED BLOCK -- \(videoNum), \(videoID)")
            videoNum = videoNum + 1
            DispatchQueue.main.async{
                let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
                var video: Video! = nil
                let vids = EpsilonStreamDataModel.videos(ofYoutubeId: videoID)
                
                if vids.count == 0{ //new video
                    video = Video(context: container.viewContext)
                }else{
                    video = vids[0]
                    if vids.count > 1{
                        print("error too many videos")
                    }
                }
                video.update(fromCloudRecord: record)
            }
        }else{
            print("error got no video id on video from cloud")
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
        
        EpsilonStreamBackgroundFetch.setActionStart()
        
        let pred = NSPredicate(format: "modificationDate > %@", latestMathObjectDate! as NSDate)
        let query = CKQuery(recordType: "MathObject", predicate: pred)
        query.sortDescriptors = [NSSortDescriptor(key: "modificationDate", ascending: true)]
        
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
            EpsilonStreamBackgroundFetch.setActionFinish()
        }
        
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    class func readMathObjectLinksFromCloud(){
        
        EpsilonStreamBackgroundFetch.setActionStart()
        
        let pred = NSPredicate(format: "modificationDate > %@", latestMathObjectLinkDate! as NSDate)
        let query = CKQuery(recordType: "MathObjectLinks", predicate: pred)
        query.sortDescriptors = [NSSortDescriptor(key: "modificationDate", ascending: true)]

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
            EpsilonStreamBackgroundFetch.setActionFinish()
        }
        
        CKContainer.default().publicCloudDatabase.add(operation)
    }

    
    

    
    class func readFeaturedURLsFromCloud(){
        
        EpsilonStreamBackgroundFetch.setActionStart()
        
        let pred = NSPredicate(format: "modificationDate > %@", latestFeatureDate! as NSDate)
        let query = CKQuery(recordType: "FeaturedURL", predicate: pred)
        query.sortDescriptors = [NSSortDescriptor(key: "modificationDate", ascending: true)]

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
            
            EpsilonStreamBackgroundFetch.setActionFinish()
        }
        
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    //indicates if any of the background actions is in progress at any given time
    //the idea is that at most action will be in progress at any given time
    //action progress is either initiated through user behaviour (sometimes in curation mode)
    //or it is a result of the background scan
    static var numBackGroundActionsInProgress = 0
    
    class func setActionStart(){
        //QQQQ synch semaphore problem (also in setActionFinish() method)
//        DispatchQueue.main.sync {
            numBackGroundActionsInProgress += 1
//        }
    }
    
    class func setActionFinish(){
//        DispatchQueue.main.sync {
            numBackGroundActionsInProgress -= 1
            if numBackGroundActionsInProgress < 0{
                print("error")//QQQQ assert
            }
//        }
    }
    
    
    class func backgroundScan(){
   
        var counter = 0

        while true{
            sleep(10)
            if numBackGroundActionsInProgress > 0{
                continue;
            }
            switch counter % 9{
            case 0:
                print("refresh images")
                //QQQQ I am worried that this happens in background thread
                //If we do it with main.async it freezes with many videos (in curate mode)
                ImageManager.refreshImageManager()
            case 1:
                print("clean videos")
                DispatchQueue.main.async {
                    EpsilonStreamDataModel.videoIntegrityCheck()
                }
            case 2:
                print("clean features")
                break
            case 3:
                print("clean math objects")
                break
            case 3:
                print("clean math math object links")
                break
            case 4:
                print("fetch videos")
                EpsilonStreamBackgroundFetch.readVideoDataFromCloud(isInAdminMode == false)
                break
            case 5:
                print("fetch math objects")
                EpsilonStreamBackgroundFetch.readMathObjectsFromCloud()
                break
            case 6:
                print("fetch math object links")
                EpsilonStreamBackgroundFetch.readMathObjectLinksFromCloud()
                break
            case 7:
                print("fetch epsilon stream info")

                break
            case 8:
                print("fetch features")
                EpsilonStreamBackgroundFetch.readFeaturedURLsFromCloud()
                break
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
            let mathObjectLinks = try managedObjectContext.fetch(request)
            if mathObjectLinks.count == 0{
                let mol = MathObjectLink(inContext: managedObjectContext)
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
    
    ///////////////////////////
    ///////////////////////////
    // This is for getting all the videos in the cloud and seeing what they are
    
    static var videoCount:[String:Int] = [:]
    static var peekVideoDone = false
    
    class func peekVideoDataFromCloud(){
        EpsilonStreamBackgroundFetch.setActionStart() //QQQQ?
        
        videoCount = [:]
        
        let query = CKQuery(recordType: "Video", predicate: NSPredicate(value:true))
        query.sortDescriptors = [NSSortDescriptor(key: "modificationDate", ascending: true)]
        
        let operation = CKQueryOperation(query: query)
        operation.recordFetchedBlock = gotRecord(withVideoRecord:)
        
        var gotCursor = false
        
        operation.queryCompletionBlock = { (cursor, error) in
            if error == nil{
                //print("no error")
                if cursor != nil{
                    gotCursor = true
                    peekVideoRecords(withCursor: cursor!)
                }
            }else{
                print("\(error!.localizedDescription)")
            }
        }
        
        operation.completionBlock = {
            if gotCursor == false{
                //QQQQ is this really called after the last fetchVideoRecords??? Could be a problem.
                EpsilonStreamBackgroundFetch.setActionFinish()
            }//otherwise will be set by fetchVideoRecords()
        }
        
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    class func gotRecord(withVideoRecord record: CKRecord){
        let videoID = record["youtubeVideoId"] as! String;
        if let num = videoCount[videoID]{
            videoCount[videoID] = num + 1
        }else{
            videoCount[videoID] = 1
        }
    }
    
    class func peekVideoRecords(withCursor cursor: CKQueryCursor){
        print("peekVideoRecords()")
        
        let operation = CKQueryOperation(cursor: cursor)
        //operation.qualityOfService = .userInteractive
        operation.recordFetchedBlock = gotRecord(withVideoRecord:)
        
        operation.queryCompletionBlock = { (cursor, error) in
            if error == nil{
                //print("no error")
                if cursor != nil{
                    peekVideoRecords(withCursor: cursor!)
                }else{
                    //onFinish() //QQQQ should this be in a mutex?
                    peekVideoDone = true
                    print("done")
                }
            }else{
                print("\(error!.localizedDescription)")
            }
        }
        
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
}
