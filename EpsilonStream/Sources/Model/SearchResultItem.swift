//
//  SearchResultItem.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 29/12/16.
//  Copyright © 2016 Yoni Nazarathy. All rights reserved.
//

import Foundation
import UIKit

enum SearchResultItemType {
    case video
    case iosApp
    case gameWebPage
    case blogWebPage
    case mathObjectLink
    case specialItem
    case messageItem
}

class SearchResultItem {
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
}

class IOsAppSearchResultItem: FeatureSearchResultItem {
    var appId = ""
}

class GameWebPageSearchResultItem: FeatureSearchResultItem {
    var url = ""
}

class BlogWebPageSearchResultItem: FeatureSearchResultItem {
    var url = ""
}

class MathObjectLinkSearchResultItem: SearchResultItem {
    var hashTags                    = "" //QQQQ note sure that need this
    var searchTitle                 = ""
    var titleDetail                 = ""
    var imageKey                    = ""
    var ourMathObjectLinkHashTag    = ""
    
    convenience init(mathObjectLink: MathObjectLink) {
        self.init()
        
        title = mathObjectLink.ourTitle
        hashTags = mathObjectLink.hashTags
        channel = "MATH-OBJECT-LINK-CHANNEL"
        type = SearchResultItemType.mathObjectLink
        title = mathObjectLink.ourTitle
        searchTitle = mathObjectLink.searchTitle
        imageKey = mathObjectLink.imageKey
        imageURL = URL(string: mathObjectLink.imageURL)
        inCollection = mathObjectLink.isInCollection
        hashTagPriorities = mathObjectLink.hashTagPriorities
        rawPriority = mathObjectLink.displaySearchPriority
        titleDetail = mathObjectLink.ourTitleDetail
        splashKey = mathObjectLink.splashKey
        ourMathObjectLinkHashTag = mathObjectLink.ourMathObjectLinkHashTag
    }
}

class SpecialSearchResultItem: SearchResultItem {
}

class UserMessageResultItem: SearchResultItem {
}
