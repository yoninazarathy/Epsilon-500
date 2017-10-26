import UIKit

public class IKFileManager: NSObject {
    public static let shared = IKFileManager()
    var errorOutputEnabled = true
    
    // MARK: Init
    
    public override init() {
        super.init()
        
        if fileExists(atPath: downloadsTempDirectory) == false {
            createDirectory(atPath: downloadsTempDirectory)
        }
    }
    
    // MARK: Special directories
    
    public var documentsDirectory: String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, false)
        return paths.first!
    }
    
    public var cachesDirectory: String {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, false)
        return paths.first!
    }
    
    public var tempDirectory: String {
        return NSTemporaryDirectory()
    }
    
    public var libraryDirectory: String {
        let paths = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, false)
        return paths.first!
    }
    
    public var downloadsTempDirectory: String {
        return (tempDirectory as NSString).appendingPathComponent("DownloadsTemp")
    }
    
    // MARK: Utility
    
    private func printError(prefix: String, path: String, error: Error?) {
        if errorOutputEnabled == true && error != nil {
            print("\(prefix) \(path) error:\n \(error!.localizedDescription)")
        }
    }
    
    public func absolutePath(forPath path: String) -> String {
        return (path as NSString).expandingTildeInPath
    }
    
    // MARK: Create/Read
    
    public func fileExists(atPath path: String) -> Bool {
        return FileManager.default.fileExists(atPath: absolutePath(forPath: path))
    }
    
    @discardableResult public func fileExists(atPath path: String, isDirectory: inout Bool) -> Bool {
        var isDir: ObjCBool = ObjCBool(false)
        let result = FileManager.default.fileExists(atPath: absolutePath(forPath: path), isDirectory: &isDir)
        isDirectory = isDir.boolValue
        return result
    }
    
    @discardableResult public func createDirectory(atPath path: String, withIntermediateDirectories: Bool = true) -> Bool {
        var result = true
        
        do {
            try FileManager.default.createDirectory(atPath: absolutePath(forPath: path), withIntermediateDirectories: withIntermediateDirectories,
                                                    attributes: nil)
        } catch let error {
            result = false
            printError(prefix: "Create directory", path: path, error: error)
        }
        
        return result
    }
    
    @discardableResult public func createDirectoryIfDoesntExist(atPath path: String) -> Bool {
        var result = true
        
        if fileExists(atPath: path) == false {
            result = createDirectory(atPath: path)
        }
        
        return result
    }
    
    public func contentsOfDirectory(atPath path: String) -> [String] {
        var result = [String]()
        
        do {
            try result.append(contentsOf: FileManager.default.contentsOfDirectory(atPath: absolutePath(forPath: path)) )
        } catch let error {
            printError(prefix: "Contents of directory", path: path, error: error)
        }
        
        return result
    }

    public func filePathsOfDirectory(atPath path: String, recursive: Bool = true) -> [String] {
        var result = [String]()
        let fileNames = contentsOfDirectory(atPath: path)
        var directories = [String]()
        
        for fileName in fileNames {
            var isDirectory = false
            
            let filePath = (path as NSString).appendingPathComponent(fileName)
            if fileExists(atPath: filePath, isDirectory: &isDirectory) == true {
                if isDirectory == true {
                    directories.append(filePath)
                } else {
                    result.append(filePath)
                }
            }
        }
        
        if recursive == true {
            for directory in directories {
                result.append(contentsOf: filePathsOfDirectory(atPath: directory, recursive: recursive))
            }
        }
        
        return result
    }
    
    public func dataWithContentsOfFile(atPath path: String?) -> Data? {
        guard path == nil else {
            return nil
        }
        
        var data: Data?
        
        do {
            try data = Data(contentsOf: URL(fileURLWithPath: absolutePath(forPath: path!)))
        } catch let error {
            printError(prefix: "Read file", path: path!, error: error)
        }
        
        return data
    }
    
    @discardableResult public func createFile(atPath path: String, contents data: Data?, attributes attr: [String : Any]? = nil,
                                              overwrites: Bool = true) -> Bool {
        var result = false
        
        if overwrites == true || fileExists(atPath: absolutePath(forPath: path)) == false {
            result = FileManager.default.createFile(atPath: absolutePath(forPath: path), contents: data, attributes: attr)
            if result == false {
                printError(prefix: "Save file", path: path, error: nil)
            }
        }
        return result
    }
    
    public func path(forResource name: String) -> String? {
        let result = Bundle.main.path(forResource: name, ofType: nil)
        
        if result == nil {
            //printError(prefix: "Resource not found", path: name, error: nil)
        }
        
        return result
    }
    
    public func imageWithContentsOfFile(atPath path: String?) -> UIImage? {
        guard path != nil else {
            return nil
        }
        
        let result = UIImage(contentsOfFile: absolutePath(forPath: path!))
        
        if result == nil {
            printError(prefix: "Image not found", path: path!, error: nil)
        }
        
        return result
    }
    
    public func stringWithContentsOfFile(atPath path: String?) -> String? {
        guard path != nil else {
            return nil
        }
        
        
        var result: String?
        
        do {
            try result = String.init(contentsOf: URL(fileURLWithPath: absolutePath(forPath: path!)))
        } catch let error {
            printError(prefix: "Read text file", path: path!, error: error)
        }
        
        return result
    }
    
    public func writeString(_ string: String, toFileAtPath path: String) {
        let data = string.data(using: .utf8)
        createFile(atPath: absolutePath(forPath: path), contents: data)
    }
    
    // MARK: Copy/Move
    
    @discardableResult public func copyItem(atPath srcPath: String, toPath dstPath: String) -> Bool {
        var result = false
        
        do {
            try FileManager.default.copyItem(atPath: absolutePath(forPath: srcPath), toPath: dstPath)
            result = true
        } catch let error {
            printError(prefix: "Copy item", path: srcPath, error: error)
        }
        
        return result
    }
    
    @discardableResult public func moveItem(atPath srcPath: String, toPath dstPath: String) -> Bool {
        var result = false
        
        do {
            try FileManager.default.moveItem(atPath: absolutePath(forPath: srcPath), toPath: absolutePath(forPath: dstPath))
            result = true
        } catch let error {
            printError(prefix: "Move item", path: srcPath, error: error)
        }
        
        return result
    }
    
    // MARK: Remove
    
    @discardableResult public func removeItem(atPath path: String) -> Bool {
        var result = false
        
        do {
            try FileManager.default.removeItem(atPath: absolutePath(forPath: path))
            result = true
        } catch let error {
            printError(prefix: "Remove item", path: path, error: error)
        }
        
        return result
    }
    
    public func clearDirectory(atPath path: String) {
        var isDirectory = false
        fileExists(atPath: absolutePath(forPath: path), isDirectory: &isDirectory)
        if isDirectory == false {
            return
        }
        
        let items = contentsOfDirectory(atPath: absolutePath(forPath: path))
        for item in items {
            let fullPath = (path as NSString).appendingPathComponent(item)
            removeItem(atPath: fullPath)
        }
    }
    
    // MARK: Attributes
    
    public func attributesOfItem(atPath path: String) -> [FileAttributeKey: Any]? {
        var result: [FileAttributeKey: Any]?
        
        do {
            try result = FileManager.default.attributesOfItem(atPath: absolutePath(forPath: path))
        } catch let error {
            printError(prefix: "Attributes of item", path: path, error: error)
        }
        
        return result
    }

    public func setAttributes(_ attributes: [FileAttributeKey: Any], ofItemAtPath path: String) {
        do {
            try FileManager.default.setAttributes(attributes, ofItemAtPath: absolutePath(forPath: path))
        } catch let error {
            printError(prefix: "Set attributes", path: path, error: error)
        }
    }
    
    public func addSkipBackupAttributeToItem(atPath path: String) -> Bool {
        var result = false
        
        let fileURL = URL(fileURLWithPath: absolutePath(forPath: path))

        do {
            
            //try url.setResourceValue(true, forKey:NSURLIsExcludedFromBackupKey)
            try (fileURL as NSURL).setResourceValue(true, forKey: .isExcludedFromBackupKey)
            
            result = true
            
        } catch let error {
            
            printError(prefix: "Add skip backup attribute", path: path, error: error)
            
        }
        
        return result
    }

    // MARK: Property list
    
    public func propertyListDictionary(withFileAtPath path: String) -> [String: Any]? {
        let data = dataWithContentsOfFile(atPath: path)
        var result: Any?
        
        if data != nil {
            var format = PropertyListSerialization.PropertyListFormat.xml
            do {
                try result = PropertyListSerialization.propertyList(from: data!, options: .mutableContainersAndLeaves, format: &format)
            } catch let error {
                printError(prefix: "Read property list", path: path, error: error)
            }
            
        }
        
        return (result as? [String: Any])
    }
    
    public func propertyListDictionary(withName name: String) -> [String: Any]? {
        let path = self.path(forResource: name)
        if path != nil {
            return propertyListDictionary(withFileAtPath: path!)
        }
        return nil
    }
    
    public func propertyList(name: String, valueForKey key: String) -> Any? {
        return propertyListDictionary(withName: name)?[key]
    }
    
}
