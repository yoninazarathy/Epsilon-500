import Foundation
import CoreData

@objc(VersionInfo)
public class VersionInfo: BaseCoreDataModel {

}

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
