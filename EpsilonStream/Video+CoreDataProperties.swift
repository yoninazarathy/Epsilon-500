//
//  Video+CoreDataProperties.swift
//  EpsilonStreamPrototype
//
//  Created by Yoni Nazarathy on 25/12/16.
//  Copyright © 2016 Yoni Nazarathy. All rights reserved.
//

import Foundation
import CoreData


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
    @NSManaged public var isInVideoCollection: Bool
    @NSManaged public var ourTitle: String
    @NSManaged public var commentAndReview: String
    @NSManaged public var channelKey: String
    @NSManaged public var imageURLlocal: String?
    @NSManaged public var whyVsHow: Float
    @NSManaged public var youtubeTitle: String
    @NSManaged public var youtubeVideoId: String
    @NSManaged public var hashTags: String
    @NSManaged public var durationSec: Int32
    @NSManaged public var percentWatched: Float
    
    @NSManaged public var bufferIndex: Int64
    
}
