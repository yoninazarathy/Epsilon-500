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
    
    static var isUpdatingNow = false
    static var finishedVideos = false
    static var finishedMathObjects = false
    static var finishedFeaturedURLs = false
    static var finishedImages = false
    
    class func runUpdate(){//onBuffer buffer: Int, withVersion version: Int64){
        
        DispatchQueue.main.async(){
            EpsilonStreamBackgroundFetch.pullEpsilonStreamInfo()
        }
        
        DispatchQueue.main.async(){
            while infoReadyToGo == false{
                sleep(1)
                print("waiting for infoReadyToGo")
            }
            
            finishedImages = false
            readAllImagesFromCloud()

            finishedMathObjects = false
            readMathObjectsFromCloud()
        
            finishedVideos = false
            readVideoDataFromCloud()
        
            finishedFeaturedURLs = false
            readFeaturedURLsFromCloud()
        }
    }
    
    class func onFinish(){
        dbReadyToGo = finishedVideos && finishedFeaturedURLs &&  finishedMathObjects && finishedImages
        
        if dbReadyToGo{
            EpsilonStreamDataModel.setUpAutoCompleteLists()
        }
    }
    
    class func createDBVideo(fromDataSource cloudSource: CKRecord){
        //unique key
        let videoID = cloudSource["youtubeVideoId"] as! String
        
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    
        let newVideo = Video(context: container.viewContext)

        newVideo.oneOnEpsilonTimeStamp = cloudSource["modificationDate"] as! Date
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
        

        //QQQQ why aren't all fields treated this way?
        // -- currently it is with caution since just added duration
        if let ds = cloudSource["durationSec"] as? Int32{
            newVideo.durationSec = ds
        }else{
            print("--- FOUND NO DURATION ---")
        }
        
        newVideo.imageURL = cloudSource["imageURL"] as! String
        
        //QQQQ not using it now
        //ImageManager.pushImageToGet(withKey: videoID,newVideo.isAwesome )
    }
    
    
    class func createDBMathObject(fromDataSource cloudSource: CKRecord){
        //unique key
        
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
            
        let newMathObject = MathObject(context: container.viewContext)
        
        newMathObject.oneOnEpsilonTimeStamp = cloudSource["modificationDate"] as! Date
        newMathObject.hashTag = cloudSource["hashTag"] as! String
        newMathObject.associatedTitles = cloudSource["associatedTitles"] as! String
        if let cr = cloudSource["curator"]{
            newMathObject.curator = cr as! String;
        }else{
            newMathObject.curator = "None";
        }
        
        if let rv = cloudSource["reviewer"]{
            newMathObject.reviewer = rv as! String;
        }else{
            newMathObject.reviewer = "None";
        }

    }
    
    class func createDBFeaturedURL(fromDataSource cloudSource: CKRecord){
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let newFeaturedURL = FeaturedURL(context: managedObjectContext)

        if let oneOnEpsilonTimeStamp = cloudSource["modificationDate"] as? Date{
            newFeaturedURL.oneOnEpsilonTimeStamp = oneOnEpsilonTimeStamp
        }else{
            //QQQQ report error
            print("DB error with \(cloudSource)")
            return
        }

        if let hashTags = cloudSource["hashTags"] as? String{
            newFeaturedURL.hashTags = hashTags
        }else{
            //QQQQ report error
            print("DB error with \(cloudSource)")
            return
        }
        
        if let urlOfItem = cloudSource["urlOfItem"] as? String{
            newFeaturedURL.urlOfItem = urlOfItem
        }else{
            //QQQQ report error
            print("DB error with \(cloudSource)")
            return
        }

        if let imageKey = cloudSource["imageKey"] as? String{
            newFeaturedURL.imageKey = imageKey
        }else{
            //QQQQ report error
            print("DB error with \(cloudSource)")
            return
        }
        if let imageURL = cloudSource["imageURL"] as? String{
            newFeaturedURL.imageURL = imageURL
        }else{
            //QQQQ report error
            print("DB error with \(cloudSource)")
            return
        }
        
        if let ourTitle = cloudSource["ourTitle"] as? String{
            newFeaturedURL.ourTitle = ourTitle
        }else{
            //QQQQ report error
            print("DB error with \(cloudSource)")
            return
        }
        
        if let ourDescription = cloudSource["ourDescription"] as? String{
            newFeaturedURL.ourDescription = ourDescription
        }else{
            //QQQQ report error
            print("DB error with \(cloudSource)")
            return
        }
        
        if let ourFeaturedURLHashtag = cloudSource["ourFeaturedURLHashtag"] as? String{
            newFeaturedURL.ourFeaturedURLHashtag = ourFeaturedURLHashtag
        }else{
            //QQQQ report error
            print("DB error with \(cloudSource)")
            return
        }
        
        if let isAppStoreApp = cloudSource["isAppStoreApp"] as? Bool{
            newFeaturedURL.isAppStoreApp = isAppStoreApp
        }else{
            //QQQQ report error
            print("DB error with \(cloudSource)")
            return
        }
        
        if let provider = cloudSource["provider"] as? String{
            newFeaturedURL.provider = provider
        }else{
            //QQQQ report error
            print("DB error with \(cloudSource)")
            return
        }
        
        if let typeOfFeature = cloudSource["typeOfFeature"] as? String{
            newFeaturedURL.typeOfFeature = typeOfFeature
        }else{
            //QQQQ report error
            print("DB error with \(cloudSource)")
            return
        }
        
        ImageManager.pushImageToGet(withKey: newFeaturedURL.imageKey!)
    }
    
    static var videoNum = 0
    
    class func readVideoDataFromCloud(){//withVersion version: Int64){
        let pred = NSPredicate(format: "modificationDate > %@", latestVideoDate! as NSDate)
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
        print("Got Video with timestamp: \(record["modificationDate"] as! Date)")
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
            print(record.modificationDate)
            
            createDBMathObject(fromDataSource: record)
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

            print(record.modificationDate, obtainedKey)
            
            
            ImageManager.storeImage(fromRecord: record, withKey: obtainedKey)

            
            //createDBMathObject(fromDataSource: record)
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
            print("GOT IMAGE: ----- \(obtainedKey)")
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
        
        operation.completionBlock = {
        }
        
        CKContainer.default().publicCloudDatabase.add(operation)
    }
}
