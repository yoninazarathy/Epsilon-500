//
//  UserMessageManager.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 4/11/17.
//  Copyright © 2017 Yoni Nazarathy. All rights reserved.
//

import Foundation

class UserMessageManager{
    
    static var searchCount = 0
    
    //returns nil if there isn't a message to show
    //returns a string with the message to show if needed.
    class func showMessage() -> String?{
        if searchCount < 30{
            return "Search above"
        }else{
            return nil
        }
    }
    
    class func userDidKeyInAction(){
        searchCount += 1
        if searchCount > 40{
            searchCount = 40
        }
    }
    
    class func userDidAnotherAction(){
        searchCount -= 8
        if searchCount < 0{
            searchCount = 0
        }
    }
}
