//
//  ClientSettingsViewController.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 29/12/16.
//  Copyright © 2016 Yoni Nazarathy. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import StoreKit

class ClientSettingsViewController: UIViewController {

    @IBOutlet var stackView: UIStackView!

    
    @IBOutlet weak var webLockButton: UIButton!
    
    @IBOutlet var shareAppButton: UIButton!
    
    @objc func termListAction(_ sender: Any) {
        //QQQQ record curator id
        Analytics.logEvent("curatorTermList_action", parameters: nil)
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

        //QQQQ - links below are also old
        //_ = WebViewPrefetcher.doWebPage(withURLString: "https://www.epsilonstream.com/")
        //view.addSubview(vw1!)
        //_ = WebViewPrefetcher.doWebPage(withURLString: "https://www.oneonepsilon.com/register")
        //view.addSubview(vw2!)
        //_ = WebViewPrefetcher.doWebPage(withURLString: "https://www.oneonepsilon.com/contact")
        //view.addSubview(vw3!)
        //_ = WebViewPrefetcher.doWebPage(withURLString: "https://www.oneonepsilon.com")

        //QQQQ doesn't work vw3?.scrollView.setContentOffset(CGPoint.zero, animated: false)
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor :UIColor.white]


        navigationController?.navigationBar.tintColor = UIColor(rgb: ES_watch1)
        navigationController?.navigationBar.barTintColor = UIColor(rgb: ES_watch1)
        navigationController?.navigationBar.backgroundColor = UIColor(rgb: ES_watch1)
        navigationController?.navigationBar.alpha = 1.0
        
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
            termButton.setTitleColor(UIColor.red,for: .normal)
            termButton.translatesAutoresizingMaskIntoConstraints = false
            termButton.addTarget(self, action: #selector(termListAction), for: .primaryActionTriggered)
            stackView.addArrangedSubview(termButton)
            
            let adminButton = UIButton()
            adminButton.setTitle("Admin Control Panel", for: .normal)
            adminButton.setTitleColor(UIColor.red,for: .normal)
            adminButton.translatesAutoresizingMaskIntoConstraints = false
            adminButton.addTarget(self, action: #selector(changeToAdmin), for: .primaryActionTriggered)
            stackView.addArrangedSubview(adminButton)
            
            /*
            let addVideoButton = UIButton()
            addVideoButton.setTitle("Add Video", for: .normal)
            addVideoButton.setTitleColor(UIColor.red,for: .normal)
            addVideoButton.translatesAutoresizingMaskIntoConstraints = false
            addVideoButton.addTarget(self, action: #selector(addVideo), for: .primaryActionTriggered)
            stackView.addArrangedSubview(addVideoButton)
            
            let addURLButton = UIButton()
            addURLButton.setTitle("Add URL", for: .normal)
            addURLButton.setTitleColor(UIColor.red,for: .normal)
            addURLButton.translatesAutoresizingMaskIntoConstraints = false
            addURLButton.addTarget(self, action: #selector(addURL), for: .primaryActionTriggered)
            stackView.addArrangedSubview(addURLButton)
            */
        }
    }
    

    @objc func settingsBackClicked(){
        navigationController?.popViewController(animated: true)
    }

    
    @objc func changeToAdmin(){
        Analytics.logEvent("changeToAdmin_action", parameters: nil)
        //(UIApplication.shared.delegate as! AppDelegate).loadAdmin()
        if let vc = storyboard?.instantiateViewController(withIdentifier: "AdminSettings") as? AdminSettingsViewController{
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func addVideo(){
        Analytics.logEvent("addVideo_action", parameters: nil)
        //(UIApplication.shared.delegate as! AppDelegate).loadAdmin()
        if let vc = storyboard?.instantiateViewController(withIdentifier: "AdminSettings") as? AdminSettingsViewController{
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    func addURL(){
        Analytics.logEvent("addURL_action", parameters: nil)
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
            vc.splashKey = "OoE-splash"
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func textFieldChange(_ sender: UITextField) {
        okAction.isEnabled = (sender.text!.count == 6)
    }
    
    @objc func textFieldChangeLocked(_ sender: UITextField) {
        if sender.text! == webLockKey!{
            okAction.isEnabled = true
        }else{
            okAction.isEnabled = false
        }
    }

    
    var okAction: UIAlertAction! = nil

    // MARK: - Actions
    
    @IBAction func epsilonStreamAction(_ sender: Any) {
        Analytics.logEvent("epsilonStreamIcon_action", parameters: nil)
        jumpToWebPage(withURLstring: "https://oneonepsilon.com/epsilonstream")
    }
    
    @IBAction func creditActions(_ sender: Any) {
        Analytics.logEvent("credit_action", parameters: nil)
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "creditsViewController") as? CreditsViewController{
            navigationController?.pushViewController(vc, animated: true)
        }
        
        
    }
    
    @IBAction func oneOnEpsilonAction(_ sender: UIButton) {
        Analytics.logEvent("oneOnEpsilonIcon_action", parameters: nil)
        jumpToWebPage(withURLstring: "https://www.oneonepsilon.com")
        
    }
    
    @IBAction func aboutAction(_ sender: Any) {
        Analytics.logEvent("about_action", parameters: nil)
        
//        jumpToWebPage(withURLstring: "https://www.epsilonstream.com") //QQQQ for now
//
//        return //QQQQ skip this now
        
        // IK: Replaced with segue in storyboard.
//        if let vc = storyboard?.instantiateViewController(withIdentifier: "aboutViewController") as? AboutViewController {
//            navigationController?.pushViewController(vc, animated: true)
//        }
    }
    
    @IBAction func webLockButtonAction(_ sender: Any) {
        //QQQQ add more info
        Analytics.logEvent("webLock_action", parameters: nil)

        if let _ = webLockKey{
            let alert = UIAlertController(title: "Web access settings", message: "Epsilon Stream is currently web locked and requires your safety code to allow access to external web pages. You may remove web lock by entering your safety code now.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Enter 6 character Safety Code"
            }
            let textField = alert.textFields![0] as UITextField

            textField.addTarget(self, action: #selector(textFieldChangeLocked), for: .editingChanged)

            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {_ in
                print("OK")
                UserDataManager.setWebLock(withKey: nil)
            }))
            okAction = alert.actions[0]
            okAction.isEnabled = false
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: {_ in
                print("Cancel")
            }))
            self.present(alert, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "Web access settings", message: "You may restrict access to external web pages by entering a Safety Code.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Enter 6 character Safety Code"
            }
            let textField = alert.textFields![0] as UITextField
            textField.addTarget(self, action: #selector(textFieldChange), for: .editingChanged)

            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {_ in
                print("OK")
                UserDataManager.setWebLock(withKey: textField.text)
            }))
            okAction = alert.actions[0]
            okAction.isEnabled = false
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: {_ in
                print("Cancel")
            }))
            self.present(alert, animated: true, completion: nil)

        }
    }
    
    @IBAction func shareAppAction(_ sender: Any) {
        Analytics.logEvent("shareApp_action", parameters: nil)
        
        let shareString = "I am exploring mathematics with Epsilon Stream. Get it and use it for free from https://oneonepsilon.com/epsilonstream ."
        let vc = UIActivityViewController(activityItems: [shareString], applicationActivities: [])
        vc.popoverPresentationController?.sourceView = shareAppButton
        present(vc, animated:  true)
    }
    
    @IBAction func registerAction(_ sender: Any) {
        Analytics.logEvent("register_action", parameters: nil)
        jumpToWebPage(withURLstring: "https://oneonepsilon.com/register")
    }
    
    @IBAction func resetAllAction(_ sender: Any) {
        //QQQQ send more analytics on what has reset
        Analytics.logEvent("resetAllConsider_action", parameters: nil)
        
        
        let alert = UIAlertController(title: "Reset All Viewed", message: "Are you sure you want to reset all views?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default){action in print("cancel reset")})
        alert.addAction(UIAlertAction(title: "Reset", style: UIAlertActionStyle.default){action in print("reset!!!!!!")
            UserDataManager.deletedAllSecondsWatched()
            Analytics.logEvent("resetAllGoThrough_action", parameters: nil)
        })
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func reviewAppButtonAction(_ sender: Any) {
        if let url = URL(string: "https://itunes.apple.com/app/id1200152358") {
            //UIApplication.shared.open(url, options: [:], completionHandler: nil)
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func feedbackAction(_ sender: Any) {
        Analytics.logEvent("feedback_action", parameters: nil)
        jumpToWebPage(withURLstring: "https://oneonepsilon.com/contact")
    }
}
