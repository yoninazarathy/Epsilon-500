import Foundation

class MappingTestClass: NSObject {
    var testString = "test string"
    //var testDate = NSDate()
    var testInt = 1
    var testDouble = 2.0
    var testBool = true
    var testNil: String?
    
    var testReadonly: Int {
        return 111
    }
}

extension Array where Element : DictionaryMappingProtocol  {
    public init(dictionaries: [ AnyDictionary ]) {
        self.init()
    
        let elementType = type(of: self).Element.self
//        DLog(elementType)
        
        for dictionary in dictionaries {
            let object = elementType.init(dictionary: dictionary)
            //object.setValues(fromDictionary: dictionary)
            self.append(object)
            
            //print(dictionary)
        }
    }
    
    public func toDictionaries() -> [ AnyDictionary ] {
        var array = [ AnyDictionary ]()
        
        for element in self {
            array.append(element.toDictionary())
        }
        
        return array
    }
}

extension NSObject: DictionaryMappingProtocol {
    
//    public init(dictionary: AnyDictionary) {
//        self.init()
//        
//        setValues(fromDictionary: dictionary)
//    }
    
    public func setValues(fromDictionary dictionary: AnyDictionary) {
        
        // We use static dictionary: [className: [propertyName: propertyType] ] here to store structure of class.
        // Probably it should make mapping faster.
        struct StaticHolder {
            static var propertyTypesForTypes = [String: [String: Any.Type] ]()
        }
        
        let typeName = String(describing: type(of: self))
        var propertyTypes = StaticHolder.propertyTypesForTypes[typeName]
        
        if propertyTypes == nil {
            propertyTypes = Mirror(reflecting: self).allPropertyNamesAndTypes()
        
            StaticHolder.propertyTypesForTypes[typeName] = propertyTypes
            //print(StaticHolder.propertyTypesForTypes)
        }
        //
        
        for (key, value) in dictionary {
            //print(key)
            
            if (self.responds(to: Selector(key)) == true) {
                
                let propertyType = propertyTypes?[key]
//                let valueType = type(of: value)     // looks like this is always "Any"
                var finalValue = value

                // Need to add [valueClass isSubclassOfClass: propertyClass] check here.
                // Don't know how to do it correctly in Swift.
                guard propertyType != nil else {
                    continue
                }
                
//                print("111111 \(finalValue)")
//                print("222222 \(propertyType) \(propertyType is Date?.Type)")
                
                if value is AnyDictionary {
                
                    if propertyType is NSObject.Type || propertyType is NSObject?.Type {
                        finalValue = (propertyType as! NSObject.Type).init()
                        (finalValue as! NSObject).setValues(fromDictionary: (value as! AnyDictionary) )
                    }
                    
                } else if propertyType is Date.Type || propertyType is Date?.Type {
                    
                    if let doubleValue = value as? Double {
                        finalValue = Date(timeIntervalSince1970: doubleValue)
                    }
                    
                }
                
                //if let type = valueType as? String.Type {
                //    print("dfofofko \(valueType): \(key)")
                //}
                
//                if let value = value as? [ [String: Any?] ] {
//                    print(">>> Array type: \(propertyType)")
//                    
//                    let arrayType = (propertyType as? [NSObject].Type)
//                    if arrayType != nil {
//                        let type = type(of: arrayType!.Element())
//                        print(">>> Element type: \(type)")
//                        finalValue = arrayType?.init(dictionaries: value, targetType: type)
//                    }
//
//                }
                
                self.setValue(finalValue, forKey: key)
    
            }
        }
    }
    
    public func toDictionary() -> AnyDictionary {
        let mirror = Mirror(reflecting: self)
        let dictionary = mirror.toDictionary()
        
        var result = AnyDictionary()
        for (key, value) in dictionary {
            
            var resultValue = value
            
            if let object = value as? NSObject, let _ = object as? RecursiveDictionaryMappingProtocol {
                
                resultValue = object.toDictionary()
                
            } else if let mappingValue = value as? DictionaryMappingProtocol {
                
                resultValue = mappingValue.toDictionary()
                
            } else if let date = value as? Date {
              
                // Dates are stored as double values.
                resultValue = date.timeIntervalSince1970
                
            }
                
            result[key] = resultValue
        
        }
        
        return result
    }
}
