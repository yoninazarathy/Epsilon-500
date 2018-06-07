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

// To add new database version:
// 1) Select CoreData xcdatamodel file
// 2) Editor -> Add Model Version
// 3) Update "version" propety in this class
// The app should do everything automatically on next app launch.

class PersistentStorageManager: NSObject {
    
    static public let shared = PersistentStorageManager()
    
    private var storageFileNamePrefix: String {
        return "EpsilonStreamDataModel"
    }
    
    private var version: Int {
        return 3
    }
    
    private var storageDirectoryURL: URL {
        return IKFileManager.shared.libraryDirectoryURL.appendingPathComponent("Application Support")
    }
    
    private var storageFileName: String {
        return "EpsilonStreamDataModel"
        //return "EpsilonStreamDataModel_\(version)"
    }
    
    private var storageFileURL: URL {
        return storageDirectoryURL.appendingPathComponent("\(storageFileName).sqlite")
    }
    
    public func removeOldVersion() {
        if IKFileManager.shared.fileExists(atURL: storageFileURL) == false {
            // File with current version doesn't exist - we need to clean data and re-dowload everything.
            var files = IKFileManager.shared.contentsOfDirectory(atPath: IKFileManager.shared.absolutePath(forPath: storageDirectoryURL.relativePath) )
            files = files.filter({ (fileName: String) -> Bool in
                return fileName.starts(with: self.storageFileNamePrefix)
            })
            
            for fileName in files {
                IKFileManager.shared.removeItem(atURL: storageDirectoryURL.appendingPathComponent(fileName))
            }
            EpsilonStreamDataModel.resetDates()
        }
    }
    
    // MARK: - Setup storage iOS 10 and above
    
    @available(iOS 10.0, *) private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: storageFileName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Setup storage iOS 9
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        var modelURL = Bundle.main.resourceURL!.appendingPathComponent("\(storageFileName).momd")
        modelURL.appendPathComponent("\(storageFileNamePrefix)_ \(version).mom") // For some reason XCode adds "space" symbol before the version in the file name.
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: PersistentStorageManager.shared.managedObjectModel)

        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storageFileURL, options: nil)
        } catch let error {
            DLog("Add persistent store error \(error)")
            abort()
        }
        
        return coordinator
    }()
    
    // MARK: - Usage
    
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
    
    public func saveMainContext() {
        let saveContext = {
            do {
                try self.mainContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        
        if Thread.isMainThread {
            saveContext()
        } else {
            DispatchQueue.main.sync {
                saveContext()
            }
        }
    }

}
