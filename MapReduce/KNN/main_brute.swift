//
//  KNN_main_brute.swift
//  MapReduce
//
//  Created by Charlie Imhoff on 5/31/17.
//  Copyright © 2017 Charlie Imhoff. All rights reserved.
//

import Foundation

func main_brute(k: Int) {
	let test_data = Dataset(.test)
	let train_data = Dataset(.training)
	
    var labels = [Int!].init(repeating: nil, count: test_data.count)
    for i in 0..<test_data.count {
        let point = test_data[i]
        let result = knn(point: point, data: train_data, k: k)
        
        // vote for class label
        var nearbyLabels = [Int:Int]()
        for label in result {
            if nearbyLabels[label] == nil {
                nearbyLabels[label] = 1
            } else {
                nearbyLabels[label]! += 1
            }
        }
        
        // find label with most votes
        var maxLabel : Int = -1
        var maxCount : Int = 0
        for (label, count) in nearbyLabels {
            if count > maxCount {
                maxLabel = label
                maxCount = count
            } else if count == maxCount {
                maxLabel = label < maxLabel ? label : maxLabel
            }
        }
        
        labels[i] = maxLabel
    }
    var i : Int = 0
    for label in labels {
        i += 1
        printToAppConsole("label: \(label!), item: \(i)")
    }
}

/// Brute force kNN for a single point, to compare to our pretty function
///
/// - Parameters:
///   - point: <#point description#>
///   - data: <#data description#>
///   - k: number of nearest neighbors
/// - Returns: an array of integers representing class labels
func knn(point: Point, data: Dataset, k: Int) -> [Int] {
    var cdprior = PriorityQueue<PrioritizedElement<Int>>()
    
    // find distance to each point
    for train_point in data {
        let dist = point - train_point
        let element = PrioritizedElement(data: point.label!, priority: dist)
        cdprior.push(element)
    }
    
    // find the k closest points
    let result = Array(cdprior.prefix(k))
    return result.map { $0.data }
}
