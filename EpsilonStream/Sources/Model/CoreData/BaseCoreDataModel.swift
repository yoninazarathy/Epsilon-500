import UIKit
import CoreData
import CloudKit

public class BaseCoreDataModel: NSManagedObject {
    
    @NSManaged public var recordID: CKRecordID?
    
    public class var cloudTypeName: String {
        return String(describing: self)
    }
    
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
    
    public func toCKRecordDictionary() -> AnyDictionary {
        return toDictionary()
    }
    
    public func save() {
        PersistentStorageManager.shared.saveMainContext()
    }
    
    public func discardChanges() {
        managedObjectContext?.refresh(self, mergeChanges: false)
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
    
//    public func updateFromCloudRecord(record: CKRecord) {
//        let dictionary = record.toDictionary()
//        DLog("aaa")
//    }
    
    public func updateCloudRecord(completion: ((Error?) -> ())? ) {
        let methodCompletion = { error in
            Common.performOnMainThread(closure: {
                completion?(error)
            })
        }
        
        
        let predicate = NSPredicate(format: "recordID == %@", recordID!)
        
        var targetRecord: CKRecord?
        let operation = CKQueryOperation(query: CKQuery(recordType: type(of: self).cloudTypeName, predicate: predicate) )
        operation.recordFetchedBlock = { record in
            //DLog("record: %@", record)
            targetRecord = record
        }
        
        operation.queryCompletionBlock = { (cursor, error) in
            if error == nil {
                
                if targetRecord != nil {
                    
                    targetRecord!.setValues(fromDictionary: self.toCKRecordDictionary())
                    //DLog("record: %@", targetRecord!)
                    
                    CKContainer.default().publicCloudDatabase.save( targetRecord!){ record, error in
                        if error == nil {
                            self.save()
                        }
                        methodCompletion(error)
                    }

                } else {
                    
                    methodCompletion(nil)
                    
                }
                
            } else {
                
                DLog("Query record with ID \(self.recordID!) error: \(error!)")
                methodCompletion(error)
                
            }
            
        }
        
        CKContainer.default().publicCloudDatabase.add(operation)
    }
}
