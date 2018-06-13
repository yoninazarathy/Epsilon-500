import Foundation
import CloudKit

enum MathObjectLinkCreatorState {
    case initial
    case enterSearchTerm
    case finishCreation
}

class MathObjectLinkCreator: NSObject {
    var defaultTitle: String {
        return LocalString("MathObjectLinkCreatorDefaultTitle") + " " + searchString
    }
    
    var defaultSubtitle: String {
        return LocalString("MathObjectLinkCreatorDefaultSubtitle")
    }
    
    var state = MathObjectLinkCreatorState.initial {
        didSet {
            if state != oldValue {
                if state == .initial {
                    hashTag = ""
                    searchString = ""
                }
                didChangeState?()
            }
        }
    }
    var didChangeState: (() -> Void)?
    
    var hashTag = "" {
        didSet {
            if hashTag != oldValue {
                didChangeHashTag?()
            }
        }
    }
    var didChangeHashTag: (() -> Void)?
    
    var searchString = "" {
        didSet {
            if searchString != oldValue {
                didChangeSearchString?()
            }
        }
    }
    var didChangeSearchString: (() -> Void)?
    
    func submitMathObjectLink(withTitle title: String?, subtitle: String?, completion: @escaping ((Error?)->Void) ) {
        var finalTitle = title
        if title == nil || title!.isEmpty {
            finalTitle = defaultTitle
        }
        var finalSubtitle = subtitle
        if subtitle == nil || subtitle!.isEmpty {
            finalSubtitle = defaultSubtitle
        }
        
        let record = CKRecord(recordType: String(describing: "MathObjectLinks") )
        record["avoidPlatforms"]            = ""                            as CKRecordValue
        record["cellImageKey"]              = ""                            as CKRecordValue
        record["contentVersionNumber"]      = 1                             as CKRecordValue
        record["displaySearchPriority"]     = 0                             as CKRecordValue
        record["hashTagPriorities"]         = ""                            as CKRecordValue
        record["hashTags"]                  = hashTag                       as CKRecordValue
        record["imageKey"]                  = ""                            as CKRecordValue
        record["imageURL"]                  = ""                            as CKRecordValue
        record["isInCollection"]            = true                          as CKRecordValue
        record["notes"]                     = ""                            as CKRecordValue
        record["ourMathObjectLinkHashTag"]  = hashTag + "MathObjectLink"    as CKRecordValue
        record["ourTitle"]                  = finalTitle!                   as CKRecordValue
        record["ourTitleDetail"]            = finalSubtitle!                as CKRecordValue
        record["searchTitle"]               = searchString                  as CKRecordValue
        record["splashKey"]                 = ""                            as CKRecordValue

        AlertManager.shared.showWait()
        CKContainer.default().publicCloudDatabase.save(record) { (record, error) in
            Common.performOnMainThread {
                if record != nil {
                    let newLink = MathObjectLink(inContext: PersistentStorageManager.shared.mainContext)
                    newLink.update(fromCloudRecord: record!)
                    PersistentStorageManager.shared.saveMainContext()
                }
                
                AlertManager.shared.closeWait()
                completion(error)
            }
        }
    }
}
