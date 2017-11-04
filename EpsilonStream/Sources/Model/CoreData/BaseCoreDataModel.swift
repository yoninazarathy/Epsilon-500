import UIKit
import CoreData

public class BaseCoreDataModel: NSManagedObject {
    
    convenience init(inContext managedObjectContext: NSManagedObjectContext) {
        if #available(iOS 10.0, *) {
            self.init(context: managedObjectContext)
        } else {
            let entityDescription = NSEntityDescription.entity(forEntityName: String(describing: type(of: self)), in: managedObjectContext)
            self.init(entity: entityDescription!, insertInto: managedObjectContext)
        }
    }
    
}
