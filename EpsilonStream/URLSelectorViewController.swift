//
//  URLSelectorViewController.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 2/1/17.
//  Copyright © 2017 Yoni Nazarathy. All rights reserved.
//

import UIKit
import WebKit

class URLSelectorViewController: UIViewController,WKNavigationDelegate {

    var webView: WKWebView!
    
    var currentURLString = ""
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!){
        //print("YYYYYYY \(webView.url)")
        currentURLString = webView.url!.absoluteString
    }
    
    func resetView(){
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        let url = URL(string: "https://google.com")!
        webView.load(URLRequest(url: url))
        webView.reloadFromOrigin()
        view = webView
    }
    
    override func loadView() {
        resetView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit Page", style: .plain, target: self, action: #selector(submitTapped))
    }
    
    func textFieldChange(_ sender: UITextField) {
        if sender.text! == "1234"{ //QQQQ curator password
            okAction.isEnabled = true
        }else{
            okAction.isEnabled = false
        }
    }

    var okAction: UIAlertAction! = nil

    
    func submitTapped(){
        let alert = UIAlertController(title: "One on Epsilon Development", message: "Do you want to add this webpage to the DB?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Safety Code"
        }
        let textField = alert.textFields![0] as UITextField
        textField.addTarget(self, action: #selector(textFieldChange), for: .editingChanged)
        
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {_ in
            EpsilonStreamAdminModel.currentFeature = FeaturedURL(inContext: PersistentStorageManager.shared.mainContext)
            EpsilonStreamAdminModel.currentFeature.ourFeaturedURLHashtag = "#newUnfinishedFeature"
            EpsilonStreamAdminModel.currentFeature.urlOfItem = self.currentURLString
            
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "curateArticleViewController") as? CurateArticleViewController{
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }))
        okAction = alert.actions[0]
        okAction.isEnabled = false
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {_ in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        resetView()
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
