//
//  KNN_main.swift
//  MapReduce
//
//  Created by Charlie Imhoff on 5/28/17.
//  Copyright © 2017 Charlie Imhoff. All rights reserved.
//

import Foundation
import MapReduce

func main(k: Int) {
	printToAppConsole("Hello World! \(k)")
	
    let test_data = Dataset(.test)
    let train_data = Dataset(.training)

    let mappedPoints = mapKnn(train: train_data, test: test_data)
    
//    var i : Int = 0
//    for result in results {
//        i += 1
//        if i > 50 {
//            printToAppConsole("class: \(result[0])")
//            i = 0
//        }
//    }
    
    let labels = reduceKnn(test: test_data, train: mappedPoints, k: k)
//    
//    var i : Int = 0
    for label in labels {
//        i += 1
//        if i > 50 {
        printToAppConsole("class: \(label)")
//            i = 0
//        }
    }
}

func mapKnn(train train_data: Dataset, test test_data: Dataset) -> MappedSet {
    
    var results = [[MappedPoint]]()
    
    // use map to find the distance to each other point, in parallel
    var i : Int = 0
    for point in test_data {
        i += 1
        if i < 100 {
            continue
        }
        i = 0
        results.append(train_data.parallelMapChunked {
            train_point -> MappedPoint in
            return MappedPoint(label: train_point.label!, dist: point - train_point)
        })
        
        
//        // add the neighbors to a priority queue and
//        var neighborQueue = PriorityQueue<PrioritizedElement<Int>>()
//        for neighbor in neighbors {
//            let element = PrioritizedElement(data: neighbor.label, priority: neighbor.dist)
//            neighborQueue.push(element)
//        }
//        let result = Array(neighborQueue.prefix(k))
//        let point = Point(features: result.map {$0.data}, label: nil)
//        results.append(point)
    }

    return MappedSet(points: results)
}

func reduceKnn(test test_data: Dataset, train train_data: MappedSet, k: Int) -> [Int] {
    let labels = test_data.map{ point -> Int in
        let base = [MappedPoint]()
        let result = train_data.reduce(base) { p1, p2 in
            var mergedPoints = [MappedPoint]()
            var index1 = 0
            var index2 = 0
            for _ in 0..<k {
                if index1 < p1.count && p1[index1].dist < p2[index2].dist {
                    mergedPoints.append(p1[index1])
                    index1 += 1
                } else if index2 < p2.count {
                    mergedPoints.append(p2[index2])
                    index2 += 1
                }
            }
            return mergedPoints
        }
        
        // vote for class label
        var nearbyLabels = [Int:Int]()
        for point in result {
            if nearbyLabels[point.label] == nil {
                nearbyLabels[point.label] = 1
            } else {
                nearbyLabels[point.label]! += 1
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
        
        return maxLabel
    }
    
    return labels
}

// Brute force kNN for a single point, it's garbage but for now we just need a
// proof of concept
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
