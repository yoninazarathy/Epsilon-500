//
//  WebViewingViewController.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 2/1/17.
//  Copyright © 2017 Yoni Nazarathy. All rights reserved.
//

import UIKit
import WebKit
import Firebase
import SafariServices

class WebViewingViewController: UIViewController,WKNavigationDelegate {

    var webView: WKWebView!
    var splashKey: String = ""
    var webURLString: String! = nil
    var coverImageView: UIImageView! = nil
    
    var pageLoaded: Bool = false
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!){
        /*
        print("start: \(navigation)")
        if let webKey = webLockKey{
            print("QQQQ handle weblock")
        }else{
            let alert = UIAlertController(title: "You are leaving Epsilon Stream to an external page", message: "If you wish to block such functionallity, you can web lock Epsilon Stream in the settings menu.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Go to page", style: UIAlertActionStyle.default, handler: {_ in
                let safariVC = SFSafariViewController(url: NSURL(string: "QQQQ"/*????*/) as! URL)
                self.present(safariVC, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {_ in
            }))
            self.present(alert, animated: true, completion: nil)
        }
        */
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!){
        //print("XXXXXXX \(webView.url)")
        coverImageView.removeFromSuperview()
        webView.scrollView.isScrollEnabled = true


    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
        coverImageView.removeFromSuperview()
        webView.scrollView.isScrollEnabled = true

    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error){
        FIRAnalytics.logEvent(withName: "web_fail", parameters: ["webURL" :  webURLString! as NSObject])
        backClicked()//QQQQ refactor name
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void){
        decisionHandler(.allow)
    }



    
    override func loadView() {
        super.loadView()
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: view.frame, configuration: webConfiguration)
        webView.navigationDelegate = self
        
        view.addSubview(webView)
        
        let url = URL(string: webURLString)!
        let urlRequest = URLRequest(url: url)
        webView.load(urlRequest)
        
        let window = UIApplication.shared.keyWindow!
        var imageName: String = ""
        if splashKey == "OoE-splash"{
            imageName = "oneOnEpsilonSplash"
        }else if splashKey == "gmp-splash"{
            imageName = "ed_background1"
        }else{
            imageName = "Screen_About_Explore"
        }
        coverImageView = UIImageView(image: UIImage(named: imageName))
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.frame = CGRect(x: window.frame.origin.x, y: window.frame.origin.y, width: window.frame.width, height: window.frame.height)
        window.addSubview(coverImageView)
        UIView.animate(withDuration: 3.0, animations: {
            self.coverImageView.alpha = 0.2
        }, completion:
            {_ in })//self.coverImageView.removeFromSuperview()})
    }
    
    override func viewDidAppear(_ animated: Bool) {
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        
        if splashKey == "OoE-splash"{
            navigationController?.navigationBar.barTintColor = UIColor(rgb: ES_watch1)
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor :UIColor.white]
            navigationItem.title = "One on Epsilon"
        }else if splashKey == "gmp-splash"{
            navigationController?.navigationBar.barTintColor = UIColor.blue.lighter(by: 0.5)
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor :UIColor.white]
            navigationItem.title = "The Global Math Project"
        }else{
            navigationController?.navigationBar.barTintColor = UIColor(rgb: ES_explore1)
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor :UIColor.white]
            navigationItem.title = "Epsilon Stream"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(named: "Navigation_Icon_Left_Passive"), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        btn1.addTarget(self, action: #selector(backClicked), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btn1)
    }
    
    @objc func backClicked(){
        navigationController?.popViewController(animated: true)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppUtility.lockOrientation(.all)
        coverImageView.removeFromSuperview()
    }
}
