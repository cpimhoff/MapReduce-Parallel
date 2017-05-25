//
//  Reduce.swift
//  MapReduce
//
//  Created by Charlie Imhoff on 5/21/17.
//  Copyright © 2017 Charlie Imhoff. All rights reserved.
//

import Foundation

//
//	this implementation of `reduce` is bad... very bad.
//	additionally, it has a variety of race conditions and bad access
//
// 	so... a draft of a draft.
//

public func reduce<T:DataSource, R>
	(_ datasource: T, initialResult: R,
	 using reduceClosure: @escaping (R, T.DataPoint) -> R,
	 mergeWith mergeClosure: @escaping (R, R) -> R) -> R {
	
	// how big should our chunks be // how many of them
	let chunks = Int(sqrt(Double(datasource.count)).rounded(.up))
	
	// dispatch work to concurrent queue, reduces each chunk seperately and saving to `chunkedResults`
	let queue = DispatchQueue.global(qos: .utility)
	var chunkedResults = Array<R!>.init(repeating: nil, count: chunks)
	for chunkIndex in 0...chunks {
		queue.async {
			let chunkStart = chunkIndex * chunks
			let chunkEnd = min(chunkStart + chunks, datasource.count)
			
			let chunkResult = subReduce(datasource, initialResult: initialResult,
			                            startIndex: chunkStart, endIndex: chunkEnd,
			                            using: reduceClosure)
			chunkedResults[chunkIndex] = chunkResult
		}
	}
	
	// syncronously merge chunked work
	return queue.sync(flags: [.barrier]) {
		let flatResults = chunkedResults.flatMap { $0 }
		return flatResults.reduce(initialResult, mergeClosure)
	}
}

private func subReduce<T:DataSource, R>(_ datasource: T, initialResult: R,
            startIndex: Int, endIndex: Int,
            using reduceClosure: @escaping (R, T.DataPoint) -> R) -> R {
	
	// non-concurrently reduces the items in `datasource[startIndex..<endIndex]`
	
	var result = initialResult
	for i in startIndex..<endIndex {
		let item = datasource[i]
		result = reduceClosure(result, item)
	}
	
	return result
}
