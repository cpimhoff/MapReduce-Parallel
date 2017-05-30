//
//  ViewController.swift
//  KNN
//
//  Created by Charlie Imhoff on 5/28/17.
//  Copyright © 2017 Charlie Imhoff. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

	static var consoleTextBox : NSTextField!
	
	@IBOutlet weak var textBox : NSTextField!
	@IBOutlet weak var kField : NSTextField!

	override func viewDidLoad() {
		ViewController.consoleTextBox = self.textBox
	}
	
	@IBAction func runKNN(_ sender: Any?) {
		clearAppConsole()
		
		if let k = Int(kField.stringValue), k > 0 {
			main(k: k)
		} else {
			printToAppConsole("K must be a positive Integer")
		}
	}
	
}

func clearAppConsole() {
	ViewController.consoleTextBox.stringValue = ""
}

func printToAppConsole(_ obj: Any) {
	let description = String(describing: obj)
	ViewController.consoleTextBox.stringValue += (description + "\n")
}
