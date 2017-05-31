//
//  main_brute.swift
//  MapReduce
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

/// Brute force kNN for a single point, to compare to our parallel function
///
/// - Parameters:
///   - point: the point to find the kNN of
///   - data: the dataset to find neighbors within
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
