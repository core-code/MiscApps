//
//  AppDelegate.swift
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
import MapKit

//FIXME: https://www.spamcop.net
//TODO: https://www.spamcop.net
//TODO: "copy all the hops listed in the pop-up"

@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate
{
    func applicationWillFinishLaunching(_ notification: Notification) {
        cc = CoreLib()

    }

	func applicationDidFinishLaunching(_ aNotification: Notification)
	{


		let docstr : NSString = "~/Documents/"
		let docDir : NSString = docstr.expandingTildeInPath as NSString
		let files = (try! FileManager.default.subpathsOfDirectory(atPath: docDir as String)) 
		for file in files
		{
			let fullFile = docDir.appendingPathComponent(file)
			if fullFile.hasSuffix(".eml")
			{
				do {
					try FileManager.default.removeItem(atPath: fullFile)
				} catch _ {
				}
			}
		}

//        var bla = IPGeoLocation("208.80.152.201")
//        var bla = IPGeoLocation("127.0.0.1")
        

        
//        let mailDir = NSString(string: "~/Documents/EMLX/").expandingTildeInPath
//        let mailDirURL = URL(fileURLWithPath: mailDir)
//        do
//        {
//
//            let mails = try FileManager.default.subpathsOfDirectory(atPath: mailDir) as [String]
//            
//            
//            for file in mails
//            {
//                if file.hasSuffix(".eml") || file.hasSuffix(".emlx")
//                {
//                    let fullFile = mailDirURL.appendingPathComponent(file)
//
//                    print(fullFile)
//                    
//                    let data = NSData(contentsOf: fullFile)
//                    let string = NSString(data: data! as Data, encoding: String.Encoding.utf8.rawValue)
//                    
//                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dropReceived"), object: string)
//                    
//                }
//            }
//        }
//        catch {
//            print("error getting xml string: \(error)")
//        }
        
	}
   

    func application(_ sender: NSApplication, openFiles filenames: [String])
    {
        for file in filenames
        {
            let data = NSData(contentsOfFile: file as String)
            var string: NSString? = nil
            var lossyConversion: ObjCBool = false
            
            let _ = NSString.stringEncoding(for: data! as Data, encodingOptions: nil, convertedString: &string, usedLossyConversion: &lossyConversion)
            
            
            
            if (string != nil && (string?.length)! > 0)
            {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dropReceived"), object: string)
            }
            else
            {
                Swift.print("Error: could not decode \(file)")
            }
        }
    }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool
	{
        return true;
    }

	@IBAction func openURL(_ sender: AnyObject)
	{
		let first = (sender.value(forKey:"tag") as AnyObject).intValue as Int32

		cc.openURL(first)
	}
}

