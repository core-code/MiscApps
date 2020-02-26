//
//  DropViewController.swift
//  MailSpy
//
//  Created by CoreCode on 16.11.14.
/*	Copyright © 2018 CoreCode Limited
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

    @IBOutlet var adPanel: NSPanel!
    
    func userHasPaid() -> Bool {
        #if RECEIPTCODE
        let ov = JMReceiptOriginalVersion();
        
        let cr = ov?.compare("1.0.5", options: NSString.CompareOptions.numeric)
        
        if (cr == ComparisonResult.orderedAscending && !(ov == "1.0"))
        {
            return false;
        }
        else
        {
            return true;
        }
        #else
        #warning("building without promotion")
        return true;
        #endif
    }

    
    override func viewDidAppear() {
        
        let usages = UserDefaults.standard.integer(forKey: "usages")
        UserDefaults.standard.set(usages + 1, forKey: "usages")
        
        if (usages > 10 && usages % 3 == 0)
        {
            if (!self.userHasPaid()) {
             self.view.window!.beginSheet(adPanel)
            }
        }

    }

	override func viewDidLoad()
	{
		super.viewDidLoad()


        
		NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "dropReceived"), object: nil, queue: OperationQueue.main )
		{ not in


			//print("dropReceived", terminator: "")
            

            
			if (self.progresses == 0)
			{
				DispatchQueue.global().async
				{
					self.view.window!.beginProgress("Importing")
				}
			}
			self.progresses += 1

			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) 
			{

				let storyboard = NSStoryboard(name: "Main", bundle: nil)
				let wc = storyboard.instantiateController(withIdentifier: "detailWindowController") as! NSWindowController
				let resultViewController = wc.contentViewController as! ResultViewController
				resultViewController.emlString = not.object as! String
				self.controllers.append(wc)
				let index = self.controllers.count




				if Host(name: "www.google.com").address != nil
				{
					DispatchQueue.main.async
					{

						wc.showWindow(nil)
						NSApp.activate(ignoringOtherApps: true)
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
					DispatchQueue.main.async
					{
						self.view.window!.endProgress()
						let alert = NSAlert()
						alert.messageText = "Network Offline";
						alert.informativeText = "You need an active internet connection to analyze mails and display their origin location in the map."
						alert.addButton(withTitle: "D'Oh")
						alert.runModal()
					}
				}
			}
		}
	}
    @IBAction func closeAd(_ sender: Any) {
        self.view.window!.endSheet(adPanel)
        adPanel.orderOut(self)
        
    }
}

