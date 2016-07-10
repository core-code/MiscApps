//
//  DragDestinationView.swift
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

class DragDestinationView: NSView
{

	var highlighted = false
	var promisedURL : NSURL?


	required init?(coder: NSCoder)
	{
		super.init(coder: coder)

		self.registerForDraggedTypes([NSFilesPromisePboardType, NSFilenamesPboardType])
	}

    override func drawRect(dirtyRect: NSRect)
	{
        super.drawRect(dirtyRect)


		if (highlighted)
		{
			NSColor.selectedControlColor().set()
			NSBezierPath.strokeRect(bounds)
			NSBezierPath.strokeRect(NSInsetRect(bounds, 1, 1))
		}
    }

	override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation
	{
		let pb = sender.draggingPasteboard()
		let items = pb.pasteboardItems!
		let item = items[0] 
		let str = item.stringForType("com.apple.pasteboard.promised-file-content-type")
		var succ = str == "com.apple.mail.email";

        let files = pb.propertyListForType(NSFilenamesPboardType) as? [NSString]

        
        if files != nil
        {
			for file in files!
			{
				if file.pathExtension.lowercaseString == "eml"
				{
					succ = true
				}
			}
        }
        
		if (succ)
		{
			highlighted = true
			needsDisplay = true

		}
		
		return succ ? NSDragOperation.Copy : NSDragOperation.None;
	}

	override func draggingExited(sender: NSDraggingInfo?)
	{
		highlighted = false
		needsDisplay = true
	}

	override func concludeDragOperation(sender: NSDraggingInfo?)
	{
		highlighted = false
		needsDisplay = true

        if (sender!.draggingPasteboard().propertyListForType(NSFilenamesPboardType) != nil)
        {
            return // eml already imported direct file drag
        }
        
		if (promisedURL == nil)
		{
			var i = 0
			var done = false

			if (i < 50 && !done)
			{
				i += 1
				usleep(100000)
				let docstr = "~/Documents/" as NSString
				let docDir =  docstr.stringByExpandingTildeInPath as NSString
				let files = (try! NSFileManager.defaultManager().subpathsOfDirectoryAtPath(docDir as String )) 
				for file in files
				{
					let fullFile = docDir.stringByAppendingPathComponent(file)
					if fullFile.hasSuffix(".eml")
					{
						promisedURL = NSURL.fileURLWithPath(fullFile)
						Swift.print("Info: rebasing succeeded");
						done = true
						break;
					}
				}
			}
		}
		if (promisedURL == nil)
		{
			Swift.print("Error: rebasing failed");
			return;
		}

		var i = 0
		let promisedPath = promisedURL!.path!
		while (NSFileManager.defaultManager().fileExistsAtPath(promisedPath) != true)
		{
			i += 1
			usleep(100000)

			if (i > 50)
			{
				Swift.print("Error: timeout");
				return;
			}
		}

		let data = NSData(contentsOfURL: promisedURL!)
		let string = NSString(data: data!, encoding: NSUTF8StringEncoding)

		NSNotificationCenter.defaultCenter().postNotificationName("dropReceived", object: string)

		do
		{
			try NSFileManager.defaultManager().removeItemAtURL(promisedURL!)
		}
		catch _
		{
		}
	}


	override func prepareForDragOperation(sender: NSDraggingInfo) -> Bool
	{
		return draggingEntered(sender) == NSDragOperation.Copy
	}


	override func performDragOperation(sender: NSDraggingInfo) -> Bool
	{
		promisedURL = nil;
        
		let docstr = "~/Documents/" as NSString
		let urlBase = NSURL.fileURLWithPath(docstr.stringByExpandingTildeInPath)
		let pb = sender.draggingPasteboard()
		let items = pb.pasteboardItems!
		let item = items[0] 


        if let files = pb.propertyListForType(NSFilenamesPboardType) as? [NSString]
        {
            var foundEML = false

            for file in files
            {
                if file.pathExtension.lowercaseString == "eml"
                {
                    
                    let data = NSData(contentsOfFile: file as String)
                    let string = NSString(data: data!, encoding: NSUTF8StringEncoding)

                    NSNotificationCenter.defaultCenter().postNotificationName("dropReceived", object: string)
                    foundEML = true
                }
            }
            
            if foundEML == true
            {
                return true
            }
            else
            {
                return false
            }
        }


        if	let pl = item.propertyListForType("com.apple.mail.PasteboardTypeAutomator") as? NSArray,
			let dict = pl[0] as? NSDictionary,
			let sub = dict["subject"] as? String
        {
            if sub.utf16.count > 255
            {
                Swift.print("Error ignoring promise too long filename");
                
                let alert = NSAlert()
                alert.messageText = "Import Failed";
                alert.informativeText = "This e-mail can not be analyzed because the subject is longer than 255 characters. Let us know if you need support for this."
                alert.addButtonWithTitle("D'Oh")
                alert.runModal()
                
                return true;
            }
        }


		if	let files = sender.namesOfPromisedFilesDroppedAtDestination(urlBase),
			let file = files[0] as NSString?
		{

			Swift.print(file);
			if (!file.hasSuffix(".eml"))
			{
				Swift.print("Error ignoring promise");
				return true;
			}
		  
			// huh (lldb) po item.stringForType("com.apple.pasteboard.promised-file-url")

			promisedURL = urlBase.URLByAppendingPathComponent(file as String)
			return true
		}
		else
		{
			Swift.print("Error");
			return false;
		}
	}
}