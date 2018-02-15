//
//  BrowseStackManager.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 24/8/17.
//  Copyright © 2017 Yoni Nazarathy. All rights reserved.
//

import Foundation

class BrowseStackManager{
    
    static let bufferLimit = 10000 //QQQQ
    
    static var searchArray: [EpsilonStreamSearch] = Array(repeating: EpsilonStreamSearch(), count: bufferLimit)
    static var topIndex = 1 //always points to next available slot
    static var currentIndex = 0 //points to current slot
    
    class func reset(withBaseSearch sr: EpsilonStreamSearch){
        topIndex = 1
        currentIndex = 0
        searchArray[currentIndex] = sr
    }
    
    class func canBack() -> Bool{
        return currentIndex > 0
    }
    
    class func canForward() -> Bool{
        return currentIndex < topIndex - 1
    }
    
    class func pushNew(search sr: EpsilonStreamSearch){
        if topIndex == bufferLimit{
            print("history buffer full QQQQ")
            return
        }
        
        //if at top of stack
        if currentIndex == topIndex - 1{
            currentIndex += 1
            topIndex += 1
            searchArray[currentIndex] = sr
        }else{//not on top of stack
            currentIndex += 1
            searchArray[currentIndex] = sr
            topIndex = currentIndex + 1
        }
    }
    
    
    //assumes canBack()
    class func moveBack() -> EpsilonStreamSearch{
        if currentIndex > 0{
            currentIndex -= 1
        }else{
            print("QQQQ error moving back")
        }
        return searchArray[currentIndex]
    }
    
    //assumes canForward()
    class func moveForward() -> EpsilonStreamSearch{
        if currentIndex < topIndex - 1{
            currentIndex += 1
        }else{
            print("QQQQ error moving forward")
        }
        return searchArray[currentIndex]
    }
}
