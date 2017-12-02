import UIKit

extension CGPoint {
    init(x: CGFloat) {
        self.init(x: x, y: x)
    }
}

extension CGPoint: DictionaryMappingProtocol {
    public func toDictionary() -> AnyDictionary {
        var dictionary = AnyDictionary()
        dictionary["x"] = x
        dictionary["y"] = y
        
        return dictionary
    }
    
    public mutating func setValues(fromDictionary dictionary: AnyDictionary) {
        x = (dictionary["x"] as? CGFloat) ?? 0
        y = (dictionary["y"] as? CGFloat) ?? 0
    }
}
