//
//  Point.swift
//  MapReduce
//

import Foundation

struct Point {
	
	var features : [Int]
    var label : Int?
	
	/// Euclidean distance between this Point and the reciever
	func distance(to other: Point) -> Float {
		let featurePairs = zip(self.features, other.features)
		
		var squaredDist : Float = 0
		for pair in featurePairs {
			let dif = Float(pair.0 - pair.1)
			let sqr = pow(dif, 2)
			squaredDist += sqr
		}
		
		return sqrt(squaredDist)
	}

}

extension Point : Equatable {
	
	// check if two points are identical
	static func ==(_ lhs: Point, _ rhs: Point) -> Bool {
		let featurePairs = zip(lhs.features, rhs.features)
		return !featurePairs.contains { x, y in x != y }
	}
	
	// take distance between points using the '-' operator
	static func -(_ lhs: Point, _ rhs: Point) -> Float {
		return lhs.distance(to: rhs)
    }
    
    /// Index the receiver with the first element at index `0`, and the last at index `self.count - 1`
    subscript(index: Int) -> Int {
        return self.features[index]
    }
	
}
