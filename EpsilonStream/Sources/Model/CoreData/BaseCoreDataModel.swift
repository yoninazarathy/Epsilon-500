import UIKit
import CoreData

public class BaseCoreDataModel: NSManagedObject {
    
    // This initialiser is iOS9 compatible. Once the app doesn't support iOS9 then this methods can be removed
    // and native init(context:) method can be used instead.
    convenience init(inContext managedObjectContext: NSManagedObjectContext) {
//        self.init(context: managedObjectContext)
        
        let entityDescription = NSEntityDescription.entity(forEntityName: String(describing: type(of: self)), in: managedObjectContext)
        self.init(entity: entityDescription!, insertInto: managedObjectContext)
    }
    
}
