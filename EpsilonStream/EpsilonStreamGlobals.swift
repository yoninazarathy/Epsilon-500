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

//For putting a contentVersionNumber when submitting a video entry
var tempCurrentVersionForSubmit = 1

var currentDBBuffer: Int = 0 //either 0 or 1 indicating which buffer is used

let float4Picker: [Float] = [0.0, 0.3, 0.6, 1.0]
let floatToIndex4: [Float: Int] = [0.0:0, 0.3:1, 0.6:2, 1.0:3]

let float3Picker: [Float] = [0.0, 0.5, 1.0]
let floatToIndex3: [Float:Int] = [0.0:0, 0.5:1, 1.0:2]

var runningCloudRetrieve = true

var sleepTimeCloudRetrieve: UInt32 = 30
var sleepTimeCheckForUpdates: UInt32 = 1

var sleepTimeImageRetrieve: UInt32 = 5 //QQQQ currently not used 

let maxVideosToShow = 5
let maxAppsToShow = 1
let maxBlogsToShow = 2

var queryOperationResultLimit = 500

var latestVideoDate: Date? = nil
var latestMathObjectDate: Date? = nil
var latestFeatureDate: Date? = nil
var latestChannelDate: Date? = nil