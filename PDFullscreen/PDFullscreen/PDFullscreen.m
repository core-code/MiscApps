//
//  PDFullscreen.m
//  PDFullscreen
//
//  Created by CoreCode on 19.01.05.
/*	Copyright (c) 2016 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import "PDFullscreen.h"
#import <ApplicationServices/ApplicationServices.h>

#define METHOD 0

@implementation FullscreenWindow

- (BOOL)canBecomeKeyWindow
{
	return YES;
}
@end

@implementation PDFullscreen

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
	int windowLevel;
	NSRect screenRect;
	
	if (METHOD == 0)
	{
		// Capture the main display
		if (CGDisplayCapture(kCGDirectMainDisplay) != kCGErrorSuccess) // Note: you'll probably want to display a proper error dialog here
			NSLog(@"Couldn't capture the main display!");
			

		// Get the shielding window level
		windowLevel = CGShieldingWindowLevel();
		//windowLevel = NSMainMenuWindowLevel +1;
	}
	// Get the screen rect of our main display
	screenRect = [[NSScreen mainScreen] frame];
	// Put up a new window
	mainWindow = [[FullscreenWindow alloc] initWithContentRect:screenRect
													 styleMask:NSBorderlessWindowMask
													   backing:NSBackingStoreBuffered
														 defer:NO screen:[NSScreen mainScreen]];
	if (METHOD == 0)
		[mainWindow setLevel:windowLevel];
	[mainWindow setBackgroundColor:[NSColor blackColor]];
	
	pdfView = [[PDFullscreenView alloc] initWithFrame:[mainWindow frame]];
	[mainWindow setContentView:pdfView];
	[mainWindow setWindowController:self];
	
	// Creates a new CGPDFDocumentRef with a reference count of 1.
	CGPDFDocumentRef doc = CGPDFDocumentCreateWithURL((CFURLRef)[[NSURL alloc] initFileURLWithPath:filename]);

	
	[pdfView setPDFDocument:doc]; // Increments doc's reference count
	[pdfView setNeedsDisplay:YES];
	
	if (METHOD != 0)
		[NSMenu setMenuBarVisible:0];
	
	// Now we have to remove our reference, leaving the reference count at 1 again.
	// That way the document really goes away when it is released in PDFView's
	// -dealloc method.
	CGPDFDocumentRelease(doc);
	
	[mainWindow makeKeyAndOrderFront:nil];
	[NSApp activateIgnoringOtherApps:YES];
	
	return YES;
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	[mainWindow orderOut:self];
	
	if (METHOD != 0)
		[NSMenu setMenuBarVisible:1];
	else
	{
		// Release the display(s)
		if (CGDisplayRelease(kCGDirectMainDisplay) != kCGErrorSuccess)
		{
			NSLog(@"Couldn't release the display(s)!");
			// Note: if you display an error dialog here, make sure you set
			// its window level to the same one as the shield window level,
			// or the user won't see anything.
		}
	}
}
@end

int main(int argc, char *argv[])
{
	return NSApplicationMain(argc, (const char **) argv);
}