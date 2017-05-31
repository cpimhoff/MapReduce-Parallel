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

    // calculate the accuracy of the program
    var numCorrect : Int = 0
    for i in 0..<test_data.count {
        let label = labels[i]
        // ugly unfolded if necessary because of compiler optimizations
        if i < 100 && label == 1 {
            numCorrect += 1
        } else if i < 200 && label == 2 {
            numCorrect += 1
        } else if i < 300 && label == 7 {
            numCorrect += 1
        }
    }
    
    printToAppConsole("percent correct: \(Float(numCorrect) / Float(test_data.count))")
}

/// Uses our asynchronous map function to map each training point to a class
/// label and distance.
///
/// - Parameters:
///   - train_data: <#train_data description#>
///   - test_data: <#test_data description#>
/// - Returns: a MappedSet storing the mapped training data for each test point
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


/// <#Description#>
///
/// - Parameters:
///   - test_data: <#test_data description#>
///   - train_data: <#train_data description#>
///   - k: <#k description#>
/// - Returns: <#return value description#>
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
