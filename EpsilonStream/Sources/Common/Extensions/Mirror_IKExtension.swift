import Foundation

extension Mirror {
    public func toDictionary() -> AnyDictionary {
        var dictionary = AnyDictionary()
        for child in children {
            if let key = child.label {
                dictionary[key] = child.value
            }
        }
        
        if let superDictionary = superclassMirror?.toDictionary() {
            for (key,value) in superDictionary {
                dictionary[key] = value
            }
        }
        
        return dictionary
    }
    
    public func allPropertyNamesAndTypes() -> [String: Any.Type] {
        var propertyTypes = [String: Any.Type]()
        
        for child in children {
            if let key = child.label {
                propertyTypes[key] = type(of: child.value)
            }
        }
        
        if let superMirror = superclassMirror {
            let superPropertyTypes = superMirror.allPropertyNamesAndTypes()
            for (key,value) in superPropertyTypes {
                propertyTypes.updateValue(value, forKey:key)
            }
        }
        
        return propertyTypes
    }
}
