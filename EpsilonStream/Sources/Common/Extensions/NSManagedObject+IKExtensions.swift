import CoreData

extension NSManagedObject {
    
    // NSManagedObject uses simplified (compared to NSObject) version of methods declared in DictionaryMappingProtocol
    // Because Mirror.children can't be used here. Also NSManagedObject can't have complex types as properties.
    
    override public func toDictionary() -> AnyDictionary {
        var dictionary = AnyDictionary()
        for (name, _) in entity.attributesByName {
            dictionary[name] = value(forKey: name)
        }
        
        return dictionary
    }
    
    override public func setValues(fromDictionary dictionary: AnyDictionary) {
        for (key, value) in dictionary {
            setValue(value, forKey: key)
        }
    }
    
}
