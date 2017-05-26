//
//  Reduce.swift
//  MapReduce
//
//  Created by Charlie Imhoff on 5/21/17.
//  Copyright © 2017 Charlie Imhoff. All rights reserved.
//

import Foundation

public func reduce<Source:DataSource, Result>
	(_ datasource: Source,
	 baseValue: @escaping (Source.DataPoint) -> Result,
	 merge: @escaping (Result, Result) -> Result) -> Result {
	
	let queue = DispatchQueue(label: "edu.carleton.chaz&ben.map", qos: .userInitiated,
	                          attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
	let all : Range<Int> = 0..<datasource.count
	
	//	Call down into the heavier private API to handle this
	return subreduce(datasource, range: all, onQueue: queue, baseValue: baseValue, merge: merge)
}

private func subreduce<Source:DataSource, Result>
	(_ datasource: Source, range: Range<Int>, onQueue queue: DispatchQueue,
	 baseValue: @escaping (Source.DataPoint) -> Result,
	 merge: @escaping (Result, Result) -> Result) -> Result {
	
	// base case
	if range.count == 1 {
		let item = datasource[range.lowerBound]
		return baseValue(item)
	}
	
	// rec. case, merge results
	let midPoint = range.lowerBound + (range.count / 2)
	let lowerCut : Range<Int> = range.lowerBound..<midPoint
	let upperCut : Range<Int> = midPoint..<range.upperBound
	
	// asynchronously handle subcases
	let batch = DispatchGroup()
	
	var lowerResult : Result! = nil
	var upperResult : Result! = nil
	queue.async(group: batch) {
		lowerResult = subreduce(datasource, range: lowerCut,
		                        onQueue: queue, baseValue: baseValue, merge: merge)
	}
	queue.async(group: batch) {
		upperResult = subreduce(datasource, range: upperCut,
		                        onQueue: queue, baseValue: baseValue, merge: merge)
	}
	
	// barrier (block) until subcases are complete
	// merge synchronously
	let _ = batch.wait(timeout: .distantFuture)
	return merge(lowerResult, upperResult)
}
