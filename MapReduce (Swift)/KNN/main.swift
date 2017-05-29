//
//  main.swift
//  KNN
//
//  Created by Charlie Imhoff on 5/28/17.
//  Copyright © 2017 Charlie Imhoff. All rights reserved.
//

import Foundation
import MapReduce

print("Hello, World!")
let data = [1,2,3]

let result = map(data) { (point) -> String in
	return "hello \(point)"
}
print(result)
