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
extension MappedSet : Collection {
    
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
