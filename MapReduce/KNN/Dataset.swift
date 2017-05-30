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
	
	enum BundledSet : String { case training = "train", test = "test" }
	/// Initialize a Dataset from the data files packaged alongside this app,
	/// either the training set or the test set
	convenience init(_ source: Dataset.BundledSet) {
		let base = source.rawValue
		
		let dataPath = Bundle.main.path(forResource: "\(base)_data", ofType: "txt")!
		let trainPath = Bundle.main.path(forResource: "\(base)_labels", ofType: "txt")!
		
		self.init(dataFilepath: dataPath, labelFilepath: trainPath)
	}
    
    /// Loads a CSV dataset into memory from a file, as well as another file storing class labels for each datapoint
    convenience init(dataFilepath: String, labelFilepath: String) {
        let dataContents = try! String(contentsOfFile: dataFilepath)
        let labelContents = try! String(contentsOfFile: labelFilepath)
        
        let dataLines = dataContents.components(separatedBy: .newlines)
        let labelLines = labelContents.components(separatedBy: .newlines)
        
        var points = [Point]()
        for i in 0..<dataLines.count {
            let dataLine = dataLines[i]
            let labelLine = labelLines[i]

            if dataLine.isEmpty || labelLine.isEmpty { continue }
            
            let featureValues = dataLine.components(separatedBy: ",").map { Int($0)! }
            let label = Int(labelLine)!
            let point = Point(features: featureValues, label: label)
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
    subscript(subRange: CountableRange<Int>) -> ArraySlice<Point> {
        return self.points[subRange]
    }
    
    /// Index the receiver with the first element at index `0`, and the last at index `self.count - 1`, returning an ArraySlice<Point> over a provided Range<Int> of indices
    subscript(subRange: CountableClosedRange<Int>) -> ArraySlice<Point> {
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
