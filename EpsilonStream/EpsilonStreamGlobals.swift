//
//  EpsilonStreamGlobals.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 29/12/16.
//  Copyright © 2016 Yoni Nazarathy. All rights reserved.
//

import Foundation

//DebugConstants
let allowsAdminMode = true

//general flag indicating if in admin mode or not
var isInAdminMode = true

var infoReadyToGo = false

//When false then db is still not updated and searching can't be used
var dbReadyToGo = false

//For putting a contentVersionNumber when submitting a video entry
var tempCurrentVersionForSubmit = 1

//var currentDBBuffer: Int = 0 //either 0 or 1 indicating which buffer is used

let float4Picker: [Float] = [0.0, 0.3, 0.6, 1.0]
let floatToIndex4: [Float: Int] = [0.0:0, 0.3:1, 0.6:2, 1.0:3]

let float3Picker: [Float] = [0.0, 0.5, 1.0]
let floatToIndex3: [Float:Int] = [0.0:0, 0.5:1, 1.0:2]

var runningCloudRetrieve = true

var sleepTimeCloudRetrieve: UInt32 = 5
var sleepTimeCheckForUpdates: UInt32 = 1

var sleepTimeImageRetrieve: UInt32 = 120 //QQQQ currently not used

let maxVideosToShow = 10000
let maxAppsToShow = 10000
let maxBlogsToShow = 10000

var queryOperationResultLimit = 500

var latestImageDate: Date? = nil
var latestVideoDate: Date? = nil
var latestMathObjectDate: Date? = nil
var latestFeatureDate: Date? = nil
