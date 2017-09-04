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

    @IBOutlet var spinner: UIActivityIndicatorView!
    
    @IBOutlet var splashLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        splashLabel.isHidden = false
        spinner.isHidden = true
        
        EpsilonStreamBackgroundFetch.runUpdate()
        
        splashLabel.text = ""
        
        /*
        UIView.animate(withDuration: 0.7, animations: {
            //self.view.viewWithTag(4)!.alpha = 0
            self.view.viewWithTag(1)!.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.6, animations: {
                self.view.viewWithTag(1)!.alpha = 0
                self.view.viewWithTag(2)!.alpha = 1
            }, completion: { _ in
                UIView.animate(withDuration: 0.5, animations: {
                    self.view.viewWithTag(2)!.alpha = 0
                    self.view.viewWithTag(3)!.alpha = 1
                }, completion: { _ in
                    UIView.animate(withDuration: 1.3, animations: {
                        self.view.viewWithTag(3)!.alpha = 0
                        self.view.viewWithTag(4)!.alpha = 1
                    }, completion: { _ in
                        if let user = currentUserId{
                            self.splashLabel.text = "Alpha \(versionNumber()), user: \(user)"
                        }else{
                            self.splashLabel.text = "Alpha \(versionNumber())"
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1500), execute: {
                            self.spinner.isHidden = false
                            self.spinner.startAnimating()
                            Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true){
                                timer in
                                if true || dbReadyToGo{ //QQQQ
                                    timer.invalidate()
                                    self.moveOnToClient()
                                }

                            }
                        })
                    })
                })
            })
        })
 */
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func moveOnToClient(){
        spinner.stopAnimating()
        if let vc = storyboard?.instantiateViewController(withIdentifier: "clientNavViewController"){
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc,animated: true, completion: { _ in })
            //navigationController?.show(vc, sender: self)
        }
    }
    
    
     override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        
        //let movieView = view.viewWithTag(1)!

        let resourcePath = Bundle.main.resourcePath
        let url = URL(fileURLWithPath:resourcePath!).appendingPathComponent("LogoAnimationVert_9sec.mp4")
        //print(url)
        let player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        let screenSize = UIScreen.main.bounds
        playerLayer.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        //print(playerLayer.frame)
        view.layer.addSublayer(playerLayer)
        playerLayer.borderWidth = 0.0
        player.play()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(beginExitProcedure))
        
        let transparentView = UIView()
        transparentView.frame = playerLayer.frame
        transparentView.alpha = 1.0
        view.addSubview(transparentView)
        transparentView.addGestureRecognizer(gesture)

        
        view.bringSubview(toFront: splashLabel)
        view.bringSubview(toFront: spinner)
        
        NotificationCenter.default.addObserver(self, selector: #selector(beginExitProcedure),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        


        
    }
    
    func beginExitProcedure(note: NSNotification) {
        if let user = currentUserId{
            self.splashLabel.text = "Beta \(versionNumber()), user: \(user)"
        }else{
            self.splashLabel.text = "Beta \(versionNumber())"
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false){
            _ in
            Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true){
                timer in
                if dbReadyToGo{
                    timer.invalidate()
                    self.moveOnToClient()
                }
                self.spinner.isHidden = false
                self.spinner.startAnimating()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppUtility.lockOrientation(.all)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
