//
//  ReduceTests.swift
//  MapReduceTests
//

import XCTest
import MapReduce

private let artificialWorkTime : TimeInterval = 0.01
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
	
	func testParallelReduce() {
		var result : Int!
		var expected : Int!
		
		// performance is roughly = ...
		self.measure {
			result = self.data.parallelReduce {
				x, y in
				Thread.sleep(forTimeInterval: artificialWorkTime)
				return x + y
			}
		}
		
		// accuracy assurance
		expected = self.data.reduce(0) {
			sum, next in
			Thread.sleep(forTimeInterval: artificialWorkTime)
			return sum + next
		}
		
		XCTAssertEqual(result, expected)
	}
	
}
