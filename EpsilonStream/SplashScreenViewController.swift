//
//  SplashScreenViewController.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 23/3/17.
//  Copyright © 2017 Yoni Nazarathy. All rights reserved.
//

import UIKit

class SplashScreenViewController: UIViewController {

    @IBOutlet var spinner: UIActivityIndicatorView!
    
    @IBOutlet var splashLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        spinner.startAnimating()
        
        EpsilonStreamBackgroundFetch.runUpdate()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1500), execute: {
            self.splashLabel.text = "Preparing Your Content"
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
            self.seeIfReadyToMove()
        })
    }
    
    func seeIfReadyToMove(){
        if dbReadyToGo && ImageManager.loadedIndex() > 0.2{
            moveOnToClient()
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                self.seeIfReadyToMove()
            })
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func moveOnToClient(){
        
        spinner.stopAnimating()

        
     //   (UIApplication.shared.delegate as! AppDelegate).loadClient(withVCString: "epsilonStreamSearch")
        if let vc = storyboard?.instantiateViewController(withIdentifier: "epsilonStreamSearch") as? ClientSearchViewController{
            navigationController?.show(vc, sender: self)
        }
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
