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
    
    var dataFilepath = Bundle.main.path(forResource: "train_data", ofType: "txt")!
    var labelFilepath = Bundle.main.path(forResource: "train_labels", ofType: "txt")!
    let train_data = Dataset(dataFilepath: dataFilepath,
                             labelFilepath: labelFilepath)

    dataFilepath = Bundle.main.path(forResource: "test_data", ofType: "txt")!
    labelFilepath = Bundle.main.path(forResource: "test_labels", ofType: "txt")!
    let test_data = Dataset(dataFilepath: dataFilepath,
                            labelFilepath: labelFilepath)

    // results is a mapping of [subset_index : CD], where CD is a two
    // dimensional array. Each row is associated with a test point, and
    // contains the k nearest neighbors from the train data
    var results = [[(label: Int, dist: Float)]]()
    results = map(test_data) { test_point in
        var cd = [(label: Int, dist: Float)!].init(repeating: nil, count: k)
        let nn = knn(point: test_point, data: train_data, k: 10)
        for n in 0..<k {
            cd[n] = (label: nn[n].label, dist: nn[n].dist)
        }
        
        return cd
    }

    for result in results {
        for neighbor in result {
            printToAppConsole("class: \(neighbor.label)")
        }
    }
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
