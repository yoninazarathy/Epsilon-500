import UIKit

extension CGRect {
    init(center: CGPoint, size: CGSize) {
        self.init(x: center.x - size.width / 2, y: center.y - size.height / 2, width: size.width, height: size.height)
    }

    var midPoint: CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }
}

extension CGRect: DictionaryMappingProtocol {
    
    public func toDictionary() -> AnyDictionary {
        var dictionary = AnyDictionary()
        dictionary["origin"] = origin.toDictionary()
        dictionary["size"] = size.toDictionary()
        
        return dictionary
    }
    
    public mutating func setValues(fromDictionary dictionary: AnyDictionary) {
        origin = (dictionary["origin"] as? CGPoint) ?? .zero
        size = (dictionary["size"] as? CGSize) ?? .zero
    }
}
