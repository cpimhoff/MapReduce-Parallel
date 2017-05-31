//
//  SynchronizedArray.swift
//  MapReduce
//

import Foundation

/// Thread safe box over a standard Swift array.
///
/// Adapted (and expanded upon) from:
/// https://stackoverflow.com/a/28191539/3777491
internal class SynchronizedArray<T> : ExpressibleByArrayLiteral {
	
	private var _array: [T]
	private let accessQueue = DispatchQueue(label: "SynchronizedArrayAccess", attributes: .concurrent)
	
	public var array : [T] {
		get {
			return self.accessQueue.sync {
				return self._array
			}
		}
	}
	
	init(_ elements: [T]) {
		self._array = elements
	}
	
	init(repeating value: T, count: Int) {
		self._array = Array<T>.init(repeating: value, count: count)
	}
	
	public required init(arrayLiteral elements: T...) {
		self._array = elements
	}
	
	public func append(newElement: T) {
		self.accessQueue.async(flags:.barrier) {
			self._array.append(newElement)
		}
	}
	
	public func removeAtIndex(index: Int) {
		
		self.accessQueue.async(flags:.barrier) {
			self._array.remove(at: index)
		}
	}
	
	public var count: Int {
		var count = 0
		
		self.accessQueue.sync {
			count = self._array.count
		}
		
		return count
	}
	
	public func first() -> T? {
		var element: T?
		
		self.accessQueue.sync {
			if !self._array.isEmpty {
				element = self._array[0]
			}
		}
		
		return element
	}
	
	public subscript(index: Int) -> T {
		set {
			self.accessQueue.async(flags:.barrier) {
				self._array[index] = newValue
			}
		}
		get {
			return self.accessQueue.sync {
				return self._array[index]
			}
		}
	}
	
}
