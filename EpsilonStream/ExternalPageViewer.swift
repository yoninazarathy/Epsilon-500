////
////  ExternalPageViewer.swift
////  EpsilonStream
////
////  Created by Yoni Nazarathy on 12/8/17.
////  Copyright © 2017 Yoni Nazarathy. All rights reserved.
////
//
//import Foundation
//import SafariServices
//
//class ExternalPageViewer : UIViewController, SFSafariViewControllerDelegate{
//    
//    func openPage(onViewController vc: UIViewController)
//    {
//        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
//        
//        let safariVC = SFSafariViewController(url: NSURL(string: "https://www.google.co.in") as! URL)
//        
//        vc.present(safariVC, animated: true, completion: nil)
//    }
//    
//    func safariViewControllerDidFinish(controller: SFSafariViewController)
//    {
//        controller.dismiss(animated: true, completion: nil)
//    }
//    
//}
//    
