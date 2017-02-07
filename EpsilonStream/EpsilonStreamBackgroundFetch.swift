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


//QQQQ need to organize so this class is more for cloud and the other class is more for core data...?

class EpsilonStreamBackgroundFetch{
    
    static var searcherUI: SearcherUI! = nil
    
    static var needUpdate: Bool? = nil
    
    static var pullEpsilonStreamInfoInProgress = false
    static var epsilonStreamInfoRecord: CKRecord? = nil
    
    class func pullEpsilonStreamInfo(){
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let query = CKQuery(recordType: "EpsilonStreamInfo", predicate: predicate)

        let operation = CKQueryOperation(query: query)
        operation.resultsLimit = 1
        
        operation.recordFetchedBlock = { record in
            DispatchQueue.main.async {//In which context to run it?
                updateEpsilonStreamInfoInDB(fromDataSource: record)
            }
        }
        
        operation.queryCompletionBlock = { (cursor, error) in
            //print("readVideoMetaDataFromCloud OPERATION COMPLETE BLOCK")
            DispatchQueue.main.async{
                if error == nil{
                    //print("no error")
                }
                else{
                    print("\(error!.localizedDescription)")
                }
            }
        }
        
        operation.completionBlock = {
            DispatchQueue.main.async {
                EpsilonStreamBackgroundFetch.pullEpsilonStreamInfoInProgress = false
            }
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
        let otherBuffer = 1-currentDBBuffer
        request.predicate = NSPredicate(format: "bufferIndex == %@", otherBuffer as NSNumber)
        
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
        
        versionInfo.bufferIndex = Int64(otherBuffer)
        
        EpsilonStreamDataModel.saveViewContext()
    }
    
    //check locally for updates
    class func checkForUpdates(){
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let request = VersionInfo.createFetchRequest()
        let otherBuffer = 1-currentDBBuffer
        let sort = NSSortDescriptor(key: "bufferIndex", ascending: true)
        request.sortDescriptors = [sort]

        do{
            let versionInfo = try container.viewContext.fetch(request)
            if versionInfo.count > 2{
                print("error - too many version info objects")
            }else if versionInfo.count == 0{
                //nothing to do - need to wait for version
            }else if versionInfo.count == 1{
                (UIApplication.shared.delegate as! AppDelegate).flipCurrentDBBuffer()
                DispatchQueue.main.async {
                    EpsilonStreamBackgroundFetch.pullEpsilonStreamInfo()//QQQQ could interfere with background one...
                }
                //This should be the "case" when just installing
                //check if need update
                //print("VERSION NUMBER: \(versionInfo[0].contentVersionNumber)")
            }else{
                let lv = EpsilonStreamDataModel.latestVersion()
                let llv = EpsilonStreamDataModel.latestLoadedVersion()
                let numVidBuff0 = EpsilonStreamDataModel.numVideos(onBuffer: 0)
                let numVidBuff1 = EpsilonStreamDataModel.numVideos(onBuffer: 1)
                let numMOBuff0 = EpsilonStreamDataModel.numMathObjects(onBuffer: 0)
                let numMOBuff1 = EpsilonStreamDataModel.numMathObjects(onBuffer: 1)
                let numFUBuff0 = EpsilonStreamDataModel.numFeaturedURLs(onBuffer: 0)
                let numFUBuff1 = EpsilonStreamDataModel.numFeaturedURLs(onBuffer: 1)

                print("-------------------")
                print("DBindex: \(currentDBBuffer).\n Vinfo[0]: \(versionInfo[0].contentVersionNumber). Vinfo[0].loaded: \(versionInfo[0].loaded).  Vinfo[1]: \(versionInfo[1].contentVersionNumber). Vinfo[1].loaded: \(versionInfo[1].loaded).\n latest: \(lv). latestLoaded: \(llv).\n numVid_0: \(numVidBuff0). numVid_1: \(numVidBuff1). numMO_0: \(numMOBuff0). numMO_1: \(numMOBuff1). numFU_0: \(numFUBuff0). numFU_1: \(numFUBuff1)")
                print("-------------------")

                
                if lv > llv{
                    //(versionInfo[otherBuffer].loaded == false && versionInfo[otherBuffer].contentVersionNumber > lv) ||
                    //(versionInfo[otherBuffer].loaded == false && versionInfo[currentDBBuffer].loaded == false){
                    runUpdate(onBuffer: otherBuffer, withVersion: versionInfo[otherBuffer].contentVersionNumber)
                }
                
            }
        }catch{
            print("Fetch failed")
        }
    }
    
    static var isUpdatingNow = false
    static var finishedVideos = false
    static var finishedMathObjects = false
    static var finishedFeaturedURLs = false
    
    class func runUpdate(onBuffer buffer: Int, withVersion version: Int64){
        if isUpdatingNow == true{
            return
        }else{
            isUpdatingNow = true
        }
        print("runUpdate onBuffer: \(buffer)")
        
        //The delete here is needed for cases where update operation is aborted in process
        EpsilonStreamDataModel.deleteAllMathObjects(ofBuffer: 1-currentDBBuffer)
        EpsilonStreamDataModel.deleteAllVideos(ofBuffer: 1-currentDBBuffer)
        EpsilonStreamDataModel.deleteAllFeaturedURLs(ofBuffer: 1-currentDBBuffer)
        
        finishedMathObjects = false
        readMathObjectsFromCloud(withVersion: version)
        
        finishedVideos = false
        readVideoDataFromCloud(withVersion: version)
        
        finishedFeaturedURLs = false
        readFeaturedURLsFromCloud(withVersion: version)
        
        
        
    }
    
    class func onFinish(){
        if finishedVideos && finishedMathObjects && finishedFeaturedURLs{
            let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
            let request = VersionInfo.createFetchRequest()
            request.predicate = NSPredicate(format: "bufferIndex == %@", 1-currentDBBuffer as NSNumber)
            
            do{
                let results = try container.viewContext.fetch(request)
                if results.count != 1 {
                    print("error with number of VersionInfos")
                }else{
                    for result in results{ //this should loop only once
                        result.loaded = true
                    }
                }
            }catch{
                print("Fetch failed")
            }

            EpsilonStreamDataModel.saveViewContext()
            
            (UIApplication.shared.delegate as! AppDelegate).flipCurrentDBBuffer()
            
            EpsilonStreamDataModel.deleteAllMathObjects(ofBuffer: 1-currentDBBuffer)
            EpsilonStreamDataModel.deleteAllVideos(ofBuffer: 1-currentDBBuffer)
            EpsilonStreamDataModel.deleteAllFeaturedURLs(ofBuffer: 1-currentDBBuffer)
            
            DispatchQueue.main.async {
                searcherUI.refreshSearch()
            }
            
            isUpdatingNow = false
            print("FINISHED UPDATE AND SWITCH.")
        }else{
            print("onFinish() but still not finished")
        }
    }
    
    class func createDBVideo(fromDataSource cloudSource: CKRecord){
        //unique key
        let videoID = cloudSource["youtubeVideoId"] as! String
        
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    
        let newVideo = Video(context: container.viewContext)

        newVideo.oneOnEpsilonTimeStamp = cloudSource["oneOnEpsilonTimeStamp"] as! Date
        newVideo.age8Rating = cloudSource["age8Rating"] as! Float
        newVideo.age10Rating = cloudSource["age10Rating"] as! Float
        newVideo.age12Rating = cloudSource["age12Rating"] as! Float
        newVideo.age14Rating = cloudSource["age14Rating"] as! Float
        newVideo.age16Rating = cloudSource["age16Rating"] as! Float
        newVideo.exploreVsUnderstand = cloudSource["exploreVsUnderstand"] as! Float
        newVideo.isAwesome = cloudSource["isAwesome"] as! Bool
        newVideo.isInVideoCollection = cloudSource["isInVideoCollection"] as! Bool
        newVideo.ourTitle = cloudSource["ourTitle"] as! String
        newVideo.commentAndReview = cloudSource["commentAndReview"] as! String
        newVideo.channelKey = cloudSource["channelKey"] as! String
        newVideo.whyVsHow = cloudSource["whyVsHow"] as! Float
        newVideo.youtubeTitle = cloudSource["youtubeTitle"] as! String
        newVideo.youtubeVideoId = videoID
        newVideo.hashTags = cloudSource["hashTags"] as! String
        
        let otherBuffer = Int64(1-currentDBBuffer)
        newVideo.bufferIndex = otherBuffer //QQQQ a bit messy here

        //QQQQ why aren't all fields treated this way?
        // -- currently it is with caution since just added duration
        if let ds = cloudSource["durationSec"] as? Int32{
            newVideo.durationSec = ds
        }else{
            print("--- FOUND NO DURATION ---")
        }
        
        newVideo.imageURL = cloudSource["imageURL"] as! String
        
        storeImage(fromRecord: cloudSource, withVideo: newVideo, withKey: newVideo.youtubeVideoId)
    }
    
    
    //QQQQ doc and factor
    class func storeImage(fromRecord record: CKRecord, withVideo video: Video, withKey key: String){
        if let asset = record["imagePic"] as? CKAsset{
            do{
                let data = try Data(contentsOf: asset.fileURL)
                let image = UIImage(data: data)
                video.imageURLlocal = ImageManager.store(image!, withKey: key)
                //print("STORING URL: \(video.imageURLlocal)")
            }catch{
                print("err with image")
            }
        }else{
            print("NO ASSET - with image")
            video.imageURLlocal = nil
        }
    }

    
    class func createDBMathObject(fromDataSource cloudSource: CKRecord){
        //unique key
        let hashTag = cloudSource["hashTag"] as! String
            
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
            
        let newMathObject = MathObject(context: container.viewContext)
        
        newMathObject.oneOnEpsilonTimeStamp = cloudSource["oneOnEpsilonTimeStamp"] as! Date
        newMathObject.hashTag = cloudSource["hashTag"] as! String
        newMathObject.associatedTitles = cloudSource["associatedTitles"] as! String
        
        let otherBuffer = Int64(1-currentDBBuffer)
        newMathObject.bufferIndex = otherBuffer //QQQQ a bit messy here
    }
    
    class func createDBFeaturedURL(fromDataSource cloudSource: CKRecord){
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let newFeaturedURL = FeaturedURL(context: managedObjectContext)

        newFeaturedURL.oneOnEpsilonTimeStamp = cloudSource["oneOnEpsilonTimeStamp"] as! Date
        newFeaturedURL.urlOfItem = cloudSource["urlOfItem"] as! String
        newFeaturedURL.hashTags = cloudSource["hashTags"] as! String
        newFeaturedURL.imageURL = cloudSource["imageURL"] as! String
        newFeaturedURL.imageURLlocal = nil //QQQQ //cloudSource["imagePic"]  nil //QQQQ
        newFeaturedURL.ourTitle = cloudSource["ourTitle"] as! String
        newFeaturedURL.ourDescription = cloudSource["ourDescription"] as! String
        newFeaturedURL.ourFeaturedURLHashtag = cloudSource["ourFeaturedURLHashtag"] as! String
        newFeaturedURL.isAppStoreApp = cloudSource["isAppStoreApp"] as! Bool
        
        let otherBuffer = Int64(1-currentDBBuffer)
        newFeaturedURL.bufferIndex = otherBuffer //QQQQ a bit messy here
        
    }
    
    static var videoNum = 0
    
    class func readVideoDataFromCloud(withVersion version: Int64){
        //print("UPON READ VIDEO FETCH REQUEST latestVideoDate: \(latestVideoDate)")
        //let datePredicate = NSPredicate(format: "oneOnEpsilonTimeStamp > %@", latestVideoDate! as NSDate)
        let pred = NSPredicate(format: "contentVersionNumber <= %@", version as NSNumber)
        let query = CKQuery(recordType: "Video", predicate: pred)
        
        let operation = CKQueryOperation(query: query)
        operation.qualityOfService = .userInteractive //QQQQ this is maybe abusive - but may speed up
        operation.resultsLimit = queryOperationResultLimit
        
        videoNum = 0
        operation.recordFetchedBlock = populate(withVideoRecord:)
        
        operation.queryCompletionBlock = { (cursor, error) in
            if error == nil{
                //print("no error")
                if cursor != nil{
                    fetchVideoRecords(withCursor: cursor!)
                }
            }else{
                print("\(error!.localizedDescription)")
            }
        }
        
        operation.completionBlock = {
            print("readVideoMetaDataFromCloud COMPLETION BLOCK")
//            DispatchQueue.main.async {
//                EpsilonStreamDataModel.setLatestDates() //QQQQ not clear if best here --
//            }
            finishedVideos = true
            onFinish() //QQQQ should this be in a mutex?
        }
        
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    class func populate(withVideoRecord record: CKRecord){
        print("Video - RECORD FETCHED BLOCK -- \(videoNum)")
        videoNum = videoNum + 1 //QQQQ handle cursurs???
        print("Got Video with timestamp: \(record["oneOnEpsilonTimeStamp"] as! Date)")
        createDBVideo(fromDataSource: record)
    }
    
    class func fetchVideoRecords(withCursor cursor: CKQueryCursor){
        let operation = CKQueryOperation(cursor: cursor)
        operation.qualityOfService = .userInteractive
        operation.recordFetchedBlock = populate(withVideoRecord:)
        
        operation.queryCompletionBlock = { (cursor, error) in
            if error == nil{
                //print("no error")
                if cursor != nil{
                    fetchVideoRecords(withCursor: cursor!)
                }
            }else{
                print("\(error!.localizedDescription)")
            }
        }
        
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    class func readMathObjectsFromCloud(withVersion version: Int64){
        let pred = NSPredicate(format: "contentVersionNumber <= %@", version as NSNumber)
        let query = CKQuery(recordType: "MathObject", predicate: pred)
        
        let operation = CKQueryOperation(query: query)
        operation.resultsLimit = queryOperationResultLimit

        var num = 0
        operation.recordFetchedBlock = { record in
            print("MathObject - RECORD FETCHED BLOCK -- \(num)")
            num = num + 1 //QQQQ handle cursurs???
            
            createDBMathObject(fromDataSource: record)
        }
        
        operation.queryCompletionBlock = { (cursor, error) in
            //print("readMathObjectsDataFromCloud OPERATION COMPLETE BLOCK")
            DispatchQueue.main.async{
                if error == nil{
                    EpsilonStreamDataModel.setUpAutoCompleteLists()
                }
                else{
                    print("\(error!.localizedDescription)")
                }
            }
        }
        
        operation.completionBlock = {
            //print("readMathObjectsDataFromCloud COMPLETION BLOCK")
//            DispatchQueue.main.async {
//                EpsilonStreamDataModel.setLatestDates() //QQQQ not clear if best here --
//            }
            finishedMathObjects = true
            onFinish() //QQQQ should this be in a mutex?
        }
        
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    class func readFeaturedURLsFromCloud(withVersion version: Int64){
        let pred = NSPredicate(format: "contentVersionNumber <= %@", version as NSNumber)
        let query = CKQuery(recordType: "FeaturedURL", predicate: pred)
        
        let operation = CKQueryOperation(query: query)
        var num = 0
        operation.recordFetchedBlock = { record in
            print("Featured URL - RECORD FETCHED BLOCK -- \(num)")
            num = num + 1 //QQQQ handle cursurs???
            
            createDBFeaturedURL(fromDataSource: record)
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
}
