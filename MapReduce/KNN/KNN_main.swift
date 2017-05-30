//
//  KNN_main.swift
//  MapReduce
//
//  Created by Charlie Imhoff on 5/28/17.
//  Copyright © 2017 Charlie Imhoff. All rights reserved.
//

import Foundation
import MapReduce

func main(k: Int) {
	printToAppConsole("Hello World! \(k)")
	
	// here's how to initialize the bundled datasets
	let test = Dataset.init(.test)
	let train = Dataset.init(.training)
}
