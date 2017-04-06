//
//  PlayVideoViewController.swift
//  EpsilonStreamPrototype
//
//  Created by Yoni Nazarathy on 19/12/16.
//  Copyright © 2016 Yoni Nazarathy. All rights reserved.
//

import UIKit
import Alamofire
import YouTubePlayer


class PlayVideoViewController: UIViewController, YouTubePlayerDelegate {

    var videoPlayer: YouTubePlayerView!

    var videoIdToPlay: String?
    
    var searchResultItem: SearchResultItem! = nil
    
    override func awakeFromNib() {
        //print("awakeFromNib(): \(videoIdToPlay)") //QQQQ remove this function
    }
    
    override func loadView() {
        super.loadView()
        videoPlayer = YouTubePlayerView(frame:view.frame)
        videoPlayer.loadVideoID(videoIdToPlay!)
        videoPlayer.delegate = self
        view = videoPlayer
    }
    
    func playerReady(_ videoPlayer: YouTubePlayerView){
        print("player ready")
        videoPlayer.play()
        EpsilonStreamDataModel.updatePercentWatched(forVideo: videoIdToPlay!, withSeconds: 0)
    }
    
    func playerStateChanged(_ videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState){
        print("PLAYER STATE in player: \(playerState)")
        switch playerState{
        case YouTubePlayerState.Unstarted:
            break
        case YouTubePlayerState.Ended:
            print("going back because Ended")
            let time = Int((videoPlayer.getCurrentTime()! as NSString).doubleValue.rounded())
            EpsilonStreamDataModel.updatePercentWatched(forVideo: videoIdToPlay!, withSeconds: time)
            _ = navigationController?.popViewController(animated: true)
        case YouTubePlayerState.Playing:
            break
        case YouTubePlayerState.Paused:
            print("going back because Paused - QQQQ replace with pause")
            _ = navigationController?.popViewController(animated: true)
            let time = Int((videoPlayer.getCurrentTime()! as NSString).doubleValue.rounded())
            EpsilonStreamDataModel.updatePercentWatched(forVideo: videoIdToPlay!, withSeconds: time)
            break
        case YouTubePlayerState.Buffering:
            break
        case YouTubePlayerState.Queued:
            break
        }
    }
    




    override func viewDidLoad() {
        super.viewDidLoad()
        videoPlayer.isHidden = false
        videoPlayer.delegate = self
        videoPlayer.play()//QQQQ what if it didn't get to load before...???
    }
}
