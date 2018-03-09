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


class PlayVideoViewController: BaseViewController, YouTubePlayerDelegate {

    // MARK: - Model
    
    var previousIsStatusBarHidden = false
    var previousInteractivePopGestureRecognizerIsEnabled = false
    
    var isExplodingDots = false {
        didSet {
            if isExplodingDots != oldValue {
                refresh()
            }
        }
    }
    var videoIdToPlay: String?
    var startSeconds = 0
    var playSafetyCoverSpare: CGFloat!
    
    // MARK: - UI
    
    lazy var videoPlayer = YouTubePlayerView()
    
    lazy var backButton = UIButton()
    lazy var shareButton = UIButton()
    
    lazy var loadingBackgroundView = UIView()
    lazy var loadingImageView = UIImageView()
    lazy var playSafetyCover = UIView()
    
    // MARK: - Init
    
    override func initialize() {
        super.initialize()
    }
    
    // MARK: - View
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .purple
        
        //QQQQ This is an ugly hack - in iOS 11 there are controls at the top of the video player
        //                          so don't want the panel to cover them.
        if #available(iOS 11.0, *) {
            playSafetyCoverSpare = 80
        } else {
            playSafetyCoverSpare = 0
        }

        videoPlayer.backgroundColor = .green
        // See https://developers.google.com/youtube/player_parameters
        videoPlayer.delegate = self
        videoPlayer.playerVars = [
            "playsinline"       : "1" as AnyObject, //this is key with allowsInlineMediaPlayback
            "controls"          : "2" as AnyObject, //yes controls
            "autoplay"          : "1" as AnyObject, //yes autoplay  (looks like doesn't work)
            "fs"                : "0" as AnyObject, //no full screen button (looks like it's only for web-player)
            "modestbranding"    : "0" as AnyObject, //no youtube logo throughout
            "showinfo"          : "0" as AnyObject, //no show info
            "loop"              : "0" as AnyObject, //no loop
            "rel"               : "0" as AnyObject, //no related videos
            "cc_load_policy"    : "0" as AnyObject, //no closed captions
            "start"             : startSeconds as AnyObject
            // "color": "red" as AnyObject //red color on progress bar
        ]
        view.addSubview(videoPlayer)
        
        loadingBackgroundView.backgroundColor = .black
        view.addSubview(loadingBackgroundView)
        
        loadingImageView.contentMode = .scaleAspectFill
        view.addSubview(loadingImageView)
        
        //playSafetyCover.backgroundColor = .orange
        let tapGestureRecongizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecongizerAction(sender:)))
        playSafetyCover.addGestureRecognizer(tapGestureRecongizer)
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeGestureRecongizerAction(sender:)))
        swipeRightGesture.direction = UISwipeGestureRecognizerDirection.right
        playSafetyCover.addGestureRecognizer(swipeRightGesture)
        view.addSubview(playSafetyCover)
        
        //backButton.backgroundColor = .green
        backButton.setImage(UIImage(named: "Navigation_Icon_Left_Passive"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonPressed(sender:)), for: .touchUpInside)
        backButton.isEnabled = true
        playSafetyCover.addSubview(backButton)
        
        //shareButton.backgroundColor = .brown
        shareButton.setImage(UIImage(named: "shareTemp"), for: .normal)
        shareButton.addTarget(self, action: #selector(shareButtonPressed(sender:)), for: .touchUpInside)
        shareButton.isEnabled = true
        playSafetyCover.addSubview(shareButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // This is to allow sound playback under silent.
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {}
        } catch {}
        //
        
        //
        previousIsStatusBarHidden = navigationController!.isNavigationBarHidden
        previousInteractivePopGestureRecognizerIsEnabled = navigationController!.interactivePopGestureRecognizer!.isEnabled
        navigationController?.isNavigationBarHidden = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        //
        
        videoPlayer.loadVideoID(videoIdToPlay!)
        //videoPlayer.play()
        
        startLoadingAnimation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // This is to put the sound category back (e.g. in menu not to make clicks if silent).
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategorySoloAmbient)
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {}
        } catch {}
        //
        
        navigationController?.isNavigationBarHidden = previousIsStatusBarHidden
        navigationController?.interactivePopGestureRecognizer?.isEnabled = previousInteractivePopGestureRecognizerIsEnabled
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoPlayer.play()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        //QQQQ redudent maybe for analytics
        if UIDevice.current.orientation.isLandscape {
            Analytics.logEvent("video_to_landscape", parameters: ["videoId" : videoIdToPlay! as NSObject])
        } else {
            Analytics.logEvent("video_to_portrait", parameters: ["videoId" : videoIdToPlay! as NSObject])
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func refresh() {
        guard shouldRefresh else {
            return
        }
        super.refresh()
        
        var origin = CGPoint.zero
        var size = view.bounds.size
        videoPlayer.frame = CGRect(origin: origin, size: size)
        
        loadingBackgroundView.frame = view.bounds
        
        loadingImageView.image = isExplodingDots ? UIImage(named: "ed_background1") : UIImage(named: "Screen_About_Watch")
        loadingImageView.frame = view.bounds
        
        origin = CGPoint(x: 0, y: playSafetyCoverSpare)
        size = CGSize(width: view.bounds.width, height: view.bounds.height - origin.y - 52)
        playSafetyCover.frame = CGRect(origin: origin, size: size)
        
        backButton.isHidden = (videoPlayer.playerState == .Playing)
        size = CGSize(width: 35, height: 35)
        origin = CGPoint(x: 0, y: (backButton.superview!.bounds.height - size.height) / 2)
        backButton.frame = CGRect(origin: origin, size: size)
        
        shareButton.isHidden = (videoPlayer.playerState != .Paused)
        size = backButton.bounds.size
        origin = CGPoint(x: view.frame.width - size.width - 10, y: 0)
        shareButton.frame = CGRect(origin: origin, size: size)
        
        DLog("Player state: \(videoPlayer.playerState)")
    }
    
    override func close() {
        videoPlayer.stop()
        super.close()
    }
    
    func startLoadingAnimation() {
        loadingBackgroundView.alpha = 1
        loadingImageView.alpha = 1
        UIView.animate(withDuration: 1, delay: 0, options: [.autoreverse, .repeat], animations: {
            self.loadingImageView.alpha = 0.5
        }, completion: nil)
    }
    
    func stopLoadingAnimation() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .beginFromCurrentState, animations: {
            self.loadingBackgroundView.alpha = 0
            self.loadingImageView.alpha = 0
        }, completion: nil)
    }
    
    // MARK: - Actions
    
    @objc func backButtonPressed(sender: UIButton) {
        close()
    }
    
    @objc func shareButtonPressed(sender: UIButton) {
        let shareString = "Check out this video: https://youtu.be/\(videoIdToPlay!), shared using Epsilon Stream, https://www.epsilonstream.com."
        let vc = UIActivityViewController(activityItems: [shareString], applicationActivities: [])
        vc.popoverPresentationController?.sourceView = shareButton.superview
        present(vc, animated: true)
    }
    
    @objc func tapGestureRecongizerAction(sender: UITapGestureRecognizer) {
        if videoPlayer.playerState == .Playing {
            videoPlayer.pause()
        } else {
            videoPlayer.play()
        }
    }
    
    @objc func swipeGestureRecongizerAction(sender: UISwipeGestureRecognizer) {
        close()
    }

    // MARK: - YouTubePlayerDelegate

    func playerReady(_ videoPlayer: YouTubePlayerView){
        videoPlayer.play()
        UserDataManager.updateSecondsWatched(forKey: self.videoIdToPlay!, withSeconds: 0)
    }
    
    func playerStateChanged(_ videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState){
        switch playerState{
        case YouTubePlayerState.Unstarted:
            break
        case YouTubePlayerState.Ended:
            let time = Int((videoPlayer.getCurrentTime()! as NSString).doubleValue.rounded())
            UserDataManager.updateSecondsWatched(forKey: videoIdToPlay!, withSeconds: time)
            close()
            //QQQQ Analytics of video end.
        case YouTubePlayerState.Playing:
            stopLoadingAnimation()
            break
        case YouTubePlayerState.Paused:
            let time = Int((videoPlayer.getCurrentTime()! as NSString).doubleValue.rounded())
            UserDataManager.updateSecondsWatched(forKey: videoIdToPlay!, withSeconds: time)
            Analytics.logEvent("video_paused", parameters: ["videoId" : videoIdToPlay! as NSObject])
            break
        case YouTubePlayerState.Buffering:
            break
        case YouTubePlayerState.Queued:
            break
        }
        refresh()
    }
    
    func playerQualityChanged(_ videoPlayer: YouTubePlayerView, playbackQuality: YouTubePlaybackQuality) {
        DLog("Playback quality: \(playbackQuality)")
    }
}
