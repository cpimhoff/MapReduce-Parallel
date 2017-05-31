//
//  Reduce.swift
//  MapReduce
//

import Foundation

public extension DataSource {
	
	/// Returns the result of combining the elements of the reciever using the given closure.
	/// - Note: Use in conjunction with `map` to modify an array of values `[S]` to a single value (of dissimilar type) `R`.
	///
	/// - Parameter merge: An _associative_ closure which combines two subresults into one
	/// - Returns: The final result of merging all the items of the reciver.
	func parallelReduce(_ merge: @escaping (DataPoint, DataPoint) -> DataPoint) -> DataPoint {
		let queue = DispatchQueue(label: "edu.carleton.chaz&ben.map", qos: .userInitiated,
		                          attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
		let all : Range<Int> = 0..<self.count
		
		//	Call down into the heavier private API to handle this
		return self._parallelReduce(range: all, onQueue: queue, merge: merge)
	}
	
	private func _parallelReduce(range: Range<Int>, onQueue queue: DispatchQueue,
		 merge: @escaping (DataPoint, DataPoint) -> DataPoint) -> DataPoint {
		
		// base cases
		if range.count == 1 {
			let item = self[range.lowerBound]
			return item
		} else if range.count == 2 {
			// small optimization, just compute directly
			let lowerItem = self[range.lowerBound]
			let upperItem = self[range.upperBound - 1]
			return merge(lowerItem, upperItem)
		}
		
		// rec. case, merge results
		let midPoint = range.lowerBound + (range.count / 2)
		let lowerCut : Range<Int> = range.lowerBound..<midPoint
		let upperCut : Range<Int> = midPoint..<range.upperBound
		
		// asynchronously handle subcases
		let batch = DispatchGroup()
		
		var lowerResult : DataPoint! = nil
		var upperResult : DataPoint! = nil
		// async down to another thread to handle `lowerCut`
		queue.async(group: batch) {
			lowerResult = self._parallelReduce(range: lowerCut, onQueue: queue, merge: merge)
		}
		// reuse this thread in handling `upperCut`, as we'll be blocking on handling both cases anyways
		upperResult = self._parallelReduce(range: upperCut, onQueue: queue, merge: merge)
		
		// barrier (block) until subcases are complete
		// merge synchronously
		let _ = batch.wait(timeout: .distantFuture)
		return merge(lowerResult, upperResult)
	}
	
}
