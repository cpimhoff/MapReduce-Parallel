//
//  Map.swift
//  MapReduce
//
//  Created by Charlie Imhoff on 5/21/17.
//  Copyright © 2017 Charlie Imhoff. All rights reserved.
//

import Foundation

public func map<Source:DataSource, MappedPoint>(_ datasource: Source,
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
