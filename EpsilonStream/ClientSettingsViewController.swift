//
//  ClientSettingsViewController.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 29/12/16.
//  Copyright © 2016 Yoni Nazarathy. All rights reserved.
//

import UIKit

class ClientSettingsViewController: UIViewController {

    @IBAction func aboutAction(_ sender: Any) {
        jumpToWebPage(withURLstring: "https://www.epsilonstream.com/")

    }
    
    
    @IBOutlet var stackView: UIStackView!
    
    @IBOutlet var shareAppButton: UIButton!
    @IBAction func shareAppAction(_ sender: Any) {
        print("share app")
        let shareString = "I am using Epsilon Stream. Get it from https://www.epsilonstream.com ."
        let vc = UIActivityViewController(activityItems: [shareString], applicationActivities: [])
        vc.popoverPresentationController?.sourceView = shareAppButton
        present(vc, animated:  true)
    }
    
    @IBAction func registerAction(_ sender: Any) {
        jumpToWebPage(withURLstring: "https://www.oneonepsilon.com/register")
    }
    
    @IBAction func resetAllAction(_ sender: Any) {
        let alert = UIAlertController(title: "Reset All Viewed", message: "Are you sure you want to reset all views?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default){action in print("cancel reset")})
        alert.addAction(UIAlertAction(title: "Reset", style: UIAlertActionStyle.default){action in print("reset!!!!!!")
            EpsilonStreamDataModel.resetAllViewed()
        })
        self.present(alert, animated: true, completion: nil)

    }
    
    @IBAction func feedbackAction(_ sender: Any) {
        jumpToWebPage(withURLstring: "https://www.oneonepsilon.com/contact")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        _ = WebViewPrefetcher.doWebPage(withURLString: "https://www.epsilonstream.com/")
        //view.addSubview(vw1!)
        _ = WebViewPrefetcher.doWebPage(withURLString: "https://www.oneonepsilon.com/register")
        //view.addSubview(vw2!)
        _ = WebViewPrefetcher.doWebPage(withURLString: "httpsh://www.oneonepsilon.com/contact")
        //view.addSubview(vw3!)
        //QQQQ doesn't work vw3?.scrollView.setContentOffset(CGPoint.zero, animated: false)
        
        if allowsAdminMode{
            let adminButton = UIButton()
            adminButton.setTitle("Go to Admin Mode", for: .normal)
            adminButton.setTitleColor(UIColor.red,for: .normal)
            adminButton.translatesAutoresizingMaskIntoConstraints = false
            adminButton.addTarget(self, action: #selector(changeToAdmin), for: .primaryActionTriggered)
            stackView.addArrangedSubview(adminButton)
        }
    }
    
    func changeToAdmin(){
        (UIApplication.shared.delegate as! AppDelegate).loadAdmin()
    }
    

    override func viewDidAppear(_ animated: Bool) {
        //(UIApplication.shared.delegate as! AppDelegate).setInAdminMode(true)
        //(UIApplication.shared.delegate as! AppDelegate).loadAdmin()
        navigationController!.title = "shit"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //QQQQ this code is duplicated
    func jumpToWebPage(withURLstring string: String){
        if let vc = storyboard?.instantiateViewController(withIdentifier: "webViewingViewController") as? WebViewingViewController{
            vc.webURLString = string
            navigationController?.pushViewController(vc, animated: true)
        }
    }

}
