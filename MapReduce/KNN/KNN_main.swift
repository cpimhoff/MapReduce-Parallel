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
	
    let train_data = Dataset(.training)
    let test_data = Dataset(.test)

    let results = mapKnn(train: train_data, test: test_data, k: k)
    
    for result in results {
        for neighbor in result {
            printToAppConsole("class: \(neighbor)")
        }
    }
}

func mapKnn(train train_data: Dataset, test test_data: Dataset, k: Int) -> [[Int]] {
    // results is a mapping of [subset_index : CD], where CD is a two
    // dimensional array. Each row is associated with a test point, and
    // contains the k nearest neighbors from the train data
    var results = [[Int]]()
    results = map(test_data) { test_point in
        var cd = [Int!].init(repeating: nil, count: k)
        let nn = knn(point: test_point, data: train_data, k: 10)
        for n in 0..<k {
            cd[n] = nn[n]
        }
        
        return cd
    }
    
    return results
}

// Brute force kNN for a single point, it's garbage but for now we just need a
// proof of concept
func knn(point: Point, data: Dataset, k: Int) -> [Int] {
	var cdprior = PriorityQueue<PrioritizedElement<Int>>()
    
    // find distance to each point
    for train_point in data {
		let dist = point - train_point
		let element = PrioritizedElement(data: point.label, priority: dist)
        cdprior.push(element)
    }
    
    // find the k closest points
	let result = Array(cdprior.prefix(k))
	return result.map { $0.data }
}
