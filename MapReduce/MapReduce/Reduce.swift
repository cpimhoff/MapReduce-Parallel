//
//  Reduce.swift
//  MapReduce
//

import Foundation

private func parallelReduce<S:DataSource>
	(_ datasource: S,
	 merge: @escaping (S.DataPoint, S.DataPoint) -> S.DataPoint) -> S.DataPoint {
	
	let queue = DispatchQueue(label: "edu.carleton.chaz&ben.map", qos: .userInitiated,
	                          attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
	let all : Range<Int> = 0..<datasource.count
	
	//	Call down into the heavier private API to handle this
	return _parallelReduce(datasource, range: all, onQueue: queue, merge: merge)
}

private func _parallelReduce<S:DataSource>
	(_ datasource: S, range: Range<Int>, onQueue queue: DispatchQueue,
	 merge: @escaping (S.DataPoint, S.DataPoint) -> S.DataPoint) -> S.DataPoint {
	
	// base cases
	if range.count == 1 {
		let item = datasource[range.lowerBound]
		return item
	} else if range.count == 2 {
		// small optimization, just compute directly
		let lowerItem = datasource[range.lowerBound]
		let upperItem = datasource[range.upperBound - 1]
		return merge(lowerItem, upperItem)
	}
	
	// rec. case, merge results
	let midPoint = range.lowerBound + (range.count / 2)
	let lowerCut : Range<Int> = range.lowerBound..<midPoint
	let upperCut : Range<Int> = midPoint..<range.upperBound
	
	// asynchronously handle subcases
	let batch = DispatchGroup()
	
	var lowerResult : S.DataPoint! = nil
	var upperResult : S.DataPoint! = nil
	// async down to another thread to handle `lowerCut`
	queue.async(group: batch) {
		lowerResult = _parallelReduce(datasource, range: lowerCut, onQueue: queue, merge: merge)
	}
	// reuse this thread in handling `upperCut`, as we'll be blocking on handling both cases anyways
	upperResult = _parallelReduce(datasource, range: upperCut, onQueue: queue, merge: merge)
	
	// barrier (block) until subcases are complete
	// merge synchronously
	let _ = batch.wait(timeout: .distantFuture)
	return merge(lowerResult, upperResult)
}

/// API is attached to `DataSource`
public extension DataSource {
	
	func parallelReduce(_ merge: @escaping (DataPoint, DataPoint) -> DataPoint) -> DataPoint {
		return MapReduce.parallelReduce(self, merge: merge)
	}
	
}
