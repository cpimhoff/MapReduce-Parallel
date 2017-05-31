//
//  MappedPoint.swift
//  MapReduce
//

import Foundation

/// Intermidiary representation of a training data point
/// in the context of its distance to a test point.
/// - note: the associated test point is not directly referenced by this struct
struct MappedPoint {
    var label: Int
    var dist: Float
}
