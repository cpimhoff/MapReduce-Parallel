//
//  DataSource.swift
//  MapReduce
//

import Foundation

/// Abstraction over input data structures
/// because DataSource is used only for reading input values,
/// a non-thread-safe implementation (such as the standard `Array`) is acceptable.
public protocol DataSource {
	
	associatedtype DataPoint
	
	/// The amount of datapoints represented by the reciever.
	var count : Int { get }
	
	/// Index the reciver with the first element at index `0`, and the last at index `self.count - 1`
	subscript(index: Int) -> DataPoint { get }
	
}

// explicitly comform `Array` and `SynchronizedArray` to `DataSource`
// (they already has all the protocol requirements implemented)
extension Array : DataSource {}
extension SynchronizedArray : DataSource {}
