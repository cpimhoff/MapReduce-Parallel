//
//  main_parallel.swift
//  MapReduce
//

import Foundation
import MapReduce

func main_parallel(k: Int) {
    let test_data = Dataset(.test)
    let train_data = Dataset(.training)

    // map and reduce points
    var labels = [Int!].init(repeating: nil, count: test_data.count)
    for i in 0..<test_data.count {
        let point = test_data[i]
        let mappedPoint = mapKnn(point: point, train: train_data)
        let nearestNeighbors = reduceKnn(data: mappedPoint, k: k)
        labels[i] = majorityVote(result: nearestNeighbors)
    }

    // calculate the accuracy of the program, and print to console
    printToAppConsole("percent correct: \(accuracy(of: labels, for: test_data))")
}

/// Uses our asynchronous map function to map each training point
/// to a class label and distance (`MappedPoint`). Collect these in a `MappedMatrix`.
///
/// - Parameters:
///   - test_data: points to be classified
///   - train_data: training points used to classify the test points
/// - Returns: a `MappedSet` storing the mapped training data for each test point.
func mapKnn(point test_point: Point, train train_data: Dataset) -> MappedMatrix {
    // use map to find the distance to each other point, in parallel
    let result = train_data.parallelMapChunked {
        train_point -> [MappedPoint] in
        return [MappedPoint(label: train_point.label!,
                            dist: test_point - train_point)]
    }

    return MappedMatrix(rawArray: result)
}

/// Reduce the given test point and training data distances to the k nearest
/// neighbors for each point.
///
/// - Parameters:
///   - data: a matrix containing distances from training points to a test point
///   - k: number of nearest neighbors
/// - Returns: an array of MappedPoints representing nearest neighbors
func reduceKnn(data train_data: MappedMatrix, k: Int) -> [MappedPoint] {
    // merge two sorted arrays of MappedPoints together
    let result = train_data.parallelReduce { nn1, nn2 in
        var mergedPoints = [MappedPoint]()
        var index1 = 0
        var index2 = 0
        
        // only merge the first k points, since we never care about more
        for _ in 0..<k {
            // walk through the two arrays, adding the closest point at
            // each step
            // we have to unroll the if statement into more cases than
            // appears necessary because of compiler optimizations
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
    
    return result
}

/// Finds the class label with the highest number of votes.
///
/// - Parameter result: array of Ints storing votes for class labels
/// - Returns: the class label with the highest number of votes
func majorityVote(result: [MappedPoint]) -> Int {
    // vote for class label
    var nearbyLabels = [Int:Int]()
    for point in result {
        let label = point.label
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
    
    return maxLabel
}

/// Returns the accuracy of the supplied labels against the test set.
/// Our test set only includes points with labels 1,3,7, whose ranges are known.
func accuracy(of labels: [Int], for set: Dataset) -> Float {
	var numCorrect : Int = 0
	for i in 0..<set.count {
		let label = labels[i]
		// ugly unfolded if is necessary because of compiler optimizations
		if i < 100 && label == 1 {
			numCorrect += 1
		} else if i < 200 && label == 2 {
			numCorrect += 1
		} else if i < 300 && label == 7 {
			numCorrect += 1
		}
	}
	
	return Float(numCorrect) / Float(set.count)
}
