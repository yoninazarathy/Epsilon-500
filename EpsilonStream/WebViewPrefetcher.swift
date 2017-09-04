//
//  WebViewPrefetcher.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 1/2/17.
//  Copyright © 2017 Yoni Nazarathy. All rights reserved.
//

import Foundation
import WebKit

class SnifferTemp: NSObject, WKNavigationDelegate{
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!){
        print("start....")
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!){
        print("XXXXXXX \(webView.url)")
    }
}

class WebViewPrefetcher{
    
    static let maxPages = 8 //QQQQ ensure there isn't "thrashing"
    static var numPages = 0
    static var sequenceNumber = 0
    
    static var webViews: [String:WKWebView] = [:]
    
    static var priority: [String:Int] = [:]
    
    class func setUp(){
        //QQQQ maybe nothing to do.
    }
    
    //class func
    
    static var st: WKNavigationDelegate! = nil
    
    //QQQQ temp
    class func getFreshWebPage(withURLString webURLString: String)->WKWebView?{
        let webConfiguration = WKWebViewConfiguration()
        //QQQQ delete webConfiguration.suppressesIncrementalRendering = true
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        if st == nil{
            st = SnifferTemp()
        }

        webView.navigationDelegate = st
        let url = URL(string: webURLString)!
        webView.load(URLRequest(url: url))
        webView.reloadFromOrigin()
        return webView
    }
    
    //QQQQ temporarilly removing
    /*
    class func doWebPage(withURLString webURLString: String)->WKWebView?{
        //if not allowed more pages, return nil
        
        //if already has key
        if webViews[webURLString] != nil{
            return webViews[webURLString]
        }
        
        //otherwise if here, will create new webView
        
        let webConfiguration = WKWebViewConfiguration()
        //QQQQ delete webConfiguration.suppressesIncrementalRendering = true
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        if st == nil{
            st = SnifferTemp()
        }
        
        webView.navigationDelegate = st
        let url = URL(string: webURLString)!
        webView.load(URLRequest(url: url))
        webView.reloadFromOrigin()
        webViews[webURLString] = webView
        
        priority[webURLString] = sequenceNumber
        sequenceNumber = sequenceNumber + 1
        numPages = numPages + 1
        if numPages > maxPages{
            var minSeq = Int.max
            var minKey = ""
            for (k,_) in webViews{
                if priority[k]! < minSeq{
                    minSeq = priority[k]!
                    minKey = k
                }
            }
            webViews.removeValue(forKey: minKey)
            priority.removeValue(forKey: minKey)
            numPages = numPages - 1
           // print(webViews)
            //print("bumped out: \(minKey)")
        }
        //print("NUM WEB VIEW PAGES: \(numPages)")
        return webView
    }
    */
    
    
}
