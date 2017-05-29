//
//  Dataset.swift
//  MapReduce
//
//  Created by Charlie Imhoff on 5/29/17.
//  Copyright © 2017 Charlie Imhoff. All rights reserved.
//

import Foundation
import MapReduce

class Dataset {
	
	let points : [Point]
	
	init(points: [Point]) {
		self.points = points
	}
	
	/// Loads a CSV dataset into memory from a file
	convenience init(filepath: String) {
		let contents = try! String(contentsOfFile: filepath)
		
		var points = [Point]()
		for line in contents.components(separatedBy: .newlines) {
			if line.isEmpty { continue }
			
			let featureValues = line.components(separatedBy: ",").map { Int($0)! }
			let point = Point(features: featureValues)
			points.append(point)
		}
		
		self.init(points: points)
	}
	
}

// Conform this structure to `DataSource` so our MapReduce framework can use it directly, and to `Sequence` to allow range-based for loops and iteration
extension Dataset : DataSource, Sequence {
	
	/// The amount of datapoints represented by the reciever.
	var count : Int {
		return self.points.count
	}
	
    /// Index the receiver with the first element at index `0`, and the last at index `self.count - 1`
    subscript(index: Int) -> Point {
        return self.points[index]
    }

    /// Index the receiver with the first element at index `0`, and the last at index `self.count - 1`, returning an ArraySlice<Point> over a provided Range<Int> of indices
    subscript(subRange: Range<Int>) -> ArraySlice<Point> {
        return self.points[subRange]
    }
	
    /// An iterator over the Points in the Dataset
    func makeIterator() -> DatasetIterator {
        return DatasetIterator(dataset: self)
    }
}

// Iterator so that Dataset can conform to `Sequence`
struct DatasetIterator : IteratorProtocol {
    var dataset: Dataset
    var index = 0
    
    init(dataset: Dataset) {
        self.dataset = dataset
    }

    mutating func next() -> Point? {
        if index < dataset.count {
            index += 1
            return dataset[index]
        } else {
            return nil
        }
    }
}
