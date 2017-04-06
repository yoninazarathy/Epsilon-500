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

//QQQQ When cleaning up this class and the other one (EpsilonStreamBackgroundFetch), make
//a distinction between admin app and client (user) app

class EpsilonStreamDataModel{
        
    //QQQQ these are currently just updated on boot
    static var hashTagAutoCompleteList: Array<String> = []
    static var titleAutoCompleteList: Array<[String]> = []
    static var channelAutoCompleteList: Array<String> = []
    
    ///////////////////////////////////////////////////
    // Searching and autocomplete
    ///////////////////////////////////////////////////
    
    class func setUpAutoCompleteLists(){
        //QQQQ can improve implementation...
        
        hashTagAutoCompleteList = []
        titleAutoCompleteList = []
        channelAutoCompleteList = []
        
        let request = MathObject.createFetchRequest()
        let sort = NSSortDescriptor(key: "hashTag", ascending: true)
        request.sortDescriptors = [sort]
        
        do{
            let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
            let mathObjects = try container.viewContext.fetch(request)
            
            for mo in mathObjects{
                EpsilonStreamDataModel.hashTagAutoCompleteList.append(mo.hashTag) //QQQQ not lowercased ?
                let titleGroups = mo.associatedTitles.components(separatedBy: "~")
                for grp in titleGroups{
                    let titles = grp.components(separatedBy: ",")
                    var titleGroup: [String] = []
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
                            }
                        }
                    }
                    if titleGroup.count > 0{
                        EpsilonStreamDataModel.titleAutoCompleteList.append(titleGroup)
                    }
                }
                
                //EpsilonStreamDataModel.titleAutoCompleteList = []//titlesSet.sorted()
                //EpsilonStreamDataModel.titleAutoCompleteList.sort()
            }
        }catch{
            print("Fetch failed")
        }
        
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
    class func autoCompleteListChannels(_ autocompleteText: String) -> Array<String> {
        let lowerCaseText = autocompleteText.lowercased()
        let autocompleteList = EpsilonStreamDataModel.channelAutoCompleteList.filter { $0.hasPrefix(lowerCaseText) }
        return autocompleteList.sorted()
    }
    
    class func surpriseText() -> String{
        if titleAutoCompleteList.count == 0{
            return "no titles"
            //QQQQ
        }
        let index = Int(arc4random_uniform(UInt32(titleAutoCompleteList.count)))
        return titleAutoCompleteList[index][0]
    }

    class func search(withQuery query: EpsilonStreamSearch) -> [SearchResultItem]{
        var videoSearchResult: [SearchResultItem] = []
        
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        
        let request = Video.createFetchRequest()
        let hts = hashTags(ofString: query.searchString)
        
        let predicateColl = NSPredicate(format: "isInVideoCollection == %@", NSNumber(booleanLiteral: true))
        //let predicateBuffer = NSPredicate(format: "bufferIndex == %@", currentDBBuffer as NSNumber)

        var predicateOther: NSPredicate! = nil
        var predicateHashTags: NSPredicate! = nil
        
        if hts.count == 0{
            if query.searchString == ""{ //QQQQ allow spaces etc...
                predicateOther = NSPredicate(format: "isAwesome == %@", NSNumber(booleanLiteral: true))
            }else{
                predicateOther = NSPredicate(value: false)
            }
        }else{
            var plist: [NSPredicate] = []
            for tag in hts{
                let pred = NSPredicate(format: "hashTags CONTAINS[cd] %@", tag)
                plist.append(pred)
            }
            predicateHashTags = NSCompoundPredicate(orPredicateWithSubpredicates: plist)
            predicateOther = predicateHashTags
        }
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateColl, predicateOther])
        
        if query.searchString == "#allall"{
            request.predicate = NSPredicate(format: "TRUEPREDICATE")
        }
        
        do{
            let videos = try container.viewContext.fetch(request)
            var penaltyList = [Float](repeating:0.0, count: videos.count)
                        
            for i in 0..<videos.count{
                let item = VideoSearchResultItem()
                item.title = videos[i].ourTitle
                item.youtubeId = videos[i].youtubeVideoId
                item.channel = videos[i].channelKey
                item.durationString = "\(( Int(round(Float(videos[i].durationSec)/60))) == 0 ? 1 : Int(round(Float(videos[i].durationSec)/60)))" //QQQQ make neat repres
                item.percentWatched = videos[i].percentWatched
                
                item.image = ImageManager.getImage(forKey: videos[i].youtubeVideoId)
                
                videoSearchResult.append(item)
                
                penaltyList[i] = penaltyFunction(ofVideo: videos[i], withSearch: query)
            }
            
            // use zip to combine the two arrays and sort that based on the first
            let combined = zip(penaltyList, videoSearchResult).sorted {$0.0 < $1.0}
            
            // use map to extract the individual arrays
            videoSearchResult = combined.map {$0.1}
        }catch{
            print("Fetch failed")
        }
        
        //QQQQ WTF
        var appSearchResult: [SearchResultItem] = []
        var blogSearchResult: [SearchResultItem] = []
        
        let featureRequest = FeaturedURL.createFetchRequest()
        
        //in this case there is associated content - otherwise append random feature
        if predicateHashTags != nil{
            featureRequest.predicate = predicateHashTags
        }else{
            print("RANDOM AWESOME FEATURE - QQQQ")
            //featureRequest.predicate = NSPredicate(value: true)
            featureRequest.predicate = NSPredicate(value: false)
        }
        
        do{
            let features = try container.viewContext.fetch(featureRequest)
            for feature in features{
                if feature.isAppStoreApp{
                    let item = IOsAppSearchResultItem()
                    item.appId = feature.urlOfItem
                    item.title = feature.ourTitle
                    item.channel = feature.provider
                    item.image = ImageManager.getImage(forKey: feature.imageKey!)

                    item.type = SearchResultItemType.iosApp
                    appSearchResult.append(item)
                }else{
                    //QQQQ the third option is GameWebPageSearchResultItem
                    let item = BlogWebPageSearchResultItem()
                    item.url = feature.urlOfItem
                    item.title = feature.ourTitle
                    item.channel = feature.provider
                    item.image = ImageManager.getImage(forKey: feature.imageKey!)
                    item.type = SearchResultItemType.blogWebPage
                    blogSearchResult.append(item)
                }
            }
        }catch{
            print("Fetch failed")
        }
        let len = min(videoSearchResult.count,maxVideosToShow)
        var ret = [SearchResultItem](videoSearchResult[0..<len])
        ret.append(contentsOf: blogSearchResult)
        ret.append(contentsOf: appSearchResult)
        return ret
    }
    
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
    
  
        
    class func updatePercentWatched(forVideo videoId: String, withSeconds seconds: Int){
        print("updatePercentWatched: videoId: \(videoId), seconds \(seconds)")
        
        let request = Video.createFetchRequest()
        let predicate = NSPredicate(format: "youtubeVideoId == %@", videoId)
        request.predicate = predicate

        do{
            let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
            let videos = try container.viewContext.fetch(request)
            
            switch videos.count{
            case 0:
                print("error - can't find video")
            case 1:
                let video = videos[0]
                let factionWatched = Float(seconds)/Float(video.durationSec)
                var percentWatched = (100*factionWatched).rounded()
                if percentWatched < 2{
                    percentWatched = 0.0
                }else if percentWatched > 80{
                    percentWatched = 100.0
                }
                if percentWatched > video.percentWatched{
                    video.percentWatched = percentWatched
                    print("New percent watched: \(video.percentWatched)")
                }
                
                EpsilonStreamDataModel.saveViewContext()
            default:
                print("error - too many videos \(videoId) -- \(videos.count)")
                break
            }
        }catch{
            print("Fetch failed")
        }
    }
    
    //////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////
    
    //should return an array of hashtag strings of length 0, 1 or 2
    class func hashTags(ofString string: String) -> [String]{
        
        var searchString = string.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if searchString == ""{
            return []
        }else if searchString[searchString.startIndex] == "#"{
            return [searchString]
        }
        
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
                retValue.append(mo.hashTag)
            }
            
        }catch{
            print("Fetch failed")
        }

        return retValue
    }
    
     class func setLatestDates(){
        let request = Video.createFetchRequest()
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        request.fetchLimit = 1
        
        request.sortDescriptors = [NSSortDescriptor(key: "oneOnEpsilonTimeStamp", ascending: false)]
        
        do{
            let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
            let videos = try container.viewContext.fetch(request)

            if videos.count == 0{
                latestVideoDate = Date(timeIntervalSince1970: 0.0)
                print("found no videos - setting video date to 1970")
            }else{
                latestVideoDate = videos[0].oneOnEpsilonTimeStamp
                print("setting video date to \(latestVideoDate) ")
            }
        }catch{
            print("Fetch failed")
        }
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
        let request4 = Channel.createFetchRequest()
        request4.fetchLimit = 1
        request4.sortDescriptors = [NSSortDescriptor(key: "oneOnEpsilonTimeStamp", ascending: false)]
        
        do{
            let channels = try container.viewContext.fetch(request4)
            
            if channels.count == 0{
                latestChannelDate = Date(timeIntervalSince1970: 0.0)
                print("found no channels - setting channel date to 1970")
            }else{
                latestChannelDate = channels[0].oneOnEpsilonTimeStamp
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
    class func numVideos() -> Int{
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let request = Video.createFetchRequest()
        
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

    class func deleteAllEntities(withName name: String){//ofBuffer buffer: Int){
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: name)
        request.predicate = NSPredicate(format: "TRUEPREDICATE")
        let delRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try managedObjectContext.execute(delRequest)
        } catch {
            fatalError("Failed to execute request: \(error)")
        }
        EpsilonStreamDataModel.saveViewContext()
    }
    
    
    class func resetAllViewed(){
        //let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        print("need to implement")
    }

}
