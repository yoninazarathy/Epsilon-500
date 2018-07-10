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
    
    public override func toDictionary() -> AnyDictionary {
        let keys = Array(entity.attributesByName.keys)
        return dictionaryWithValues(forKeys: keys)
    }
    
    public class func createFetchRequest<T: BaseCoreDataModel>() -> NSFetchRequest<T> {
        return NSFetchRequest(entityName: String(describing: self) )
    }
    
    public class func findMany<T: BaseCoreDataModel>(byPropertyWithName propertyName: String, value: Any) -> [T] {
        let request = createFetchRequest()
        request.predicate = NSPredicate(format: "\(propertyName) == %@", argumentArray: [value])
        
        var array = [T]()
        do {
            try array.append(contentsOf: (PersistentStorageManager.shared.mainContext.fetch(request) as! [T]) )
        } catch {
            print("Fetch failed")
        }
        
        return array
    }
    
    public class func findOne<T: BaseCoreDataModel>(byPropertyWithName propertyName: String, value: CVarArg) -> T? {
        return findMany(byPropertyWithName: propertyName, value: value).first
    }
    
}
