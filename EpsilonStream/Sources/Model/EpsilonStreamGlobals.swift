//
//  EpsilonStreamGlobals.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 29/12/16.
//  Copyright © 2016 Yoni Nazarathy. All rights reserved.
//

import UIKit
import Foundation

//flag for indicating a backgroundAction
var backgroundActionInProgress = false

//general flag indicating if in admin mode or not
var isInAdminMode = false

//string id of current user
var currentUserId: String? = nil

var infoReadyToGo = false

//When false then db is still not updated and searching can't be used
var dbReadyToGo = false

//For putting a contentVersionNumber when submitting a video entry
var tempCurrentVersionForSubmit = 1

//var currentDBBuffer: Int = 0 //either 0 or 1 indicating which buffer is used

let float4Picker: [Float] = [0.0, 0.3, 0.6, 1.0]
let floatToIndex4: [Float: Int] = [0.0:0, 0.3:1, 0.6:2, 1.0:3]

var runningCloudRetrieve = true

var sleepTimeCloudRetrieve: UInt32 = 5
var sleepTimeCheckForUpdates: UInt32 = 1

let maxVideosToShow = 100
let maxAppsToShow = 100
let maxBlogsToShow = 100

let queryOperationResultLimit = 1000 //QQQQ cursor for mathobjects and features.

var latestVideoDate             = Date(timeIntervalSince1970: 0)
var latestMathObjectDate        = Date(timeIntervalSince1970: 0)
var latestFeatureDate           = Date(timeIntervalSince1970: 0)
var latestMathObjectLinkDate    = Date(timeIntervalSince1970: 0)
var latestSnippetsDate          = Date(timeIntervalSince1970: 0)

//Red
let ES_watch1 = 0xFF4646

//Green
let ES_play1 = 0x46CCA1

//Yellow
let ES_explore1 = 0xFFC864

var webLockKey: String? = nil

var curatorPasswords = ["coco":     "940322",
                        "yoni":     "695569",
                        "inna":     "239239",
                        "phil":     "919828",
                        "miriam":   "695569",
                        "yousuf":   "291456",
                        "igor":     "200787"]

