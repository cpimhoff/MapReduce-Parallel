//
//  KNN_main.swift
//  MapReduce
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
    var i : Int = 0
    for label in labels {
        i += 1
//        if i > 50 {
        printToAppConsole("class: \(label), item: \(i)")
//            i = 0
//        }
    }
}

func mapKnn(train train_data: Dataset, test test_data: Dataset) -> MappedSet {
    
    var results = [[MappedPoint]]()
    
    // use map to find the distance to each other point, in parallel
    for point in test_data {
        results.append(train_data.parallelMapChunked {
            train_point -> MappedPoint in
//            printToAppConsole("  label: \(train_point.label!)")
            return MappedPoint(label: train_point.label!, dist: point - train_point)
        })
    }

    return MappedSet(points: results)
}

func reduceKnn(test test_data: Dataset, train train_data: MappedSet, k: Int) -> [Int] {
    let labels = test_data.map{ point -> Int in
        let base = [MappedPoint]()
        
        // check that train_data has non-1 labels
        for thing in train_data {
//            let thing =
            for point in thing {
                if point.label != 1 {
//                    printToAppConsole("  label: \(point)")
                }
            }
        }
        
        // merge two arrays of MappedPoints together
        let result = train_data.reduce(base) { nn1, nn2 in
            var mergedPoints = [MappedPoint]()
            var index1 = 0
            var index2 = 0
            for _ in 0..<(nn1.count + nn2.count) {
//                for point in nn1 {
//                    if point.label != 1 {
//                        printToAppConsole("  label: \(point)")
//                    }
//                }
//                for point in nn2 {
//                    if point.label != 1 {
//                        printToAppConsole("  label: \(point)")
//                    }
//                }
//                printToAppConsole("  label: \(nn1)")
                if index1 < nn1.count && nn1[index1].dist > nn2[index2].dist {
//                    if nn1[index1].label != 1 {
//                        printToAppConsole("  label: \(nn1[index1].label)")
//                    }
                    mergedPoints.append(nn1[index1])
                    index1 += 1
                } else if index2 < nn2.count {
//                    if nn2[index2].label != 1 {
//                        printToAppConsole("  label: \(nn2[index2].label)")
//                    }
                    mergedPoints.append(nn2[index2])
                    index2 += 1
                }
            }
            return Array(mergedPoints.prefix(k))
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
