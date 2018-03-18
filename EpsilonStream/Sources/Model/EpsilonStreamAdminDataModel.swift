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
import Firebase


class YouTubeSearchResultItem{
    var title: String = ""
    var channel: String = ""
    var youtubeId: String = ""//11 chars base 64 youtube id
    var duration: Int = -1
    var imageURL: String = "" //QQQQ
    var image: UIImage? = nil
}

class YouTubeVideoListResultItem{
    var videoId: String = ""
    var channel: String = ""
    var title: String = ""
    var imageURLdef: String = ""
    var imageURLmed: String = ""
    var imageURLhigh: String = ""
    var durationString: String = ""
    var durationInt: Int32 = 0
}


//QQQQ When cleaning up this class and the other one (EpsilonStreamBackgroundFetch), make
//a distinction between admin app and client (user) app

class EpsilonStreamAdminModel: ManagedObjectContextUserProtocol {
    
    static var currentVideo: Video!
    static var currentMathObject: MathObject!
    static var currentFeature: FeaturedURL!
    static var currentChannel: Channel!  //QQQQ don't have such an object
    static var currentMathObjectLink: MathObjectLink!
    
    //QQQQ used for term selector view controller
    static var selectedHashTagList: String! = nil
    
    //The current selected HashTag
    static var currentHashTag: String = ""
    
    ////////////////////////
    // Submit
    ////////////////////////
    
    class func submitVideo(withDBVideo dbVideo: Video){
        let pred = NSPredicate(format: "youtubeVideoId == %@", dbVideo.youtubeVideoId)
        let query = CKQuery(recordType: "Video", predicate: pred)
        
        let operation = CKQueryOperation(query: query)
        var record: CKRecord! = nil
        
        var numRecords = 0
        
        operation.recordFetchedBlock = { rec in
            record = rec
            numRecords += 1
        }
        
        //this doesn't really matter - there should be just 1 on the server
        operation.resultsLimit = 10
        
        operation.queryCompletionBlock = { (cursor, error) in
            if error == nil{
                if numRecords != 1{
                    print("ERROR - too many records in db for \(dbVideo.youtubeVideoId) -- \(numRecords)")
                    Analytics.logEvent("data_exception", parameters: ["type": "too many videos during video update" as NSObject, "id": dbVideo.youtubeVideoId as NSObject, "count": numRecords as NSObject])
                }
            }
            else{
                print("\(error!.localizedDescription)")
            }
        }
        
        operation.completionBlock = {
            dbVideo.populate(cloudRecord: record)
            CKContainer.default().publicCloudDatabase.save(record){
                record, error in
                if let error = error{
                    print("error on publicCloudDataBase.save: \(error.localizedDescription)")
                    let alert = UIAlertController(title: "One on Epsilon Development", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {_ in }))
                    UIApplication.topViewController()!.present(alert, animated: true, completion: nil)
                }else{
                    print("video Record Saved on public cloud")
                }
                
                DispatchQueue.main.sync{
                    backgroundActionInProgress = false
                }
            }
        }
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    class func submitFeaturedURL(withDBFeature dbFeature: FeaturedURL){
        let featuredURL = CKRecord(recordType: "FeaturedURL")
        
        //QQQQ timeStamp isn't really used anymore (moved to modifcationDate - built in cloudkit)
        featuredURL["oneOnEpsilonTimeStamp"] = EpsilonStreamAdminModel.currentFeature.oneOnEpsilonTimeStamp as CKRecordValue
        featuredURL["isAppStoreApp"] = EpsilonStreamAdminModel.currentFeature.isAppStoreApp as CKRecordValue
        featuredURL["urlOfItem"] = EpsilonStreamAdminModel.currentFeature.urlOfItem as CKRecordValue
        featuredURL["hashTags"] = EpsilonStreamAdminModel.currentFeature.hashTags as CKRecordValue
        featuredURL["imageURL"] = EpsilonStreamAdminModel.currentFeature.imageURL as CKRecordValue
        
        featuredURL["hashTagPriorities"] = EpsilonStreamAdminModel.currentFeature.hashTagPriorities as CKRecordValue
        
        if let ik = EpsilonStreamAdminModel.currentFeature.imageKey{
            featuredURL["imageKey"] = ik as CKRecordValue
        }else{
            featuredURL["imageKey"] = "NO IMAGE KEY" as CKRecordValue
        }
        
        featuredURL["ourTitle"] = EpsilonStreamAdminModel.currentFeature.ourTitle as CKRecordValue
        featuredURL["ourDescription"] = EpsilonStreamAdminModel.currentFeature.ourDescription as CKRecordValue
        featuredURL["ourFeaturedURLHashtag"] = EpsilonStreamAdminModel.currentFeature.ourFeaturedURLHashtag as CKRecordValue
        featuredURL["provider"] = EpsilonStreamAdminModel.currentFeature.provider as CKRecordValue
        featuredURL["typeOfFeature"] = EpsilonStreamAdminModel.currentFeature.typeOfFeature as CKRecordValue
        featuredURL["isInCollection"] = EpsilonStreamAdminModel.currentFeature.isInCollection as CKRecordValue
        featuredURL["whyVsHow"] = EpsilonStreamAdminModel.currentFeature.whyVsHow as CKRecordValue

        
        //QQQQ do a spinner thing with a dirty .... etc..
        deleteCloudFeaturedURLRecordsAndReplace(withHashTag: dbFeature.ourFeaturedURLHashtag, withNewRecord: featuredURL)
    }
    
    //QQQQ need
    // class func submitMathObjectLink(){
    //}


    class func submitMathObject(){
        let mathObject = CKRecord(recordType: "MathObject")
        //QQQQ timeStamp isn't really used anymore (moved to modifcationDate - built in cloudkit)
        mathObject["oneOnEpsilonTimeStamp"] = EpsilonStreamAdminModel.currentMathObject.oneOnEpsilonTimeStamp as CKRecordValue
        mathObject["hashTag"] = EpsilonStreamAdminModel.currentMathObject.hashTag as CKRecordValue
        mathObject["associatedTitles"] = EpsilonStreamAdminModel.currentMathObject.associatedTitles as CKRecordValue
        
        mathObject["curator"] = EpsilonStreamAdminModel.currentMathObject.curator as CKRecordValue
        mathObject["reviewer"] = EpsilonStreamAdminModel.currentMathObject.reviewer as CKRecordValue
        mathObject["isInCollection"] = EpsilonStreamAdminModel.currentMathObject.isInCollection as CKRecordValue
        
        
        deleteCloudMathRecordsAndReplace(withHashTag: EpsilonStreamAdminModel.currentMathObject.hashTag, withNewRecord: mathObject)
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
        operation.recordFetchedBlock = { rec in
            print("fetched: \(rec)")
            idsToKill.append(rec.recordID)
            print(idsToKill)
        }
        
        //this doesn't really matter - there should be just 1 on the server
        operation.resultsLimit = 10
        
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
                    if id != nil {
                        print("completion handler for delete of \(id!)")
                    }
                    if let error = error{
                        print("\(error)")
                    }
                    
                    DispatchQueue.main.sync{
                        backgroundActionInProgress = false
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
        operation.recordFetchedBlock = { rec in
            idsToKill.append(rec.recordID)
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
                    if id != nil {
                        print("completion handler for delete of \(id!)")
                    }
                    if let error = error{
                        print("\(error)")
                    }
                    DispatchQueue.main.sync{
                        backgroundActionInProgress = false
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
                    if id != nil {
                        print("completion handler for delete of \(id!)")
                    }
                    if let error = error{
                        print("\(error)")
                    }
                    DispatchQueue.main.sync{
                        backgroundActionInProgress = false
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
        let newChannel = Channel(inContext: context)
        
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
    
    class func makeNewFeaturedURL(_ context: NSManagedObjectContext) -> FeaturedURL{
        let newFeaturedURL = FeaturedURL(inContext: context)
        
        newFeaturedURL.oneOnEpsilonTimeStamp = Date()
        newFeaturedURL.isAppStoreApp = true
        newFeaturedURL.urlOfItem = "URL OF ITEM - FILL IN"
        newFeaturedURL.hashTags = "#needsTag"
        newFeaturedURL.imageURL = "URL OF IMAGE - fill in"
        newFeaturedURL.imageKey = nil
        newFeaturedURL.ourFeaturedURLHashtag = "#ourFeaturedURLHashtag"
        newFeaturedURL.ourTitle = "EMPTY TITLE"
        newFeaturedURL.ourDescription = "OUR DESCRIPTION - FILL IN"
        newFeaturedURL.provider = "PROVIDER - FILL IN"
        newFeaturedURL.typeOfFeature = "article"
        
        return newFeaturedURL
    }
    
    class func makeNewMathObject(_ context: NSManagedObjectContext){
        let newMathObject = MathObject(inContext: context)
        
        newMathObject.oneOnEpsilonTimeStamp = Date()
        newMathObject.associatedTitles = "ASSOCIATED TITLES - FILL IN"
        newMathObject.hashTag = "#NEW-MATH-OBJECT"
        newMathObject.reviewer = "guest"
        newMathObject.curator = "guest"
    }
    
    class func makeNewVideo(_ context: NSManagedObjectContext){
        let newVideo = Video(inContext: context)
        
        newVideo.age8Rating = 1.0
        newVideo.age10Rating = 1.0
        newVideo.age12Rating = 1.0
        newVideo.age14Rating = 1.0
        newVideo.age16Rating = 1.0
        newVideo.exploreVsUnderstand = 1.0
        newVideo.whyVsHow = 1.0
        newVideo.imageURL = "Image URL - Fill In"
        newVideo.isAwesome = false
        newVideo.isInCollection = true
        newVideo.ourTitle = "NEW-VIDEO"
        newVideo.commentAndReview = "Comment and Review - Fill In"
        newVideo.channelKey = "Channel Key - Fill In"
        newVideo.imageURLlocal = nil
        newVideo.youtubeTitle = "YouTube title - CODE FILL IN"
        newVideo.youtubeVideoId = "NO-YOUTUBE-ID-YET"
        newVideo.hashTags = "#needsTag"
        newVideo.oneOnEpsilonTimeStamp = Date()
    }
    
    /////////////////////////////
    // Set Objects
    /////////////////////////////
    
    class func setCurrentVideo(withVideo videoId: String){
        let request = Video.createFetchRequest()
        request.predicate = NSPredicate(format: "youtubeVideoId == %@", videoId)
        
        do{
            let videos = try mainContext.fetch(request)
            if videos.count != 1{
                print("error too many videos of id \(videoId) -- \(videos.count)")
            }
            EpsilonStreamAdminModel.currentVideo = videos[0]
        }catch{
            print("Fetch failed")
        }
    }
    
    class func setCurrentFeature(withFeature featureHashTag: String){
        let request = FeaturedURL.createFetchRequest()
        request.predicate = NSPredicate(format: "ourFeaturedURLHashtag == %@", featureHashTag)
        
        do{
            let features = try mainContext.fetch(request)
            if features.count != 1{
                print("error too many videos of id \(featureHashTag) -- \(features.count)")
            }
            EpsilonStreamAdminModel.currentFeature = features[0]
        }catch{
            print("Fetch failed")
        }
    }
    
    class func setCurrentMathObjectLink(withHashTag molHashTag: String){
        let request = MathObjectLink.createFetchRequest()
        request.predicate = NSPredicate(format: "ourMathObjectLinkHashTag == %@", molHashTag)
        
        do{
            let links = try mainContext.fetch(request)
            if links.count != 1{
                print("error too many videos of id \(molHashTag) -- \(links.count)")
            }
            EpsilonStreamAdminModel.currentMathObjectLink = links[0]
        }catch{
            print("Fetch failed")
        }
    }


    
    class func setCurrentMathObject(withMathObject hashTag: String){
        let request = MathObject.createFetchRequest()
        request.predicate = NSPredicate(format: "hashTag == %@", hashTag)
        
        do{
            let mathObjects = try mainContext.fetch(request)
            if mathObjects.count != 1{
                print("error too many math objects with hashtag \(hashTag) -- \(mathObjects.count)")
            }
            EpsilonStreamAdminModel.currentMathObject = mathObjects[0]
        }catch{
            print("Fetch failed")
        }
    }
    
    /////////////////////////////
    // Mass Store to DB
    /////////////////////////////

    class func storeAllVideos(){
        EpsilonStreamBackgroundFetch.peekVideoDataFromCloud()
        
        while true{
            sleep(2)
            if EpsilonStreamBackgroundFetch.peekVideoDone{
                print("done here")
                break
            }
        }
        
        let request = Video.createFetchRequest()
        request.predicate = NSPredicate(format:"TRUEPREDICATE")
        do{
            let videos = try mainContext.fetch(request)
            for v in videos{
                if let cnt =  EpsilonStreamBackgroundFetch.videoCount[v.youtubeVideoId]{
                    //print("NOT SUBMITING VIDEO \(v.ourTitle) -- \(v.hashTags) -- \(cnt)")
                    if cnt > 1{
                        print( "TOO MANY: \(v.youtubeVideoId) -- \(v.ourTitle) -- \(v.hashTags) -- \(cnt)")
                    }
                }else{//Video not there
                    print("WILL SUBMIT VIDEO \(v.youtubeVideoId) -- \(v.ourTitle)")
                    //EpsilonStreamAdminModel.currentVideo = v
                    //QQQQ need here method prior to Nov 2!!!!
                    //EpsilonStreamAdminModel.submitVideo(withDBVideo: v)
                }
            }
        }catch{
            print("Fetch failed")
        }
    }
    
    class func storeAllMathObjects(){
        let request = MathObject.createFetchRequest()
        request.predicate = NSPredicate(format:"TRUEPREDICATE")
        do{
            let mathObjects = try mainContext.fetch(request)
            for mo in mathObjects{
                EpsilonStreamAdminModel.currentMathObject = mo
                EpsilonStreamAdminModel.submitMathObject()
            }
            
        }catch{
            print("Fetch failed")
        }
    }

    class func storeAllFeatures(){
        let request = FeaturedURL.createFetchRequest()
        request.predicate = NSPredicate(format:"TRUEPREDICATE")
        do{
            let features = try mainContext.fetch(request)
            for f in features{
                EpsilonStreamAdminModel.currentFeature = f
                EpsilonStreamAdminModel.submitFeaturedURL(withDBFeature: f)
            }
            
        }catch{
            print("Fetch failed")
        }
    }
    
    class func refreshVideosFromResources(){
        print("REFRESH VIDEOS")
        YoutubeAPICommunicator.delegate = videoDel()
        YoutubeAPICommunicator.fetchVideosFromAllResources()
    }
    
    class videoDel: YoutubeAPIDelegate{
        func searchCallDone(withItems items: [YouTubeSearchResultItem]){}
        func videoDetailsCallDone(withItem item: YouTubeVideoListResultItem){
            EpsilonStreamAdminModel.addVideoToDBIfNot(item)
            
        }
        
        func videoIdsOfChannelDone(withVideos videos: [String]){
            print("IN EpsilonStreamAdminDataModel: Got \(videos.count) videos!")
            for v in videos{
                let videos = EpsilonStreamDataModel.videos(ofYoutubeId: v)
                if videos.count == 0{
                    YoutubeAPICommunicator.getYouTubeAPIVideoInfo(v)
                }else{
                    print("already have video \(v)")
                }
                if YoutubeAPICommunicator.numVidsInGet > 1000{
                    break //stop
                }
            }
        }
    }

    class func addVideoToDBIfNot(_ item: YouTubeVideoListResultItem){
        let videos = EpsilonStreamDataModel.videos(ofYoutubeId: item.videoId)
        if videos.count != 0 {
            if videos.count > 1{
                print("error - more than 1 video with same id: \(videos)")
            }else{
                //QQQQ need to handle updating of video without overriding curated stuff
                //videos[0].update(withYouTube: item)
                //print("Updated video \(item.videoId)")
            }
        }else{
            print("New \(item.channel) -- \(item.title)")
            let newVideo = Video(inContext: mainContext)
            newVideo.update(withYouTube: item)
        }
    }

    
    class func mathObjectReport() -> String{
        var report = "Report on Math Objects as of \(Date())\n\n"

        let request = MathObject.createFetchRequest()
        request.predicate = NSPredicate(format:"TRUEPREDICATE")
        request.sortDescriptors = [NSSortDescriptor(key: "hashTag", ascending: true)]
        do{
            let mathObjects = try mainContext.fetch(request)
            var num = 1
            for mo in mathObjects{
                let moString = "\(num): (\(mo.curator), \(mo.reviewer)) -- \(mo.hashTag) -- \(mo.associatedTitles)"
                num += 1
                report.append("\(moString)\n")
            }
            
        }catch{
            print("Fetch failed")
        }

        
        
        return report
    }
    
    
    
    class func deleteSingleCloudVideoRecord(withVideoId videoId: String){
        let pred = NSPredicate(format: "youtubeVideoId == %@", videoId)
        let query = CKQuery(recordType: "Video", predicate: pred)
        
        var idsToKill: [CKRecordID] = []
        
        let operation = CKQueryOperation(query: query)
        operation.recordFetchedBlock = { record in
            print("fetched: \(record)")
            idsToKill.append(record.recordID)
        }
        
        //It is importantToHave1 here.
        operation.resultsLimit = 1
        
        operation.queryCompletionBlock = { (cursor, error) in
            
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
            if idsToKill.count != 1{
                print("error - not a single id to kill \(idsToKill.count) - \(videoId)")
            }else{
                CKContainer.default().publicCloudDatabase.delete(withRecordID: idsToKill[0]){ (id, error) in
                    if (id != nil) {
                        print("completion handler for delete of \(id!)")
                    }
                    if let error = error{
                        print("\(error)")
                    }
                    DispatchQueue.main.sync{
                        backgroundActionInProgress = false
                    }
                }
            }
            
        }
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    
}
