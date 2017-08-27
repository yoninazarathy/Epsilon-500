//
//  BrowseStackManager.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 24/8/17.
//  Copyright © 2017 Yoni Nazarathy. All rights reserved.
//

import Foundation

class BrowseStackManager{
    
    static let bufferSize = 10
    
    static var searchArray: [EpsilonStreamSearch] = Array(repeating: EpsilonStreamSearch(), count: bufferSize)
    static var topIndex = 0
    static var currentIndex = -1
    
    class func canBack() -> Bool{
        return currentIndex > 0
    }
    
    class func canForward() -> Bool{
        return currentIndex < topIndex - 1
    }
    
    class func pushNew(search sr: EpsilonStreamSearch){
        if topIndex == bufferSize{
            print("history buffer full QQQQ")
            return
        }
        
        if currentIndex == topIndex - 1{
            currentIndex += 1
            searchArray[currentIndex] = sr
        }else{
            searchArray[currentIndex] = sr
            topIndex = currentIndex+1
        }
    }
    
    //assumes canBack()
    class func moveBack() -> EpsilonStreamSearch{
        currentIndex -= 1
        return searchArray[currentIndex]
    }
    
    //assumes canForward()
    class func moveForward() -> EpsilonStreamSearch{
        currentIndex += 1
        return searchArray[currentIndex]
    }
}
