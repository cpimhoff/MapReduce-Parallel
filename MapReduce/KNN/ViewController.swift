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
		let k = Int(kField.stringValue)!
		main(k: k)
	}
	
}

func printToAppConsole(_ text: String) {
	ViewController.consoleTextBox.stringValue += (text + "\n")
}
