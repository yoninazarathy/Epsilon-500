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
    
    var webURLString: String! = nil
    
    override func loadView() {
        webView = WebViewPrefetcher.doWebPage(withURLString: webURLString)
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        //webView.removeFromSuperview()
        view = webView
        //webView.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
