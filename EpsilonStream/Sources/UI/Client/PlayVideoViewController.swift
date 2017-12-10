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
import Firebase


class PlayVideoViewController: UIViewController, YouTubePlayerDelegate {

    var isExplodingDots = false
    
    var videoPlayer: YouTubePlayerView!
    var videoIdToPlay: String?
    
    var leaveButton: UIButton! = nil
    var shareButton: UIButton! = nil
    
    var imageCover: UIImageView! = nil
    var loadSafetyCover: UIView! = nil
    var playSafetyCover: UIView! = nil

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func loadView() {
        super.loadView()
        videoPlayer = YouTubePlayerView(frame:view.frame)
        // See https://developers.google.com/youtube/player_parameters
        videoPlayer.playerVars = [
            "playsinline": "1" as AnyObject, //this is key with allowsInlineMediaPlayback
            "controls": "2" as AnyObject, //yes controls
            "autoplay": "1" as AnyObject, //yes autoplay
            "fs": "0" as AnyObject, //no full screen
            "modestbranding": "0" as AnyObject, //no youtube logo throughout
            "showinfo": "0" as AnyObject, //no show info
            "loop": "0" as AnyObject, //no loop
            "rel": "0" as AnyObject, //no related videos
            "cc_load_policy": "0" as AnyObject //no closed captions
           // "color": "red" as AnyObject //red color on progress bar
        ]
        videoPlayer.isUserInteractionEnabled = true
        videoPlayer.loadVideoID(videoIdToPlay!)
        videoPlayer.delegate = self
        view.addSubview(videoPlayer)
        
        //QQQQ this should perhaps not even be in a navigation controller
        navigationController?.navigationBar.isHidden = true
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        
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
        if let ic = imageCover{
            ic.removeFromSuperview()
        }
        if let lsc = loadSafetyCover{
            lsc.removeFromSuperview()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        let window = UIApplication.shared.keyWindow!
        let windowFrame = CGRect(x: window.frame.origin.x, y: window.frame.origin.y, width: window.frame.width, height: window.frame.height)
        //QQQQ currently not using isExplodingDots
        let image = isExplodingDots ? UIImage(named: "ed_background1") : UIImage(named: "Screen_About_Watch")

        loadSafetyCover = UIView(frame: windowFrame)
        loadSafetyCover.backgroundColor = UIColor.black
        loadSafetyCover.alpha = 1.0
        loadSafetyCover.isUserInteractionEnabled = true
        view.addSubview(loadSafetyCover)
        
        imageCover = UIImageView(image: image)
        imageCover.contentMode = .scaleAspectFill
        imageCover.frame = windowFrame
        window.addSubview(imageCover)
        
        playSafetyCover = UIView(frame: CGRect(x: window.frame.origin.x, y: window.frame.origin.y, width: window.frame.width, height: window.frame.height-52))//QQQQ constant - anyway this is a workaround
        playSafetyCover.backgroundColor = UIColor.clear//doesn't matter
//        playSafetyCover.alpha = 0.01 //QQQQ it needs to recieve events and doesn't with 0.0
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(menuPop))
        playSafetyCover.addGestureRecognizer(tapGesture)
        
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(leaveNow))
        swipeRightGesture.direction = UISwipeGestureRecognizerDirection.right
        playSafetyCover.addGestureRecognizer(swipeRightGesture)
        
        leaveButton = UIButton()//frame: CGRect(x: 5, y: playSafetyCover.frame.height*0.45, width: 35, height: 35))
        leaveButton.setImage(UIImage(named: "Navigation_Icon_Left_Passive"), for: .normal)
        leaveButton.addTarget(self, action: #selector(leaveNow), for: .touchUpInside)
        leaveButton.isEnabled = true
        
        shareButton = UIButton()//frame: CGRect(x: 5, y: playSafetyCover.frame.height*0.45, width: 35, height: 35))
        shareButton.setImage(UIImage(named: "shareTemp"), for: .normal)
        shareButton.addTarget(self, action: #selector(share), for: .touchUpInside)
        shareButton.isEnabled = true

        //addLeave(to: imageCover) //QQQQ didn't work
        
        let swipeRightGesture2 = UISwipeGestureRecognizer(target: self, action: #selector(leaveNow))
        swipeRightGesture2.direction = UISwipeGestureRecognizerDirection.right
        loadSafetyCover.addGestureRecognizer(swipeRightGesture2)
        
        
        UIView.animate(withDuration: 8.0, animations: {
            self.imageCover.alpha = 0.1
        }, completion:
            {_ in })//imageView.removeFromSuperview()})
        
        videoPlayer.delegate = self
        videoPlayer.play()
    }
    
    func addLeave(to view: UIView){
        leaveButton.frame = CGRect(x: 5, y: view.frame.height*0.5, width: 35, height: 35)
        view.addSubview(leaveButton)
    }
    
    func addShare(to view:UIView){
        shareButton.frame = CGRect(x: view.frame.width-35-10, y: 5, width: 35, height: 35)
        view.addSubview(shareButton)
    }
    
    
    func share(){
        let shareString = "Check out this video: https://youtu.be/\(videoIdToPlay!), shared using Epsilon Stream, https://www.epsilonstream.com."
        let vc = UIActivityViewController(activityItems: [shareString], applicationActivities: [])
        vc.popoverPresentationController?.sourceView = shareButton.superview
        self.present(vc, animated:  true)
    }
    
    func menuPop(){
        videoPlayer.pause()
    }
    
    func leaveNow(){
        //videoPlayer.pause()
        videoPlayer.stop()
        //videoPlayer.removeFromSuperview()
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //videoPlayer.isHidden = true
        //QQQQ what if it didn't get to load before...???
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
//        print("viewWillLayoutSubviews")
        //videoPlayer.pause()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        print("viewDidLayoutSubviews")
        videoPlayer.play()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let window = UIApplication.shared.keyWindow!
        //flipping width and height //QQQQ is there a better way to do this
        videoPlayer.frame = CGRect(x: 0, y: 0, width: window.frame.height, height: window.frame.width)
        imageCover.frame = CGRect(x: 0, y: 0, width: window.frame.height, height: window.frame.width)
        loadSafetyCover.frame = CGRect(x: 0, y: 0, width: window.frame.height, height: window.frame.width)
        playSafetyCover.frame = CGRect(x: 0, y: 0, width: window.frame.height, height: window.frame.width-52)

        leaveButton.removeFromSuperview()
        shareButton.removeFromSuperview()


        videoPlayer.pause()
        //QQQQ redudent maybe for analytics
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
            FIRAnalytics.logEvent(withName: "video_to_landscape", parameters: ["videoId" : videoIdToPlay! as NSObject])
        } else {
            FIRAnalytics.logEvent(withName: "video_to_portrait", parameters: ["videoId" : videoIdToPlay! as NSObject])
        }
    }

    func playerReady(_ videoPlayer: YouTubePlayerView){
        //print("player ready")
        videoPlayer.play()
        UserDataManager.updateSecondsWatched(forKey: videoIdToPlay!, withSeconds: 0)
    }
    
    func playerStateChanged(_ videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState){
        //print("PLAYER STATE in player: \(playerState)")
        switch playerState{
        case YouTubePlayerState.Unstarted:
            break
        case YouTubePlayerState.Ended:
            //            print("going back because Ended")
            let time = Int((videoPlayer.getCurrentTime()! as NSString).doubleValue.rounded())
            UserDataManager.updateSecondsWatched(forKey: videoIdToPlay!, withSeconds: time)
            leaveNow()
            //print("ENDED!!!!")
            //QQQQ Analytics of video end.
        case YouTubePlayerState.Playing:
            imageCover.removeFromSuperview()
            loadSafetyCover.removeFromSuperview()
            view.addSubview(playSafetyCover)
            leaveButton.removeFromSuperview()
            shareButton.removeFromSuperview()
            //print("PLAYING!!!!")
            break
        case YouTubePlayerState.Paused:
            //            print("going back because Paused - QQQQ replace with pause")
            //_ = navigationController?.popViewController(animated: true)
            let time = Int((videoPlayer.getCurrentTime()! as NSString).doubleValue.rounded())
            UserDataManager.updateSecondsWatched(forKey: videoIdToPlay!, withSeconds: time)
            videoPlayer.isUserInteractionEnabled = true
            addLeave(to: playSafetyCover)
            addShare(to: playSafetyCover)
            FIRAnalytics.logEvent(withName: "video_paused", parameters: ["videoId" : videoIdToPlay! as NSObject])
            break
        case YouTubePlayerState.Buffering:
            //print("BUFFERING!!!!")
            break
        case YouTubePlayerState.Queued:
            //print("QUEUEING!!!!")
            break
        }
    }
}
