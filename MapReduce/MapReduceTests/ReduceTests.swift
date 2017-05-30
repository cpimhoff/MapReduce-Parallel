//
//  ReduceTests.swift
//  MapReduce
//
//  Created by Charlie Imhoff on 5/24/17.
//  Copyright © 2017 Charlie Imhoff. All rights reserved.
//

import XCTest
import MapReduce

private let artificialWorkTime : TimeInterval = 0.1
private let datasetSize : Int = 10

class ReduceTests: XCTestCase {
	
	var data : [Int] = {
		var d = [Int]()
		for i in 0..<datasetSize {
			d.append(i)
		}
		return d
	}()
	
	func testBruteReduce() {
		// performance is roughly = (workTime * datasetSize)
		self.measure {
			let _ = self.data.reduce(0) {	// built in `reduce` implementation is synchronous
				sum, next -> Int in
				Thread.sleep(forTimeInterval: artificialWorkTime)
				return sum + next
			}
		}
	}
	
	func testReduce() {
		var result : Float?
		var expected : Float?
		
		let baseValuation = {
			(val:Int) -> Float in
			return Float(val)
		}
		let add = {
			(a:Float, b:Float) -> Float in
			Thread.sleep(forTimeInterval: artificialWorkTime)
			return a + b
		}
		
		// performance is roughly = ...
		self.measure {
			result = reduce(self.data, baseValue: baseValuation, merge: add)
		}
		
		// accuracy assurance
		expected = self.data.reduce(0) {
			sum, next in
			return add(sum, baseValuation(next))
		}
		
		XCTAssertEqual(result!, expected!)
	}
	
}
