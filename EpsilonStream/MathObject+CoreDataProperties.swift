//
//  MathObject+CoreDataProperties.swift
//  EpsilonStreamPrototype
//
//  Created by Yoni Nazarathy on 25/12/16.
//  Copyright © 2016 Yoni Nazarathy. All rights reserved.
//

import Foundation
import CoreData


extension MathObject {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<MathObject> {
        return NSFetchRequest<MathObject>(entityName: "MathObject");
    }

    @NSManaged public var oneOnEpsilonTimeStamp: Date
    
    @NSManaged public var hashTag: String
    @NSManaged public var associatedTitles: String
    
    @NSManaged public var curator: String
    @NSManaged public var reviewer: String

}
