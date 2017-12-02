import UIKit

extension CGSize {
    init(width: CGFloat) {
        self.init(width: width, height: width)
    }
}

extension CGSize: DictionaryMappingProtocol {
    
    public func toDictionary() -> AnyDictionary {
        var dictionary = AnyDictionary()
        dictionary["width"] = width
        dictionary["height"] = height
        
        return dictionary
    }
    
    public mutating func setValues(fromDictionary dictionary: AnyDictionary) {
        width = (dictionary["width"] as? CGFloat) ?? 0
        height = (dictionary["height"] as? CGFloat) ?? 0
    }
    
}
