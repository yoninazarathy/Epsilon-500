//
//  YoutubeAPICommunicator.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 3/1/17.
//  Copyright © 2017 Yoni Nazarathy. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


protocol YoutubeAPIDelegate {
    func searchCallDone(withItems items: [YouTubeSearchResultItem])
    func videoDetailsCallDone(withItem item: YouTubeVideoListResultItem)
    func videoIdsOfChannelDone(withVideos videos: [String])
}

extension String{
    //https://stackoverflow.com/questions/37048139/how-to-convert-duration-form-youtube-api-in-swift
    func getYoutubeFormattedDuration() -> String {
        
        let formattedDuration = self.replacingOccurrences(of: "PT", with: "").replacingOccurrences(of: "H", with:":").replacingOccurrences(of: "M", with: ":").replacingOccurrences(of: "S", with: "")
        
        let components = formattedDuration.components(separatedBy: ":")
        var duration = ""
        for component in components {
            duration = duration.count > 0 ? duration + ":" : duration
            if component.count < 2 {
                duration += "0" + component
                continue
            }
            duration += component
        }
        
        return duration
        
    }
}

struct YoutubeResource{
    var channelName: String
    var channelId: String
    var playListId: String
    var comment: String
}


class YoutubeAPICommunicator{
    
    static let API_KEY = "AIzaSyAiUytriGKVNStzDJ-0hmSWdcsOfYNnzCc"
    
    static var delegate: YoutubeAPIDelegate!
    
    static let resourceList = [
        YoutubeResource(
            channelName: "mathbff",
            channelId: "",
            playListId: "",
            comment: "Mathbff")
        ,
        YoutubeResource(
            channelName: "mathantics",
            channelId: "",
            playListId: "",
            comment: "mathantics")
        ,
        YoutubeResource(
            channelName: "",
            channelId: "",
            playListId: "PL3128E15B8D159842",
            comment: "Khan Academy, Algebra Worked Examples List")
        ,
        YoutubeResource(
            channelName: "tecmath",
            channelId: "",
            playListId: "",
            comment: "tecmath")
        ,
        YoutubeResource(
            channelName: "",
            channelId: "UC1_uAIS3r8Vu6JjXWvastJg",
            playListId: "",
            comment: "Mathologer")
        ,
        YoutubeResource(
            channelName: "",
            channelId: "UCYO_jab_esuFRV4b17AJtAw",
            playListId: "",
            comment: "3Blue1Brown")
        ,
        YoutubeResource(
            channelName: "Numberphile",
            channelId: "",
            playListId: "",
            comment: "Numberphile")
        ,
        YoutubeResource(
            channelName: "kylepearce3",
            channelId: "",
            playListId: "",
            comment: "Kyle Pearce (too many)")
        ,
        YoutubeResource(
            channelName: "",
            channelId: "",
            playListId: "PLAF816DCEEB2A2F7B",
            comment: "Trigonometry Tutorials by patrickJMT")
        ,
        YoutubeResource(
            channelName: "",
            channelId: "",
            playListId: "PL8gnhgRJl1x4rjaE3rM9C1v-jWy4kkgMC",
            comment: "PatrickJMT Algebra")
        ,
        YoutubeResource(
            channelName: "",
            channelId: "",
            playListId: "PLANMHOrJaFxPCjR2enLZBRgtZgjtXJ0MJ",
            comment: "PatrickJMT The Fundamentals of Logic")
        ,
        YoutubeResource(
            channelName: "",
            channelId: "",
            playListId: "PLANMHOrJaFxMobwlFyaSZdxoh-nl6-o1X",
            comment: "PatrickJMT Puzzle Problems - Fun Problems!")
        ,
        YoutubeResource(
            channelName: "",
            channelId: "",
            playListId: "PLANMHOrJaFxM2UbRPM9YNQ1YT3s4gX4Rp",
            comment: "PatrickJMT Inverse Trigonometric Functions")
        ,
        YoutubeResource(
            channelName: "",
            channelId: "",
            playListId: "PLANMHOrJaFxN4Ny3jqaPvTeZpxkZlxRa5",
            comment: "PatrickJMT Game Theory")
        ,
        YoutubeResource(
            channelName: "",
            channelId: "",
            playListId: "PLF1E94C1948483103",
            comment: "PatrickJMT - Optimization Problem #1")
        ,
        YoutubeResource(
            channelName: "",
            channelId: "",
            playListId: "PL4098211B87018422",
            comment: "PatrickJMT Combinations - Counting Using Combinations")
        ,
        YoutubeResource(
            channelName: "",
            channelId: "",
            playListId: "PL7DA48E186D1D8049",
            comment: "PatrickJMT - Logarithms")
        ,
        YoutubeResource(
            channelName: "",
            channelId: "",
            playListId: "PLDDDAA7E0D61A5CFA",
            comment: "PatrickJMT - Conic Sections")
        ,
        YoutubeResource(
            channelName: "",
            channelId: "",
            playListId: "PLAC5EA62150BD3A5A",
            comment: "PatrickJMT - Complex Numbers")
        ,
        YoutubeResource(
            channelName: "",
            channelId: "",
            playListId: "PL9F8908A958AF7DC9",
            comment: "PatrickJMT -  Functions : The basics")
        , //QQQQ Note still missing many playlists of PatrickJMT
        YoutubeResource(
            channelName: "",
            channelId: "",
            playListId: "PL7AF1C14AF1B05894",
            comment: "Khan Acemdy Algebra")
        ,
        YoutubeResource(
            channelName: "",
            channelId: "",
            playListId: "PL238F98B2C6422A95",
            comment: "Khan Acemdy Pre-algebra")
        ,
        YoutubeResource(
            channelName: "",
            channelId: "",
            playListId: "PL1C68557896CFABA8",
            comment: "Khan Acemdy Developmental Math 2")
        ,
        YoutubeResource(
            channelName: "",
            channelId: "",
            playListId: "PL50D1D09ABE9CE271",
            comment: "Khan Acemdy Developmental Math")
        ,
        YoutubeResource(
            channelName: "",
            channelId: "",
            playListId: "PLE23E2FDF6E935778",
            comment: "Khan Acemdy Developmental Math 3")
        ,
        YoutubeResource(
            channelName: "",
            channelId: "",
            playListId: "PLD6DA74C1DBF770E7",
            comment: "Khan Acemdy Trigonometry")
        ,
        YoutubeResource(
            channelName: "",
            channelId: "",
            playListId: "PL301908982CBFE20D",
            comment: "Khan Academy Arithmetic")
        ,
        YoutubeResource(
            channelName: "standupmaths",
            channelId: "",
            playListId: "",
            comment: "standupmaths")
        ,
        YoutubeResource(
            channelName: "Vihart",
            channelId: "",
            playListId: "",
            comment: "Vihart")
        ,
        YoutubeResource(
            channelName: "yourteachermathhelp",
            channelId: "",
            playListId: "",
            comment: "MathHelp (too many - not pulling all)")
        ,
        YoutubeResource(
            channelName: "MathMeeting",
            channelId: "",
            playListId: "",
            comment: "Math Meeting")
        ,
        YoutubeResource(
            channelName: "",
            channelId: "",
            playListId: "PL5KkMZvBpo5ASS7uoLegCA5i6clf4zNsq",
            comment: "Eddie Woo EPB1 (Relative Frequency & Probability)")
        ,
        YoutubeResource(
            channelName: "",
            channelId: "",
            playListId: "PL5KkMZvBpo5COUEncIR00qy3aq6wYhD64",
            comment: "Eddie Woo Y7 Maths: Fractions & Percentages")
        ,
        YoutubeResource(
            channelName: "",
            channelId: "",
            playListId: "PL5KkMZvBpo5DNtpt3UXFH2pXEn5GM3Z0F",
            comment: "Eddie Woo MM2 (Perimeter, Area & Volume)")
        ,
        YoutubeResource(
            channelName: "",
            channelId: "",
            playListId: "PL5KkMZvBpo5AD2kCGbz4241HbbGzlRqUq",
            comment: "Eddie Woo DS1-3 (Basic Data & Statistics)")
        ,
        YoutubeResource(
            channelName: "",
            channelId: "",
            playListId: "PL5KkMZvBpo5Cfz3KdRqBcXuVakBanFwuW",
            comment: "Eddie Woo AM3 (Further Algebraic Skills & Techniques)")
        ,
        YoutubeResource(
            channelName: "",
            channelId: "",
            playListId: "PL5KkMZvBpo5AElNjo5a2CaIWg6TlLd6vW",
            comment: "Eddie Woo Measurement & Geometry")
        ,
        YoutubeResource(
            channelName: "",
            channelId: "UCjwOWaOX-c-NeLnj_YGiNEg",
            playListId: "",
            comment: "Tipping Point Math")
        ,
        YoutubeResource(
            channelName: "DrJamesTanton",
            channelId: "",
            playListId: "",
            comment: "DrJamesTanton")
        ,
        YoutubeResource(
            channelName: "",
            channelId: "UCib_J32VI8rQI_LCFXn1XAA",
            playListId: "",
            comment: "James Tanton (exploding dots)")
        ,
        YoutubeResource(
            channelName: "",
            channelId: "UCXZIDlJ_DgzrEwYop2s3JOQ",
            playListId: "",
            comment: "National Museum of Mathematics")
        ,
        YoutubeResource(
            channelName: "ArtOfTheProblem",
            channelId: "",
            playListId: "",
            comment: "Art of the Problem")
        ,
        YoutubeResource(
            channelName: "",
            channelId: "",
            playListId: "PL1C537F4A57B3F09B",
            comment: "Brightstorm - Geometry"),
        YoutubeResource(
            channelName: "",
            channelId: "",
            playListId: "PLD286B3F281B219D4",
            comment: "Brightstorm - Algebra 1"),
        YoutubeResource(
            channelName: "",
            channelId: "",
            playListId: "PLB2606C762CF0B898",
            comment: "Brightstorm - Precalculus"),
        YoutubeResource(
            channelName: "",
            channelId: "",
            playListId: "PL2EC6AA23B1563190",
            comment: "Brightstorm - Algebra 2"),
        YoutubeResource(
            channelName: "",
            channelId: "",
            playListId: "PL8FE0AF517D088CB8",
            comment: "Brightstorm - Trigonometry"),
        YoutubeResource(
            channelName: "",
            channelId: "",
            playListId: "PLlssSNhNZaPPpwByvVFNqCRr6T57JtODr",
            comment: "Brightstorm - Pre-Algebra"),
        YoutubeResource(
            channelName: "Computerphile",
            channelId: "",
            playListId: "",
            comment: "Computerphile")
        ,
        YoutubeResource(
            channelName: "",
            channelId: "UCiTjCIT_9EXV1Wp1cY0zaUA",
            playListId: "",
            comment: "Don't Memorise"),
        YoutubeResource(
            channelName: "MindYourDecisions",
            channelId: "",
            playListId: "",
            comment: "MindYourDecisions")
        ,
        YoutubeResource(
            channelName: "minutephysics",
            channelId: "",
            playListId: "",
            comment: "minutephysics")
        ,
        YoutubeResource(
            channelName: "singingbanana",
            channelId: "",
            playListId: "",
            comment: "singingbanana")
        ,
        YoutubeResource(
            channelName: "MathTV",
            channelId: "",
            playListId: "",
            comment: "Math TV")
        ,
        YoutubeResource(
            channelName: "spoonfulofmaths",
            channelId: "",
            playListId: "",
            comment: "Spoonful of Maths")
        ,
        YoutubeResource(
            channelName: "DrSaradaHerke",
            channelId: "",
            playListId: "",
            comment: "Sarada Herke")
        ,
        YoutubeResource(
            channelName: "StudyPug",
            channelId: "",
            playListId: "",
            comment: "StudyPug")
        ,
        YoutubeResource(
            channelName: "Vsauce",
            channelId: "",
            playListId: "",
            comment: "Vsauce")
        ,
        YoutubeResource(
            channelName: "Taylorns34",
            channelId: "",
            playListId: "",
            comment: "Welch Labs")
        ,
        YoutubeResource(
            channelName: "MathMammoth",
            channelId: "",
            playListId: "",
            comment: "Math Mammoth"),
        YoutubeResource(
            channelName: "",
            channelId: "UCLo4jBc9fQkVPbmdnSL4IRg",
            playListId: "",
            comment: "The Global Math Project"),
        YoutubeResource(
            channelName: "",
            channelId: "UC_SvYP0k05UKiJ_2ndB02IA",
            playListId: "",
            comment: "Black Pen Red Pen"),
        YoutubeResource(
            channelName: "",
            channelId: "UCxqAWLTk1CmBvZFPzeZMd9A",
            playListId: "",
            comment: "Domain of Science"),
        YoutubeResource(
            channelName: "",
            channelId: "UCsooa4yRKGN_zEE8iknghZA",
            playListId: "",
            comment: "TED-Ed"),
        YoutubeResource(
            channelName: "",
            channelId: "UCY5NDinr2975LghozXAeTWQ",
            playListId: "",
            comment: "OxfordSparks"),
        YoutubeResource(
            channelName: "",
            channelId: "UCs4aHmggTfFrpkPcWSaBN9g",
            playListId: "",
            comment: "PBS Infinite Series"),
        YoutubeResource(
            channelName: "",
            channelId: "UC9yt3wz-6j19RwD5m5f6HSg",
            playListId: "",
            comment: "Think Twice"),
        YoutubeResource(
            channelName: "",
            channelId: "UC_OjzlVO230cu7vQYUSNNDw",
            playListId: "",
            comment: "TyYann"),
        YoutubeResource(
            channelName: "",
            channelId: "UCG32MfGLit1pcqCRXyy9cAg",
            playListId: "",
            comment: "Statistics Learning Centre"),
        YoutubeResource(
            channelName: "",
            channelId: "UCciX2VHmW7Ix_FVWQ_u4RwQ",
            playListId: "",
            comment: "GoldfishAndRobin"),
        YoutubeResource(
            channelName: "ebalzarini",
            channelId: "",
            playListId: "",
            comment: "the AllAroundMathGuy"),
        YoutubeResource(
            channelName: "",
            channelId: "UCKl7MXLRrk6hnWuObFwKxdg",
            playListId: "",
            comment: "Cole's World of Mathematics"),
        YoutubeResource(
            channelName: "blc0527",
            channelId: "",
            playListId: "",
            comment: "blc0527"),
        YoutubeResource(
            channelName: "",
            channelId: "UCfG0OGu8IR9KqgZiDQOHIfg",
            playListId: "",
            comment: "Kealing Geometry"),
        YoutubeResource(
            channelName: "",
            channelId: "UClOR1BiPyOkkIAnv9Cmj4iw",
            playListId: "",
            comment: "Mario's Math Tutoring"),
        YoutubeResource(
            channelName: "",
            channelId: "UC7iAQJ5Ldf1lZSz96TUns0Q",
            playListId: "",
            comment: "The Bearded Math Man"),
        YoutubeResource(
            channelName: "EHSmathwithmurphy",
            channelId: "",
            playListId: "",
            comment: "Math With Murphy"),
        YoutubeResource(
            channelName: "Mathfortress",
            channelId: "",
            playListId: "",
            comment: "Math Fortress"),
        YoutubeResource(
            channelName: "",
            channelId: "UCtBtcQJ8_jsrjPzb8i1tOsA",
            playListId: "",
            comment: "MashUp Math"),
        YoutubeResource(
            channelName: "teachertubemath",
            channelId: "",
            playListId: "",
            comment: "TeacherTube Math"),
        YoutubeResource(
            channelName: "MrBrianMcLogan",
            channelId: "",
            playListId: "",
            comment: "Brian McLogan"),
        YoutubeResource(
            channelName: "DLBmaths",
            channelId: "",
            playListId: "",
            comment: "DLBmaths"),
        YoutubeResource(
            channelName: "profrobbob",
            channelId: "",
            playListId: "",
            comment: "ProfRobBob"),
        YoutubeResource(
            channelName: "TheIntegralCALC",
            channelId: "",
            playListId: "",
            comment: "Krista King"),
        YoutubeResource(
            channelName: "yaymath",
            channelId: "",
            playListId: "",
            comment: "yaymath"),
        YoutubeResource(
            channelName: "mathtutordvd",
            channelId: "",
            playListId: "",
            comment: "mathtutordvd"),
        YoutubeResource(
            channelName: "bullcleo1",
            channelId: "",
            playListId: "",
            comment: "Mathispower4u"),
        YoutubeResource(
            channelName: "derekowens",
            channelId: "",
            playListId: "",
            comment: "Derek Owens"),
        YoutubeResource(
            channelName: "MySecretMathTutor",
            channelId: "",
            playListId: "",
            comment: "MySecretMathTutor"),
        YoutubeResource(
            channelName: "FortBendTutoring",
            channelId: "",
            playListId: "",
            comment: "FortBendTutoring"),
        YoutubeResource(
            channelName: "mrskrummel",
            channelId: "",
            playListId: "",
            comment: "Michelle Krummel"),
        YoutubeResource(
            channelName: "MyWhyU",
            channelId: "",
            playListId: "",
            comment: "MyWhyU"),
        YoutubeResource(
            channelName: "",
            channelId: "UCtoBnL9JM0r_ZVXABGFkCyg",
            playListId: "",
            comment: "GoldPlatedGoof"),
        YoutubeResource(
            channelName: "",
            channelId: "UCRGXV1QlxZ8aucmE45tRx8w",
            playListId: "",
            comment: "NancyPi"),
        YoutubeResource(
            channelName: "",
            channelId: "UCQytXvP9Z-6flNSCEtdw1dA",
            playListId: "",
            comment: "MathsSmart"),
        YoutubeResource(
            channelName: "",
            channelId: "",
            playListId: "PLl4T6p7km9dbGCsAooT8-ujI9xAQnjsfJ",
            comment: "Nerdist MathBites")
        
    ]
    static func fetchResource(_ resource: YoutubeResource){
        resourceQueryCount += 1
        
        if resource.channelName != ""{
            fetchVideosOfChannel(withChannelName: resource.channelName,fromResrouce: resource.comment)
        }else if resource.channelId != ""{
            fetchVideosOfChannel(withChannelId: resource.channelId, fromResrouce: resource.comment)
        }else if resource.playListId != ""{
            fetchVideosOfPlayList(withPlaylistlId: resource.playListId,fromResrouce: resource.comment)
        }else{
            print("error with resource")
        }
    }
    
    
    
    //////////////
    //////////////
    static func fetchVideosOfChannel(withChannelName channelName: String,fromResrouce resource: String){
        let YOUTUBE_API_CHANNEL_URL = "https://www.googleapis.com/youtube/v3/channels"
        var params: [String:String] = [:]
        params = ["part":"snippet",
                  "forUsername":channelName,
                  "key":API_KEY]
        
        Alamofire.request(YOUTUBE_API_CHANNEL_URL,parameters: params).responseJSON{
            response in
            
            switch response.result {
            case .success(let data):
                let json = JSON(data)
                let id = json["items"][0]["id"].stringValue
                fetchVideosOfChannel(withChannelId: id,fromResrouce: resource)
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    
    static var resourceQueryCount = 0
    
    static var videoIdList: [String] = []
    
    static func pushVideo(_ video: String, fromResource resource:String){
        videoIdList.append(video)
        print("\(videoIdList.count): \(resource) -- \(video)")
    }
    
    //////////////
    //////////////
    static func fetchVideosOfChannel(withChannelId channelId: String,fromResrouce resource:String, withPageToken pageToken:String = ""){
        let YOUTUBE_API_SEARCH_URL = "https://www.googleapis.com/youtube/v3/search"
        var params: [String:String] = [:]
        params = ["part":"snippet",
                  "channelId":channelId,
                  "type":"video",
                  "maxResults":"50",
                  "pageToken":pageToken,
                  "key":API_KEY]
        
        Alamofire.request(YOUTUBE_API_SEARCH_URL,parameters: params).responseJSON{
            response in
            
            switch response.result {
            case .success(let data):
                let json = JSON(data)
                //print(json)
                let numItems = json["items"].count
                for i in 0..<numItems{
                    let vidId = json["items"][i]["id"]["videoId"].stringValue
                    pushVideo(vidId, fromResource: resource)
                }
                
                if numItems == json["pageInfo"]["resultsPerPage"].int{
                    let nextToken = json["nextPageToken"].stringValue
                    fetchVideosOfChannel(withChannelId: channelId,fromResrouce: resource,withPageToken: nextToken)
                }else{
                    //print("got to end")
                    finishedFetch()
                }
                
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    
    
    //////////////
    //////////////
    static func fetchVideosOfPlayList(withPlaylistlId playlistId: String,fromResrouce resource:String, withPageToken pageToken:String = ""){
        let YOUTUBE_API_SEARCH_URL = "https://www.googleapis.com/youtube/v3/playlistItems"
        var params: [String:String] = [:]
        params = ["part":"snippet",
                  "playlistId":playlistId,
                  "maxResults":"50",
                  "pageToken":pageToken,
                  "key":API_KEY]
        
        Alamofire.request(YOUTUBE_API_SEARCH_URL,parameters: params).responseJSON{
            response in
            
            switch response.result {
            case .success(let data):
                let json = JSON(data)
                let numItems = json["items"].count
                for i in 0..<numItems{
                    let vidId = json["items"][i]["snippet"]["resourceId"]["videoId"].stringValue
                    pushVideo(vidId, fromResource: resource)
                }
                
                if numItems == json["pageInfo"]["resultsPerPage"].int{
                    let nextToken = json["nextPageToken"].stringValue
                    fetchVideosOfPlayList(withPlaylistlId: playlistId,fromResrouce: resource,withPageToken: nextToken)
                }else{
                    //print("got to end")
                    finishedFetch()
                }
                
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    
    
    static func finishedFetch(){
        resourceQueryCount -= 1
        print("finished fetch: \(resourceQueryCount)")
        if resourceQueryCount == 0{
            print("FINISHED ALL FETCHES")
            delegate.videoIdsOfChannelDone(withVideos: videoIdList)
        }
    }
    
    
    static func fetchVideosFromAllResources(){
        
        if(resourceQueryCount > 0){
            print("ERROR - TRYING TO FETCH WHILE FETCH ON: \(resourceQueryCount)")
        }
        
        videoIdList = []
        resourceQueryCount = 0
        for r in resourceList{
            fetchResource(r)
        }
    }
    
    
    
    
    //////////////
    //////////////
    static func getYouTubeAPIFeedVideos(_ qVal: String){
        
        
        let YOUTUBE_API_SEARCH_URL = "https://www.googleapis.com/youtube/v3/search"
        var params: [String:String] = [:]
        
        params = ["part":"snippet",
                  //"channelId":"UCy5ev9EE-u5Iwbt2NHrcayw",
            //"channelType":"any",
            "q":qVal,
            "type":"video",
            "maxResults":"30",
            //"order":"viewCount",
            "key":API_KEY]
        
        //QQQQ All this is troublsome below - study it well
        
        
        Alamofire.request(YOUTUBE_API_SEARCH_URL,parameters: params).responseJSON{
            response in
            
            var vidInfoList = [YouTubeSearchResultItem]()
            switch response.result {
            case .success(let data):
                let json = JSON(data)
                if let numRes = json["pageInfo"]["resultsPerPage"].int{
                    for i in 0..<numRes{
                        let newItem = YouTubeSearchResultItem()
                        newItem.youtubeId = json["items"][i]["id"]["videoId"].stringValue
                        newItem.title = json["items"][i]["snippet"]["title"].stringValue
                        newItem.channel = json["items"][i]["snippet"]["channelTitle"].stringValue
                        newItem.imageURL = json["items"][i]["snippet"]["thumbnails"]["high"]["url"].stringValue
                        
                        Alamofire.request(newItem.imageURL).responseData{
                            response in
                            DispatchQueue.main.async {
                                newItem.image = UIImage(data: response.data!)
                                delegate.searchCallDone(withItems: vidInfoList)
                            }
                        }
                        
                        newItem.image = nil //QQQQ load
                        vidInfoList.append(newItem)
                    }
                    DispatchQueue.main.async {
                        delegate.searchCallDone(withItems: vidInfoList)
                    }
                }
                
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    
    
    static var numVidsInGet = 0
    
    //////////////
    //////////////
    static func getYouTubeAPIVideoInfo(_ idString: String){
        
        numVidsInGet += 1
        print("NUM (request): \(numVidsInGet)")
        
        let YOUTUBE_API_VIDEOS_URL = "https://www.googleapis.com/youtube/v3/videos"
        var params: [String:String] = [:]
        
        params = ["part":"id,contentDetails,snippet",
                  "id":idString,
                  "key":API_KEY]
        
        //QQQQ All this is troublsome below - study it well
        
        Alamofire.request(YOUTUBE_API_VIDEOS_URL,parameters: params).responseJSON{
            response in
            
            numVidsInGet -= 1
            print("NUM (response): \(numVidsInGet)")
            //var vidInfoList = [YouTubeSearchResultItem]()
            switch response.result {
            case .success(let data):
                //print(data)
                let json = JSON(data)
                
                
                //QQQQ organize this code nicely - e.g. put siwtch below as part of string extension?
                let duration = json["items"][0]["contentDetails"]["duration"].stringValue
                let cleanDuration = duration.getYoutubeFormattedDuration()
                //print(cleanDuration)
                let dur = cleanDuration.components(separatedBy: CharacterSet(charactersIn: ":"))
                var seconds: Int = 0
                switch dur.count{
                case 1:
                    seconds = Int(dur[0])!
                case 2:
                    seconds = Int(dur[0])! * 60 + Int(dur[1])!
                case 3:
                    seconds = Int(dur[0])! * 3600 + Int(dur[1])! * 60 + Int(dur[2])!
                default:
                    print("error with parsing duration")
                    break
                }
                //print(seconds)
                
                let item = YouTubeVideoListResultItem()
                item.durationInt = Int32(seconds)
                item.durationString = cleanDuration
                
                item.videoId = idString
                item.title = json["items"][0]["snippet"]["title"].stringValue
                item.channel = json["items"][0]["snippet"]["channelTitle"].stringValue
                item.imageURLdef = json["items"][0]["snippet"]["thumbnails"]["default"]["url"].stringValue
                item.imageURLmed = json["items"][0]["snippet"]["thumbnails"]["medium"]["url"].stringValue
                item.imageURLhigh = json["items"][0]["snippet"]["thumbnails"]["high"]["url"].stringValue
                
                DispatchQueue.main.async {
                    delegate.videoDetailsCallDone(withItem: item)
                }
                
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
}
