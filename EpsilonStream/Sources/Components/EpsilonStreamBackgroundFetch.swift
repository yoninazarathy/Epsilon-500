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

    static var readRecordsCount = [String: Int]()
    static var videoNum = 0
    static var videoCount = [String: Int]()
    static var peekVideoDone = false

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
        
        if isReady {
            didItOnce = true
            PersistentStorageManager.shared.saveMainContext()
            
            EpsilonStreamDataModel.setUpAutoCompleteLists(withContext: PersistentStorageManager.shared.newBackgroundContext() )
            
            DispatchQueue.main.async {
                //EpsilonStreamDataModel.setUpAutoCompleteLists(withContext: mainContext)
                EpsilonStreamDataModel.setLatestDates()
                ImageManager.setup()
                
                DispatchQueue.global(qos: .background).async{
                    EpsilonStreamBackgroundFetch.backgroundScan()
                }
                
                UserDataManager.lastDatabaseUpdateDate = Date()
                dbReadyToGo = true
            }
        }
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
            if numBackGroundActionsInProgress < 0 {
                DLog("Error: negative numBackGroundActionsInProgress")//QQQQ assert
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
                Analytics.logEvent("background_long_cycle", parameters: ["counter" : counter as NSObject])
            }
        }
    }
    
    // MARK: - Factory methods
    
    class func defaultQueryCompletionBlock() -> ((CKQueryCursor?, Error?) -> Void) {
        let block = { (cursor: CKQueryCursor?, error: Error?) -> Void in
            if error != nil {
                DLog("\(error!.localizedDescription)")
            }
        }
        return block
    }
    
    class func modificationDateSortDescriptor() -> NSSortDescriptor {
        return NSSortDescriptor(key: "modificationDate", ascending: true)
    }
    
    class func defaultSortDescriptors() -> [NSSortDescriptor] {
        return [modificationDateSortDescriptor()]
    }
    
    // MARK: - Save to local database
    
    class func createDBVideo(fromDataSource cloudSource: CKRecord){
        //unique key
        //let videoID = cloudSource["youtubeVideoId"] as! String
        let newVideo = Video(inContext: mainContext)
        newVideo.update(fromCloudRecord: cloudSource)
    }
    
    class func createOrUpdateDBMathObject(fromDataSource cloudSource: CKRecord){
        
        let hashTag = cloudSource["hashTag"] as! String
        
        let request = MathObject.createFetchRequest()
        request.predicate = NSPredicate(format: "hashTag == %@", hashTag)
        do {
            let mo = try mainContext.fetch(request)
            if mo.count == 0 {
                let newMathObject = MathObject(inContext: mainContext)
                newMathObject.update(fromCloudRecord: cloudSource)
            } else if mo.count == 1 {
                mo[0].update(fromCloudRecord: cloudSource)
            } else {
                print("error - too many MathObjects \(hashTag) -- \(mo.count)")
            }
        } catch {
            print("Fetch failed")
        }
    }
    
    class func createDBFeaturedURL(fromDataSource cloudSource: CKRecord){
        //let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let ourFeaturedURLHashtag = cloudSource["ourFeaturedURLHashtag"] as! String
        
        let request = FeaturedURL.createFetchRequest()
        request.predicate = NSPredicate(format: "ourFeaturedURLHashtag == %@", ourFeaturedURLHashtag)
        do{
            let furl = try mainContext.fetch(request)
            if furl.count == 0{
                let newFeature = FeaturedURL(inContext: mainContext)
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
            let mol = try mainContext.fetch(request)
            if mol.count == 0{
                let newMathObjectLink = MathObjectLink(inContext: mainContext)
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
    
    // MARK: - Read from cloud kit
    
    class func readRecordsFromCloud(recordTypeName: String, cursor: CKQueryCursor? = nil, latestDate: Date,
                                    saveRecordBlock: @escaping (CKRecord) -> (), completion: @escaping () -> ()) {

        let operation: CKQueryOperation
        
        if cursor != nil {
            
            operation = CKQueryOperation(cursor: cursor!)
            
        } else {
            
            readRecordsCount[recordTypeName] = 0
            
            let predicate = NSPredicate(format: "modificationDate > %@", latestDate as NSDate)
            let query = CKQuery(recordType: recordTypeName, predicate: predicate)
            query.sortDescriptors = defaultSortDescriptors()
    
            operation = CKQueryOperation(query: query)
            
        }
        
        operation.recordFetchedBlock = { record in
            readRecordsCount[recordTypeName]! += 1
            if isInAdminMode {
                DLog("\(recordTypeName) - RECORD FETCHED BLOCK - \(readRecordsCount[recordTypeName]!)")
            }
            DispatchQueue.main.async {
                saveRecordBlock(record)
            }
        }
        
        operation.queryCompletionBlock = { (cursor: CKQueryCursor?, error: Error?) -> Void in
            if error != nil {
                DLog("\(error!.localizedDescription)")
            }
            
            if cursor != nil {
                
                readRecordsFromCloud(recordTypeName: recordTypeName, cursor: cursor, latestDate: latestDate,
                                     saveRecordBlock: saveRecordBlock, completion: completion)
                
            } else {
                
                DLog("\(recordTypeName) finish fetch records. Count: \(readRecordsCount[recordTypeName]!)")
                completion()
                
            }
        }
        
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    class func readVideoDataFromCloud(_ inCollection: Bool) {
        
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
            //            DispatchQueue.main.async {
            //                EpsilonStreamDataModel.setLatestDates() //QQQQ not clear if best here --
            //            }
            if gotCursor == false {
                DLog("Video records fetched. Count: \(videoNum)")
                finishedVideos = true
                onFinish() //QQQQ should this be in a mutex?
                //QQQQ is this really called after the last fetchVideoRecords??? Could be a problem.
                EpsilonStreamBackgroundFetch.setActionFinish()
            }//otherwise will be set by fetchVideoRecords()
        }
        
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    class func populate(withVideoRecord record: CKRecord) {
        if let videoID = record["youtubeVideoId"] as? String {
            videoNum = videoNum + 1
            if isInAdminMode {
                DLog("Video - RECORD FETCHED BLOCK -- \(videoNum), \(videoID)")
            }
            DispatchQueue.main.async{
                var video: Video! = nil
                let vids = EpsilonStreamDataModel.videos(ofYoutubeId: videoID)
                
                if vids.count == 0{ //new video
                    video = Video(inContext: mainContext)
                }else{
                    video = vids[0]
                    if vids.count > 1{
                        print("error too many videos")
                    }
                }
                video.update(fromCloudRecord: record)
            }
        } else {
            print("error got no video id on video from cloud")
        }
    }
    
    class func fetchVideoRecords(withCursor cursor: CKQueryCursor){
        let operation = CKQueryOperation(cursor: cursor)
        //operation.qualityOfService = .userInteractive
        operation.recordFetchedBlock = populate(withVideoRecord:)
        
        operation.queryCompletionBlock = { (cursor, error) in
            if error == nil {
                //print("no error")
                if cursor != nil {
                    fetchVideoRecords(withCursor: cursor!)
                } else {
                    DLog("Video records fetched. Count: \(videoNum)")
                    finishedVideos = true
                    onFinish() //QQQQ should this be in a mutex?
                    EpsilonStreamBackgroundFetch.setActionFinish()
                }
            }else{
                print("\(error!.localizedDescription)")
            }
        }
        
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    class func gotRecord(withVideoRecord record: CKRecord){
        let videoID = record["youtubeVideoId"] as! String
        if let num = videoCount[videoID] {
            videoCount[videoID] = num + 1
        } else {
            videoCount[videoID] = 1
        }
    }
    
    class func peekVideoRecords(withCursor cursor: CKQueryCursor) {
        let operation = CKQueryOperation(cursor: cursor)
        //operation.qualityOfService = .userInteractive
        operation.recordFetchedBlock = gotRecord(withVideoRecord:)
        
        operation.queryCompletionBlock = { (cursor, error) in
            if error == nil {
                //print("no error")
                if cursor != nil {
                    peekVideoRecords(withCursor: cursor!)
                }else{
                    //onFinish() //QQQQ should this be in a mutex?
                    peekVideoDone = true
                    print("done")
                }
            } else {
                DLog("\(error!.localizedDescription)")
            }
        }
        
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    // This is for getting all the videos in the cloud and seeing what they are
    class func peekVideoDataFromCloud() {
        EpsilonStreamBackgroundFetch.setActionStart() //QQQQ?
        
        videoCount = [:]
        
        let query = CKQuery(recordType: "Video", predicate: NSPredicate(value: true) )
        query.sortDescriptors = defaultSortDescriptors()
        
        let operation = CKQueryOperation(query: query)
        operation.recordFetchedBlock = gotRecord(withVideoRecord:)
        
        var gotCursor = false
        
        operation.queryCompletionBlock = { (cursor, error) in
            if error == nil{
                //print("no error")
                if cursor != nil {
                    gotCursor = true
                    peekVideoRecords(withCursor: cursor!)
                }
            } else {
                print("\(error!.localizedDescription)")
            }
        }
        
        operation.completionBlock = {
            if gotCursor == false {
                //QQQQ is this really called after the last fetchVideoRecords??? Could be a problem.
                EpsilonStreamBackgroundFetch.setActionFinish()
            }//otherwise will be set by fetchVideoRecords()
        }
        
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    //QQQQ add inCollectionFilter (also to Features and MathObjectLinks)
    class func readMathObjectsFromCloud() {
        EpsilonStreamBackgroundFetch.setActionStart()
        
        readRecordsFromCloud(recordTypeName: String(describing: MathObject.self), latestDate: latestMathObjectDate, saveRecordBlock: { (record) in
            createOrUpdateDBMathObject(fromDataSource: record)
        }) {
            finishedMathObjects = true
            onFinish() //QQQQ should this be in a mutex?
            EpsilonStreamBackgroundFetch.setActionFinish()
        }
    }
    
    class func readMathObjectLinksFromCloud() {
        EpsilonStreamBackgroundFetch.setActionStart()
        
        readRecordsFromCloud(recordTypeName: "MathObjectLinks", latestDate: latestMathObjectLinkDate, saveRecordBlock: { (record) in
            createOrUpdateDBMathObjectLinks(fromDataSource: record)
        }) {
            finishedMathObjectLinks = true
            onFinish() //QQQQ should this be in a mutex?
            EpsilonStreamBackgroundFetch.setActionFinish()
        }
    }
    
    class func readFeaturedURLsFromCloud() {
        EpsilonStreamBackgroundFetch.setActionStart()
        
        readRecordsFromCloud(recordTypeName: String(describing: FeaturedURL.self), latestDate: latestFeatureDate, saveRecordBlock: { (record) in
            createDBFeaturedURL(fromDataSource: record)
        }) {
            finishedFeaturedURLs = true
            onFinish() //QQQQ should this be in a mutex?
            EpsilonStreamBackgroundFetch.setActionFinish()
        }
    }

}

