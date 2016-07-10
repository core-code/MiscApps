//
//  DocumentationViewController.swift
//  MailSpy
//
//  Created by CoreCode on 13.01.15.
/*	Copyright (c) 2016 CoreCode
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

import Cocoa
import WebKit

class DocumentationViewController : NSViewController
{
	dynamic var aboutURL : NSURL?
	dynamic var versionhistoryURL : NSURL?
	dynamic var faqURL : NSURL?
	dynamic var readmeURL : NSURL?
	dynamic var build : String = ""
	dynamic var version : String = ""

	@IBOutlet weak var webView: WebView!

	override func viewDidLoad()
	{
		super.viewDidLoad()

		self.build = "Build: \(cc.appBuild)"
		self.version = "Version: \(cc.appVersionString)"


		self.aboutURL = NSBundle.mainBundle().URLForResource("Credits.rtfd", withExtension: nil)
		self.versionhistoryURL = NSBundle.mainBundle().URLForResource("History.rtf", withExtension: nil)
		self.faqURL = NSBundle.mainBundle().URLForResource("FAQ.rtf", withExtension: nil)
		self.readmeURL = NSBundle.mainBundle().URLForResource("Read Me.rtf", withExtension: nil)


		self.webView.mainFrame.loadRequest(NSURLRequest(URL: NSURL(string: "https://www.corecode.at/promotion/promotion.html")!))
	}

	@IBAction func openURL(sender: AnyObject)
	{
		let first = sender.valueForKey("tag")?.intValue as Int32!

		cc.openURL(first)
	}

	func webView(sender: WebView!, resource identifier: AnyObject!, didFinishLoadingFromDataSource dataSource: WebDataSource!)
	{

		self.webView.stringByEvaluatingJavaScriptFromString("document.documentElement.style.zoom = \"0.5875\"")
	}

	func webView(webView: WebView!, decidePolicyForNavigationAction actionInformation: [NSObject : AnyObject]!, request: NSURLRequest!, frame: WebFrame!, decisionListener listener: WebPolicyDecisionListener!)
	{
		if request.URL!.absoluteString == "https://www.corecode.at/promotion/promotion.html"
		{
			listener.use()
		}
		else
		{
			NSWorkspace.sharedWorkspace().openURL(request.URL!)

			listener.ignore()
		}
	}
}
