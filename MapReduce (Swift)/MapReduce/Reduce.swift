//
//  Reduce.swift
//  MapReduce
//
//  Created by Charlie Imhoff on 5/21/17.
//  Copyright © 2017 Charlie Imhoff. All rights reserved.
//

import Foundation

public func reduce<Source:DataSource, Result>
	(_ datasource: Source, initialResult: Result,
	 with baseValue: @escaping (Source.DataPoint) -> Result,
	 merge: @escaping (Result, Result) -> Result) -> Result {
	
	// STUB
	
	return initialResult
}
