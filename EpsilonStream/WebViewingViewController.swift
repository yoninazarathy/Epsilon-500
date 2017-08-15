//
//  WebViewingViewController.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 2/1/17.
//  Copyright © 2017 Yoni Nazarathy. All rights reserved.
//

import UIKit
import WebKit

class WebViewingViewController: UIViewController,WKNavigationDelegate {

    var webView: WKWebView!
    
    var splashKey: String = ""
    
    var webURLString: String! = nil
    
    override func loadView() {
        webView = WebViewPrefetcher.doWebPage(withURLString: webURLString)
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        //webView.removeFromSuperview()
        view = webView
        //webView.isHidden = false
        
        
        
        let window = UIApplication.shared.keyWindow!
        let imageView = UIImageView(image: UIImage(named: "Screen_About_Explore"))//"YouTube-logo-full_color"))
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
        
        //view.backgroundColor = UIColor(rgb: ES_watch2)

        navigationController?.navigationBar.barTintColor = UIColor(rgb: ES_explore1)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName :UIColor(rgb: ES_watch1)]
            
            
            //.color = UIColor(rgb: ES_watch1)
        navigationItem.title = "Epsilon Stream"
        
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(named: "Navigation_Icon_Left_Active"), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        btn1.addTarget(self, action: #selector(backClicked), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btn1)
    }
    
    func backClicked(){
        navigationController?.popViewController(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //view.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
