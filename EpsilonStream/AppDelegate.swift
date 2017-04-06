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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    
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
        
        let vc = sb.instantiateViewController(withIdentifier: "clientNavViewController")
        vc.view.frame = UIScreen.main.bounds
        UIView.transition(with: self.window!, duration: 0.5, options: .transitionCrossDissolve, animations: {self.window!.rootViewController = vc}, completion: nil)
    }
    
    func setGlobalsFromUserDefaults(){
        let bm = UserDefaults.standard.bool(forKey: "inAdmin")
        isInAdminMode = bm
    }
    
    func setInAdminMode(_ isAdmin: Bool){
        isInAdminMode = isAdmin
        UserDefaults.standard.set(isInAdminMode, forKey: "inAdmin")
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        FIRApp.configure()

        setGlobalsFromUserDefaults()
        
        
        if allowsAdminMode && isInAdminMode{
            loadAdmin()
        }else{
            loadClient()
        }
        
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
        
        WebViewPrefetcher.setUp()        
        
        EpsilonStreamDataModel.setLatestDates()
        
        ImageManager.setup()        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - Split view
    //QQQQ not clear what this is for...? (came with template)... ahhh delgate...
//    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
//        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
//        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
//        if topAsDetailController.detailItem == nil {
//            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
//            return true
//        }
//        return false
//    }

    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "EpsilonStreamDataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()    
}

