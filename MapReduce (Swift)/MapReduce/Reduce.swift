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

public func reduce<Source:DataSource, Result>
	(_ datasource: Source, initialResult: Result,
	 with baseValue: @escaping (Source.DataPoint) -> Result,
	 merge: @escaping (Result, Result) -> Result) -> Result {
	
	// STUB
	
	return initialResult
}
