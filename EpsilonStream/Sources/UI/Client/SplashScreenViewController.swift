//
//  SplashScreenViewController.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 23/3/17.
//  Copyright © 2017 Yoni Nazarathy. All rights reserved.
//


import UIKit
import AVFoundation
import AVKit
import SwiftyTimer


//FROM https://stackoverflow.com/questions/24111770/make-a-simple-fade-in-animation-in-swift
public extension UIView {
    
    /**
     Fade in a view with a duration
     
     - parameter duration: custom animation duration
     */
    func fadeIn(withDuration duration: TimeInterval = 1.0) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1.0
        })
    }
    
    /**
     Fade out a view with a duration
     
     - parameter duration: custom animation duration
     */
    func fadeOut(withDuration duration: TimeInterval = 1.0) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0.0
        })
    }
    
}


class SplashScreenViewController: UIViewController {

    var exitProcedureWasCalled = false
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var splashLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        splashLabel.isHidden = false
        splashLabel.text = ""
        
        spinner.isHidden = true
        
        EpsilonStreamBackgroundFetch.runUpdate()
    }
    
     override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)

        let period = TimeInterval(7 * 24 * 60 * 60)
        let lastDatabaseUpdateDate = UserDataManager.lastDatabaseUpdateDate
//        
        if (lastDatabaseUpdateDate == nil || NSDate().timeIntervalSince(lastDatabaseUpdateDate!) > period) || currentUserId != nil {

            // Play video on first launch or after 1 week of inactivity. Or if the app is in curation mode.
            let videoFileName = Common.is64Bit ? "LogoAnimationVert_9sec_High_Res.mp4" : "LogoAnimationVert_9sec_Norm_Res.mp4"
            let url = URL(fileURLWithPath: Bundle.main.resourcePath!).appendingPathComponent(videoFileName)
            //print(url)
            let player = AVPlayer(url: url)
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.videoGravity = .resizeAspectFill
//            playerLayer.shouldRasterize = true
//            playerLayer.rasterizationScale = UIScreen.main.scale
            let screenSize = UIScreen.main.bounds
            playerLayer.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
            view.layer.addSublayer(playerLayer)
            player.play()
            NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTime(notification:)),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
            view.bringSubview(toFront: splashLabel)
            view.bringSubview(toFront: spinner)
            
        } else {
            
            moveOnToClient()
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppUtility.lockOrientation(.all)
    }
    
    func moveOnToClient(){
        spinner.stopAnimating()
        if let vc = storyboard?.instantiateViewController(withIdentifier: "clientNavViewController"){
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc,animated: true, completion: nil)
            //navigationController?.show(vc, sender: self)
        }
    }
    
    func beginExitProcedure() {
        if exitProcedureWasCalled {
            return
        }
        exitProcedureWasCalled = true
        
        if let user = currentUserId {
            self.splashLabel.text = "\(Common.appVersion) #\(Common.buildVersion), user: \(user)"
        } else{
            self.splashLabel.text = ""
        }
        
        spinner.isHidden = false
        spinner.startAnimating()
        
        Timer.every(0.1.seconds) { (timer: Timer) in
            if dbReadyToGo {
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
                timer.invalidate()
                self.moveOnToClient()
            }
        }
    }
    
    // MARK: - Notifications
    
    @objc func playerItemDidPlayToEndTime(notification: NSNotification) {
        beginExitProcedure()
    }
}
