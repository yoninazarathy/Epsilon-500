//
//  MathObjectLink+CoreDataProperties.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 21/7/17.
//  Copyright © 2017 Yoni Nazarathy. All rights reserved.
//

import Foundation
import CoreData
import CloudKit


extension MathObjectLink {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<MathObjectLink> {
        return NSFetchRequest<MathObjectLink>(entityName: "MathObjectLink");
    }

    @NSManaged public var searchTitle: String
    @NSManaged public var hashTags: String 
    @NSManaged public var imageKey: String
    @NSManaged public var ourTitle: String
    @NSManaged public var ourTitleDetail: String
    @NSManaged public var oneOnEpsilonTimeStamp: Date
    @NSManaged public var isInCollection: Bool
    @NSManaged public var displaySearchPriority: Float//QQQQ actualy not used - maybe deleted throughout system
    @NSManaged public var hashTagPriorities: String
    @NSManaged public var ourMathObjectLinkHashTag: String
    @NSManaged public var splashKey: String
    @NSManaged public var cellImageKey: String

    func update(fromCloudRecord record: CKRecord){
        searchTitle = record["searchTitle"] as! String
        hashTags = record["hashTags"] as! String
        imageKey = record["imageKey"] as! String
        ourTitle = record["ourTitle"] as! String
        oneOnEpsilonTimeStamp = record["modificationDate"] as! Date
        isInCollection = record["isInCollection"] as! Bool
        
        //QQQQ actually not used maybe deleted
        if let pr = record["displaySearchPriority"] as? Float{
            displaySearchPriority = pr
        }else{
            //the 3+ puts after videos(0,1)  ,articles (1,2)  ,games(2,3)
            displaySearchPriority = 3 + Float(arc4random()) / 0xFFFFFFFF
        }
        
        if let htp = record["hashTagPriorities"] as? String{
            hashTagPriorities = htp
        }else{
            hashTagPriorities = ""
        }
        
        ourMathObjectLinkHashTag = record["ourMathObjectLinkHashTag"] as! String
        
        if let sk = record["splashKey"] as? String{
            splashKey = sk
        }else{
            splashKey = ""
        }
        
        if let otd = record["ourTitleDetail"] as? String{
            ourTitleDetail = otd
        }else{
            print("--- FOUND NO Our Title Detail ---") //QQQQ
            ourTitleDetail = ""
        }
        
        if let cik = record["cellImageKey"] as? String{
            cellImageKey = cik
        }else{
            //print("--- FOUND NO CELL IMAGE KEY  ---") //QQQQ
            cellImageKey = ""
        }
    }
    
}
