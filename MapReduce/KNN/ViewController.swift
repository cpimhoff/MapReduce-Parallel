//
//  ViewController.swift
//  KNN
//

import Cocoa

class ViewController: NSViewController {

	static var consoleTextBox : NSTextView!
	
	@IBOutlet weak var textBox : NSTextView!
	@IBOutlet weak var kField : NSTextField!
	@IBOutlet weak var progressIndicator : NSProgressIndicator!

	override func viewDidLoad() {
		ViewController.consoleTextBox = self.textBox
		self.textBox.string = ""
		self.progressIndicator.isDisplayedWhenStopped = false
	}
	
	@IBAction func runKNN(_ sender: Any?) {
		clearAppConsole()
		
		if let k = Int(kField.stringValue), k > 0 {
		
			progressIndicator.startAnimation(self)
			(sender as? NSButton)!.isEnabled = false
			
			DispatchQueue.global(qos: .userInitiated).async {
				main(k: k)
				
				DispatchQueue.main.sync {
					self.progressIndicator.stopAnimation(self)
					(sender as? NSButton)!.isEnabled = true
				}
			}
		} else {
			printToAppConsole("K must be a positive Integer")
		}
	}
	
}

func clearAppConsole() {
	if Thread.isMainThread {
		ViewController.consoleTextBox.string = ""
	} else {
		DispatchQueue.main.sync {
			ViewController.consoleTextBox.string = ""
		}
	}
}

func printToAppConsole(_ obj: Any) {
	let description = String(describing: obj)
	
	if Thread.isMainThread {
		ViewController.consoleTextBox.string! += (description + "\n")
	} else {
		DispatchQueue.main.sync {
			ViewController.consoleTextBox.string! += (description + "\n")
		}
	}
}
