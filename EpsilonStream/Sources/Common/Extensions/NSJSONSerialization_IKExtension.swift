import Foundation

extension JSONSerialization {
    
    // MARK: - JSON Objects from NSString

    public class func jsonObject(with string: String, options opt: JSONSerialization.ReadingOptions = []) -> Any? {
        var object: Any?
        if let data = string.data(using: .utf8) {
            do {
                object = try jsonObject(with: data, options: opt)
            } catch let error {
                print(error)
            }
        }
        
        return object
    }
    
    // MARK: - NSString
    
    public class func string(withJSONObject obj: Any, options opt: JSONSerialization.WritingOptions = []) -> String? {
        var string: String?
        do {
            let data = try self.data(withJSONObject: obj, options: opt)
            string = String(data: data, encoding: .utf8)
        } catch let error {
            print(error)
        }
        
        return string
    }
    
}
