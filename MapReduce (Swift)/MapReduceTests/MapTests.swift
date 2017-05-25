//
//  MapTests.swift
//  MapTests
//
//  Created by Charlie Imhoff on 5/21/17.
//  Copyright © 2017 Charlie Imhoff. All rights reserved.
//

import XCTest
import MapReduce

private let artificialWorkTime : TimeInterval = 0.001
private let datasetSize : Int = 1_000

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
	
    func testMap() {
		var results : [String]?
		var expected : [String]?

		// performance is roughly = workTime * (datasetSize / max_threads)
		self.measure {
			results = map(self.data) {
				x in
				Thread.sleep(forTimeInterval: artificialWorkTime)
				return "\(x)"
			}
		}
	
		// accuracy assurance
		expected = self.data.map { x in "\(x)" }
		
		XCTAssertEqual(results!, expected!)
	}
    
}
