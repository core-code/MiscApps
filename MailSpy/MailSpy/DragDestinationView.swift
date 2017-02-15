//
//  DragDestinationView.swift
//  MailSpy
//
//  Created by CoreCode on 16.11.14.
/*	Copyright © 2017 CoreCode Limited
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

		self.register(forDraggedTypes: [NSFilesPromisePboardType, NSFilenamesPboardType])
	}

    override func draw(_ dirtyRect: NSRect)
	{
        super.draw(dirtyRect)


		if (highlighted)
		{
			NSColor.selectedControlColor.set()
			NSBezierPath.stroke(bounds)
			NSBezierPath.stroke(NSInsetRect(bounds, 1, 1))
		}
    }

	override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation
	{
		let pb = sender.draggingPasteboard()
		let items = pb.pasteboardItems!
		let item = items[0] 
		let str = item.string(forType: "com.apple.pasteboard.promised-file-content-type")
		var succ = str == "com.apple.mail.email";

        let files = pb.propertyList(forType: NSFilenamesPboardType) as? [NSString]

        
        if files != nil
        {
			for file in files!
			{
				if file.pathExtension.lowercased() == "eml" || file.pathExtension.lowercased() == "emlx"
				{
					succ = true
                    break;
				}
			}
        }
        
		if (succ)
		{
			highlighted = true
			needsDisplay = true

		}
		
		if succ
		{
			return NSDragOperation.copy
		}
		else
		{
			return [];
		}
	}

	override func draggingExited(_ sender: NSDraggingInfo?)
	{
		highlighted = false
		needsDisplay = true
	}

	override func concludeDragOperation(_ sender: NSDraggingInfo?)
	{
		highlighted = false
		needsDisplay = true

        if (sender!.draggingPasteboard().propertyList(forType: NSFilenamesPboardType) != nil)
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
				let docDir =  docstr.expandingTildeInPath as NSString
				let files = (try! FileManager.default.subpathsOfDirectory(atPath: docDir as String )) 
				for file in files
				{
					let fullFile = docDir.appendingPathComponent(file)
					if fullFile.hasSuffix(".eml") || fullFile.hasSuffix(".emlx")
					{
						promisedURL = NSURL.fileURL(withPath: fullFile) as NSURL?
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
		while (FileManager.default.fileExists(atPath: promisedPath) != true)
		{
			i += 1
			usleep(100000)

			if (i > 50)
			{
				Swift.print("Error: timeout");
				return;
			}
		}

		let data = NSData(contentsOf: promisedURL! as URL)
		let string = NSString(data: data! as Data, encoding: String.Encoding.utf8.rawValue)

		NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dropReceived"), object: string)

		do
		{
			try FileManager.default.removeItem(at: promisedURL! as URL)
		}
		catch _
		{
		}
	}


	override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool
	{
		return draggingEntered(sender) == NSDragOperation.copy
	}


	override func performDragOperation(_ sender: NSDraggingInfo) -> Bool
	{
		promisedURL = nil;
        
		let docstr = "~/Documents/" as NSString
		let urlBase = NSURL.fileURL(withPath: docstr.expandingTildeInPath)
		let pb = sender.draggingPasteboard()
		let items = pb.pasteboardItems!
		let item = items[0] 


        if let files = pb.propertyList(forType: NSFilenamesPboardType) as? [NSString]
        {
            var foundEML = false

            for file in files
            {
                if file.pathExtension.lowercased() == "eml" || file.pathExtension.lowercased() == "emlx"
                {
             
                    let data = NSData(contentsOfFile: file as String)
                    var string: NSString? = nil
                    var lossyConversion: ObjCBool = false

                    let _ = NSString.stringEncoding(for: data as! Data, encodingOptions: nil, convertedString: &string, usedLossyConversion: &lossyConversion)
                    
                    
                    
                    if (string != nil && (string?.length)! > 0)
                    {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dropReceived"), object: string)
                        foundEML = true
                    }
                    else
                    {
                        Swift.print("Error: could not decode \(file)")
                    }
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


        if	let pl = item.propertyList(forType: "com.apple.mail.PasteboardTypeAutomator") as? NSArray,
			let dict = pl[0] as? NSDictionary,
			let sub = dict["subject"] as? String
        {
            if sub.utf16.count > 255
            {
                Swift.print("Error: ignoring promise too long filename");
                
                let alert = NSAlert()
                alert.messageText = "Import Failed";
                alert.informativeText = "This e-mail can not be analyzed because the subject is longer than 255 characters. Let us know if you need support for this."
                alert.addButton(withTitle: "D'Oh")
                alert.runModal()
                
                return true;
            }
        }


		if	let files = sender.namesOfPromisedFilesDropped(atDestination: urlBase),
			let file = files[0] as NSString?
		{

			Swift.print(file);
			if (!file.hasSuffix(".eml"))
			{
				Swift.print("Error: suffix file \(file)");
				return true;
			}
		  
			// huh (lldb) po item.stringForType("com.apple.pasteboard.promised-file-url")

			promisedURL = urlBase.appendingPathComponent(file as String) as NSURL?
			return true
		}
		else
		{
			Swift.print("Error: namesOfPromisedFilesDropped");
			return false;
		}
	}
}
