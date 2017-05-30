//
//  KNN_main.swift
//  MapReduce
//
//  Created by Charlie Imhoff on 5/28/17.
//  Copyright © 2017 Charlie Imhoff. All rights reserved.
//

import Foundation
import MapReduce

let K : Int = 10

func main(k: Int) {
	printToAppConsole("Hello World! \(k)")
}

// Brute force kNN for a single point, it's garbage but for now we just need a
// proof of concept
func knn(point: Point, data: Dataset, k: Int) -> [(label: Int, dist: Float)] {
    var cd = [(label: Int, dist: Float)]()
    
    // find distance to each point
    for train_point in data {
        cd.append((point.label, point - train_point))
    }
    
    // find the k closest points
    cd.sort(by: { p1, p2 in p1.dist > p2.dist })
    return Array(cd.prefix(k))
}
