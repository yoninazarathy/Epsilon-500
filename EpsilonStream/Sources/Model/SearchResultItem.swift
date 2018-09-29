import Foundation
import UIKit
import CloudKit

enum SearchResultItemType {
    case video
    case iosApp
    case gameWebPage
    case blogWebPage
    case mathObjectLink
    case specialItem
    case messageItem
    case snippet
}

class SearchResultItem {
    var recordName: String!
    var title = ""
    var channel = ""
    var imageName = ""
    var imageURL: URL?
    var type = SearchResultItemType.video
    var inCollection = true
    var hashTagPriorities = ""
    var rawPriority = Float(-1.0)
    var foundPriority = Float(0.5)
    var splashKey = "none"
}

class VideoSearchResultItem: SearchResultItem {
    var youtubeId = ""//11 chars base 64 youtube id
    var durationString: String?
    var percentWatched = Float(0.0)
}

class FeatureSearchResultItem: SearchResultItem {
    var ourFeaturedURLHashtag = ""
    var isExternal = false
    
    init(featuredURL: FeaturedURL, itemType: SearchResultItemType) {
        super.init()
        
        recordName             = featuredURL.recordName
        title                  = featuredURL.ourTitle
        channel                = featuredURL.provider
        ourFeaturedURLHashtag  = featuredURL.ourFeaturedURLHashtag
        imageName              = featuredURL.imageKey!
        imageURL               = URL(string: featuredURL.imageURL)
        hashTagPriorities      = featuredURL.hashTagPriorities
        rawPriority            = featuredURL.displaySearchPriority
        isExternal             = featuredURL.isExternal
        splashKey              = featuredURL.splashKey
        type                   = itemType
    }
}

class IOsAppSearchResultItem: FeatureSearchResultItem {
    var appId = ""
    
    override init(featuredURL: FeaturedURL, itemType: SearchResultItemType) {
        super.init(featuredURL: featuredURL, itemType: itemType)
        
        appId = featuredURL.urlOfItem
    }
}

class GameWebPageSearchResultItem: FeatureSearchResultItem {
    var url = ""
    
    override init(featuredURL: FeaturedURL, itemType: SearchResultItemType) {
        super.init(featuredURL: featuredURL, itemType: itemType)
        
        url = featuredURL.urlOfItem
    }
}

class BlogWebPageSearchResultItem: FeatureSearchResultItem {
    var url = ""
    
    override init(featuredURL: FeaturedURL, itemType: SearchResultItemType) {
        super.init(featuredURL: featuredURL, itemType: itemType)
        
        url = featuredURL.urlOfItem
    }
}

class MathObjectLinkSearchResultItem: SearchResultItem {
    var hashTags                    = "" //QQQQ note sure that need this
    var searchTitle                 = ""
    var titleDetail                 = ""
    var imageKey                    = ""
    var ourMathObjectLinkHashTag    = ""
    
    init(mathObjectLink: MathObjectLink) {
        super.init()
        
        recordName                  = mathObjectLink.recordName
        title                       = mathObjectLink.ourTitle
        hashTags                    = mathObjectLink.hashTags
        channel                     = "MATH-OBJECT-LINK-CHANNEL"
        type                        = .mathObjectLink
        title                       = mathObjectLink.ourTitle
        searchTitle                 = mathObjectLink.searchTitle
        imageKey                    = mathObjectLink.imageKey
        imageURL                    = URL(string: mathObjectLink.imageURL)
        inCollection                = mathObjectLink.isInCollection
        hashTagPriorities           = mathObjectLink.hashTagPriorities
        rawPriority                 = mathObjectLink.displaySearchPriority
        titleDetail                 = mathObjectLink.ourTitleDetail
        splashKey                   = mathObjectLink.splashKey
        ourMathObjectLinkHashTag    = mathObjectLink.ourMathObjectLinkHashTag
    }
}

class SpecialSearchResultItem: SearchResultItem {
}

class UserMessageResultItem: SearchResultItem {
}

class SnippetSearchResultItem: SearchResultItem {
    init(snippet: Snippet) {
        super.init()
        
        recordName  = snippet.recordName
        type        = .snippet
        title       = snippet.title
    }
}
