import Foundation
import CoreData
import CloudKit

@objc(MathObject)
public class MathObject: BaseCoreDataModel {

}

extension MathObject {
    
    @nonobjc public class func createFetchRequest() -> NSFetchRequest<MathObject> {
        return NSFetchRequest<MathObject>(entityName: "MathObject");
    }
    
    @NSManaged public var oneOnEpsilonTimeStamp: Date
    @NSManaged public var hashTag: String
    @NSManaged public var associatedTitles: String
    @NSManaged public var curator: String
    @NSManaged public var reviewer: String
    @NSManaged public var isInCollection: Bool
    @NSManaged public var supportsWhyVsHow: Bool
    @NSManaged public var splashKey: String
    
    
    func update(fromCloudRecord record: CKRecord){
        recordName = record.recordID.recordName
        
        oneOnEpsilonTimeStamp = record["modificationDate"] as! Date
        hashTag = record["hashTag"] as! String
        associatedTitles = record["associatedTitles"] as! String
        if let cr = record["curator"]{
            curator = cr as! String;
        }else{
            curator = "None";
        }
        
        if let rv = record["reviewer"]{
            reviewer = rv as! String;
        }else{
            reviewer = "None";
        }
        
        if let iic = record["isInCollection"] as? Bool{
            isInCollection = iic
        }else{
            //QQQQ report error
            // print("no isInCollection for mathObject \(hashTag) - setting to true")
            isInCollection = true
        }
        
        if let wvh = record["supportsWhyVsHow"] as? Bool{
            supportsWhyVsHow = wvh
        }else{
            //QQQQ report error
            //print("no supportsWhyVsHow for mathObject \(hashTag) - setting to false")
            supportsWhyVsHow = false
        }
        
        if let sk = record["splashKey"] as? String{
            splashKey = sk
        }else{
            splashKey = ""
        }
        
    }
    
}
