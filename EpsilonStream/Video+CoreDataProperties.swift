//
//  Video+CoreDataProperties.swift
//  EpsilonStreamPrototype
//
//  Created by Yoni Nazarathy on 25/12/16.
//  Copyright © 2016 Yoni Nazarathy. All rights reserved.
//

import Foundation
import CoreData
import CloudKit


extension Video {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Video> {
        return NSFetchRequest<Video>(entityName: "Video");
    }
    
    @NSManaged public var oneOnEpsilonTimeStamp: Date
    @NSManaged public var age8Rating: Float
    @NSManaged public var age10Rating: Float
    @NSManaged public var age12Rating: Float
    @NSManaged public var age14Rating: Float
    @NSManaged public var age16Rating: Float
    @NSManaged public var exploreVsUnderstand: Float
    @NSManaged public var imageURL: String
    @NSManaged public var isAwesome: Bool
    @NSManaged public var isInCollection: Bool
    @NSManaged public var ourTitle: String
    @NSManaged public var commentAndReview: String
    @NSManaged public var channelKey: String
    @NSManaged public var imageURLlocal: String?
    @NSManaged public var whyVsHow: Float
    @NSManaged public var youtubeTitle: String
    @NSManaged public var youtubeVideoId: String
    @NSManaged public var hashTags: String
    @NSManaged public var durationSec: Int32
    @NSManaged public var displaySearchPriority: Float //QQQQ del
    @NSManaged public var hashTagPriorities: String
    @NSManaged public var initPriority: Float
    @NSManaged public var splashKey: String

    
    func update(fromCloudRecord record: CKRecord){
        oneOnEpsilonTimeStamp = record["modificationDate"] as! Date
        age8Rating = record["age8Rating"] as! Float
        age10Rating = record["age10Rating"] as! Float
        age12Rating = record["age12Rating"] as! Float
        age14Rating = record["age14Rating"] as! Float
        age16Rating = record["age16Rating"] as! Float
        exploreVsUnderstand = record["exploreVsUnderstand"] as! Float
        isAwesome = record["isAwesome"] as! Bool
        isInCollection = record["isInVideoCollection"] as! Bool
        ourTitle = record["ourTitle"] as! String
        commentAndReview = record["commentAndReview"] as! String
        channelKey = record["channelKey"] as! String
        whyVsHow = record["whyVsHow"] as! Float
        youtubeTitle = record["youtubeTitle"] as! String
        youtubeVideoId = record["youtubeVideoId"] as! String
        hashTags = record["hashTags"] as! String
        
        //QQQQ why aren't all fields treated this way?
        // -- currently it is with caution since just added duration
        if let ds = record["durationSec"] as? Int32{
            durationSec = ds
        }else{
            print("--- FOUND NO DURATION ---") //QQQQ
        }
        
        if let pr = record["displaySearchPriority"] as? Float{
            displaySearchPriority = pr
        }else{
            displaySearchPriority = Float(arc4random()) / 0xFFFFFFFF
        }
        
        imageURL = record["imageURL"] as! String
        print(imageURL)
        
        if let htp = record["hashTagPriorities"] as? String{
            hashTagPriorities = htp
        }else{
            //print("--- FOUND NO HASH TAG PRIORITY ---") //QQQQ
            hashTagPriorities = ""
        }
        
        if let sk = record["splashKey"] as? String{
            splashKey = sk
        }else{
            splashKey = ""
        }

    }
    
    func update(withYouTube item: YouTubeVideoListResultItem){
        oneOnEpsilonTimeStamp = Date()
        age8Rating = 0.0
        age10Rating = 0.0
        age12Rating = 0.0
        age14Rating = 0.0
        age16Rating = 0.0
        exploreVsUnderstand = 0.0
        isAwesome = false
        isInCollection = false
        ourTitle = item.title
        commentAndReview = "no comment"
        channelKey = item.channel
        whyVsHow = 0.0
        youtubeTitle = item.title
        youtubeVideoId = item.videoId
        hashTags = "#noTag"
        durationSec = item.durationInt
        imageURL = item.imageURLdef //QQQQ
        splashKey = ""
        hashTagPriorities = ""
        displaySearchPriority = Float(arc4random()) / 0xFFFFFFFF
    }
    
}
