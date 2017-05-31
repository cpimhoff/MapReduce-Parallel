//
//  KNN_main.swift
//  MapReduce
//

import Foundation
import MapReduce

func main_parallel(k: Int) {
    let test_data = Dataset(.test)
    let train_data = Dataset(.training)

    let mappedPoints = mapKnn(train: train_data, test: test_data)
    let labels = reduceKnn(test: test_data, train: mappedPoints, k: k)

    var i : Int = 0
    for label in labels {
        i += 1
        printToAppConsole("label: \(label), item: \(i)")
    }
}

func mapKnn(train train_data: Dataset, test test_data: Dataset) -> MappedSet {
    
    var results = [[[MappedPoint]]]()
    
    // use map to find the distance to each other point, in parallel
    for point in test_data {
        results.append(train_data.parallelMapChunked {
            train_point -> [MappedPoint] in
            return [MappedPoint(label: train_point.label!, dist: point - train_point)]
        })
    }

    return MappedSet(points: results)
}

func reduceKnn(test test_data: Dataset, train train_data: MappedSet, k: Int) -> [Int] {
    var labels = [Int!].init(repeating: nil, count: test_data.count)
    for i in 0..<test_data.count {
        // merge two arrays of MappedPoints together
        let result = train_data[i].parallelReduce { nn1, nn2 in
            var mergedPoints = [MappedPoint]()
            var index1 = 0
            var index2 = 0
            for _ in 0..<k {
                if index1 >= nn1.count {
                    if index2 < nn2.count {
                        mergedPoints.append(nn2[index2])
                        index2 += 1
                    }
                } else if index2 >= nn2.count {
                    mergedPoints.append(nn1[index1])
                    index1 += 1
                } else if nn1[index1].dist < nn2[index2].dist {
                    mergedPoints.append(nn1[index1])
                    index1 += 1
                } else {
                    mergedPoints.append(nn2[index2])
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
        
        labels[i] = maxLabel
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
