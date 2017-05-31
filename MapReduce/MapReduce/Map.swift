//
//  Map.swift
//  MapReduce
//

import Foundation

/// The maximum amount of threads to request from GCD in `parallelMapChunked`
private let SPLIT_LIMIT = 300

public extension DataSource {
	
	/// Maps values of the reciever into new values using a provided mapping closure.
	///
	/// Work is asynchronously handled, each item on its own block, improving performance in certain cases,
	/// such as when the work to map each item is non-trivial and the datasource is somewhat small.
	///
	/// - Parameters:
	///   - mapping: A mapping closure from the points in the reciever to a new result
	/// - Returns: An array containing (in order) the points from the reciever after mapping
	func parallelMap<MappedPoint>
		(_ mapping: @escaping (Self.DataPoint) -> MappedPoint) -> [MappedPoint] {
		
		// create empty results array of length `datasource.count`
		let results = SynchronizedArray<MappedPoint!>.init(repeating: nil, count: self.count)
		
		// dispatch work to a concurrent queue, mapping items and saving them to `results`
		let queue = DispatchQueue(label: "edu.carleton.chaz&ben.map", qos: .userInitiated,
		                          attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
		
		for i in 0..<self.count {
			// pop a work block onto the queue for mapping a single item
			queue.async {
				// fetching the item is async as well, in case that is time intensive (such as on a DB)
				let item = self[i]
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
	
	/// Maps values of the reciever into new values using a provided mapping closure.
	///
	/// Work is asynchronously handled in chunks, improving performance in certain cases,
	/// such as when the work to map each item is non-trivial and the datasource is very large.
	///
	/// - Parameters:
	///   - mapping: A mapping closure from the points in the reciever to a new result
	/// - Returns: An array containing (in order) the points from the reciever after mapping
	func parallelMapChunked<MappedPoint>
		(_ mapping: @escaping (Self.DataPoint) -> MappedPoint) -> [MappedPoint] {
		
		// create empty results array of length `datasource.count`
		let results = SynchronizedArray<MappedPoint!>.init(repeating: nil, count: self.count)
		
		// dispatch work to a concurrent queue, mapping items and saving them to `results`
		let queue = DispatchQueue(label: "edu.carleton.chaz&ben.map", qos: .userInitiated,
		                          attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
		
		// chunk up the work into processable bits
		let chunkCount = Int((Double(self.count) / Double(SPLIT_LIMIT)).rounded(.up))
		let chunkSize = Int((Double(self.count) / Double(chunkCount)).rounded(.up))
		
		for chunkIndex in 0..<chunkCount {
			// pop a work block onto the queue for mapping a chunk of items
			queue.async {
				let chunkStart = chunkIndex * chunkSize
				let chunkEnd = min(chunkStart + chunkSize, self.count)
				
				// map each item in the chunk
				for itemIndex in chunkStart..<chunkEnd {
					let item = self[itemIndex]
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
	
}
