//
//  ViewController.swift
//  KNN
//

import Cocoa

class ViewController: NSViewController {

	static var consoleTextBox : NSTextField!
	
	@IBOutlet weak var textBox : NSTextField!
	@IBOutlet weak var kField : NSTextField!
	@IBOutlet weak var progressIndicator : NSProgressIndicator!

	override func viewDidLoad() {
		self.progressIndicator.isHidden = true
		ViewController.consoleTextBox = self.textBox
	}
	
	@IBAction func runKNN(_ sender: Any?) {
		clearAppConsole()
		
		if let k = Int(kField.stringValue), k > 0 {
			
			progressIndicator.isHidden = false
			progressIndicator.startAnimation(self)
			(sender as? NSButton)!.isEnabled = false
			
			DispatchQueue.global(qos: .userInitiated).async {
				main(k: k)
				
				DispatchQueue.main.sync {
					self.progressIndicator.isHidden = true
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
		ViewController.consoleTextBox.stringValue = ""
	} else {
		DispatchQueue.main.sync {
			ViewController.consoleTextBox.stringValue = ""
		}
	}
}

func printToAppConsole(_ obj: Any) {
	let description = String(describing: obj)
	
	if Thread.isMainThread {
		ViewController.consoleTextBox.stringValue += (description + "\n")
	} else {
		DispatchQueue.main.sync {
			ViewController.consoleTextBox.stringValue += (description + "\n")
		}
	}
}
