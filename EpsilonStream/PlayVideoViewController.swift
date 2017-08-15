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

    var isExplodingDots = false
    
    var videoPlayer: YouTubePlayerView!
    var videoIdToPlay: String?
    var searchResultItem: SearchResultItem! = nil
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func awakeFromNib() {
        //print("awakeFromNib(): \(videoIdToPlay)") //QQQQ remove this function
    }
    
    override func loadView() {
        super.loadView()
        videoPlayer = YouTubePlayerView(frame:view.frame)
        videoPlayer.loadVideoID(videoIdToPlay!)
        videoPlayer.delegate = self
        view = videoPlayer
        
        navigationController?.navigationBar.isHidden = true
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
            print("going back because Ended")
            let time = Int((videoPlayer.getCurrentTime()! as NSString).doubleValue.rounded())
            UserDataManager.updateSecondsWatched(forKey: videoIdToPlay!, withSeconds: time)
            _ = navigationController?.popViewController(animated: true)
        case YouTubePlayerState.Playing:
            break
        case YouTubePlayerState.Paused:
            print("going back because Paused - QQQQ replace with pause")
            _ = navigationController?.popViewController(animated: true)
            let time = Int((videoPlayer.getCurrentTime()! as NSString).doubleValue.rounded())
            UserDataManager.updateSecondsWatched(forKey: videoIdToPlay!, withSeconds: time)
            break
        case YouTubePlayerState.Buffering:
            break
        case YouTubePlayerState.Queued:
            break
        }
    }
    

    override func viewWillAppear(_ animated: Bool) {
        let window = UIApplication.shared.keyWindow!
        let image = isExplodingDots ? UIImage(named: "ed_background1") : UIImage(named: "Screen_About_Watch")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.frame = CGRect(x: window.frame.origin.x, y: window.frame.origin.y, width: window.frame.width, height: window.frame.height)
        window.addSubview(imageView)
        UIView.animate(withDuration: 3.0, animations: {
            imageView.alpha = 0.0
        }, completion:
            {_ in imageView.removeFromSuperview()})
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //QQQQ swipe not accepted??? (Maybe WKWebViewthing)?
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)

        
        
        
        videoPlayer.isHidden = false
        videoPlayer.delegate = self
        videoPlayer.play()//QQQQ what if it didn't get to load before...???
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
