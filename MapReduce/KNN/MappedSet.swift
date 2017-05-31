//
//  MappedSet.swift
//  MapReduce
//
//  Created by Ben Withbroe on 5/30/17.
//  Copyright © 2017 Charlie Imhoff. All rights reserved.
//

import Foundation
import MapReduce

class MappedSet {
    
    let points : [[MappedPoint]]
    
    init(points: [[MappedPoint]]) {
        self.points = points
    }
}

// Conform this structure to `DataSource` so our MapReduce framework can use it directly
extension MappedSet : DataSource, Sequence {
    
    /// The amount of datapoints represented by the reciever.
    var count : Int {
        return self.points.count
    }
    
    /// Index the receiver with the first element at index `0`, and the last at index `self.count - 1`
    subscript(index: Int) -> [MappedPoint] {
        return self.points[index]
    }
    
    /// Index the receiver with the first element at index `0`, and the last at index `self.count - 1`, returning an ArraySlice<Point> over a provided Range<Int> of indices
    subscript(subRange: CountableRange<Int>) -> ArraySlice<[MappedPoint]> {
        return self.points[subRange]
    }
    
    /// Index the receiver with the first element at index `0`, and the last at index `self.count - 1`, returning an ArraySlice<Point> over a provided Range<Int> of indices
    subscript(subRange: CountableClosedRange<Int>) -> ArraySlice<[MappedPoint]> {
        return self.points[subRange]
    }

    /// An iterator over the MappedPoints in the Dataset
    func makeIterator() -> MappedSetIterator {
        return MappedSetIterator(mappedSet: self)
    }
}

// Iterator so that Dataset can conform to `Sequence`
struct MappedSetIterator : IteratorProtocol {
    var mappedSet: MappedSet
    var index = 0
    
    init(mappedSet: MappedSet) {
        self.mappedSet = mappedSet
    }
    
    mutating func next() -> [MappedPoint]? {
        if index < mappedSet.count - 1 {
            index += 1
            return mappedSet[index]
        } else {
            return nil
        }
    }
}
