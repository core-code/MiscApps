//
//  DocumentationViewController.swift
//  MailSpy
//
//  Created by CoreCode on 13.01.15.
/*	Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

import Cocoa
import WebKit

class DocumentationViewController : NSViewController
{
	@objc dynamic var aboutURL : NSURL?
	@objc dynamic var versionhistoryURL : NSURL?
	@objc dynamic var faqURL : NSURL?
	@objc dynamic var readmeURL : NSURL?
	@objc dynamic var build : String = ""
	@objc dynamic var version : String = ""

	@IBOutlet weak var webView: WebView!

	override func viewDidLoad()
	{
		super.viewDidLoad()


		self.build = "Build: \(cc.appBuild)"
		self.version = "Version: \(cc.appVersionString!)"


		self.aboutURL = Bundle.main.url(forResource: "Credits.rtfd", withExtension: nil) as NSURL?
		self.versionhistoryURL = Bundle.main.url(forResource: "History.rtf", withExtension: nil) as NSURL?
		self.faqURL = Bundle.main.url(forResource: "FAQ.rtf", withExtension: nil) as NSURL?
		self.readmeURL = Bundle.main.url(forResource: "Read Me.rtf", withExtension: nil) as NSURL?


		self.webView.mainFrame.load(NSURLRequest(url: NSURL(string: "https://www.corecode.io/promotion/promotion.html?app=com.corecode.MailSpy")! as URL) as URLRequest)
	}

	@IBAction func openURL(_ sender: AnyObject)
	{
		let first = (sender.value(forKey:"tag") as AnyObject).intValue as Int32

		cc.openURL(first)
	}

	func webView(_ sender: WebView!, resource identifier: AnyObject!, didFinishLoadingFromDataSource dataSource: WebDataSource!)
	{

		self.webView.stringByEvaluatingJavaScript(from: "document.documentElement.style.zoom = \"0.5875\"")
	}

	func webView(_ webView: WebView!, decidePolicyForNavigationAction actionInformation: [NSObject : AnyObject]!, request: NSURLRequest!, frame: WebFrame!, decisionListener listener: WebPolicyDecisionListener!)
	{
		if request.url!.absoluteString.hasPrefix("https://www.corecode.io/promotion/promotion.html")
		{
			listener.use()
		}
		else
		{
			NSWorkspace.shared.open(request.url!)

			listener.ignore()
		}
	}
}
