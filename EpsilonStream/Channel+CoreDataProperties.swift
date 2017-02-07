//
//  Channel+CoreDataProperties.swift
//  EpsilonStreamPrototype
//
//  Created by Yoni Nazarathy on 25/12/16.
//  Copyright © 2016 Yoni Nazarathy. All rights reserved.
//

import Foundation
import CoreData


extension Channel {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Channel> {
        return NSFetchRequest<Channel>(entityName: "Channel");
    }

    @NSManaged public var oneOnEpsilonTimeStamp: Date
    
    @NSManaged public var channelId: String
    @NSManaged public var channelTitle: String
    @NSManaged public var channelURL: String
    @NSManaged public var isInChannelCollection: Bool
    @NSManaged public var ourChannelStringDescription: String
    @NSManaged public var imagePic: NSData?
    @NSManaged public var imageURL: String
    @NSManaged public var ourChannelHashtag: String

    @NSManaged public var bufferIndex: Int64

}
