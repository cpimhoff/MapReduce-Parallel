//
//  Dataset.swift
//  MapReduce
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
		
        // find paths to the files within the project
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
        
        // read points and labels from the files
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
extension Dataset : Collection {
	
	var startIndex: Int {
		return self.points.startIndex
	}
	
	var endIndex : Int {
		return self.points.endIndex
	}
	
	func index(after i: Int) -> Int {
		return i + 1
	}
	
    subscript(index: Int) -> Point {
        return self.points[index]
    }
	
}
