import UIKit

public class IKFileManager: NSObject {
    public static let shared = IKFileManager()
    var errorOutputEnabled = true
    
    // MARK: - Init
    
    public override init() {
        super.init()
        
        if fileExists(atPath: downloadsTempDirectoryPath) == false {
            createDirectory(atPath: downloadsTempDirectoryPath)
        }
    }
    
    // MARK: - Special directories
    
    public var documentsDirectoryURL: URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls.first!
    }
    
    public var documentsDirectoryPath: String {
        return documentsDirectoryURL.relativePath
    }
    
    public var libraryDirectoryURL: URL {
        let urls = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
        return urls.first!
    }
    
    public var libraryDirectoryPath: String {
        let paths = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, false)
        return paths.first!
    }
    
    public var cachesDirectoryURL: URL {
        let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return urls.first!
    }
    
    public var cachesDirectoryPath: String {
        return cachesDirectoryURL.relativePath
    }
    
    public var tempDirectoryURL: URL {
        return URL(fileURLWithPath: NSTemporaryDirectory())
    }
    
    public var tempDirectoryPath: String {
        return NSTemporaryDirectory()
    }
    
    public var downloadsTempDirectoryURL: URL {
        return tempDirectoryURL.appendingPathComponent("DownloadsTmp")
    }
    
    public var downloadsTempDirectoryPath: String {
        return downloadsTempDirectoryURL.relativePath
    }
    
    // MARK: - Utility
    
    private func printError(prefix: String, url: URL, error: Error?) {
        return printError(prefix: prefix, path: url.relativePath, error: error)
    }
    
    private func printError(prefix: String, path: String, error: Error?) {
        if errorOutputEnabled == true && error != nil {
            print("\(prefix) \(path) error:\n \(error!.localizedDescription)")
        }
    }
    
    public func absolutePath(forPath path: String) -> String {
        return (path as NSString).expandingTildeInPath
    }
    
    // MARK: - Create/Read
    
    public func fileExists(atURL url: URL) -> Bool {
        return fileExists(atPath: url.relativePath)
    }
    
    public func fileExists(atPath path: String) -> Bool {
        return FileManager.default.fileExists(atPath: absolutePath(forPath: path))
    }
    
    @discardableResult public func fileExists(atURL url: URL, isDirectory: inout Bool) -> Bool {
        return fileExists(atPath: url.relativePath, isDirectory: &isDirectory)
    }
    
    @discardableResult public func fileExists(atPath path: String, isDirectory: inout Bool) -> Bool {
        var isDir: ObjCBool = ObjCBool(false)
        let result = FileManager.default.fileExists(atPath: absolutePath(forPath: path), isDirectory: &isDir)
        isDirectory = isDir.boolValue
        return result
    }
    
    @discardableResult public func createDirectory(atURL url: URL, withIntermediateDirectories: Bool = true) -> Bool {
        var result = true
        
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: withIntermediateDirectories, attributes: nil)
        } catch let error {
            result = false
            printError(prefix: "Create directory", url: url, error: error)
        }
        
        return result
    }
    
    @discardableResult public func createDirectory(atPath path: String, withIntermediateDirectories: Bool = true) -> Bool {
        return createDirectory(atURL: URL(fileURLWithPath: absolutePath(forPath: path)), withIntermediateDirectories: withIntermediateDirectories)
    }
    
    @discardableResult public func createDirectoryIfDoesntExist(atURL url: URL) -> Bool {
        return createDirectoryIfDoesntExist(atPath: url.relativePath)
    }
    
    @discardableResult public func createDirectoryIfDoesntExist(atPath path: String) -> Bool {
        var result = true
        
        if fileExists(atPath: path) == false {
            result = createDirectory(atPath: path)
        }
        
        return result
    }
    
    public func contentsOfDirectory(atURL url: URL) -> [URL] {
        var result = [URL]()
        
        do {
            try result.append(contentsOf: FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: []) )
        } catch let error {
            printError(prefix: "Contents of directory", url: url, error: error)
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

    public func urlsOfDirectory(atURL url: URL, recursive: Bool = true) -> [URL] {
        var result = [URL]()
        let urls = contentsOfDirectory(atURL: url)
        var directories = [URL]()
        
        for url in urls {
            var isDirectory = false
            
            if fileExists(atURL: url, isDirectory: &isDirectory) {
                if isDirectory {
                    directories.append(url)
                } else {
                    result.append(url)
                }
            }
        }
        
        if recursive == true {
            for directory in directories {
                result.append(contentsOf: urlsOfDirectory(atURL: directory, recursive: recursive))
            }
        }
        
        return result
    }
    
    public func filePathsOfDirectory(atPath path: String, recursive: Bool = true) -> [String] {
        let urls = urlsOfDirectory(atURL: URL(fileURLWithPath: absolutePath(forPath: path)), recursive: recursive)
        let paths = urls.map {
            $0.relativePath
        }
        return paths
    }
    
    public func dataWithContentsOfFile(atURL url: URL?) -> Data? {
        guard url != nil else {
            return nil
        }
        
        var data: Data?
        
        do {
            try data = Data(contentsOf: url!)
        } catch let error {
            printError(prefix: "Read file", url: url!, error: error)
        }
        
        return data
    }
    
    public func dataWithContentsOfFile(atPath path: String?) -> Data? {
        guard path != nil else {
            return nil
        }
        return dataWithContentsOfFile(atURL: URL(fileURLWithPath: absolutePath(forPath: path!) ) )
    }
    
    @discardableResult public func createFile(atURL url: URL, contents data: Data?, attributes attr: [String : Any]? = nil,
                                              overwrites: Bool = true) -> Bool {
        return createFile(atPath: absolutePath(forPath: url.relativePath), contents: data, attributes: attr, overwrites: overwrites)
    }
    
    @discardableResult public func createFile(atPath path: String, contents data: Data?, attributes attr: [String : Any]? = nil,
                                              overwrites: Bool = true) -> Bool {
        var result = false
        
        if overwrites == true || fileExists(atPath: path) == false {
            result = FileManager.default.createFile(atPath: absolutePath(forPath: path), contents: data, attributes: attr)
            if result == false {
                printError(prefix: "Save file", path: path, error: nil)
            }
        }
        return result
    }
    
    public func url(forResource name: String) -> URL? {
        let result = Bundle.main.url(forResource: name, withExtension: nil)
        
        if result == nil {
            printError(prefix: "Resource not found", path: name, error: nil)
        }
        
        return result
    }
    
    public func path(forResource name: String) -> String? {
        if let url = url(forResource: name) {
            return absolutePath(forPath: url.relativePath)
        }
        return nil
    }
    
    public func imageWithContentsOfFile(atURL url: URL?) -> UIImage? {
        return imageWithContentsOfFile(atPath: url?.relativePath)
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
    
    public func stringWithContentsOfFile(atURL url: URL?) -> String? {
        guard url != nil else {
            return nil
        }
        
        var result: String?
        
        do {
            try result = String(contentsOf: url!)
        } catch let error {
            printError(prefix: "Read text file", url: url!, error: error)
        }
        
        return result
    }
    
    public func stringWithContentsOfFile(atPath path: String?) -> String? {
        return stringWithContentsOfFile(atURL: URL(fileURLWithPath: absolutePath(forPath: path!) ) )
    }
    
    public func writeString(_ string: String, toFileAtURL url: URL) {
        let data = string.data(using: .utf8)
        createFile(atURL: url, contents: data)
    }
    
    public func writeString(_ string: String, toFileAtPath path: String) {
        writeString(string, toFileAtURL: URL(fileURLWithPath: absolutePath(forPath: path) ) )
    }
    
    // MARK: - Copy/Move
    
    @discardableResult public func copyItem(atURL srcURL: URL, toURL dstURL: URL) -> Bool {
        var result = false
        
        do {
            try FileManager.default.copyItem(at: srcURL, to: dstURL)
            result = true
        } catch let error {
            printError(prefix: "Copy item", url: srcURL, error: error)
        }
        
        return result
    }
    
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
    
    @discardableResult public func moveItem(atURL srcURL: URL, toURL dstURL: URL) -> Bool {
        var result = false
        
        do {
            try FileManager.default.moveItem(at: srcURL, to: dstURL)
            result = true
        } catch let error {
            printError(prefix: "Move item", url: srcURL, error: error)
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
    
    // MARK: - Remove
    
    @discardableResult public func removeItem(atURL url: URL) -> Bool {
        var result = false
        
        do {
            try FileManager.default.removeItem(at: url)
            result = true
        } catch let error {
            printError(prefix: "Remove item", url: url, error: error)
        }
        
        return result
    }
    
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
    
    public func clearDirectory(atURL url: URL) {
        clearDirectory(atPath: url.relativePath)
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
    
    // MARK: - Attributes
    
    public func attributesOfItem(atURL url: URL) -> [FileAttributeKey: Any]? {
        return attributesOfItem(atPath: url.relativePath)
    }
    
    public func attributesOfItem(atPath path: String) -> [FileAttributeKey: Any]? {
        var result: [FileAttributeKey: Any]?
        
        do {
            try result = FileManager.default.attributesOfItem(atPath: absolutePath(forPath: path))
        } catch let error {
            printError(prefix: "Attributes of item", path: path, error: error)
        }
        
        return result
    }

    public func setAttributes(_ attributes: [FileAttributeKey: Any], ofItemAtURL url: URL) {
        setAttributes(attributes, ofItemAtPath: url.relativePath)
    }
    
    public func setAttributes(_ attributes: [FileAttributeKey: Any], ofItemAtPath path: String) {
        do {
            try FileManager.default.setAttributes(attributes, ofItemAtPath: absolutePath(forPath: path))
        } catch let error {
            printError(prefix: "Set attributes", path: path, error: error)
        }
    }
    
    public func addSkipBackupAttributeToItem(atURL url: URL) -> Bool {
        var result = false
        
        do {
            try (url as NSURL).setResourceValue(true, forKey: .isExcludedFromBackupKey)
            result = true
        } catch let error {
            printError(prefix: "Add skip backup attribute", url: url, error: error)
        }
        
        return result
    }
    
    public func addSkipBackupAttributeToItem(atPath path: String) -> Bool {
        return addSkipBackupAttributeToItem(atURL:  URL(fileURLWithPath: absolutePath(forPath: path) ) )
    }

    // MARK: -  Property list
    
    public func propertyListDictionary(withFileAtURL url: URL) -> [String: Any]? {
       return propertyListDictionary(withFileAtPath: url.relativePath)
    }
    
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
