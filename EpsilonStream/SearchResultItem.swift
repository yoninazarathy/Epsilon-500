//
//  SearchResultItem.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 29/12/16.
//  Copyright © 2016 Yoni Nazarathy. All rights reserved.
//

import Foundation
import UIKit

enum SearchResultItemType{
    case video
    case iosApp
    case gameWebPage
    case blogWebPage
    case mathObjectLink
    case specialItem
}

class SearchResultItem{
    var title: String = ""
    var channel: String = ""
    //var image: UIImage? = nil //QQQQ delete
    var imageName: String = ""
    var type: SearchResultItemType = SearchResultItemType.video
    var inCollection: Bool = true
    var hashTagPriorities: String = ""
    var rawPriority: Float = -1.0
    var foundPriority: Float = 0.5
    var splashKey: String = "none"
}

class VideoSearchResultItem: SearchResultItem{
    var youtubeId: String = ""//11 chars base 64 youtube id
    var durationString: String? = nil
    var percentWatched: Float = 0.0
}

class FeatureSearchResultItem: SearchResultItem{
    var ourFeaturedURLHashtag: String = ""
    var isExternal: Bool = false
}

class IOsAppSearchResultItem: FeatureSearchResultItem{
    var appId: String = ""
}

class GameWebPageSearchResultItem: FeatureSearchResultItem{
    var url: String = ""
}

class BlogWebPageSearchResultItem: FeatureSearchResultItem{
    var url: String = ""
}

class MathObjectLinkSearchResultItem: SearchResultItem{
    var hashTags: String = "" //QQQQ note sure that need this
    var searchTitle: String = ""
    var titleDetail: String = ""
    var imageKey: String = ""
    var ourMathObjectLinkHashTag: String = ""
}

class SpecialSearchResultItem: SearchResultItem{
}
