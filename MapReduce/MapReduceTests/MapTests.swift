//
//  MapTests.swift
//  MapReduceTests
//

import XCTest
import MapReduce

private let artificialWorkTime : TimeInterval = 0.000001
private let datasetSize : Int = 100_000

class MapTests: XCTestCase {
	
	var data : [Int] = {
		var d = [Int]()
		for i in 0..<datasetSize {
			d.append(i)
		}
		return d
	}()

	func testBruteMap() {
		// performance is roughly = (workTime * datasetSize)
		self.measure {
			let _ = self.data.map {	// built in `map` implementation is synchronous
				x -> String in
				Thread.sleep(forTimeInterval: artificialWorkTime)
				return "\(x)"
			}
		}
	}
	
    func testParallelMap() {
		var results : [String]!
		var expected : [String]!

		// performance is roughly = workTime * (datasetSize / max_threads)
		self.measure {
			results = self.data.parallelMap {
				x in
				Thread.sleep(forTimeInterval: artificialWorkTime)
				return "\(x)"
			}
		}
	
		// accuracy assurance
		expected = self.data.map { x in "\(x)" }
		
		XCTAssertEqual(results, expected)
	}
	
	func testConcurrentMap() {
		var results : [String]!
		var expected : [String]!
		
		// performance is roughly = workTime * (datasetSize / max_threads)
		self.measure {
			results = self.data.concurrentMap {
				x in
				Thread.sleep(forTimeInterval: artificialWorkTime)
				return "\(x)"
			}
		}
		
		// accuracy assurance
		expected = self.data.map { x in "\(x)" }
		
		XCTAssertEqual(results, expected)
	}
	
	func testParallelMapChunked() {
		var results : [String]!
		var expected : [String]!
		
		// performance is roughly = workTime * (datasetSize / max_threads)
		self.measure {
			results = self.data.parallelMapChunked {
				x in
				Thread.sleep(forTimeInterval: artificialWorkTime)
				return "\(x)"
			}
		}
		
		// accuracy assurance
		expected = self.data.map { x in "\(x)" }
		
		XCTAssertEqual(results, expected)
	}
    
}
