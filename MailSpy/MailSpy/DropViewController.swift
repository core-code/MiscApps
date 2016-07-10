//
//  DropViewController.swift
//  MailSpy
//
//  Created by CoreCode on 16.11.14.
/*	Copyright (c) 2016 CoreCode
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

import Cocoa

class DropViewController: NSViewController
{

	var controllers : Array<NSWindowController> = []
	var progresses : Int = 0


	override func viewDidLoad()
	{
		super.viewDidLoad()


		NSNotificationCenter.defaultCenter().addObserverForName("dropReceived", object: nil, queue: NSOperationQueue.mainQueue() )
		{ not in


			print("dropReceived", terminator: "")

			if (self.progresses == 0)
			{
				dispatch_async(dispatch_get_global_queue(0, 0))
				{
					self.view.window!.beginProgress("Importing")
				}
			}
			self.progresses += 1

			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue())
			{

				let storyboard = NSStoryboard(name: "Main", bundle: nil)
				let wc = storyboard.instantiateControllerWithIdentifier("detailWindowController") as! NSWindowController
				let resultViewController = wc.contentViewController as! ResultViewController
				resultViewController.emlString = not.object as! String
				self.controllers.append(wc)
				let index = self.controllers.count




				if NSHost(name: "www.google.com").address != nil
				{
					dispatch_async(dispatch_get_main_queue())
					{

						wc.showWindow(nil)
						NSApp.activateIgnoringOtherApps(true)
						wc.window?.setFrameOrigin(CGPoint(x:Int(wc.window!.frame.origin.x) + index * 30, y:Int(wc.window!.frame.origin.y) + index * -30))
						wc.window?.makeKeyAndOrderFront(nil)

						self.progresses -= 1

						if (self.progresses == 0)
						{
							self.view.window!.endProgress()
						}
					}
				}
				else
				{
					dispatch_async(dispatch_get_main_queue())
					{
						self.view.window!.endProgress()
						let alert = NSAlert()
						alert.messageText = "Network Offline";
						alert.informativeText = "You need an active internet connection to analyze mails and display their origin location in the map."
						alert.addButtonWithTitle("D'Oh")
						alert.runModal()
					}
				}
			}
		}
	}
}

