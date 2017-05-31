//
//  Map.swift
//  MapReduce
//

import Foundation

/// Maps values from the provided datasource into new values using a provided mapping closure.
///
/// Work is asynchronously handled, each item on its own block, improving performance in certain cases,
/// such as when the work to map each item is non-trivial and the datasource is somewhat small.
///
/// - Parameters:
///   - datasource: The data to use as initial values, passed into the `mapping` closure.
///   - mapping: A mapping closure from the points in `datasource` to a new result
/// - Returns: An array containing (in order) the points from `datasource` after mapping
private func parallelMap<Source:DataSource, MappedPoint>(_ datasource: Source,
                using mapping: @escaping (Source.DataPoint) -> MappedPoint) -> [MappedPoint] {
	
	// create empty results array of length `datasource.count`
	let results = SynchronizedArray<MappedPoint!>.init(repeating: nil, count: datasource.count)
	
	// dispatch work to a concurrent queue, mapping items and saving them to `results`
	let queue = DispatchQueue(label: "edu.carleton.chaz&ben.map", qos: .userInitiated,
	                          attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
	
	for i in 0..<datasource.count {
		// pop a work block onto the queue for mapping a single item
		queue.async {
			// fetching the item is async as well, in case that is time intensive (such as on a DB)
			let item = datasource[i]
			// envoke user specified mapping function
			let mappedItem = mapping(item)
			
			results[i] = mappedItem
		}
	}
	
	// barrier (block) until all work items have completed
	return queue.sync(flags: .barrier) {
		return results.array
	}
}

/// The maximum amount of "worker threads" that `parallelMapChunked` can request from GCD.
private let SPLIT_LIMIT : Double = 300

/// Maps values from the provided datasource into new values using a provided mapping closure.
///
/// Work is asynchronously handled in chunks, improving performance in certain cases,
/// such as when the work to map each item is non-trivial and the datasource is very large.
///
/// - Parameters:
///   - datasource: The data to use as initial values, passed into the `mapping` closure.
///   - mapping: A mapping closure from the points in `datasource` to a new result
/// - Returns: An array containing (in order) the points from `datasource` after mapping
private func parallelMapChunked<Source:DataSource, MappedPoint>(_ datasource: Source,
                using mapping: @escaping (Source.DataPoint) -> MappedPoint) -> [MappedPoint] {
	
	// create empty results array of length `datasource.count`
	let results = SynchronizedArray<MappedPoint!>.init(repeating: nil, count: datasource.count)
	
	// dispatch work to a concurrent queue, mapping items and saving them to `results`
	let queue = DispatchQueue(label: "edu.carleton.chaz&ben.map", qos: .userInitiated,
	                          attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
	
	// chunk up the work into processable bits
	let chunkCount = Int((Double(datasource.count) / SPLIT_LIMIT).rounded(.up))
	let chunkSize = Int((Double(datasource.count) / Double(chunkCount)).rounded(.up))
	
	for chunkIndex in 0..<chunkCount {
		// pop a work block onto the queue for mapping a chunk of items
		queue.async {
			let chunkStart = chunkIndex * chunkSize
			let chunkEnd = min(chunkStart + chunkSize, datasource.count)
			
			// map each item in the chunk
			for itemIndex in chunkStart..<chunkEnd {
				let item = datasource[itemIndex]
				// envoke user specified mapping function
				let mappedItem = mapping(item)
				
				results[itemIndex] = mappedItem
			}
		}
	}
	
	// barrier (block) until all work items have completed
	return queue.sync(flags: .barrier) {
		return results.array
	}
}

/// API is attached to `DataSource`
public extension DataSource {
	
	/// Maps values from the provided datasource into new values using a provided mapping closure.
	///
	/// Work is asynchronously handled, each item on its own block, improving performance in certain cases,
	/// such as when the work to map each item is non-trivial and the datasource is somewhat small.
	///
	/// - Parameters:
	///   - datasource: The data to use as initial values, passed into the `mapping` closure.
	///   - mapping: A mapping closure from the points in `datasource` to a new result
	/// - Returns: An array containing (in order) the points from `datasource` after mapping
	func parallelMap<MappedPoint>
		(_ mapping: @escaping (Self.DataPoint) -> MappedPoint) -> [MappedPoint] {
		
		return MapReduce.parallelMap(self, using: mapping)
	}
	
	/// Maps values from the provided datasource into new values using a provided mapping closure.
	///
	/// Work is asynchronously handled in chunks, improving performance in certain cases,
	/// such as when the work to map each item is non-trivial and the datasource is very large.
	///
	/// - Parameters:
	///   - datasource: The data to use as initial values, passed into the `mapping` closure.
	///   - mapping: A mapping closure from the points in `datasource` to a new result
	/// - Returns: An array containing (in order) the points from `datasource` after mapping
	func parallelMapChunked<MappedPoint>
		(_ mapping: @escaping (Self.DataPoint) -> MappedPoint) -> [MappedPoint] {
		
		return MapReduce.parallelMapChunked(self, using: mapping)
	}
	
}
