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
}

extension String{
    //http://stackoverflow.com/questions/37048139/how-to-convert-duration-form-youtube-api-in-swift
    func getYoutubeFormattedDuration() -> String {
        
        let formattedDuration = self.replacingOccurrences(of: "PT", with: "").replacingOccurrences(of: "H", with:":").replacingOccurrences(of: "M", with: ":").replacingOccurrences(of: "S", with: "")
        
        let components = formattedDuration.components(separatedBy: ":")
        var duration = ""
        for component in components {
            duration = duration.characters.count > 0 ? duration + ":" : duration
            if component.characters.count < 2 {
                duration += "0" + component
                continue
            }
            duration += component
        }
        
        return duration
        
    }
}


class YoutubeAPICommunicator{

    static let API_KEY = "AIzaSyAiUytriGKVNStzDJ-0hmSWdcsOfYNnzCc"

    static var delegate: YoutubeAPIDelegate!

    //////////////
    //////////////
    static func getYouTubeAPIFeedVideos(_ qVal: String){
        let YOUTUBE_API_SEARCH_URL = "https://www.googleapis.com/youtube/v3/search"
        var params: [String:String] = [:]
        
        params = ["part":"snippet",
                  //"channelId":CHANNEL_ID,
            //"channelType":"any",
            "q":qVal,
            "type":"video",
            "maxResults":"30",
            "order":"viewCount",
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

    
    //////////////
    //////////////
    static func getYouTubeAPIVideoInfo(_ idString: String){

        let YOUTUBE_API_VIDEOS_URL = "https://www.googleapis.com/youtube/v3/videos"
        var params: [String:String] = [:]
        
        params = ["part":"id,contentDetails",
                  "id":idString,
                  "key":API_KEY]
        
        //QQQQ All this is troublsome below - study it well
        
        
        Alamofire.request(YOUTUBE_API_VIDEOS_URL,parameters: params).responseJSON{
            response in
            
            //var vidInfoList = [YouTubeSearchResultItem]()
            switch response.result {
            case .success(let data):
                print(data)
                let json = JSON(data)
                
                
                //QQQQ organize this code nicely - e.g. put siwtch below as part of string extension?
                let duration = json["items"][0]["contentDetails"]["duration"].stringValue
                let cleanDuration = duration.getYoutubeFormattedDuration()
                print(cleanDuration)
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
                print(seconds)

                let item = YouTubeVideoListResultItem()
                item.durationInt = Int32(seconds)
                item.durationString = cleanDuration
                
                DispatchQueue.main.async {
                    delegate.videoDetailsCallDone(withItem: item)
                }
                
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
}
