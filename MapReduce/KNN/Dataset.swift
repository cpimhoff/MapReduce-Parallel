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

// Conform this structure to `DataSource` so our MapReduce framework can use it directly
extension Dataset : DataSource {
	
	/// The amount of datapoints represented by the reciever.
	var count : Int {
		return self.points.count
	}
	
	/// Index the reciver with the first element at index `0`, and the last at index `self.count - 1`
	subscript(index: Int) -> Point {
		return self.points[index]
	}
	
}
