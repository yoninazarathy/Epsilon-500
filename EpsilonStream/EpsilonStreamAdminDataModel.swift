//
//  EpsilonStreamAdminDataModel.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 23/1/17.
//  Copyright © 2017 Yoni Nazarathy. All rights reserved.
//

import Foundation
import CoreData
import CloudKit
import UIKit

//QQQQ When cleaning up this class and the other one (EpsilonStreamBackgroundFetch), make
//a distinction between admin app and client (user) app

class EpsilonStreamAdminModel{
    
    static var currentVideo: Video!
    static var currentMathObject: MathObject!
    static var currentFeature: FeaturedURL!
    static var currentChannel: Channel!
    
    ////////////////////////
    // Submit
    ////////////////////////
    
    class func submitVideo(){
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        EpsilonStreamDataModel.saveViewContext()
        
        let video = CKRecord(recordType: "Video")
        video["oneOnEpsilonTimeStamp"] = EpsilonStreamAdminModel.currentVideo.oneOnEpsilonTimeStamp as CKRecordValue
        video["age8Rating"] = EpsilonStreamAdminModel.currentVideo.age8Rating as CKRecordValue
        video["age10Rating"] = EpsilonStreamAdminModel.currentVideo.age10Rating as CKRecordValue
        video["age12Rating"] = EpsilonStreamAdminModel.currentVideo.age12Rating as CKRecordValue
        video["age14Rating"] = EpsilonStreamAdminModel.currentVideo.age14Rating as CKRecordValue
        video["age16Rating"] = EpsilonStreamAdminModel.currentVideo.age16Rating as CKRecordValue
        video["exploreVsUnderstand"] = EpsilonStreamAdminModel.currentVideo.exploreVsUnderstand as CKRecordValue
        video["imageURL"] = EpsilonStreamAdminModel.currentVideo.imageURL as CKRecordValue
        video["isAwesome"] = EpsilonStreamAdminModel.currentVideo.isAwesome as CKRecordValue
        video["isInVideoCollection"] = EpsilonStreamAdminModel.currentVideo.isInVideoCollection as CKRecordValue
        video["ourTitle"] = EpsilonStreamAdminModel.currentVideo.ourTitle as CKRecordValue
        video["commentAndReview"] = EpsilonStreamAdminModel.currentVideo.commentAndReview as CKRecordValue
        video["channelKey"] = EpsilonStreamAdminModel.currentVideo.channelKey as CKRecordValue
        video["durationSec"] = EpsilonStreamAdminModel.currentVideo.durationSec as CKRecordValue
        
        video["contentVersionNumber"] = tempCurrentVersionForSubmit as CKRecordValue//QQQQ temp - have in settings app
        
        //QQQQ is ok?
        if let str = EpsilonStreamAdminModel.currentVideo.imageURLlocal{
            //QQQQ same problem as in the other place with url2            let url = URL(string: str)!
            
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let url2 = documentsDirectory.appendingPathComponent("imageThumbnails").appendingPathComponent(EpsilonStreamAdminModel.currentVideo.youtubeVideoId).appendingPathExtension("png")
            
            //QQQQ no idea - why url is not working - as a workaround reconstructing path here...
            
            
            video["imagePic"] = CKAsset(fileURL: url2)//QQQQ
        }else{
            video["imagePic"] = nil
            print("No local URL for image - will try to cloud it without")
        }
        
        video["whyVsHow"] = EpsilonStreamAdminModel.currentVideo.whyVsHow as CKRecordValue
        video["youtubeTitle"] = EpsilonStreamAdminModel.currentVideo.youtubeTitle as CKRecordValue
        video["youtubeVideoId"] = EpsilonStreamAdminModel.currentVideo.youtubeVideoId as CKRecordValue
        video["hashTags"] = EpsilonStreamAdminModel.currentVideo.hashTags as CKRecordValue
        
        //QQQQ do a spinner thing with a dirty .... etc..
        deleteCloudVideoRecordsAndReplace(withVideoId: EpsilonStreamAdminModel.currentVideo.youtubeVideoId, withNewRecord: video)
    }
    
    class func submitMathObject(){
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        EpsilonStreamDataModel.saveViewContext()
        
        let mathObject = CKRecord(recordType: "MathObject")
        mathObject["oneOnEpsilonTimeStamp"] = EpsilonStreamAdminModel.currentMathObject.oneOnEpsilonTimeStamp as CKRecordValue
        mathObject["hashTag"] = EpsilonStreamAdminModel.currentMathObject.hashTag as CKRecordValue
        mathObject["associatedTitles"] = EpsilonStreamAdminModel.currentMathObject.associatedTitles as CKRecordValue
        
        //QQQQ do a spinner thing with a dirty .... etc..
        deleteCloudMathRecordsAndReplace(withHashTag: EpsilonStreamAdminModel.currentMathObject.hashTag, withNewRecord: mathObject)
    }
    
    class func submitFeaturedURL(){
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        EpsilonStreamDataModel.saveViewContext()
        
        let featuredURL = CKRecord(recordType: "FeaturedURL")
        featuredURL["oneOnEpsilonTimeStamp"] = EpsilonStreamAdminModel.currentFeature.oneOnEpsilonTimeStamp as CKRecordValue
        featuredURL["isAppStoreApp"] = EpsilonStreamAdminModel.currentFeature.isAppStoreApp as CKRecordValue
        featuredURL["urlOfItem"] = EpsilonStreamAdminModel.currentFeature.urlOfItem as CKRecordValue
        featuredURL["hashTags"] = EpsilonStreamAdminModel.currentFeature.hashTags as CKRecordValue
        featuredURL["imageURL"] = EpsilonStreamAdminModel.currentFeature.imageURL as CKRecordValue
        featuredURL["ourTitle"] = EpsilonStreamAdminModel.currentFeature.ourTitle as CKRecordValue
        featuredURL["ourDescription"] = EpsilonStreamAdminModel.currentFeature.ourDescription as CKRecordValue
        featuredURL["ourFeaturedURLHashtag"] = EpsilonStreamAdminModel.currentFeature.ourFeaturedURLHashtag as CKRecordValue
        
        
        //QQQQ do a spinner thing with a dirty .... etc..
        deleteCloudFeaturedURLRecordsAndReplace(withHashTag: EpsilonStreamAdminModel.currentFeature.ourFeaturedURLHashtag, withNewRecord: featuredURL)
    }
    
    class func submitChannel(){
        //QQQQ Impelment
    }
    
    ///////////////////////////
    // delete from cloud (if needed) and replace
    ///////////////////////////
    
    //Our basic philosphy is to ensure there is one unique item in the cloud per unique identifier.
    // The unique identifiers are:
    //          Video:  youtubeVideoId
    //          MathObject: hashTag
    //          FeaturedURL: ourFeaturedURLHashtag
    //          Channel: ourChannelHashtag
    
    class func deleteCloudVideoRecordsAndReplace(withVideoId videoId: String,withNewRecord record: CKRecord){
        let pred = NSPredicate(format: "youtubeVideoId == %@", videoId)//QQQQ want [cd] but didn't work
        let query = CKQuery(recordType: "Video", predicate: pred)
        
        var idsToKill: [CKRecordID] = []
        
        let operation = CKQueryOperation(query: query)
        operation.recordFetchedBlock = { record in
            idsToKill.append(record.recordID)
        }
        
        operation.queryCompletionBlock = { (cursor, error) in
            
            CKContainer.default().publicCloudDatabase.save(record){
                record, error in
                DispatchQueue.main.async{
                    if let error = error{
                        print("error on publicCloudDataBase.save: \(error.localizedDescription)")
                    }else{
                        print("video Record Saved on public cloud")
                    }
                }
            }
            
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
            for id in idsToKill{
                CKContainer.default().publicCloudDatabase.delete(withRecordID: id){ (id, error) in
                    print("completion handler for delete of \(id)")
                    if let error = error{
                        print("\(error)")
                    }
                }
            }
        }
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    class func deleteCloudMathRecordsAndReplace(withHashTag hashTag: String,withNewRecord record: CKRecord){
        let pred = NSPredicate(format: "hashTag == %@", hashTag)//QQQQ want [cd] but didn't work
        let query = CKQuery(recordType: "MathObject", predicate: pred)
        
        var idsToKill: [CKRecordID] = []
        
        let operation = CKQueryOperation(query: query)
        operation.recordFetchedBlock = { record in
            idsToKill.append(record.recordID)
        }
        
        operation.queryCompletionBlock = { (cursor, error) in
            
            CKContainer.default().publicCloudDatabase.save(record){
                record, error in
                DispatchQueue.main.async{
                    if let error = error{
                        print("error on publicCloudDataBase.save: \(error.localizedDescription)")
                    }else{
                        print("mathObject Record Saved on public cloud")
                    }
                }
            }
            
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
            for id in idsToKill{
                CKContainer.default().publicCloudDatabase.delete(withRecordID: id){ (id, error) in
                    print("completion handler for delete of \(id)")
                    if let error = error{
                        print("\(error)")
                    }
                }
            }
        }
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    class func deleteCloudFeaturedURLRecordsAndReplace(withHashTag hashTag: String,withNewRecord record: CKRecord){
        
        let pred = NSPredicate(format: "ourFeaturedURLHashtag == %@", hashTag)//QQQQ want [cd] but didn't work
        let query = CKQuery(recordType: "FeaturedURL", predicate: pred)
        
        var idsToKill: [CKRecordID] = []
        
        let operation = CKQueryOperation(query: query)
        operation.recordFetchedBlock = { record in
            idsToKill.append(record.recordID)
        }
        
        operation.queryCompletionBlock = { (cursor, error) in
            
            CKContainer.default().publicCloudDatabase.save(record){
                record, error in
                DispatchQueue.main.async{
                    if let error = error{
                        print("error on publicCloudDataBase.save: \(error.localizedDescription)")
                    }else{
                        print("featured URL Record Saved on public cloud")
                    }
                }
            }
            
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
            for id in idsToKill{
                CKContainer.default().publicCloudDatabase.delete(withRecordID: id){ (id, error) in
                    print("completion handler for delete of \(id)")
                    if let error = error{
                        print("\(error)")
                    }
                }
            }
        }
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    
    class func deleteCloudChannelRecordsAndReplace(withHashTag hashTag: String,withNewRecord record: CKRecord){
        //QQQQ implement as above //ourChannelHashtag
    }
    
    
    /////////////////////////////
    // Make New Objects
    /////////////////////////////
    
    class func makeNewChannel(_ context: NSManagedObjectContext){
        let newChannel = Channel(context: context)
        
        newChannel.channelId = "Channel Id - Fill In"
        newChannel.channelTitle = "Channel Title - Fill In"
        newChannel.channelURL = "Channel URL - Fill In"
        newChannel.isInChannelCollection = true
        newChannel.ourChannelStringDescription = "Our Channel Description - Fill In"
        newChannel.imagePic = nil
        newChannel.imageURL = "Channel URL - fill In"
        newChannel.ourChannelHashtag = "Our channel HashTag - Fill In"
        newChannel.oneOnEpsilonTimeStamp = Date()
    }
    
    class func makeNewFeaturedURL(_ context: NSManagedObjectContext){
        let newFeaturedURL = FeaturedURL(context: context)
        
        newFeaturedURL.oneOnEpsilonTimeStamp = Date()
        newFeaturedURL.isAppStoreApp = true
        newFeaturedURL.urlOfItem = "URL OF ITEM - FILL IN"
        newFeaturedURL.hashTags = "#needsTag"
        newFeaturedURL.imageURL = "URL OF IMAGE - fill in"
        newFeaturedURL.imageURLlocal = nil
        newFeaturedURL.ourFeaturedURLHashtag = "#ourFeaturedURLHashtag"
        newFeaturedURL.ourTitle = "EMPTY TITLE"
        newFeaturedURL.ourDescription = "OUR DESCRIPTION - FILL IN"
        newFeaturedURL.bufferIndex = 0
    }
    
    class func makeNewMathObject(_ context: NSManagedObjectContext){
        let newMathObject = MathObject(context: context)
        
        // If appropriate, configure the new managed object.
        newMathObject.oneOnEpsilonTimeStamp = Date()
        newMathObject.associatedTitles = "ASSOCIATED TITLES - FILL IN"
        newMathObject.hashTag = "#NEW-MATH-OBJECT"
        newMathObject.bufferIndex = 0
    }
    
    class func makeNewVideo(_ context: NSManagedObjectContext){
        let newVideo = Video(context: context)
        
        newVideo.age8Rating = 1.0
        newVideo.age10Rating = 1.0
        newVideo.age12Rating = 1.0
        newVideo.age14Rating = 1.0
        newVideo.age16Rating = 1.0
        newVideo.exploreVsUnderstand = 1.0
        newVideo.whyVsHow = 1.0
        newVideo.imageURL = "Image URL - Fill In"
        newVideo.isAwesome = false
        newVideo.isInVideoCollection = true
        newVideo.ourTitle = "NEW-VIDEO"
        newVideo.commentAndReview = "Comment and Review - Fill In"
        newVideo.channelKey = "Channel Key - Fill In"
        newVideo.imageURLlocal = nil
        newVideo.youtubeTitle = "YouTube title - CODE FILL IN"
        newVideo.youtubeVideoId = "NO-YOUTUBE-ID-YET"
        newVideo.hashTags = "#needsTag"
        newVideo.oneOnEpsilonTimeStamp = Date()
        
        newVideo.bufferIndex = 0
    }
}
