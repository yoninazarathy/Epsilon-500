//
//  VersionInfo+CoreDataProperties.swift
//  
//
//  Created by Yoni Nazarathy on 22/1/17.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension VersionInfo {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<VersionInfo> {
        return NSFetchRequest<VersionInfo>(entityName: "VersionInfo");
    }

    @NSManaged public var mathObjectCount: Int64
    @NSManaged public var videoCount: Int64
    @NSManaged public var featuredURLCount: Int64
    @NSManaged public var textMessageToShow: String
    @NSManaged public var numberOfTimesToShowMessage: Int64
    @NSManaged public var minimalSoftwareVersion: String?
    @NSManaged public var numberOfTimesLeftToShowMessage: Int64
    @NSManaged public var contentVersionNumber: Int64
    @NSManaged public var inProgressContentVersionNumber: Int64
    
    @NSManaged public var loaded: Bool
    
    @NSManaged public var bufferIndex: Int64


}
