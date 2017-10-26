import Foundation
import CoreData
import CloudKit

@objc(FeaturedURL)
public class FeaturedURL: BaseCoreDataModel {

}

extension FeaturedURL {
    
    @nonobjc public class func createFetchRequest() -> NSFetchRequest<FeaturedURL> {
        return NSFetchRequest<FeaturedURL>(entityName: "FeaturedURL");
    }
    
    @NSManaged public var oneOnEpsilonTimeStamp: Date
    @NSManaged public var isAppStoreApp: Bool
    @NSManaged public var urlOfItem: String
    @NSManaged public var hashTags: String
    @NSManaged public var imageURL: String
    @NSManaged public var imageKey: String?
    @NSManaged public var ourTitle: String
    @NSManaged public var ourDescription: String
    @NSManaged public var ourFeaturedURLHashtag: String
    @NSManaged public var provider: String
    @NSManaged public var typeOfFeature: String
    @NSManaged public var isInCollection: Bool
    @NSManaged public var whyVsHow: Float
    @NSManaged public var displaySearchPriority: Float //QQQQ del
    @NSManaged public var hashTagPriorities: String
    @NSManaged public var splashKey: String
    @NSManaged public var isExternal: Bool
    
    func update(fromCloudRecord record: CKRecord){
        if let ts = record["modificationDate"] as? Date{
            oneOnEpsilonTimeStamp = ts
        }else{
            //QQQQ report error
            print("DB error with \(record)")
            return
        }
        
        if let ht = record["hashTags"] as? String{
            hashTags = ht
        }else{
            //QQQQ report error
            print("DB error with \(record)")
            return
        }
        
        if let url = record["urlOfItem"] as? String{
            urlOfItem = url
        }else{
            //QQQQ report error
            print("DB error with \(record)")
            return
        }
        
        if let ik = record["imageKey"] as? String{
            imageKey = ik
        }else{
            //QQQQ report error
            print("DB error with \(record)")
            return
        }
        if let iu = record["imageURL"] as? String{
            imageURL = iu
        }else{
            //QQQQ report error
            print("DB error with \(record)")
            return
        }
        
        if let ot = record["ourTitle"] as? String{
            ourTitle = ot
        }else{
            //QQQQ report error
            print("DB error with \(record)")
            return
        }
        
        if let od = record["ourDescription"] as? String{
            ourDescription = od
        }else{
            //QQQQ report error
            print("DB error with \(record)")
            return
        }
        
        if let ht = record["ourFeaturedURLHashtag"] as? String{
            ourFeaturedURLHashtag = ht
        }else{
            //QQQQ report error
            print("DB error with \(record)")
            return
        }
        
        if let iaa = record["isAppStoreApp"] as? Bool{
            isAppStoreApp = iaa
        }else{
            //QQQQ report error
            print("DB error with \(record)")
            return
        }
        
        if let pv = record["provider"] as? String{
            provider = pv
        }else{
            //QQQQ report error
            print("DB error with \(record)")
            return
        }
        
        if let tof = record["typeOfFeature"] as? String{
            typeOfFeature = tof
        }else{
            //QQQQ report error
            print("DB error with \(record)")
            return
        }
        
        if let wvh = record["whyVsHow"] as? Float{
            whyVsHow = wvh
        }else{
            //QQQQ report error
            print("no whyVsHow for feature \(ourFeaturedURLHashtag) - setting to 0.5")
            whyVsHow = 0.5
        }
        
        if let iic = record["isInCollection"] as? Bool{
            isInCollection = iic
        }else{
            //QQQQ report error
            //print("no isInCollection for feature \(ourFeaturedURLHashtag) - setting to true")
            isInCollection = true
        }
        
        if let pr = record["displaySearchPriority"] as? Float{
            displaySearchPriority = pr
        }else{
            //the "1+" puts features after videos
            displaySearchPriority = 1 + Float(arc4random()) / 0xFFFFFFFF
            if typeOfFeature == "Game" || typeOfFeature == "game"{ //QQQQ
                displaySearchPriority += 1 //games come one after features
            }
        }
        
        if let htp = record["hashTagPriorities"] as? String{
            hashTagPriorities = htp
        }else{
            hashTagPriorities = ""
        }
        
        if let sk = record["splashKey"] as? String{
            splashKey = sk
        }else{
            splashKey = ""
        }
        
        //QQQQ messed up "isExternal" in cloudkit as string (should have been bool)
        if let ie = record["isExternal"] as? String{
            if ie == "true"{
                isExternal = true
            }else{
                isExternal = false
            }
        }else{
            isExternal = false
        }
        
    }
}
