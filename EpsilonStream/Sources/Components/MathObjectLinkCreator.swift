import Foundation
import CloudKit

enum MathObjectLinkCreatorState {
    case initial
    case enterSearchTerm
    case finishCreation
}

class MathObjectLinkCreator: NSObject {
    
    // MARK: - Properties
    
    var defaultTitle: String {
        return LocalString("MathObjectLinkCreatorDefaultTitle") + " " + searchString
    }
    
    var defaultSubtitle: String {
        return LocalString("MathObjectLinkCreatorDefaultSubtitle")
    }
    
    private(set) var state = MathObjectLinkCreatorState.initial {
        didSet {
            if state != oldValue {
                if state == .initial {
                    hashTag         = ""
                    searchString    = ""
                    imageURL        = ""
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
    
    var imageURL = ""
    let defaultImageURLs =          [ "", "https://es-app.com/assets/eded3c.png", "https://es-app.com/assets/eabs45.png",
                                      "https://es-app.com/assets/e3DF6h.png", "https://es-app.com/assets/" ]
    let defaultImageURLsAliases =   [ "No image", "Exploding Dots", "Full Logo", "Bullet Logo", "Custom" ]
    let customImageIndex = 4
    
    // MARK: - Methods
    
    public func reset() {
        state = .initial
    }
    
    private func startCreateMathObjectLink(withHashTag hashTag: String) {
        self.hashTag = hashTag
        state = .enterSearchTerm
    }
    
    public func confirmStartCreateMathObjectLink(withHashTag hashTag: String, confirmation: ((Bool) ->())? = nil) {
        AlertManager.shared.showStartCreateMathObjectLink(confirmation: { (confirmed, _) in
            if confirmed {
                self.startCreateMathObjectLink(withHashTag: hashTag)
            }
            confirmation?(confirmed)
        })
    }
    
    private func submitMathObjectLink(withTitle title: String?, subtitle: String?) {
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
        record["imageURL"]                  = imageURL                      as CKRecordValue
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
                
                if (error == nil) {
                    self.state = .initial
                } else {
                    AlertManager.shared.showError(error: error!)
                }
            }
        }
    }
    
    private func finishCreateMathObjectLink() {
        let title = defaultTitle
        let subtitle = defaultSubtitle
        
        AlertManager.shared.showEditMOLinkTitleAndSubtitle(withTitle: title, subtitle: subtitle, confirmation: { (title, subtitle) in
            //DLog("\(title), \(subtitle)")
            
            AlertManager.shared.showSelectMOLinkImageURL(withURLAliases: self.defaultImageURLsAliases, confirmation: { (confirmed, buttonIndex) in
                if confirmed {
                    self.imageURL = self.defaultImageURLs[buttonIndex]
                    
                    if buttonIndex == self.customImageIndex {
                        let message = LocalString("MathObjectLinkCreatorCustomImageURLMessage")
                        AlertManager.shared.showTextField(withText: "", message: message, confirmation: { (confirmed, text) in
                            if (confirmed == true) {
                                self.imageURL = (text != nil && text!.count > 0) ? self.imageURL + text! : ""
                                self.submitMathObjectLink(withTitle: title, subtitle: subtitle)
                            }
                        })
                    } else {
                        self.submitMathObjectLink(withTitle: title, subtitle: subtitle)
                    }
                }
            })
            
        })
    }
    
    public func confirmFinishCreateMathObjectLink(confirmation: ((Bool) ->())? = nil ) {
        AlertManager.shared.showFinishCreateMathObjectLink(hashtag: hashTag, searchText: searchString, confirmation: { (confirmed, _) in
            if confirmed {
                self.finishCreateMathObjectLink()
            }
            confirmation?(confirmed)
        })
    }
}
