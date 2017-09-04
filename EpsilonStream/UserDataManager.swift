//
//  UserDataManager.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 12/8/17.
//  Copyright © 2017 Yoni Nazarathy. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import FirebaseAnalytics

class UserDataManager{
    
    
    class func crash(){
        var variable:Int! = nil
        var variable2 = 0
        variable2 += variable
        print("never gonna get here: \(variable2)")
    }
    
    
    /////////////
    // Setters //
    /////////////
    
    class func setWebLock(withKey key: String?){
        webLockKey = key
        UserDefaults.standard.set(key, forKey: "webLockKey")
    }
    
    
    class func setInAdminMode(_ isAdmin: Bool, withUser user: String? = nil){
        if isAdmin{
            if let usr = user{
                FIRAnalytics.logEvent(withName: "admin_modeEnter", parameters: ["user": usr as NSObject])
            }
        }else{
            if let usr = currentUserId{
                FIRAnalytics.logEvent(withName: "admin_modeEnter", parameters: ["user": usr as NSObject])
            }
        }

        //print("changing adming mode to: \(isAdmin)")
        isInAdminMode = isAdmin
        UserDefaults.standard.set(isInAdminMode, forKey: "inAdmin")
        
        currentUserId = user
        UserDefaults.standard.set(user, forKey: "userId")
        //print("changing userId to: \(user)")
        
        EpsilonStreamDataModel.deleteAllEntities(withName: "Video")
        
        sleep(5)
        
        crash()
        
    }
    
    class func deletedAllSecondsWatched(){
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let request = Video.createFetchRequest()
        //QQQQ check if fetchlimit?
        
        do{
            let result = try container.viewContext.fetch(request)
            for v in result{
                //print("going to try to delete seconds of \(v.youtubeVideoId)")
                UserDefaults.standard.removeObject(forKey: v.youtubeVideoId)
            }
        }catch{
            print("Fetch failed")
        }
    }
    
    class func updateSecondsWatched(forKey key:String,withSeconds seconds:Int){
        let oldSeconds = UserDefaults.standard.integer(forKey: key)
        if seconds > oldSeconds{
            UserDefaults.standard.set(seconds, forKey: key)
        }
    }
    
    /////////////
    // Getters //
    /////////////

    //QQQQ not using this in AppDelegate -but should
    class func getWebLock() -> String?{
        return UserDefaults.standard.string(forKey: "webLockKey")
    }
    
    class func getSecondsWatched(forKey key:String)-> Int{
        return UserDefaults.standard.integer(forKey: key)
    }

    class func getPercentWatched(forKey key: String) -> Float{
        let secondsWatched = UserDefaults.standard.integer(forKey: key) //may be 0
        
        if let duration = EpsilonStreamDataModel.getDuration(forVideo: key){
            let factionWatched = Float(secondsWatched)/Float(duration)
            var percentWatched = (100*factionWatched).rounded()
            if percentWatched > 100{
                print("error with percent watched \(percentWatched)")
                percentWatched = 100
            }
            return percentWatched
        }else{
            print("error - no duation for \(key)")
            return 0.0
        }
    }
    
}
