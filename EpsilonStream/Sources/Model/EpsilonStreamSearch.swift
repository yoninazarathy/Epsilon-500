//
//  EpsilonStreamSearch.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 29/12/16.
//  Copyright © 2016 Yoni Nazarathy. All rights reserved.
//


struct EpsilonStreamSearch {
    var searchString: String = ""
    var whyHow: Float = 0.5
    var exploreUnderstand: Float = 0.5
    var age8importance: Float = 0.0
    var age10importance: Float = 0.0
    var age12importance: Float = 0.0
    var age14importance: Float = 0.0
    var age16importance: Float = 0.0

    mutating func setAgeWeights(basedOn age: Int){
        let ageMap: [Int:[Float]] = [
            8: [1.0, 0.4, 0.4, 0.2, 0.0],
            10: [0.6, 1.0, 0.6, 0.4, 0.2],
            12: [0.4, 0.6, 1.0, 0.6, 0.4],
            14: [0.0, 0.2, 0.4, 1.0, 0.6],
            16: [0.0, 0.0, 0.2, 0.4, 1.0]
        ]
        let ageWeights = ageMap[age]!
        age8importance = ageWeights[0]
        age10importance = ageWeights[1]
        age12importance = ageWeights[2]
        age14importance = ageWeights[3]
        age16importance = ageWeights[4]        
    }
}
