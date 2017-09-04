//
//  ClientSettingsViewController.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 29/12/16.
//  Copyright © 2016 Yoni Nazarathy. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class ClientSettingsViewController: UIViewController {

    @IBOutlet var stackView: UIStackView!

    
    @IBOutlet weak var webLockButton: UIButton!
    @IBAction func aboutAction(_ sender: Any) {
        FIRAnalytics.logEvent(withName: "about_action", parameters: [:])
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "aboutViewController") as? AboutViewController{
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func epsilonStreamAction(_ sender: Any) {
        FIRAnalytics.logEvent(withName: "epsilonStreamIcon_action", parameters: [:])
        jumpToWebPage(withURLstring: "https://www.epsilonstream.com")
    }
    
    @IBAction func creditActions(_ sender: Any) {
        FIRAnalytics.logEvent(withName: "credit_action", parameters: [:])
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "creditsViewController") as? CreditsViewController{
            navigationController?.pushViewController(vc, animated: true)
        }

        
    }
    
    @IBAction func oneOnEpsilonAction(_ sender: UIButton) {
        FIRAnalytics.logEvent(withName: "oneOnEpsilonIcon_action", parameters: [:])
        jumpToWebPage(withURLstring: "https://www.oneonepsilon.com")

    }
    
    @IBOutlet var shareAppButton: UIButton!
    
    @IBAction func shareAppAction(_ sender: Any) {
        FIRAnalytics.logEvent(withName: "shareApp_action", parameters: [:])
        
        let shareString = "I am exploring mathematics with Epsilon Stream for iOS. Get it and use it for free from https://www.epsilonstream.com ."
        let vc = UIActivityViewController(activityItems: [shareString], applicationActivities: [])
        vc.popoverPresentationController?.sourceView = shareAppButton
        present(vc, animated:  true)
    }
    
    @IBAction func registerAction(_ sender: Any) {
        FIRAnalytics.logEvent(withName: "register_action", parameters: [:])
        jumpToWebPage(withURLstring: "https://www.oneonepsilon.com/register")
    }
    
    @IBAction func resetAllAction(_ sender: Any) {
        //QQQQ send more analytics on what has reset
        FIRAnalytics.logEvent(withName: "resetAllConsider_action", parameters: [:])

        
        let alert = UIAlertController(title: "Reset All Viewed", message: "Are you sure you want to reset all views?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default){action in print("cancel reset")})
        alert.addAction(UIAlertAction(title: "Reset", style: UIAlertActionStyle.default){action in print("reset!!!!!!")
            UserDataManager.deletedAllSecondsWatched()
            FIRAnalytics.logEvent(withName: "resetAllGoThrough_action", parameters: [:])
        })
        self.present(alert, animated: true, completion: nil)

    }
    
    @IBAction func feedbackAction(_ sender: Any) {
        FIRAnalytics.logEvent(withName: "feedback_action", parameters: [:])
        jumpToWebPage(withURLstring: "https://www.oneonepsilon.com/contact")
    }
    
    func termListAction(_ sender: Any) {
        //QQQQ record curator id
        FIRAnalytics.logEvent(withName: "curatorTermList_action", parameters: [:])
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

        //_ = WebViewPrefetcher.doWebPage(withURLString: "https://www.epsilonstream.com/")
        //view.addSubview(vw1!)
        //_ = WebViewPrefetcher.doWebPage(withURLString: "https://www.oneonepsilon.com/register")
        //view.addSubview(vw2!)
        //_ = WebViewPrefetcher.doWebPage(withURLString: "https://www.oneonepsilon.com/contact")
        //view.addSubview(vw3!)
        //_ = WebViewPrefetcher.doWebPage(withURLString: "https://www.oneonepsilon.com")

        //QQQQ doesn't work vw3?.scrollView.setContentOffset(CGPoint.zero, animated: false)
        
        //view.backgroundColor = UIColor(rgb: ES_watch2)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName :UIColor.white]


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
    

    func settingsBackClicked(){
        navigationController?.popViewController(animated: true)
    }

    
    func changeToAdmin(){
        FIRAnalytics.logEvent(withName: "changeToAdmin_action", parameters: [:])
        //(UIApplication.shared.delegate as! AppDelegate).loadAdmin()
        if let vc = storyboard?.instantiateViewController(withIdentifier: "AdminSettings") as? AdminSettingsViewController{
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func addVideo(){
        FIRAnalytics.logEvent(withName: "addVideo_action", parameters: [:])
        //(UIApplication.shared.delegate as! AppDelegate).loadAdmin()
        if let vc = storyboard?.instantiateViewController(withIdentifier: "AdminSettings") as? AdminSettingsViewController{
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    func addURL(){
        FIRAnalytics.logEvent(withName: "addURL_action", parameters: [:])
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
        if sender.text!.characters.count ==  6{
            okAction.isEnabled = true
        }else{
            okAction.isEnabled = false
        }
    }
    
    @objc func textFieldChangeLocked(_ sender: UITextField) {
        if sender.text! ==  webLockKey!{
            okAction.isEnabled = true
        }else{
            okAction.isEnabled = false
        }
    }

    
    var okAction: UIAlertAction! = nil

    
    @IBAction func webLockButtonAction(_ sender: Any) {
        //QQQQ add more info
        FIRAnalytics.logEvent(withName: "webLock_action", parameters: [:])

        if let key = webLockKey{
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
}
