//
//  EpsilonStreamLoginManager.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 4/7/17.
//  Copyright © 2017 Yoni Nazarathy. All rights reserved.
//

import Foundation
import UIKit

//https://stackoverflow.com/questions/26667009/get-top-most-uiviewcontroller
extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}


class EpsilonStreamLoginManager{
    
    static let manager = EpsilonStreamLoginManager()
    
    static func getInstance() -> EpsilonStreamLoginManager{
        return manager
    }
    
    @objc func textFieldChange(_ sender: UITextField) {
        if sender.text! ==  curatorPasswords[selectedUser]{
            okAction.isEnabled = true
        }else{
            okAction.isEnabled = false
        }
    }
    
    var okAction: UIAlertAction! = nil
    
    var selectedUser: String = ""
    
    func refreshAdminMode(){
        
    }
    
    static var initialAdminRequest = false
    
    func loginAdminRequest(withUser user: String? = nil){
        if user == nil{
            EpsilonStreamLoginManager.initialAdminRequest = true
            selectedUser = ""
            return
        }else if EpsilonStreamLoginManager.initialAdminRequest && (user == "coco" || user == "yoni" || user == "phil" || user == "inna" || user == "yousuf"){
            
            selectedUser = user!
            
            let alert = UIAlertController(title: "One on Epsilon Development", message: "\(user!), you are about to enter curate mode.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Enter Your Safety Code"
            }
            let textField = alert.textFields![0] as UITextField
            textField.addTarget(self, action: #selector(textFieldChange), for: .editingChanged)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {_ in
                UserDataManager.setInAdminMode(true, withUser: user)
            }))
            okAction = alert.actions[0]
            okAction.isEnabled = false
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {_ in
            }))
            UIApplication.topViewController()!.present(alert, animated: true, completion: nil)
        }else{
            //QQQQ report to FIR (anyway report)
        }
    }
    
    func logoutAdmin(){
        let alert = UIAlertController(title: "One on Epsilon Development", message: "You are about to leave curate mode.", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {_ in
            UserDataManager.setInAdminMode(false,withUser: nil)
            EpsilonStreamLoginManager.initialAdminRequest = false
        }))
        UIApplication.topViewController()!.present(alert, animated: true, completion: nil)

    }
    
}
