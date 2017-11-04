import Foundation
import CoreData

@objc(ImageThumbnail)
public class ImageThumbnail: BaseCoreDataModel {

}

extension ImageThumbnail {
    
    @nonobjc public class func createFetchRequest() -> NSFetchRequest<ImageThumbnail> {
        return NSFetchRequest<ImageThumbnail>(entityName: "ImageThumbnail");
    }
    
    @NSManaged public var oneOnEpsilonTimeStamp: Date
    @NSManaged public var keyName: String
    @NSManaged public var imageURL: String
    @NSManaged public var hasFile: Bool
    @NSManaged public var priority: Int64
    @NSManaged public var primarySourceIsCloud: Bool
    @NSManaged public var webRequestSent: Bool
    @NSManaged public var cloudRequestSent: Bool
}
