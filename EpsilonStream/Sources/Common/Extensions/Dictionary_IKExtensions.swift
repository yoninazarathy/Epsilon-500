import Foundation

public typealias AnyDictionary = [String: Any]
public typealias AnyObjectDictionary = [String: AnyObject]

public protocol DictionaryMappingProtocol {
    init()
    init(dictionary: AnyDictionary)
    mutating func setValues(fromDictionary dictionary: AnyDictionary)
    func toDictionary() -> AnyDictionary
}

extension DictionaryMappingProtocol {
    
    public init(dictionary: AnyDictionary) {
        self.init()
        setValues(fromDictionary: dictionary)
    }
    
}

// NSObject subclasses should conform to this protocol to allow recursive mapping.
public protocol RecursiveDictionaryMappingProtocol : DictionaryMappingProtocol {
}

extension Dictionary {
    
    mutating func update(other: Dictionary?) {
        guard other != nil else {
            return
        }
        
        for (key,value) in other! {
            self[key] = value
        }
    }
    
}

extension Dictionary where Key: Comparable, Value: Hashable {
    public var hashValue: Int {
        let prime = 31
        var result = 1
        
        let sortedKeys = self.keys.sorted()
        for (key) in sortedKeys {
            let value = self[key]!
            result = Int.addWithOverflow(Int.multiplyWithOverflow(prime, result).0, key.hashValue).0
            result = Int.addWithOverflow(Int.multiplyWithOverflow(prime, result).0, value.hashValue).0
        }
        
        return result
    }
}
