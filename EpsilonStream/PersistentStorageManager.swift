import UIKit
import CoreData

protocol ManagedObjectContextUserProtocol {
    static var mainContext: NSManagedObjectContext { get }
}

extension ManagedObjectContextUserProtocol {
    static var mainContext: NSManagedObjectContext {
        return PersistentStorageManager.shared.mainContext
    }
}

class PersistentStorageManager: NSObject {
    
    static public let shared = PersistentStorageManager()
    
    // MARK: - Database storage
    
    @available(iOS 10.0, *) private lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "EpsilonStreamDataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "EpsilonStreamDataModel", withExtension: "mom")
        return NSManagedObjectModel(contentsOf: modelURL!)!
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: PersistentStorageManager.shared.managedObjectModel)
        var path = (IKFileManager.shared.libraryDirectory as NSString).appendingPathComponent("Application Support")
        path = (path as NSString).appendingPathComponent("EpsilonStreamDataModel.sqlite")
        path = IKFileManager.shared.absolutePath(forPath: path)
        let url = URL(fileURLWithPath: path)
        
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch let error {
            NSLog("Add persistent store error \(error)")
            abort()
        }
        
        return coordinator
    }()
    
    public lazy var mainContext: NSManagedObjectContext = {
        if #available(iOS 10.0, *) {
            return PersistentStorageManager.shared.persistentContainer.viewContext
        } else {
            let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            managedObjectContext.persistentStoreCoordinator = PersistentStorageManager.shared.persistentStoreCoordinator
            return managedObjectContext
        }
    }()
    
    public func newBackgroundContext() -> NSManagedObjectContext {
        if #available(iOS 10.0, *) {
            return persistentContainer.newBackgroundContext()
        } else {
            let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            //managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
            managedObjectContext.parent = mainContext
            return managedObjectContext
        }
        
    }
    
    public func saveMainContext(){
        DispatchQueue.main.async {
            do {
                try self.mainContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
