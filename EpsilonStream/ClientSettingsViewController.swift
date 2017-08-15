//
//  ClientSettingsViewController.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 29/12/16.
//  Copyright © 2016 Yoni Nazarathy. All rights reserved.
//

import UIKit

class ClientSettingsViewController: UIViewController {

    @IBOutlet var stackView: UIStackView!

    
    @IBAction func aboutAction(_ sender: Any) {
        jumpToWebPage(withURLstring: "https://www.epsilonstream.com/")

    }
    
    
    
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
            UserDataManager.deletedAllSecondsWatched()
        })
        self.present(alert, animated: true, completion: nil)

    }
    
    @IBAction func feedbackAction(_ sender: Any) {
        jumpToWebPage(withURLstring: "https://www.oneonepsilon.com/contact")
    }
    
    func termListAction(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "termListViewController") as? TermListViewController{
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppUtility.lockOrientation(.all)
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
        
        //view.backgroundColor = UIColor(rgb: ES_watch2)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName :UIColor.white]

        
        navigationController?.navigationBar.barTintColor = UIColor(rgb: ES_watch1)
        navigationController?.navigationBar.backgroundColor = UIColor(rgb: ES_watch1)
        navigationController?.navigationBar.alpha = 1.0 //barTintColor = UIColor(rgb: ES_watch2)

        navigationItem.title = "Epsilon Stream"

        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(named: "Navigation_Icon_Left_Passive"), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        btn1.addTarget(self, action: #selector(settingsBackClicked), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btn1)

        //QQQQ admin mode should be encapulsated
        if isInAdminMode{
            let termButton = UIButton()
            termButton.setTitle("Math Objects", for: .normal)
            termButton.setTitleColor(UIColor.white,for: .normal)
            termButton.translatesAutoresizingMaskIntoConstraints = false
            termButton.addTarget(self, action: #selector(termListAction), for: .primaryActionTriggered)
            stackView.addArrangedSubview(termButton)
            
            let adminButton = UIButton()
            adminButton.setTitle("Admin Control Panel", for: .normal)
            adminButton.setTitleColor(UIColor.white,for: .normal)
            adminButton.translatesAutoresizingMaskIntoConstraints = false
            adminButton.addTarget(self, action: #selector(changeToAdmin), for: .primaryActionTriggered)
            stackView.addArrangedSubview(adminButton)
            
            let addVideoButton = UIButton()
            addVideoButton.setTitle("Add Video", for: .normal)
            addVideoButton.setTitleColor(UIColor.white,for: .normal)
            addVideoButton.translatesAutoresizingMaskIntoConstraints = false
            addVideoButton.addTarget(self, action: #selector(addVideo), for: .primaryActionTriggered)
            stackView.addArrangedSubview(addVideoButton)
            
            let addURLButton = UIButton()
            addURLButton.setTitle("Add URL", for: .normal)
            addURLButton.setTitleColor(UIColor.white,for: .normal)
            addURLButton.translatesAutoresizingMaskIntoConstraints = false
            addURLButton.addTarget(self, action: #selector(addURL), for: .primaryActionTriggered)
            stackView.addArrangedSubview(addURLButton)
        }
    }
    

    func settingsBackClicked(){
        navigationController?.popViewController(animated: true)
    }

    func changeToAdmin(){
        //(UIApplication.shared.delegate as! AppDelegate).loadAdmin()
        if let vc = storyboard?.instantiateViewController(withIdentifier: "AdminSettings") as? AdminSettingsViewController{
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func addVideo(){
        //(UIApplication.shared.delegate as! AppDelegate).loadAdmin()
        if let vc = storyboard?.instantiateViewController(withIdentifier: "AdminSettings") as? AdminSettingsViewController{
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    func addURL(){
        //(UIApplication.shared.delegate as! AppDelegate).loadAdmin()
        if let vc = storyboard?.instantiateViewController(withIdentifier: "URLSelectorViewController") as? URLSelectorViewController{
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
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
    
    @IBAction func webLockButtonAction(_ sender: Any) {
        let alert = UIAlertController(title: "Web lock password settings", message: "In version 1.0 you can password protect to only allow curated web content to appear.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {_ in
            print("OK")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}
