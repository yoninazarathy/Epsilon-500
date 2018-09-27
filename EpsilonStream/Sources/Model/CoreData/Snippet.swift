import UIKit

@objc(Snippet)
public class Snippet: BaseCoreDataModel {
    @NSManaged public var body: String
    @NSManaged public var hashTags: String
    @NSManaged public var imageURL: String
    @NSManaged public var title: String
}
