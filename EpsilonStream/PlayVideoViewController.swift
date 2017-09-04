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
import AVFoundation


class PlayVideoViewController: UIViewController, YouTubePlayerDelegate {

    var isExplodingDots = false
    
    var videoPlayer: YouTubePlayerView!
    var videoIdToPlay: String?
    var searchResultItem: SearchResultItem! = nil
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func loadView() {
        super.loadView()
        videoPlayer = YouTubePlayerView(frame:view.frame)
        videoPlayer.isUserInteractionEnabled = false
        videoPlayer.loadVideoID(videoIdToPlay!)
        videoPlayer.delegate = self
        view = videoPlayer
        
        navigationController?.navigationBar.isHidden = true
        
        //This is to allow sound playback under silent
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch _ as NSError {}
        } catch{}
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        //This is to put the sound category back (e.g. in menu not to make clicks if silent)
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategorySoloAmbient)
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch _ as NSError {}
        } catch{}

        
    }
    
    
    func playerReady(_ videoPlayer: YouTubePlayerView){
        print("player ready")
        videoPlayer.play()
        UserDataManager.updateSecondsWatched(forKey: videoIdToPlay!, withSeconds: 0)
    }
    
    func playerStateChanged(_ videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState){
        print("PLAYER STATE in player: \(playerState)")
        switch playerState{
        case YouTubePlayerState.Unstarted:
            break
        case YouTubePlayerState.Ended:
//            print("going back because Ended")
            let time = Int((videoPlayer.getCurrentTime()! as NSString).doubleValue.rounded())
            UserDataManager.updateSecondsWatched(forKey: videoIdToPlay!, withSeconds: time)
            _ = navigationController?.popViewController(animated: true)
        case YouTubePlayerState.Playing:
            videoPlayer.isUserInteractionEnabled = false
            print("PLAYING!!!!")
            break
        case YouTubePlayerState.Paused:
//            print("going back because Paused - QQQQ replace with pause")
            _ = navigationController?.popViewController(animated: true)
            let time = Int((videoPlayer.getCurrentTime()! as NSString).doubleValue.rounded())
            UserDataManager.updateSecondsWatched(forKey: videoIdToPlay!, withSeconds: time)
            break
        case YouTubePlayerState.Buffering:
            print("BUFFERING!!!!")
            break
        case YouTubePlayerState.Queued:
            print("QUEUEING!!!!")
            break
        }
    }
    
    
    var imageCover: UIImageView! = nil
    var loadSafetyCover: UIView! = nil

    override func viewWillAppear(_ animated: Bool) {
        let window = UIApplication.shared.keyWindow!
        let image = isExplodingDots ? UIImage(named: "ed_background1") : UIImage(named: "Screen_About_Watch")
        imageCover = UIImageView(image: image)
        imageCover.contentMode = .scaleAspectFill
        imageCover.frame = CGRect(x: window.frame.origin.x, y: window.frame.origin.y, width: window.frame.width, height: window.frame.height)
        loadSafetyCover = UIView(frame: imageCover.frame)
        loadSafetyCover.backgroundColor = UIColor.black
        window.addSubview(loadSafetyCover)
        window.addSubview(imageCover)
        UIView.animate(withDuration: 5.0, animations: {
            self.imageCover.alpha = 0.05
        }, completion:
            {_ in })//imageView.removeFromSuperview()})
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        videoPlayer.addGestureRecognizer(swipeLeft)

        videoPlayer.isHidden = true
        videoPlayer.delegate = self
        videoPlayer.play()//QQQQ what if it didn't get to load before...???
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        print("viewWillLayoutSubviews")
        videoPlayer.pause()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("viewDidLayoutSubviews")
        loadSafetyCover.removeFromSuperview()
        imageCover.removeFromSuperview()
        videoPlayer.play()
    }
    
    func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
            default:
                break
            }
        }
    }

    
}
