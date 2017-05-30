//
//  Point.swift
//  MapReduce
//
//  Created by Charlie Imhoff on 5/29/17.
//  Copyright © 2017 Charlie Imhoff. All rights reserved.
//

import Foundation

struct Point {
	
	let features : [Int]
    let label : Int
	
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
	
}
