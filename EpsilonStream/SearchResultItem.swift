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
}

class SearchResultItem{
    var title: String = ""
    var channel: String = ""
    var image: UIImage? = nil
    var type: SearchResultItemType = SearchResultItemType.video
}

class VideoSearchResultItem: SearchResultItem{
    var youtubeId: String = ""//11 chars base 64 youtube id
    var durationString: String? = nil
    var percentWatched: Float = 0.0
}

class IOsAppSearchResultItem: SearchResultItem{
    var appId: String = ""
}

class GameWebPageSearchResultItem: SearchResultItem{
    var url: String = ""
}

class BlogWebPageSearchResultItem: SearchResultItem{
    var url: String = ""
}
