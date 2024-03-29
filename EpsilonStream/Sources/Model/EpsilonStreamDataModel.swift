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

class EpsilonStreamDataModel: ManagedObjectContextUserProtocol {
    
    //maps "." commands to an NSPredicate tuple, 1 for video and 1 for feature
    static let specialCommands: [String: (NSPredicate, NSPredicate)] = [
        ".curatelogin":         (NSPredicate(value:false),NSPredicate(value:false)),
        ".curatelogin.Coco":    (NSPredicate(value:false),NSPredicate(value:false)), //QQQQ implement these logins
        ".curatelogin.Inna":    (NSPredicate(value:false),NSPredicate(value:false)),
        ".curatelogin.Phil":    (NSPredicate(value:false),NSPredicate(value:false)),
        ".curatelogin.Yoni":    (NSPredicate(value:false),NSPredicate(value:false)),
        ".curatelogin.Yousuf":  (NSPredicate(value:false),NSPredicate(value:false)),
        ".curatelogin.Igor":    (NSPredicate(value:false),NSPredicate(value:false)),
        ".curatelogout":        (NSPredicate(value:false),NSPredicate(value:false)),
        ".all":(NSPredicate(value:true),NSPredicate(value:true)),
        ".features":(NSPredicate(value:false),NSPredicate(value:true)),
        ".khan":(NSPredicate(format:"channelKey CONTAINS[cd] %@","Khan Academy"),NSPredicate(value:false)),
        ".mathbff":(NSPredicate(format:"channelKey CONTAINS[cd] %@","mathbff"),NSPredicate(value:false)),
        ".numberphile":(NSPredicate(format:"channelKey CONTAINS[cd] %@","numberphile"),NSPredicate(value:false)),
        ".vihart":(NSPredicate(format:"channelKey CONTAINS[cd] %@","vihart"),NSPredicate(value:false)),
        ".jamestanton":(NSPredicate(format:"channelKey CONTAINS[cd] %@","James Tanton"),NSPredicate(value:false)),
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
        ".drjamestanton":(NSPredicate(format:"channelKey CONTAINS[cd] %@","DrJamesTanton"),NSPredicate(value:false)),
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
        ".globalmathproject":(NSPredicate(format:"channelKey CONTAINS[cd] %@","Global Math Project"),NSPredicate(value:false)),
        ".blackpenredpen":(NSPredicate(format:"channelKey CONTAINS[cd] %@","blackpenredpen"),NSPredicate(value:false)),
        ".domainofscience":(NSPredicate(format:"channelKey CONTAINS[cd] %@","Domain of Science"),NSPredicate(value:false)),
        ".teded":(NSPredicate(format:"channelKey CONTAINS[cd] %@","TED-Ed"),NSPredicate(value:false)),
        ".oxsfordsparks":(NSPredicate(format:"channelKey CONTAINS[cd] %@","OxfordSparks"),NSPredicate(value:false)),
        ".pbsinfiniteseries":(NSPredicate(format:"channelKey CONTAINS[cd] %@","PBS Infinite Series"),NSPredicate(value:false)),
        ".thinktwice":(NSPredicate(format:"channelKey CONTAINS[cd] %@","Think Twice"),NSPredicate(value:false)),
        ".tyyann":(NSPredicate(format:"channelKey CONTAINS[cd] %@","TyYann"),NSPredicate(value:false)),
        ".statisticslearningcentre":(NSPredicate(format:"channelKey CONTAINS[cd] %@","Statistics Learning Centre"),NSPredicate(value:false)),
        ".goldfishandrobin":(NSPredicate(format:"channelKey CONTAINS[cd] %@","GoldfishAndRobin"),NSPredicate(value:false)),
        ".theallaroundmathguy":(NSPredicate(format:"channelKey CONTAINS[cd] %@","the AllAroundMathGuy"),NSPredicate(value:false)),
        ".colesworldofmath":(NSPredicate(format:"channelKey CONTAINS[cd] %@","Cole's World of Mathematics"),NSPredicate(value:false)),
        ".brandoncraft":(NSPredicate(format:"channelKey CONTAINS[cd] %@","Brandon Craft"),NSPredicate(value:false)),
        ".kealinggeometry":(NSPredicate(format:"channelKey CONTAINS[cd] %@","Kealing Geometry"),NSPredicate(value:false)),
        ".mariosmathtutoring":(NSPredicate(format:"channelKey CONTAINS[cd] %@","Mario's Math Tutoring"),NSPredicate(value:false)),
        ".thebeardedmathman":(NSPredicate(format:"channelKey CONTAINS[cd] %@","The Bearded Math Man"),NSPredicate(value:false)),
        ".mathwithmurphy":(NSPredicate(format:"channelKey CONTAINS[cd] %@","Math With Murphy"),NSPredicate(value:false)),
        ".mathfortress":(NSPredicate(format:"channelKey CONTAINS[cd] %@","Math Fortress"),NSPredicate(value:false)),
        ".mashupmath":(NSPredicate(format:"channelKey CONTAINS[cd] %@","MashUp Math"),NSPredicate(value:false)),
        ".teachertubemath":(NSPredicate(format:"channelKey CONTAINS[cd] %@","TeacherTube Math"),NSPredicate(value:false)),
        ".brianmclogan":(NSPredicate(format:"channelKey CONTAINS[cd] %@","Brian McLogan"),NSPredicate(value:false)),
        ".dlbmaths":(NSPredicate(format:"channelKey CONTAINS[cd] %@","DLBmaths"),NSPredicate(value:false)),
        ".profrobob":(NSPredicate(format:"channelKey CONTAINS[cd] %@","ProfRobBob"),NSPredicate(value:false)),
        ".kristaking":(NSPredicate(format:"channelKey CONTAINS[cd] %@","Krista King"),NSPredicate(value:false)),
        ".yaymath":(NSPredicate(format:"channelKey CONTAINS[cd] %@","yaymath"),NSPredicate(value:false)),
        ".mathtutordvd":(NSPredicate(format:"channelKey CONTAINS[cd] %@","mathtutordvd"),NSPredicate(value:false)),
        ".mathispower4u":(NSPredicate(format:"channelKey CONTAINS[cd] %@","Mathispower4u"),NSPredicate(value:false)),
        ".derekowens":(NSPredicate(format:"channelKey CONTAINS[cd] %@","Derek Owens"),NSPredicate(value:false)),
        ".mysecretmathtutor":(NSPredicate(format:"channelKey CONTAINS[cd] %@","MySecretMathTutor"),NSPredicate(value:false)),
        ".fortbendtutoring":(NSPredicate(format:"channelKey CONTAINS[cd] %@","Fort Bend Tutoring"),NSPredicate(value:false)),
        ".michellekrummel":(NSPredicate(format:"channelKey CONTAINS[cd] %@","Michelle Krummel"),NSPredicate(value:false)),
        ".mywhyu":(NSPredicate(format:"channelKey CONTAINS[cd] %@","MyWhyU"),NSPredicate(value:false))
    ]

    
    //QQQQ these are currently just updated on boot
    static var fullHashTagList: Array<String> = []
    static var hashTagAutoCompleteList: Array<String> = []
    static var titleAutoCompleteList: Array<[String]> = []
    static var titlesForSurprise: Array<String> = []
    static var hashTagOfTitle = [String:String]()
    static var fullTitles = Array<String>()
    static var rawTitleOfHashTag = [String:String]()
    
    static var curatorOfHashTag     = [String: String]()
    static var reviewerOfHashTag    = [String: String]()
    static var hashTagInCollection  = [String: Bool]()
    
    static var videoIDsForHashTags                          = [String: Array<String>]()
    static var videoIDsForHashTagsInCollection              = [String: Array<String>]()
    static var articleURLHashtagsForHashTags                = [String: Array<String>]()
    static var articleURLHashtagsForHashTagsInCollection    = [String: Array<String>]()
    static var gamesURLHashTagsForHashTags                  = [String: Array<String>]()
    static var gamesURLHashTagsForHashTagsInCollection      = [String: Array<String>]()
    
    static var searchStack: [EpsilonStreamSearch] = []
    static var searchStackIndex = 0
    
    // MARK: - Storage
    
    private static var autoCompletionStorageFilePath: String = {
        var path = IKFileManager.shared.documentsDirectoryPath
        path = (path as NSString).appendingPathComponent("EpsilonStreamDataModel")
        path = (path as NSString).appendingPathComponent("AutoCompletion")
        IKFileManager.shared.createDirectoryIfDoesntExist(atPath: path)
        
        return path
    }()
    
    private static func pathForAutoCompletionCollection(withName name: String) -> String {
        var result = (autoCompletionStorageFilePath as NSString).appendingPathComponent(name)
        result = (result as NSString).appendingPathExtension("json")!
        return result
    }
    
    private static func loadAutoCompletionCollection<T: Collection>(atPath path: String) -> T? {
        var result: T?
        if IKFileManager.shared.fileExists(atPath: path), let data = IKFileManager.shared.dataWithContentsOfFile(atPath: path) {
            do {
                result = try JSONSerialization.jsonObject(with: data) as? T
            } catch {
                
            }
        }

        return result
    }
    
    private static func loadAutoCompletionCollection<T: Collection>(withName name: String) -> T? {
        return loadAutoCompletionCollection(atPath: pathForAutoCompletionCollection(withName: name) )
    }
    
    static func loadAllAutoCompletionDictionaries() {
        //let date = Date()
        fullHashTagList             = loadAutoCompletionCollection(withName: "fullHashTagList")         ?? fullHashTagList
        hashTagAutoCompleteList     = loadAutoCompletionCollection(withName: "hashTagAutoCompleteList") ?? hashTagAutoCompleteList
        titleAutoCompleteList       = loadAutoCompletionCollection(withName: "titleAutoCompleteList")   ?? titleAutoCompleteList
        titlesForSurprise           = loadAutoCompletionCollection(withName: "titlesForSurprise")       ?? titlesForSurprise
        hashTagOfTitle              = loadAutoCompletionCollection(withName: "hashTagOfTitle")          ?? hashTagOfTitle
        fullTitles                  = loadAutoCompletionCollection(withName: "fullTitles")              ?? fullTitles
        rawTitleOfHashTag           = loadAutoCompletionCollection(withName: "rawTitleOfHashTag")       ?? rawTitleOfHashTag
        
        curatorOfHashTag            = loadAutoCompletionCollection(withName: "curatorOfHashTag")    ?? curatorOfHashTag
        reviewerOfHashTag           = loadAutoCompletionCollection(withName: "reviewerOfHashTag")   ?? reviewerOfHashTag
        hashTagInCollection         = loadAutoCompletionCollection(withName: "hashTagInCollection") ?? hashTagInCollection
        
        videoIDsForHashTags                          = loadAutoCompletionCollection(withName: "videoIDsForHashTags") ??
            videoIDsForHashTags
        videoIDsForHashTagsInCollection              = loadAutoCompletionCollection(withName: "videoIDsForHashTagsInCollection") ??
            videoIDsForHashTagsInCollection
        articleURLHashtagsForHashTags                = loadAutoCompletionCollection(withName: "articleURLHashtagsForHashTags") ??
            articleURLHashtagsForHashTags
        articleURLHashtagsForHashTagsInCollection    = loadAutoCompletionCollection(withName: "articleURLHashtagsForHashTagsInCollection") ??
            articleURLHashtagsForHashTagsInCollection
        gamesURLHashTagsForHashTags                  = loadAutoCompletionCollection(withName: "gamesURLHashTagsForHashTags") ??
            gamesURLHashTagsForHashTags
        gamesURLHashTagsForHashTagsInCollection      = loadAutoCompletionCollection(withName: "gamesURLHashTagsForHashTagsInCollection") ??
            gamesURLHashTagsForHashTagsInCollection
        //DLog("loadAllAutoCompletionDictionaries duration: \(Date().timeIntervalSince(date))")
    }
    
    private static func saveAutoCompletionCollection<T: Collection>(_ collection: T, atPath path: String) {
        do {
            let data = try JSONSerialization.data(withJSONObject: collection)
            IKFileManager.shared.createFile(atPath: path, contents: data)
        } catch {
        }
    }

    private static func saveAutoCompletionCollection<T: Collection>(_ collection: T, withName name: String) {
        saveAutoCompletionCollection(collection, atPath: pathForAutoCompletionCollection(withName: name))
    }
    
    private static func saveAllAutoCompletionCollections() {
        saveAutoCompletionCollection(fullHashTagList,           withName: "fullHashTagList")
        saveAutoCompletionCollection(hashTagAutoCompleteList,   withName: "hashTagAutoCompleteList")
        saveAutoCompletionCollection(titleAutoCompleteList,     withName: "titleAutoCompleteList")
        saveAutoCompletionCollection(titlesForSurprise,         withName: "titlesForSurprise")
        saveAutoCompletionCollection(hashTagOfTitle,            withName: "hashTagOfTitle")
        saveAutoCompletionCollection(fullTitles,                withName: "fullTitles")
        saveAutoCompletionCollection(rawTitleOfHashTag,         withName: "rawTitleOfHashTag")
        
        saveAutoCompletionCollection(curatorOfHashTag,          withName: "curatorOfHashTag")
        saveAutoCompletionCollection(reviewerOfHashTag,         withName: "reviewerOfHashTag")
        saveAutoCompletionCollection(hashTagInCollection,       withName: "hashTagInCollection")
        
        saveAutoCompletionCollection(videoIDsForHashTags,                       withName: "videoIDsForHashTags")
        saveAutoCompletionCollection(videoIDsForHashTagsInCollection,           withName: "videoIDsForHashTagsInCollection")
        saveAutoCompletionCollection(articleURLHashtagsForHashTags,             withName: "articleURLHashtagsForHashTags")
        saveAutoCompletionCollection(articleURLHashtagsForHashTagsInCollection, withName: "articleURLHashtagsForHashTagsInCollection")
        saveAutoCompletionCollection(gamesURLHashTagsForHashTags,               withName: "gamesURLHashTagsForHashTags")
        saveAutoCompletionCollection(gamesURLHashTagsForHashTagsInCollection,   withName: "gamesURLHashTagsForHashTagsInCollection")
    }
    
    //MARK: - Searching and autocomplete
    
    class func printMathObjects(){
        let request = MathObject.createFetchRequest()
        let sort = NSSortDescriptor(key: "hashTag", ascending: true)
        request.sortDescriptors = [sort]
        
        do{
            let mathObjects = try mainContext.fetch(request)
            
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
    class func setUpAutoCompleteLists(withContext context: NSManagedObjectContext) {
        //QQQQ can improve implementation...
        
//        let startDate = Date()
        var tempFullHashTagList                     = Array<String>()
        var tempHashTagAutoCompleteList             = Array<String>()
        var tempTitleAutoCompleteList               = Array<[String]>()
        var tempTitlesForSurprise                   = Array<String>()
        var tempHashTagOfTitle                      = [String:String]()
        var tempFullTitles                          = Array<String>()
        var tempRawTitleOfHashTag                   = [String:String]()
        
        var tempCuratorOfHashTag     = [String: String]()
        var tempReviewerOfHashTag    = [String: String]()
        var tempHashTagInCollection  = [String: Bool]()
        
        var tempVideoIDsForHashTags                         = [String: Array<String>]()
        var tempVideoIDsForHashTagsInCollection             = [String: Array<String>]()
        var tempArticleURLHashtagsForHashTags               = [String: Array<String>]()
        var tempArticleURLHashtagsForHashTagsInCollection   = [String: Array<String>]()
        var tempGamesURLHashTagsForHashTags                 = [String: Array<String>]()
        var tempGamesURLHashTagsForHashTagsInCollection     = [String: Array<String>]()
        
        let request = MathObject.createFetchRequest()
        let sort = NSSortDescriptor(key: "hashTag", ascending: true)
        request.sortDescriptors = [sort]
        
        // For debug of performance
//        var videosCount = 0
//        var videosInCollectionCount = 0
//        var articlesCount = 0
//        var articlesInCollectionCount = 0
//        var gamesCount = 0
//        var gamesInCollectionCount = 0
        //
        
        do {
            let mathObjects = try context.fetch(request)
            
            for mathObject in mathObjects {
                
                let hashTag = mathObject.hashTag
                
                tempFullHashTagList.append(hashTag) //QQQQ not lowercased ?
                if mathObject.isInCollection {
                    tempHashTagAutoCompleteList.append(hashTag)
                }

                tempRawTitleOfHashTag[hashTag] = mathObject.associatedTitles
                
                // Videos
                let videos = fetchVideos(withContext: context, hashTag: hashTag)
                tempVideoIDsForHashTags[hashTag] = videos.map {
                    $0.youtubeVideoId
                }
                tempVideoIDsForHashTagsInCollection[hashTag] = videos.filter {
                    $0.isInCollection
                }.map {
                    $0.youtubeVideoId
                }
                //
                
                // Articles
                let articles = fetchArticles(withContext: context, hashTag: hashTag)
                tempArticleURLHashtagsForHashTags[hashTag] = articles.map {
                    $0.ourFeaturedURLHashtag
                }
                tempArticleURLHashtagsForHashTagsInCollection[hashTag] = articles.filter {
                    $0.isInCollection
                }.map {
                    $0.ourFeaturedURLHashtag
                }
                //

                // Games
                let games = fetchGames(withContext: context, hashTag: hashTag)
                tempGamesURLHashTagsForHashTags[hashTag] = games.map {
                    return $0.ourFeaturedURLHashtag
                }
                tempGamesURLHashTagsForHashTagsInCollection[hashTag] = games.filter {
                    return $0.isInCollection
                }.map {
                    return $0.ourFeaturedURLHashtag
                }
                //

                //
//                videosCount                 += tempVideoIDsForHashTags[hashTag]!.count
//                videosInCollectionCount     += tempVideoIDsForHashTagsInCollection[hashTag]!.count
//                articlesCount               += tempArticleURLHashtagsForHashTags[hashTag]!.count
//                articlesInCollectionCount   += tempArticleURLHashtagsForHashTagsInCollection[hashTag]!.count
//                gamesCount                  += tempGamesURLHashTagsForHashTags[hashTag]!.count
//                gamesInCollectionCount      += tempGamesURLHashTagsForHashTagsInCollection[hashTag]!.count
                //
                
                tempCuratorOfHashTag[hashTag] = mathObject.curator
                tempReviewerOfHashTag[hashTag] = mathObject.reviewer
                tempHashTagInCollection[hashTag] = mathObject.isInCollection
                
                if mathObject.isInCollection {
                    // IK: Propbably this can be moved to separate method
                    let titleGroups = mathObject.associatedTitles.components(separatedBy: "~")
                    for grp in titleGroups{
                        let titles = grp.components(separatedBy: ",")
                        var titleGroup: [String] = []
                        var first = true
                        for title in titles {
                            if title.first != "$" || title.last != "$" {
                                print("Error with title: \(title) in \(titles)")
                            } else {
                                let stripTitle = title.substring(with: 1..<(title.count - 1))
                                if stripTitle.contains("$") || stripTitle.contains(",") || stripTitle.contains("~") {
                                    DLog("Error with title: \(stripTitle)")
                                } else {
                                    //DLog("stripTitle: \(stripTitle)");
                                    titleGroup.append(stripTitle)
                                    tempHashTagOfTitle[stripTitle] = hashTag
                                    tempFullTitles.append(stripTitle)
                                    if first && hashTag != "#homePage" && hashTag != "#channels" && hashTag != "#games" && hashTag != "#awesome"{
                                        tempTitlesForSurprise.append(stripTitle)
                                    }
                                }
                            }
                            first = false
                        }
                        if titleGroup.count > 0 {
                            tempTitleAutoCompleteList.append(titleGroup)
                        }
                    }
                }
            }
        } catch {
            print("Fetch failed")
        }
        
        tempFullTitles.sort()
        tempTitlesForSurprise.sort()
        
        //
        fullHashTagList         = tempFullHashTagList
        hashTagAutoCompleteList = tempHashTagAutoCompleteList
        titleAutoCompleteList   = tempTitleAutoCompleteList
        titlesForSurprise       = tempTitlesForSurprise
        hashTagOfTitle          = tempHashTagOfTitle
        fullTitles              = tempFullTitles
        rawTitleOfHashTag       = tempRawTitleOfHashTag
        
        curatorOfHashTag        = tempCuratorOfHashTag
        reviewerOfHashTag       = tempReviewerOfHashTag
        hashTagInCollection     = tempHashTagInCollection
        
        videoIDsForHashTags                         = tempVideoIDsForHashTags
        videoIDsForHashTagsInCollection             = tempGamesURLHashTagsForHashTagsInCollection
        articleURLHashtagsForHashTags               = tempArticleURLHashtagsForHashTags
        articleURLHashtagsForHashTagsInCollection   = tempArticleURLHashtagsForHashTagsInCollection
        gamesURLHashTagsForHashTags                 = tempGamesURLHashTagsForHashTags
        gamesURLHashTagsForHashTagsInCollection     = tempGamesURLHashTagsForHashTagsInCollection
        
        saveAllAutoCompletionCollections()
        //
        
        
//        DLog(">>> \(videosCount), \(articlesCount), \(gamesCount)")
//        DLog(">>> \(videosInCollectionCount), \(articlesInCollectionCount), \(gamesInCollectionCount)")
//        DLog("setUpAutoCompleteLists duration: \(Date().timeIntervalSince(startDate))")
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
        let autocompleteList = hashTagAutoCompleteList.filter { $0.hasPrefix(lowerCaseText) }
        return autocompleteList.sorted()
    }

    
    /// Returns an array of strings that starts with the provided text
    class func autoCompleteListCommands(_ autocompleteText: String) -> Array<String> {
        let lowerCaseText = autocompleteText.lowercased()
        let commandArray = Array(specialCommands.keys) // for Dictionary
        let autocompleteList = commandArray.filter { $0.hasPrefix(lowerCaseText) }
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
            videos = try mainContext.fetch(request)
        }catch{
            print("Fetch failed")
        }
        
        return videos
    }

    private class func finishConfigureFetchRequest<T: NSManagedObject>(_ request: NSFetchRequest<T>, predicate: NSPredicate, inCollection: Bool? = nil) {
        if let ic = inCollection {
            let predicate2 = NSPredicate(format: "isInCollection = %@", NSNumber(booleanLiteral: ic))
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
        } else {
            request.predicate = predicate
        }
        //request.includesPropertyValues = false
    }
    
    private class func fetchVideos(withContext context: NSManagedObjectContext, hashTag: String, inCollection: Bool? = nil) -> [Video] {
        let request = Video.createFetchRequest()
        let pattern = NSString(format: "(.*(%1$@),.*|.*(%1$@)\\z)", hashTag)
        let predicate = NSPredicate(format: "(hashTags MATCHES[c] %@)", pattern)
//        let predicate = NSPredicate(format: "%K CONTAINS[cd] %@", "hashTags", hashTag)    // may include wrong results
        finishConfigureFetchRequest(request, predicate: predicate, inCollection: inCollection)
        
        var videos = [Video]()
//        do {
//            videos = try mainContext.fetch(request)
//        } catch {
//            print("Videos for hashtag fetch failed")
//        }
// Trying to make it work on background thread
//        context.performAndWait {
            do {
                videos = try context.fetch(request)
    //            videos = try mainContext.fetch(request)
            } catch {
                print("Videos for hashtag fetch failed")
            }
//        }
        
//        for video in videos {
//            DLog("video ID: \(video.youtubeVideoId)")
//        }

        return videos
    }
    
    
    private class func fetchArticles(withContext context: NSManagedObjectContext, hashTag: String, inCollection: Bool? = nil) -> [FeaturedURL] {
        let articleType = "article" // TODO: define this constant somewhere on global level
        
        let request = FeaturedURL.createFetchRequest()
        let pattern = NSString(format: "(.*(%1$@),.*|.*(%1$@)\\z)", hashTag)
        let predicate = NSPredicate(format: "(hashTags MATCHES[c] %@) && (%K = %@ || %K = %@)", pattern, "typeOfFeature", articleType,
                                    "typeOfFeature", articleType.capitalized)
        finishConfigureFetchRequest(request, predicate: predicate, inCollection: inCollection)
        
        var articles = [FeaturedURL]()
        do {
            articles = try context.fetch(request)
        } catch {
            print("Articles for hashtag fetch failed")
        }
        
        return articles
    }
    
    
    private class func fetchGames(withContext context: NSManagedObjectContext, hashTag: String, inCollection: Bool? = nil) -> [FeaturedURL] {
        let request = FeaturedURL.createFetchRequest()
        let pattern = NSString(format: "(.*(%1$@),.*|.*(%1$@)\\z)", hashTag)
        let predicate = NSPredicate(format: "(hashTags MATCHES[c] %@) && %K = %@", pattern, "isAppStoreApp", NSNumber(value: true) )
        finishConfigureFetchRequest(request, predicate: predicate, inCollection: inCollection)
        
        var games = [FeaturedURL]()
        do {
            games = try context.fetch(request)
        } catch {
            print("Games for hashtag fetch failed")
        }
        
        return games
    }
    
    // IK: This method should be separated into several smaller methods.
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
        var snippetsPredicate: NSPredicate!
        
        let setAllPredicatesFalse = {
            videosPredicate             = NSPredicate(value: false)
            featuresPredicate           = NSPredicate(value: false)
            mathObjectLinksPredicate    = NSPredicate(value: false)
            snippetsPredicate           = NSPredicate(value: false)
        }
        
        let showAll = isInAdminMode
        
        if let ch = searchString.first {
            switch ch {
                case ".":
                    if searchString == ".curatelogin"{
                        EpsilonStreamLoginManager.getInstance().loginAdminRequest(withUser:nil)
                        setAllPredicatesFalse()
                        break
                    }else if searchString.hasPrefix(".curatelogin."){
                        let user = searchString.substring(from: 13)
                        print(user)
                        EpsilonStreamLoginManager.getInstance().loginAdminRequest(withUser:user)
                        setAllPredicatesFalse()
                        break
                    }else if searchString == ".curatelogout"{
                        if isInAdminMode{
                            EpsilonStreamLoginManager.getInstance().logoutAdmin()
                        }
                        setAllPredicatesFalse()
                        break
                    }
                    
                    if isInAdminMode == false {
                        setAllPredicatesFalse()
                        break
                    }
                    
                    //QQQQ treat "..<searchString>" as ".all.<searchString>"
                    if searchString.count >= 2 && searchString.substring(with: 0..<2) == ".."{
                        searchString = ".all.\(searchString.substring(from: 2))"
                    }
                    let comps = searchString.components(separatedBy: ".")
                    if let predTuple = specialCommands[".\(comps[1])"]{
                        videosPredicate = predTuple.0
                        featuresPredicate = predTuple.1
                        mathObjectLinksPredicate = NSPredicate(value: false)
                        snippetsPredicate = NSPredicate(value: false)
                    }else{
                        setAllPredicatesFalse()
                    }
                    if comps.count > 2{
                        let searchTerm = comps[2]
                        videosPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [videosPredicate, NSPredicate(format: "youtubeTitle CONTAINS[cd] %@",searchTerm)])
                        featuresPredicate = NSPredicate(format: "ourTitle CONTAINS[cd] %@",searchTerm)
                        mathObjectLinksPredicate = NSPredicate(value: false)
                        snippetsPredicate = NSPredicate(value: false)
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
                    snippetsPredicate = videosPredicate
                
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
                    snippetsPredicate = videosPredicate
            }
        } else {
            return [] //QQQQ return in case of no video
        }
        
        let predicateColl = showAll ? NSPredicate(value: true) : NSPredicate(format: "isInCollection == %@", NSNumber(booleanLiteral: true))

        let request = Video.createFetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateColl, videosPredicate])
        
        var videoSearchResult: [SearchResultItem] = []
        var appSearchResult: [SearchResultItem] = []
        var blogSearchResult: [SearchResultItem] = []
        var mathObjectLinkSearchResult: [SearchResultItem] = []
        var snippetSearchResult: [SearchResultItem] = []

        request.fetchLimit = maxVideosToShow //QQQQ not needed below //QQQQ do for features

        do {
            let videos = try mainContext.fetch(request)
            
            for video in videos {
                let item = VideoSearchResultItem()
                item.recordName = video.recordName
                item.title = video.ourTitle
                item.youtubeId = video.youtubeVideoId
                item.channel = video.channelKey
                item.durationString = "\(( Int(round(Float(video.durationSec)/60))) == 0 ? 1 : Int(round(Float(video.durationSec)/60)))" //QQQQ make neat repres
                item.percentWatched = UserDataManager.getPercentWatched(forKey: video.youtubeVideoId)
                item.inCollection = video.isInCollection
                item.imageName = video.youtubeVideoId
                item.imageURL = URL(string: video.imageURL)
                item.hashTagPriorities = video.hashTagPriorities
                item.rawPriority = video.displaySearchPriority
                
                videoSearchResult.append(item)
            }
        } catch {
            print("Fetch failed")
        }
        
        let featureRequest = FeaturedURL.createFetchRequest()
        
        featureRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateColl, featuresPredicate])

        do {
            let features = try mainContext.fetch(featureRequest)
            for feature in features {
                if feature.isAppStoreApp {
                    
                    appSearchResult.append(IOsAppSearchResultItem(featuredURL: feature, itemType: .iosApp))
                    
                    //QQQQ assert here type is game and not article
                } else {
                    if feature.typeOfFeature == "game" || feature.typeOfFeature == "Game"{//QQQQ cleanup
                        //This is a game on a web-page
                        blogSearchResult.append(GameWebPageSearchResultItem(featuredURL: feature, itemType: .gameWebPage))
                        //QQQQ continue here
                    } else { //is article
                        //QQQQ the third option is GameWebPageSearchResultItem
                        blogSearchResult.append(BlogWebPageSearchResultItem(featuredURL: feature, itemType: .blogWebPage))
                        //QQQQ assert here type is article
                    }
                }
            }
        } catch {
            print("Fetch failed")
        }
        
        //
        let mathObjectLinkRequest = MathObjectLink.createFetchRequest()
        mathObjectLinkRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateColl, mathObjectLinksPredicate])
        do {
            let moLinks = try mainContext.fetch(mathObjectLinkRequest)
            for moLink in moLinks {
                mathObjectLinkSearchResult.append( MathObjectLinkSearchResultItem(mathObjectLink: moLink) )
            }
        } catch {
            DLog("MOL fetch failed")
        }
        //
        
        //
        let snippetRequest = Snippet.createFetchRequest()
        snippetRequest.predicate = snippetsPredicate
        do {
            let snippets = try mainContext.fetch(snippetRequest)
            for snippet in snippets {
                snippetSearchResult.append( SnippetSearchResultItem(snippet: snippet as! Snippet) )
            }
        } catch  {
            DLog("Snippets fetch failed")
        }
        //
        
        //QQQQ not yet handling other max (apps/features etc...)
        let len = min(videoSearchResult.count, maxVideosToShow)
        var finalResult = [SearchResultItem](videoSearchResult[0..<len])
        finalResult.append(contentsOf: blogSearchResult)
        finalResult.append(contentsOf: appSearchResult)
        finalResult.append(contentsOf: mathObjectLinkSearchResult)
        finalResult.append(contentsOf: snippetSearchResult)
        
        var priorityList = [Float](repeating:0.0, count: finalResult.count)
        for i in 0..<finalResult.count{
            if hashTag != ""{
                priorityList[i] = findPriority(inHashTagPriorityString: finalResult[i].hashTagPriorities, forHashTag: hashTag, withRawPriority: finalResult[i].rawPriority)
            }   
            finalResult[i].foundPriority = priorityList[i]
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
        let combined = zip(priorityList, finalResult).sorted {$0.0 < $1.0}

        // use map to extract the individual arrays
        finalResult = combined.map {$0.1}

        
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
        return finalResult
    }
    
    //QQQQ Consolidate with code in newPriorityString
    class func findPriority(inHashTagPriorityString priorityString:String,forHashTag tag:String, withRawPriority rawPriority: Float) ->Float{
        
        let cmp: [String] = priorityString.components(separatedBy: "#")
        for c in cmp{
            let tagFree = "\(tag.substring(from: 1)):"
            if c.hasPrefix(tagFree){
                let rem = c.substring(from: tagFree.count)
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
            let videos = try mainContext.fetch(request)
            
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
            
            let mathObjects = try mainContext.fetch(request)
            
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
    
    
    class func resetDates() {
        latestVideoDate             = Date(timeIntervalSince1970: 0.0)
        latestMathObjectDate        = Date(timeIntervalSince1970: 0.0)
        latestFeatureDate           = Date(timeIntervalSince1970: 0.0)
        latestMathObjectLinkDate    = Date(timeIntervalSince1970: 0.0)
        latestSnippetsDate          = Date(timeIntervalSince1970: 0.0)
        
        UserDataManager.lastDatabaseUpdateDate = nil
    }
    
    class func getLatestDate<T: BaseCoreDataModel>(forCoreDataClass coreDataClass: T.Type) -> Date {
        var date = Date(timeIntervalSince1970: 0)
        
        let request = coreDataClass.createFetchRequest()
        request.fetchLimit = 1
        
        request.sortDescriptors = [NSSortDescriptor(key: BaseCoreDataModel.modificationDateProperty, ascending: false)]
        
        do {
            let models = try mainContext.fetch(request)
            if models.count > 0 {
                date = models[0].modificationDate
            }
        } catch {
            print("Fetch latest date failed for class \(String(describing: T.self))")
        }
        return date
    }
    
    class func setLatestDates() {
        latestVideoDate             = getLatestDate(forCoreDataClass: Video.self)
        latestMathObjectDate        = getLatestDate(forCoreDataClass: MathObject.self)
        latestFeatureDate           = getLatestDate(forCoreDataClass: FeaturedURL.self)
        latestMathObjectLinkDate    = getLatestDate(forCoreDataClass: MathObjectLink.self)
        latestSnippetsDate          = getLatestDate(forCoreDataClass: Snippet.self)
        
        //////////////////////
        //////////////////////
//        let request = Video.createFetchRequest()
//        request.fetchLimit = 1
//
//        request.sortDescriptors = [NSSortDescriptor(key: BaseCoreDataModel.modificationDateProperty, ascending: false)]
//
//        do{
//            let videos = try mainContext.fetch(request)
//
//            if videos.count == 0{
//                latestVideoDate = Date(timeIntervalSince1970: 0.0)
//                print("found no videos - setting video date to 1970")
//            }else{
//                latestVideoDate = videos[0].modificationDate
//            }
//        }catch{
//            print("Fetch failed")
//        }
        
        //////////////////////
        //////////////////////
//        let request2 = MathObject.createFetchRequest()
//        request2.fetchLimit = 1
//        request2.sortDescriptors = [NSSortDescriptor(key: BaseCoreDataModel.modificationDateProperty, ascending: false)]
//
//        do{
//            let mathObjects = try mainContext.fetch(request2)
//
//            if mathObjects.count == 0{
//                latestMathObjectDate = Date(timeIntervalSince1970: 0.0)
//                print("found no math objects - setting math object date to 1970")
//            }else{
//                latestMathObjectDate = mathObjects[0].modificationDate
//            }
//        }catch{
//            print("Fetch failed")
//        }
        
        //////////////////////
        //////////////////////
//        let request3 = FeaturedURL.createFetchRequest()
//        request3.fetchLimit = 1
//        request3.sortDescriptors = [NSSortDescriptor(key: BaseCoreDataModel.modificationDateProperty, ascending: false)]
//
//        do{
//            let featuredURLs = try mainContext.fetch(request3)
//
//            if featuredURLs.count == 0{
//                latestFeatureDate = Date(timeIntervalSince1970: 0.0)
//                print("found no featured urls - setting featured url datedate to 1970")
//            }else{
//                latestFeatureDate = featuredURLs[0].modificationDate
//            }
//        }catch{
//            print("Fetch failed")
//        }
        
        //////////////////////
        //////////////////////
//        let request4 = MathObjectLink.createFetchRequest()
//        request4.fetchLimit = 1
//        request4.sortDescriptors = [NSSortDescriptor(key: BaseCoreDataModel.modificationDateProperty, ascending: false)]
//
//        do{
//            let mathObjectLinks = try mainContext.fetch(request4)
//
//            if mathObjectLinks.count == 0{
//                latestMathObjectLinkDate = Date(timeIntervalSince1970: 0.0)
//                print("found no math object links - setting math object date to 1970")
//            }else{
//                latestMathObjectLinkDate = mathObjectLinks[0].modificationDate
//            }
//        }catch{
//            print("Fetch failed")
//        }
//
//
     }
    
    static var minimalNextSaveTime: Date = Date()
    
    //QQQQ use generic to merge three methods
    class func numVideos(inCollection inCol: Bool? = nil) -> Int{
        let request = Video.createFetchRequest()
        if let ic = inCol{
            request.predicate = NSPredicate(format: "isInCollection = %@", NSNumber(booleanLiteral: ic))
        }
        
        var retVal = -1
        
        do{
            let result = try mainContext.fetch(request)
            retVal = result.count
        }catch{
            print("Fetch failed")
        }
        
        return retVal
    }
    
    class func numMathObjects() -> Int{
        let request = MathObject.createFetchRequest()
        
        var retVal = -1
        
        do{
            // Is there better way to get count of objects without fetching all objects?
            let result = try mainContext.fetch(request)
            retVal = result.count
        }catch{
            print("Fetch failed")
        }
        
        return retVal
    }
    
    class func numFeaturedURLs() -> Int{
        let request = FeaturedURL.createFetchRequest()
        
        var retVal = -1
        
        do{
            let result = try mainContext.fetch(request)
            retVal = result.count
        }catch{
            print("Fetch failed")
        }
        
        return retVal
    }

    class func deleteAllEntities(withName name: String, withPredicate predicate:NSPredicate = NSPredicate(format: "TRUEPREDICATE")){
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: name)
        request.predicate = predicate
        let delRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try mainContext.execute(delRequest)
        } catch {
            fatalError("Failed to execute request: \(error)")
        }
        //QQQQ EpsilonStreamDataModel.saveViewContext()
    }
    
    class func videoIntegrityCheck(){
        
        EpsilonStreamBackgroundFetch.setActionStart()
        
        let request = Video.createFetchRequest()
        
        var idHash:[String:Int] = [:]
        
        do{
            let result = try mainContext.fetch(request)
            for v in result{
                if let vcount = idHash[v.youtubeVideoId]{
                    idHash[v.youtubeVideoId] = vcount + 1
                    mainContext.delete(v)
                    Analytics.logEvent("data_exception", parameters: ["type": "too many videos" as NSObject, "id": v.youtubeVideoId as NSObject, "count": idHash[v.youtubeVideoId]! as NSObject])
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
        
        PersistentStorageManager.shared.saveMainContext()

        for (k,v) in idHash{
            if v > 1{
                print("MULTIPLE COPIES: \(k) -- \(v)")
            }
        }
        
        EpsilonStreamBackgroundFetch.setActionFinish()
        
    }
}
