//
//  SplashScreenViewController.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 23/3/17.
//  Copyright © 2017 Yoni Nazarathy. All rights reserved.
//


import UIKit



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
        
        
        view.viewWithTag(4)!.alpha = 0
        view.viewWithTag(3)!.alpha = 0
        view.viewWithTag(2)!.alpha = 0
        view.viewWithTag(1)!.alpha = 0
        
        splashLabel.text = ""
        
        
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
