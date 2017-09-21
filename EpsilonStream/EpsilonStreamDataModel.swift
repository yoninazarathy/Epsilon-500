//
//  EpsilonStreamDataModel.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 27/12/16.
//  Copyright © 2016 Yoni Nazarathy. All rights reserved.
//

import Foundation
import CoreData
import CloudKit
import UIKit
import Firebase

//https://stackoverflow.com/questions/28445917/what-is-the-most-succinct-way-to-remove-the-first-character-from-a-string-in-swi
extension String {
    func chopPrefix(_ count: Int = 1) -> String {
        return substring(from: index(startIndex, offsetBy: count))
    }
    
    func chopSuffix(_ count: Int = 1) -> String {
        return substring(to: index(endIndex, offsetBy: -count))
    }
}


//https://stackoverflow.com/questions/32305891/index-of-a-substring-in-a-string-with-swift
extension String {
    func index(of string: String, options: CompareOptions = .literal) -> Index? {
        return range(of: string, options: options)?.lowerBound
    }
    func endIndex(of string: String, options: CompareOptions = .literal) -> Index? {
        return range(of: string, options: options)?.upperBound
    }
    func indexes(of string: String, options: CompareOptions = .literal) -> [Index] {
        var result: [Index] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range.lowerBound)
            start = range.upperBound
        }
        return result
    }
    func ranges(of string: String, options: CompareOptions = .literal) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range)
            start = range.upperBound
        }
        return result
    }
}



//QQQQ When cleaning up this class and the other one (EpsilonStreamBackgroundFetch), make
//a distinction between admin app and client (user) app

class EpsilonStreamDataModel{
    
    //maps "." commands to an NSPredicate tuple, 1 for video and 1 for feature
    static let specialCommands: [String:(NSPredicate,NSPredicate)] = [
        ".curatelogin":(NSPredicate(value:false),NSPredicate(value:false)),
        ".curatelogin.Coco":(NSPredicate(value:false),NSPredicate(value:false)), //QQQQ implement these logins
        ".curatelogin.Inna":(NSPredicate(value:false),NSPredicate(value:false)),
        ".curatelogin.Phil":(NSPredicate(value:false),NSPredicate(value:false)),
        ".curatelogin.Yoni":(NSPredicate(value:false),NSPredicate(value:false)),
        ".curatelogin.Yousuf":(NSPredicate(value:false),NSPredicate(value:false)),
        ".curatelogout":(NSPredicate(value:false),NSPredicate(value:false)),
        ".all":(NSPredicate(value:true),NSPredicate(value:true)),
        ".features":(NSPredicate(value:false),NSPredicate(value:true)),
        ".khan":(NSPredicate(format:"channelKey CONTAINS[cd] %@","Khan Academy"),NSPredicate(value:false)),
        ".mathbff":(NSPredicate(format:"channelKey CONTAINS[cd] %@","mathbff"),NSPredicate(value:false)),
        ".numberphile":(NSPredicate(format:"channelKey CONTAINS[cd] %@","numberphile"),NSPredicate(value:false)),
        ".vihart":(NSPredicate(format:"channelKey CONTAINS[cd] %@","vihart"),NSPredicate(value:false)),
        ".explodingdots":(NSPredicate(format:"channelKey CONTAINS[cd] %@","James Tanton"),NSPredicate(value:false)),
        ".mathantics":(NSPredicate(format:"channelKey CONTAINS[cd] %@","Mathantics"),NSPredicate(value:false)),
        ".tecmath":(NSPredicate(format:"channelKey CONTAINS[cd] %@","tecmath"),NSPredicate(value:false)),
        ".mathologer":(NSPredicate(format:"channelKey CONTAINS[cd] %@","Mathologer"),NSPredicate(value:false)),
        ".3blue1brown":(NSPredicate(format:"channelKey CONTAINS[cd] %@","3Blue1Brown"),NSPredicate(value:false)),
        ".kylepearce":(NSPredicate(format:"channelKey CONTAINS[cd] %@","Kyle Pearce"),NSPredicate(value:false)),
        ".patrickjmt":(NSPredicate(format:"channelKey CONTAINS[cd] %@","PatrickJMT"),NSPredicate(value:false)),
        ".standupmaths":(NSPredicate(format:"channelKey CONTAINS[cd] %@","standupmaths"),NSPredicate(value:false)),
        ".mathhelp":(NSPredicate(format:"channelKey CONTAINS[cd] %@","MathHelp"),NSPredicate(value:false)),
        ".mathmeeting":(NSPredicate(format:"channelKey CONTAINS[cd] %@","Math Meeting"),NSPredicate(value:false)),
        ".wootube":(NSPredicate(format:"channelKey CONTAINS[cd] %@","Eddie Woo"),NSPredicate(value:false)),
        ".tippingpoint":(NSPredicate(format:"channelKey CONTAINS[cd] %@","Tipping Point"),NSPredicate(value:false)),
        ".jamestanton":(NSPredicate(format:"channelKey CONTAINS[cd] %@","DrJamesTanton"),NSPredicate(value:false)),
        ".nationalmuseum":(NSPredicate(format:"channelKey CONTAINS[cd] %@","National Museum of Mathematics"),NSPredicate(value:false)),
        ".artoftheproblem":(NSPredicate(format:"channelKey CONTAINS[cd] %@","Art of the Problem"),NSPredicate(value:false)),
        ".brightstorm":(NSPredicate(format:"channelKey CONTAINS[cd] %@","Brightstorm"),NSPredicate(value:false)),
        ".computerphile":(NSPredicate(format:"channelKey CONTAINS[cd] %@","Computerphile"),NSPredicate(value:false)),
        ".dontmemorise":(NSPredicate(format:"channelKey CONTAINS[cd] %@","Don't Memorise"),NSPredicate(value:false)),
        ".mathtv":(NSPredicate(format:"channelKey CONTAINS[cd] %@","MathTV"),NSPredicate(value:false)),
        ".mindyourdecisions":(NSPredicate(format:"channelKey CONTAINS[cd] %@","MindYourDecisions"),NSPredicate(value:false)),
        ".minutephysics":(NSPredicate(format:"channelKey CONTAINS[cd] %@","minutephysics"),NSPredicate(value:false)),
        ".singingbanana":(NSPredicate(format:"channelKey CONTAINS[cd] %@","singingbanana"),NSPredicate(value:false)),
        ".spoonfullofmath":(NSPredicate(format:"channelKey CONTAINS[cd] %@","Spoonful of Maths"),NSPredicate(value:false)),
        ".saradaherke":(NSPredicate(format:"channelKey CONTAINS[cd] %@","Sarada Herke"),NSPredicate(value:false)),
        ".studypug":(NSPredicate(format:"channelKey CONTAINS[cd] %@","StudyPug"),NSPredicate(value:false)),
        ".vsauce":(NSPredicate(format:"channelKey CONTAINS[cd] %@","Vsauce"),NSPredicate(value:false)),
        ".welchlabs":(NSPredicate(format:"channelKey CONTAINS[cd] %@","Welch Labs"),NSPredicate(value:false)),
        ".mathmammoth":(NSPredicate(format:"channelKey CONTAINS[cd] %@","Math Mammoth"),NSPredicate(value:false)),
        ".globalmathproject":(NSPredicate(format:"channelKey CONTAINS[cd] %@","Global Math Project"),NSPredicate(value:false))

    ]
    
    //QQQQ these are currently just updated on boot
    static var fullHashTagList: Array<String> = []
    static var hashTagAutoCompleteList: Array<String> = []
    static var hashTagListSortedByTotalContent: Array<String> = []
    static var titleAutoCompleteList: Array<[String]> = []
    static var channelAutoCompleteList: Array<String> = []
    
    static var titlesForSurprise: Array<String> = []
    
    static var hashTagOfTitle = [String:String]()
    static var fullTitles: Array<String> = []
    static var rawTitleOfHashTag = [String:String]()
    
    static var videosOfHashTag = [String:Array<String>]()
    static var articlesOfHashTag = [String:Array<String>]()
    static var gamesOfHashTag = [String:Array<String>]()

    static var videosOfHashTagInColl = [String:Array<String>]()
    static var articlesOfHashTagInColl = [String:Array<String>]()
    static var gamesOfHashTagInColl = [String:Array<String>]()
    
    static var curatorOfHashTag = [String:String]()
    static var reviewerOfHashTag = [String:String]()
    
    static var hashTagInCollection = [String:Bool]()
    
    static var searchStack: [EpsilonStreamSearch] = []
    static var searchStackIndex = 0
    
    ///////////////////////////////////////////////////
    // Searching and autocomplete
    ///////////////////////////////////////////////////
    
    class func printMathObjects(){
        let request = MathObject.createFetchRequest()
        let sort = NSSortDescriptor(key: "hashTag", ascending: true)
        request.sortDescriptors = [sort]
        
        do{
            let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
            let mathObjects = try container.viewContext.fetch(request)
            
            var i = 1
            for mo in mathObjects{
                print("\(i)\t\(mo.hashTag): \(mo.associatedTitles), \(mo.curator) - \(mo.reviewer)")
                i = i + 1
            }
        }catch{
            print("Fetch failed")
        }
    
    }
    
    //QQQQ rename to "set-local memory"
    class func setUpAutoCompleteLists(){
        //QQQQ can improve implementation...
        
        fullHashTagList = []
        hashTagAutoCompleteList = []
        titleAutoCompleteList = []
        channelAutoCompleteList = []
        titlesForSurprise = []
        hashTagOfTitle = [:]
        fullTitles = []
        rawTitleOfHashTag = [:]
        videosOfHashTag = [:]
        articlesOfHashTag = [:]
        gamesOfHashTag = [:]
        curatorOfHashTag = [:]
        reviewerOfHashTag = [:]
        hashTagInCollection = [:]
        
        let request = MathObject.createFetchRequest()
        let sort = NSSortDescriptor(key: "hashTag", ascending: true)
        request.sortDescriptors = [sort]
        
        do{
            let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
            let mathObjects = try container.viewContext.fetch(request)
            
            for mo in mathObjects{
                EpsilonStreamDataModel.fullHashTagList.append(mo.hashTag) //QQQQ not lowercased ?
                if mo.isInCollection{
                    EpsilonStreamDataModel.hashTagAutoCompleteList.append(mo.hashTag)
                }
                
                rawTitleOfHashTag[mo.hashTag] = mo.associatedTitles
                
                videosOfHashTag[mo.hashTag] = videos(ofHashTag: mo.hashTag)
                articlesOfHashTag[mo.hashTag] = articles(ofHashTag: mo.hashTag)
                gamesOfHashTag[mo.hashTag] = games(ofHashTag: mo.hashTag)

                videosOfHashTagInColl[mo.hashTag] = videos(ofHashTag: mo.hashTag,inCollection: true)
                articlesOfHashTagInColl[mo.hashTag] = articles(ofHashTag: mo.hashTag,inCollection: true)
                gamesOfHashTagInColl[mo.hashTag] = games(ofHashTag: mo.hashTag,inCollection: true)

                
                curatorOfHashTag[mo.hashTag] = mo.curator
                reviewerOfHashTag[mo.hashTag] = mo.reviewer

                hashTagInCollection[mo.hashTag] = mo.isInCollection
                
                if mo.isInCollection{
                    let titleGroups = mo.associatedTitles.components(separatedBy: "~")
                    for grp in titleGroups{
                        let titles = grp.components(separatedBy: ",")
                        var titleGroup: [String] = []
                        var first = true
                        for tit in titles{
                            if tit.characters.first != "$" || tit.characters.last != "$"{
                                print("Error with title: \(tit) in \(titles)")
                            }else{
                                let start = tit.index(tit.startIndex, offsetBy: 1)
                                let end = tit.index(tit.endIndex, offsetBy: -1)
                                let range = start..<end
                                let stripTit = tit.substring(with: range)
                                if stripTit.contains("$") || stripTit.contains(",") || stripTit.contains("~"){
                                    print("Error with title: \(stripTit)")
                                }else{
                                    //print(stripTit)
                                    titleGroup.append(stripTit)
                                    hashTagOfTitle[stripTit] = mo.hashTag
                                    fullTitles.append(stripTit)
                                    if first && mo.hashTag != "#homePage" && mo.hashTag != "#channels" && mo.hashTag != "#games" && mo.hashTag != "#awesome"{
                                        titlesForSurprise.append(stripTit)
                                    }
                                }
                            }
                            first = false
                        }
                        if titleGroup.count > 0{
                            EpsilonStreamDataModel.titleAutoCompleteList.append(titleGroup)
                        }
                    }
                }
            }
        }catch{
            print("Fetch failed")
        }
        fullTitles.sort()
        titlesForSurprise.sort()
    }
    
    /// Returns an array of strings that starts with the provided text
    class func autoCompleteListTitle(_ autocompleteText: String) -> Array<String> {
        let cleanedText = autocompleteText.lowercased()
        var retList: [String] = []

        for lst in titleAutoCompleteList{
            for str in lst{
                if(str.lowercased().hasPrefix(cleanedText)){
                    retList.append(str)
                    break //Append the first one only to the look-up list
                }
            }
            
        }        
        
        return retList.sorted()
    }
    
    /// Returns an array of strings that starts with the provided text
    class func autoCompleteListHashTags(_ autocompleteText: String) -> Array<String> {
        let lowerCaseText = autocompleteText.lowercased()
        let autocompleteList = EpsilonStreamDataModel.hashTagAutoCompleteList.filter { $0.hasPrefix(lowerCaseText) }
        return autocompleteList.sorted()
    }

    
    /// Returns an array of strings that starts with the provided text
    class func autoCompleteListCommands(_ autocompleteText: String) -> Array<String> {
        let lowerCaseText = autocompleteText.lowercased()
        let commandArray = Array(specialCommands.keys) // for Dictionary
        let autocompleteList = commandArray.filter { $0.hasPrefix(lowerCaseText) }
        return autocompleteList.sorted()
    }
    
    
    /// Returns an array of strings that starts with the provided text //QQQQ discontinued
    class func autoCompleteListChannels(_ autocompleteText: String) -> Array<String> {
        let lowerCaseText = autocompleteText.lowercased()
        let autocompleteList = EpsilonStreamDataModel.channelAutoCompleteList.filter { $0.hasPrefix(lowerCaseText) }
        return autocompleteList.sorted()
    }
    
    class func surpriseText() -> String{
        if titlesForSurprise.count == 0{
            return "no titles"
            //QQQQ
        }
        let index = Int(arc4random_uniform(UInt32(titlesForSurprise.count)))
        return titlesForSurprise[index]
    }

    class func videos(ofYoutubeId id:String)-> [Video]{
        let request = Video.createFetchRequest()
        let pred = NSPredicate(format: "youtubeVideoId CONTAINS[cd] %@", id)
        request.predicate = pred
        
        var videos:[Video]=[]
        
        do{
            let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
            
            let foundVideos = try container.viewContext.fetch(request)
            
            videos = foundVideos
        }catch{
            print("Fetch failed")
        }
        
        return videos
    }

    
    class func videos(ofHashTag hashTag: String, inCollection inColl: Bool? = nil) -> [String]{
        let request = Video.createFetchRequest()
        let pattern = NSString(format: "(.*(%1$@),.*|.*(%1$@)\\z)", hashTag)
        let pred = NSPredicate(format: "(hashTags MATCHES[c] %@)", pattern)
        if let ic = inColl{
            let pred2 = NSPredicate(format: "isInCollection = %@", NSNumber(booleanLiteral: ic))
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [pred, pred2])
        }else{
            request.predicate = pred
        }
        
        var videoStrings:[String]=[]
        
        do{
            let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
            
            let videos = try container.viewContext.fetch(request)
            
            for vid in videos{
                videoStrings.append(vid.youtubeVideoId)
            }
            
        }catch{
            print("Fetch failed")
        }

        return videoStrings
    }
    
    
    class func articles(ofHashTag hashTag: String, inCollection inColl: Bool? = nil) -> [String]{
        let request = FeaturedURL.createFetchRequest()
        let pattern = NSString(format: "(.*(%1$@),.*|.*(%1$@)\\z)", hashTag)
        let pred = NSPredicate(format: "(hashTags MATCHES[c] %@)", pattern)
        if let ic = inColl{
            let pred2 = NSPredicate(format: "isInCollection = %@", NSNumber(booleanLiteral: ic))
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [pred, pred2])
        }else{
            request.predicate = pred
        }
        
        var articleStrings:[String]=[]
        
        do{
            let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
            
            let featuredURLs = try container.viewContext.fetch(request)
            
            for fu in featuredURLs{//QQQQ clean up...
                if fu.typeOfFeature == "article" || fu.typeOfFeature == "Article"{
                    articleStrings.append(fu.ourFeaturedURLHashtag)
                }
            }
            
        }catch{
            print("Fetch failed")
        }
        
        return articleStrings
    }
    
    
    class func games(ofHashTag hashTag: String,inCollection inColl: Bool? = nil) -> [String]{
        let request = FeaturedURL.createFetchRequest()
        let pattern = NSString(format: "(.*(%1$@),.*|.*(%1$@)\\z)", hashTag)
        let pred = NSPredicate(format: "(hashTags MATCHES[c] %@)", pattern)
        if let ic = inColl{
            let pred2 = NSPredicate(format: "isInCollection = %@", NSNumber(booleanLiteral: ic))
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [pred, pred2])
        }else{
            request.predicate = pred
        }
        
        var gameStrings:[String]=[]
        
        do{
            let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
            
            let featuredURLs = try container.viewContext.fetch(request)
            
            for fu in featuredURLs{
                if fu.isAppStoreApp == true{
                    gameStrings.append(fu.ourFeaturedURLHashtag)
                }
            }
            
        }catch{
            print("Fetch failed")
        }
        
        return gameStrings
    }
    
    
    class func search(withQuery query: EpsilonStreamSearch) -> [SearchResultItem]{
        
        var hashTag = "" //QQQQ a bit of a mess
        
        var searchString = query.searchString.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if searchString == ""{
            searchString = "#homePage"
            hashTag = "#homePage"
            EpsilonStreamAdminModel.currentHashTag = hashTag //QQQQ just for admin (set priority)
        }
        
        var videosPredicate: NSPredicate!
        var featuresPredicate: NSPredicate!
        var mathObjectLinksPredicate: NSPredicate!
        
        let showAll = isInAdminMode
        
        if let ch = searchString.characters.first{
            switch ch{
                case ".":
                    if searchString == ".curatelogin"{
                        EpsilonStreamLoginManager.getInstance().loginAdminRequest(withUser:nil)
                        videosPredicate = NSPredicate(value:false)
                        featuresPredicate = NSPredicate(value:false)
                        mathObjectLinksPredicate = NSPredicate(value:false)
                        break
                    }else if searchString.hasPrefix(".curatelogin."){
                        let user = searchString.chopPrefix(13)
                        print(user)
                        EpsilonStreamLoginManager.getInstance().loginAdminRequest(withUser:user)
                        videosPredicate = NSPredicate(value:false)
                        featuresPredicate = NSPredicate(value:false)
                        mathObjectLinksPredicate = NSPredicate(value:false)
                        break
                    }else if searchString == ".curatelogout"{
                        if isInAdminMode{
                            EpsilonStreamLoginManager.getInstance().logoutAdmin()
                        }
                        videosPredicate = NSPredicate(value:false)
                        featuresPredicate = NSPredicate(value:false)
                        mathObjectLinksPredicate = NSPredicate(value:false)
                        break
                    }
                    
                    if isInAdminMode == false{
                        videosPredicate = NSPredicate(value:false)
                        featuresPredicate = NSPredicate(value:false)
                        mathObjectLinksPredicate = NSPredicate(value:false)
                        break
                    }
                    
                    //QQQQ treat "..<searchString>" as ".all.<searchString>"
                    if searchString.characters.count >= 2 && searchString.substring(with: 0..<2) == ".."{
                        searchString = ".all.\(searchString.chopPrefix(2))"
                    }
                    let comps = searchString.components(separatedBy: ".")
                    if let predTuple = specialCommands[".\(comps[1])"]{
                        videosPredicate = predTuple.0
                        featuresPredicate = predTuple.1
                        mathObjectLinksPredicate = NSPredicate(value:false)
                    }else{
                        videosPredicate = NSPredicate(value:false)
                        featuresPredicate = NSPredicate(value:false)
                        mathObjectLinksPredicate = NSPredicate(value:false)
                    }
                    if comps.count > 2{
                        let searchTerm = comps[2]
                        videosPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [videosPredicate, NSPredicate(format: "youtubeTitle CONTAINS[cd] %@",searchTerm)])
                        featuresPredicate = NSPredicate(format: "ourTitle CONTAINS[cd] %@",searchTerm)
                        mathObjectLinksPredicate = NSPredicate(value:false)
                    }
                
              case "#":
                    if searchString != "#"{//QQQQ temp to avoid searching all
                        videosPredicate = NSPredicate(format: "hashTags CONTAINS[cd] %@", searchString)//QQQQ =[cd]
                        hashTag = searchString
                    }else{
                        videosPredicate = NSPredicate(value: false)
                    }
                
                    featuresPredicate = videosPredicate
                    mathObjectLinksPredicate = videosPredicate

                default: //a "normal" search
                    let hts = hashTags(ofString: searchString)
                    var plist: [NSPredicate] = []
                    if hts.count > 0{
                        hashTag = hts[0] //QQQQ handle first
                    }
                    for tag in hts{
                        //let pred = NSPredicate(format: "hashTags CONTAINS[cd] %@", tag)//QQQQ =[cd]
                        let pattern = NSString(format: "(.*(%1$@),.*|.*(%1$@)\\z)", tag)
                        let pred = NSPredicate(format: "(hashTags MATCHES[c] %@)", pattern)
                        plist.append(pred)
                    }
                    videosPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: plist)
                    featuresPredicate = videosPredicate
                    mathObjectLinksPredicate = videosPredicate
            }
        }else{
            return [] //QQQQ return in case of no video
        }
        
        let predicateColl = showAll ? NSPredicate(value: true) : NSPredicate(format: "isInCollection == %@", NSNumber(booleanLiteral: true))

        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let request = Video.createFetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateColl, videosPredicate])

        
        var videoSearchResult: [SearchResultItem] = []
        var appSearchResult: [SearchResultItem] = []
        var blogSearchResult: [SearchResultItem] = []
        var mathObjectLinkSearchResult: [SearchResultItem] = []

        request.fetchLimit = maxVideosToShow //QQQQ not needed below //QQQQ do for features

        do{
            let videos = try container.viewContext.fetch(request)
            
            for i in 0..<videos.count{
                let item = VideoSearchResultItem()
                item.title = videos[i].ourTitle
                item.youtubeId = videos[i].youtubeVideoId
                item.channel = videos[i].channelKey
                item.durationString = "\(( Int(round(Float(videos[i].durationSec)/60))) == 0 ? 1 : Int(round(Float(videos[i].durationSec)/60)))" //QQQQ make neat repres
                item.percentWatched = UserDataManager.getPercentWatched(forKey: videos[i].youtubeVideoId)
                item.inCollection = videos[i].isInCollection
                //item.image = ImageManager.getImage(forKey: videos[i].youtubeVideoId, withDefault: "Watch_icon")
                item.imageName = videos[i].youtubeVideoId
                item.hashTagPriorities = videos[i].hashTagPriorities
                
                item.rawPriority = videos[i].displaySearchPriority
                
                videoSearchResult.append(item)
                
            }
        }catch{
            print("Fetch failed")
        }
        
        let featureRequest = FeaturedURL.createFetchRequest()
        
        featureRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateColl, featuresPredicate])

        do{
            let features = try container.viewContext.fetch(featureRequest)
            for feature in features{
                if feature.isAppStoreApp{
                    let item = IOsAppSearchResultItem()
                    item.appId = feature.urlOfItem
                    item.title = feature.ourTitle
                    item.channel = feature.provider
                    //item.image = ImageManager.getImage(forKey: feature.imageKey!, withDefault: "Play_icon")
                    item.imageName = feature.imageKey!
                    item.ourFeaturedURLHashtag = feature.ourFeaturedURLHashtag
                    item.inCollection = feature.isInCollection
                    item.hashTagPriorities = feature.hashTagPriorities
                    item.rawPriority = feature.displaySearchPriority
                    item.isExternal = feature.isExternal
                    item.type = SearchResultItemType.iosApp
                    appSearchResult.append(item)
                    
                    //QQQQ assert here type is game and not article
                    
                }else{
                    if feature.typeOfFeature == "game" || feature.typeOfFeature == "Game"{//QQQQ cleanup
                        //This is a game on a web-page
                        let item = GameWebPageSearchResultItem()
                        item.url = feature.urlOfItem
                        item.title = feature.ourTitle
                        item.channel = feature.provider
                        item.ourFeaturedURLHashtag = feature.ourFeaturedURLHashtag
                        //item.image = ImageManager.getImage(forKey: feature.imageKey!, withDefault: "Play_icon")
                        item.imageName = feature.imageKey!
                        item.type = SearchResultItemType.gameWebPage
                        item.hashTagPriorities = feature.hashTagPriorities
                        item.rawPriority = feature.displaySearchPriority
                        item.isExternal = feature.isExternal
                        item.splashKey = feature.splashKey
                        blogSearchResult.append(item)
                        //QQQQ continue here
                    }else{ //is article
                        //QQQQ the third option is GameWebPageSearchResultItem
                        let item = BlogWebPageSearchResultItem()
                        item.url = feature.urlOfItem
                        item.title = feature.ourTitle
                        item.channel = feature.provider
                        item.ourFeaturedURLHashtag = feature.ourFeaturedURLHashtag
                        //item.image = ImageManager.getImage(forKey: feature.imageKey!, withDefault: "Explore_icon")
                        item.imageName = feature.imageKey!
                        item.type = SearchResultItemType.blogWebPage
                        item.hashTagPriorities = feature.hashTagPriorities
                        item.rawPriority = feature.displaySearchPriority
                        item.isExternal = feature.isExternal
                        item.splashKey = feature.splashKey
                        blogSearchResult.append(item)
                        
                        //QQQQ assert here type is article

                    }
                }
            }
        }catch{
            print("Fetch failed")
        }
        
        
        let mathObjectLinkRequest = MathObjectLink.createFetchRequest()
        
        mathObjectLinkRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateColl, mathObjectLinksPredicate])
        
        do{
            let moLinks = try container.viewContext.fetch(mathObjectLinkRequest)
            for mol in moLinks{
                let item = MathObjectLinkSearchResultItem()
                item.title = mol.ourTitle
                item.hashTags = mol.hashTags
                item.channel = "MATH-OBJECT-LINK-CHANNEL"
                item.type = SearchResultItemType.mathObjectLink
                item.title = mol.ourTitle
                item.searchTitle = mol.searchTitle
                item.imageKey = mol.imageKey
                item.inCollection = mol.isInCollection
                item.hashTagPriorities = mol.hashTagPriorities
                item.rawPriority = mol.displaySearchPriority
                item.titleDetail = mol.ourTitleDetail
                item.splashKey = mol.splashKey
                item.ourMathObjectLinkHashTag = mol.ourMathObjectLinkHashTag
                mathObjectLinkSearchResult.append(item)
            }
        }catch{
            print("Fetch failed")
        }
        
        
        //QQQQ not yet handling other max (apps/features etc...)
        let len = min(videoSearchResult.count,maxVideosToShow)
        var ret = [SearchResultItem](videoSearchResult[0..<len])
        ret.append(contentsOf: blogSearchResult)
//        print(blogSearchResult.count)
        ret.append(contentsOf: appSearchResult)
        ret.append(contentsOf: mathObjectLinkSearchResult)
        
        var priorityList = [Float](repeating:0.0, count: ret.count)
        for i in 0..<ret.count{
            if hashTag != ""{
                priorityList[i] = findPriority(inHashTagPriorityString: ret[i].hashTagPriorities, forHashTag: hashTag, withRawPriority: ret[i].rawPriority)
            }   
            ret[i].foundPriority = priorityList[i]
        }
        
        
        //QQQQ horrible code to handle ties
        if priorityList.count > 1{
            var sortedList = priorityList.sorted()
            var minDelta = Float.infinity
            for i in 1..<sortedList.count{
                let delta = sortedList[i]-sortedList[i-1]
                if delta > 0{
                    if delta < minDelta{
                        minDelta = delta
                    }
                }else{
                    print("error - delta 0")
                }
            }
        //print(priorityList)
        
        //    for i in 0..<priorityList.count{
        //        priorityList[i] += 0.5*minDelta*(Float(arc4random()) / 0xFFFFFFFF)
        //    }
        }
        
        
        // use zip to combine the two arrays and sort that based on the first
        let combined = zip(priorityList, ret).sorted {$0.0 < $1.0}

        // use map to extract the individual arrays
        ret = combined.map {$0.1}

        
        /*
        //QQQQ "hack" if o search, search as though empty and assume will get "home". - bad
        if ret.count == 0{
            
            var searchObject = EpsilonStreamSearch()
            searchObject.searchString = "#backHomeLink"
            return search(withQuery: searchObject)
        }else{
            return ret
        }
        */
        return ret
    }
    
    //QQQQ Consolidate with code in newPriorityString
    class func findPriority(inHashTagPriorityString priorityString:String,forHashTag tag:String, withRawPriority rawPriority: Float) ->Float{
        
        let cmp: [String] = priorityString.components(separatedBy: "#")
        for c in cmp{
            let tagFree = "\(tag.substring(from: 1)):"
            if c.hasPrefix(tagFree){
                let rem = c.substring(from: tagFree.characters.count)
                if let val = NumberFormatter().number(from: rem){
                    return val.floatValue
                }
            }
        }
    
        return rawPriority
    }
    
    class func newPriorityString(oldHashTagPriorityString oldString:String,forHashTag tag:String, withRawPriority rawPriority: Float) ->String{
        let cmp: [String] = oldString.components(separatedBy: "#")
        let hashFree = tag.substring(from: 1)
        let withoutList = cmp.filter{st in return st.hasPrefix("\(hashFree):") == false}
        let withoutJoined = withoutList.joined(separator: "#")
        let retVal = "\(withoutJoined)\(tag):\(rawPriority)"
        return retVal
    }
    
    /*
 QQQQ remove
    class func penaltyFunction(ofVideo vid: Video, withSearch query: EpsilonStreamSearch) -> Float{
        var penalty = Float(0.0)
        penalty += 2.0 * abs(vid.whyVsHow - query.whyHow)
        //penalty +=  * abs(vid.exploreVsUnderstand - query.exploreUnderstand)
        penalty += abs(vid.age8Rating - query.age8importance)
        penalty += abs(vid.age10Rating - query.age10importance)
        penalty += abs(vid.age12Rating - query.age12importance)
        penalty += abs(vid.age14Rating - query.age14importance)
        penalty += abs(vid.age16Rating - query.age16importance)
        if vid.isAwesome{
            penalty *= 0.7
        }
        
        return penalty
    }
    */
  
    class func getDuration(forVideo videoId: String) -> Int?{
        let request = Video.createFetchRequest()
        request.predicate = NSPredicate(format: "youtubeVideoId == %@", videoId)
        var retVal:Int? = nil
        do{
            let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
            let videos = try container.viewContext.fetch(request)
            
            switch videos.count{
            case 0:
                print("error - can't find video")
            case 1:
                retVal = Int(videos[0].durationSec)
            default:
                print("error - too many videos \(videoId) -- \(videos.count)")
                break
            }
        }catch{
            print("Fetch failed")
        }
        return retVal
    }
    
    
    //////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////
    
    //should return an array of hashtag strings of length 0, 1 or 2 QQQQ?
    class func hashTags(ofString searchString: String) -> [String]{
        let request = MathObject.createFetchRequest()
        //QQQQ at this point when searching for "circle" we would get also stuff associated with "unit circle"
            //NEED TO HANDLE...
        let predicate = NSPredicate(format: "associatedTitles CONTAINS[cd] %@", "$\(searchString)$") //QQQQ
        request.predicate = predicate

        var retValue: [String] = []
        
        do{
            let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
            let mathObjects = try container.viewContext.fetch(request)
            
            for mo in mathObjects{
                if mo.isInCollection{
                    retValue.append(mo.hashTag)
                }
            }
            
        }catch{
            print("Fetch failed")
        }

        //QQQQ give this some thought - it is only used for curation (pushing down priority)
        if retValue.count>0{
            EpsilonStreamAdminModel.currentHashTag = retValue[0]
        }
        
        return retValue
    }
    
    
    class func resetDates(){
        latestVideoDate = Date(timeIntervalSince1970: 0.0)
        latestMathObjectDate = Date(timeIntervalSince1970: 0.0)
        latestFeatureDate = Date(timeIntervalSince1970: 0.0)
        latestMathObjectLinkDate = Date(timeIntervalSince1970: 0.0)
    }
    
    class func setLatestDates(){
        
        //////////////////////
        //////////////////////
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let request = Video.createFetchRequest()
        request.fetchLimit = 1
        
        request.sortDescriptors = [NSSortDescriptor(key: "oneOnEpsilonTimeStamp", ascending: false)]
        
        do{
            let videos = try container.viewContext.fetch(request)

            if videos.count == 0{
                latestVideoDate = Date(timeIntervalSince1970: 0.0)
                print("found no videos - setting video date to 1970")
            }else{
                latestVideoDate = videos[0].oneOnEpsilonTimeStamp
            }
        }catch{
            print("Fetch failed")
        }
        
        //////////////////////
        //////////////////////
        let request2 = MathObject.createFetchRequest()
        request2.fetchLimit = 1
        request2.sortDescriptors = [NSSortDescriptor(key: "oneOnEpsilonTimeStamp", ascending: false)]
        
        do{
            let mathObjects = try container.viewContext.fetch(request2)
            
            if mathObjects.count == 0{
                latestMathObjectDate = Date(timeIntervalSince1970: 0.0)
                print("found no math objects - setting math object date to 1970")
            }else{
                latestMathObjectDate = mathObjects[0].oneOnEpsilonTimeStamp
            }
        }catch{
            print("Fetch failed")
        }
        
        //////////////////////
        //////////////////////
        let request3 = FeaturedURL.createFetchRequest()
        request3.fetchLimit = 1
        request3.sortDescriptors = [NSSortDescriptor(key: "oneOnEpsilonTimeStamp", ascending: false)]
        
        do{
            let featuredURLs = try container.viewContext.fetch(request3)
            
            if featuredURLs.count == 0{
                latestFeatureDate = Date(timeIntervalSince1970: 0.0)
                print("found no featured urls - setting featured url datedate to 1970")
            }else{
                latestFeatureDate = featuredURLs[0].oneOnEpsilonTimeStamp
            }
        }catch{
            print("Fetch failed")
        }
        
        //////////////////////
        //////////////////////
        let request4 = MathObjectLink.createFetchRequest()
        request4.fetchLimit = 1
        request4.sortDescriptors = [NSSortDescriptor(key: "oneOnEpsilonTimeStamp", ascending: false)]
        
        do{
            let mathObjectLinks = try container.viewContext.fetch(request4)
            
            if mathObjectLinks.count == 0{
                latestMathObjectLinkDate = Date(timeIntervalSince1970: 0.0)
                print("found no math object links - setting math object date to 1970")
            }else{
                latestMathObjectLinkDate = mathObjectLinks[0].oneOnEpsilonTimeStamp
            }
        }catch{
            print("Fetch failed")
        }
     }
    
    static var minimalNextSaveTime: Date = Date()
    
    //QQQQ This is currently implemented as a workaround for crashes associated with saving the view context
    class func saveViewContext(){
        DispatchQueue.main.async {
            do {
                let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
                try container.viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //QQQQ use generic to merge three methods
    class func numVideos(inCollection inCol: Bool? = nil) -> Int{
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let request = Video.createFetchRequest()
        if let ic = inCol{
            request.predicate = NSPredicate(format: "isInCollection = %@", NSNumber(booleanLiteral: ic))
        }
        
        var retVal = -1
        
        do{
            let result = try container.viewContext.fetch(request)
            retVal = result.count
        }catch{
            print("Fetch failed")
        }
        
        return retVal
    }
    
    class func numMathObjects() -> Int{
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let request = MathObject.createFetchRequest()
        
        var retVal = -1
        
        do{
            let result = try container.viewContext.fetch(request)
            retVal = result.count
        }catch{
            print("Fetch failed")
        }
        
        return retVal
    }
    
    class func numFeaturedURLs() -> Int{
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let request = FeaturedURL.createFetchRequest()
        
        var retVal = -1
        
        do{
            let result = try container.viewContext.fetch(request)
            retVal = result.count
        }catch{
            print("Fetch failed")
        }
        
        return retVal
    }
    
    
    
    class func latestVersion() -> Int64{
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let request = VersionInfo.createFetchRequest()
        
        var max: Int64 = -1
        
        do{
            let versionInfo = try container.viewContext.fetch(request)
            for version in versionInfo{
                if version.contentVersionNumber > max{
                    max = version.contentVersionNumber
                }
            }
        }catch{
            print("Fetch failed")
        }
        return max
    }
    
    class func latestLoadedVersion() -> Int64{
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let request = VersionInfo.createFetchRequest()
        
        var max: Int64 = -1
        
        do{
            let versionInfo = try container.viewContext.fetch(request)
            for version in versionInfo{
                if version.loaded && version.contentVersionNumber > max{
                    max = version.contentVersionNumber
                }
            }
        }catch{
            print("Fetch failed")
        }
        return max
    }

    class func deleteAllEntities(withName name: String, withPredicate predicate:NSPredicate = NSPredicate(format: "TRUEPREDICATE")){
        
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: name)
        request.predicate = predicate
        let delRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try managedObjectContext.execute(delRequest)
        } catch {
            fatalError("Failed to execute request: \(error)")
        }
        //QQQQ EpsilonStreamDataModel.saveViewContext()
    }
    
    class func videoIntegrityCheck(){
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let request = Video.createFetchRequest()
        
        var idHash:[String:Int] = [:]
        
        do{
            let result = try container.viewContext.fetch(request)
            for v in result{
                if let vcount = idHash[v.youtubeVideoId]{
                    idHash[v.youtubeVideoId] = vcount + 1
                    container.viewContext.delete(v)
                    FIRAnalytics.logEvent(withName: "data_exception", parameters: ["type": "too many videos" as NSObject, "id": v.youtubeVideoId as NSObject, "count": idHash[v.youtubeVideoId]! as NSObject])
                    //QQQQ - used to clean cloud - keep commented.
                    //if isInAdminMode && currentUserId == "yoni"{
                    //    print("XXXX - deleting single record in cloud")
                    //   EpsilonStreamAdminModel.deleteSingleCloudVideoRecord(withVideoId: v.youtubeVideoId)
                    //}
                }else{
                    idHash[v.youtubeVideoId] = 1
                }
            }
        }catch{
            print("Fetch failed")
        }
        
        EpsilonStreamDataModel.saveViewContext()

        for (k,v) in idHash{
            if v > 1{
                print("MULTIPLE COPIES: \(k) -- \(v)")
            }
        }
    }
    
}
