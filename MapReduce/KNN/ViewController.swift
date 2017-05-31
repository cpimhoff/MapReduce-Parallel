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
	
	@IBOutlet weak var runParallelButton : NSButton!
	@IBOutlet weak var runBruteButton : NSButton!

	override func viewDidLoad() {
		ViewController.consoleTextBox = self.textBox
		self.textBox.string = ""
		self.progressIndicator.isDisplayedWhenStopped = false
	}
	
	@IBAction func runParallelKNN(_ sender: Any?) {
		runInAppConsole(sender, main_parallel(k:))
	}
	
	@IBAction func runBruteKNN(_ sender: Any?) {
		runInAppConsole(sender, main_brute(k:))
	}
	
	private func runInAppConsole(_ sender: Any?, _ block: @escaping (Int)->()) {
		clearAppConsole()
		
		if let k = Int(kField.stringValue), k > 0 {
			// disable UI
			progressIndicator.startAnimation(self)
			runParallelButton!.isEnabled = false
			runBruteButton!.isEnabled = false
			
			// dispatch KNN off UI thread
			DispatchQueue.global(qos: .userInitiated).async {
				block(k)
				
				// reenable UI after completion
				DispatchQueue.main.sync {
					self.progressIndicator.stopAnimation(self)
					self.runParallelButton!.isEnabled = true
					self.runBruteButton!.isEnabled = true
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
