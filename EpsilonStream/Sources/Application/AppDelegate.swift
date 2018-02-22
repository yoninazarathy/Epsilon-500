//
//  AppDelegate.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 26/12/16.
//  Copyright © 2016 Yoni Nazarathy. All rights reserved.
//

import UIKit
import CoreData
import Firebase

//https://stackoverflow.com/questions/28938660/how-to-lock-orientation-of-one-view-controller-to-portrait-mode-only-in-swift/41811798#41811798
struct AppUtility {
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    
    /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
        
        self.lockOrientation(orientation)
        
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
    }
    
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?

    /// set orientations you want to be allowed in this property by default
    var orientationLock = UIInterfaceOrientationMask.all

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }
    
    func loadAdmin(withVideo videoId: String = ""){
        if videoId != ""{
            EpsilonStreamAdminModel.setCurrentVideo(withVideo: videoId)
        }
        let sb = UIStoryboard(name: "EpsilonAdmin", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "epsilonAdminTabBar")
        vc.view.frame = UIScreen.main.bounds
        UIView.transition(with: self.window!, duration: 0.5, options: .transitionCrossDissolve, animations: {self.window!.rootViewController = vc}, completion: nil)
    }
    
    func loadClient(){
        let sb = UIStoryboard(name: "EpsilonClient", bundle: nil)
        
        let vc = sb.instantiateViewController(withIdentifier: "epsilonStreamSplash")
        vc.view.frame = UIScreen.main.bounds
        UIView.transition(with: self.window!, duration: 0.5, options: .transitionCrossDissolve, animations: {self.window!.rootViewController = vc}, completion: nil)
    }
    
    func setGlobalsFromUserDefaults(){
        let bm = UserDefaults.standard.bool(forKey: "inAdmin")
        isInAdminMode = bm
                
        let user = UserDefaults.standard.string(forKey: "userId")
        currentUserId = user
        
        webLockKey = UserDefaults.standard.string(forKey: "webLockKey")
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()
        setGlobalsFromUserDefaults()
        //WebViewPrefetcher.setUp()
        EpsilonStreamDataModel.loadAllAutoCompletionDictionaries()
        EpsilonStreamDataModel.setLatestDates()
        loadClient()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        //QQQQ is this a safe way to message the background task?
        runningCloudRetrieve = false

    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        runningCloudRetrieve = true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        //QQQQ all these maybe don't need to be here
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}
