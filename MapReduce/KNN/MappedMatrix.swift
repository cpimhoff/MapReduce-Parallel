//
//  MappedMatrix.swift
//  MapReduce
//

import Foundation
import MapReduce

/// Represents a 2D matrix where:
/// 	- the rows are test data points (points we would like to assign labels to)
///		- the columns are `MappedPoint`s representing traning data points,
///			with their label and their distance to the row's test point
class MappedMatrix {
    
    let points : [[MappedPoint]]
    
    init(rawArray: [[MappedPoint]]) {
        self.points = rawArray
    }
}

// Conform this structure to `Collection` so our MapReduce framework can use it directly
extension MappedMatrix : Collection {
    
    var startIndex: Int {
        return self.points.startIndex
    }
    
    var endIndex : Int {
        return self.points.endIndex
    }
    
    func index(after i: Int) -> Int {
        return i + 1
    }
    
    subscript(index: Int) -> [MappedPoint] {
        return self.points[index]
    }
}
