import CloudKit

extension CKRecord {//: DictionaryMappingProtocol {
    
    public override func setValues(fromDictionary dictionary: AnyDictionary) {
        for (key, value) in dictionary {
            if key == "recordID" || key == "recordName" {
                continue
            }
            
            self[key] = value as? CKRecordValue
        }
    }
    
    public override func toDictionary() -> AnyDictionary {
        var dictionary = AnyDictionary()
        
        for key in allKeys() {
            dictionary[key] = self[key]
        }
        
        return dictionary
    }
}
