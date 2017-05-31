//
//  Reduce.swift
//  MapReduce
//

import Foundation

/// The maximum amount of threads to request from GCD in a complete reduce operation.
private let SPLIT_LIMIT = 150

// Collections indexed with ascending integers can be mapped by our framework.
public extension Collection where Self.Index == Int, Self.IndexDistance == Int {
	
	typealias Result = Element
	
	/// Returns the result of combining the elements of the reciever using the given closure.
	/// - Note: Use in conjunction with `map` to modify an array of values `[S]` to a single value (of dissimilar type) `R`.
	///
	/// - Parameter merge: An **associative** closure which combines two subresults into one
	/// - Returns: The final result of merging all the items of the reciver.
	func parallelReduce(_ merge: @escaping (Element, Element) -> Result) -> Result {
		
		let queue = DispatchQueue(label: "edu.carleton.chaz&ben.map", qos: .userInitiated,
		                          attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
		let all : Range<Int> = 0..<self.count
		let baseSize = self.count / SPLIT_LIMIT
		
		//	Call down into the heavier private API to handle this
		return self._parallelReduce(range: all, on: queue, baseSize: baseSize, merge: merge)
	}
	
	private func _parallelReduce(range: Range<Int>, on queue: DispatchQueue, baseSize: Int,
	                             merge: @escaping (Element, Element) -> Result) -> Result {
		
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
		
		var lowerResult : Result! = nil
		var upperResult : Result! = nil
		
		if lowerCut.count <= baseSize {
			// handle `lowerCut` directly
			lowerResult = self._parallelReduce(range: lowerCut,
			                                   on: queue, baseSize: baseSize, merge: merge)
		} else {
			// async down to another thread to handle `lowerCut`
			queue.async(group: batch) {
				lowerResult = self._parallelReduce(range: lowerCut,
				                                   on: queue, baseSize: baseSize, merge: merge)
			}
		}
		
		// reuse this thread in handling `upperCut` in all cases,
		// as we'll be blocking on both subresults anyways
		upperResult = self._parallelReduce(range: upperCut,
		                                   on: queue, baseSize: baseSize, merge: merge)
		
		// barrier (block) until subcases are complete
		// merge synchronously
		let _ = batch.wait(timeout: .distantFuture)
		return merge(lowerResult, upperResult)
	}
	
}
