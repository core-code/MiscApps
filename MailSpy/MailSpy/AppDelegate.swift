//
//  AppDelegate.swift
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
import MapKit

//FIXME: https://www.spamcop.net
//TODO: https://www.spamcop.net

@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate
{


	func applicationDidFinishLaunching(aNotification: NSNotification)
	{
		cc = CoreLib()


		let libstr : NSString = "~/Library/"
		let docstr : NSString = "~/Documents/"

		assert(libstr.stringByExpandingTildeInPath.rangeOfString("/Library/Containers/") != nil)

		let docDir : NSString = docstr.stringByExpandingTildeInPath
		let files = (try! NSFileManager.defaultManager().subpathsOfDirectoryAtPath(docDir as String)) 
		for file in files
		{
			let fullFile = docDir.stringByAppendingPathComponent(file)
			if fullFile.hasSuffix(".eml")
			{
				do {
					try NSFileManager.defaultManager().removeItemAtPath(fullFile)
				} catch _ {
				}
			}
		}

//        var bla = IPGeoLocation("208.80.152.201")
//        var bla = IPGeoLocation("127.0.0.1")
//        let mailDir = "~/Library/Mail/V2/".stringByExpandingTildeInPath as String
//        let mails = NSFileManager.defaultManager().subpathsOfDirectoryAtPath(mailDir , error: nil)! as [String]
//        for file in mails
//        {
//            let fullFile = mailDir.stringByAppendingPathComponent(file)
//            if fullFile.hasSuffix(".eml") || fullFile.hasSuffix(".emlx")
//            {
//                //println(fullFile)
//                
//                let data = NSData(contentsOfFile: fullFile)
//                let emlString = NSString(data: data!, encoding: NSASCIIStringEncoding)!
//            }
//        }
	}

    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool
	{
        return true;
    }

	@IBAction func openURL(sender: AnyObject)
	{
		let first = sender.valueForKey("tag")?.intValue as Int32!

		cc.openURL(first)
	}
}

