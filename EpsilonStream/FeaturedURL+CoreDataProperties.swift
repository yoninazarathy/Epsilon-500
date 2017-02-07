//
//  FeaturedURL+CoreDataProperties.swift
//  EpsilonStreamPrototype
//
//  Created by Yoni Nazarathy on 25/12/16.
//  Copyright © 2016 Yoni Nazarathy. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension FeaturedURL {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<FeaturedURL> {
        return NSFetchRequest<FeaturedURL>(entityName: "FeaturedURL");
    }

    @NSManaged public var oneOnEpsilonTimeStamp: Date
    
    @NSManaged public var isAppStoreApp: Bool
    @NSManaged public var urlOfItem: String
    @NSManaged public var hashTags: String
    @NSManaged public var imageURL: String
    @NSManaged public var imageURLlocal: String?
    @NSManaged public var ourTitle: String
    @NSManaged public var ourDescription: String
    @NSManaged public var ourFeaturedURLHashtag: String
    
    @NSManaged public var bufferIndex: Int64

}
