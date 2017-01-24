//
//  MenuDockView.m
//  MenuDock
//
//  Created by CoreCode on 25.01.07.
/*	Copyright © 2017 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import "MenuDockView.h"

#define PREWIDTH 4
#define POSTWIDTH 5

@implementation MenuDockView

- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		[self updateSize];
		
		drag = FALSE;
		
		[self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
	}
	return self;
}

- (void)setStatusItem:(NSStatusItem *)si
{
	statusItem = si;
}

- (void)updateSize
{
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	NSArray *apps = [ws launchedApplications];
	const short width = (21*[apps count])-1 + PREWIDTH + POSTWIDTH;
	//	[statusItem setLength:width];
	[self setFrame:NSMakeRect(0,0,width,20)];
	[self setBounds:NSMakeRect(0,0,width,20)];
}

- (void)menuClicked:(id)sender
{
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	NSArray *apps = [ws launchedApplications];
	NSDictionary *dict = [apps objectAtIndex:(menuLocation.x - PREWIDTH) / 21];	
	ProcessSerialNumber psn = {	[[dict valueForKey:@"NSApplicationProcessSerialNumberHigh"] unsignedLongValue],
								[[dict valueForKey:@"NSApplicationProcessSerialNumberLow"] unsignedLongValue] };
	
	if ([[sender title] isEqualToString:@"Show in Finder"])
		[ws selectFile:[dict valueForKey:@"NSApplicationPath"] inFileViewerRootedAtPath:[[dict valueForKey:@"NSApplicationPath"] stringByDeletingLastPathComponent]];
	else if ([[sender title] isEqualToString:@"Hide"])
		ShowHideProcess(&psn, false);
	else if ([[sender title] isEqualToString:@"Force Quit"])	
		KillProcess(&psn);
	else if ([[sender title] isEqualToString:@"Quit"])	
	{
		AEAddressDesc	addressDesc;
		OSErr			err = AECreateDesc(typeProcessSerialNumber, &psn, sizeof(psn), &addressDesc);
		
		if (err == noErr)
		{
			AppleEvent quitAE;
			
			err = AECreateAppleEvent(kCoreEventClass, kAEQuitApplication, &addressDesc, kAutoGenerateReturnID, kAnyTransactionID, &quitAE);
			
			if (err == noErr)
			{
				AESendMessage(&quitAE, NULL, kAENoReply, kAEDefaultTimeout);
				AEDisposeDesc(&quitAE);
				AEDisposeDesc(&addressDesc);
			}
		}
	}
}

#pragma mark *** NSView subclass-methods ***

- (void)drawRect:(NSRect)rect
{
	unsigned int	 i;
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	NSArray *apps = [ws launchedApplications];
	const short width = (21 * [apps count]) - 1 + PREWIDTH + POSTWIDTH;
	NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(width,22)];
	
	[image lockFocus];
	[[NSColor lightGrayColor] set];
//	[NSBezierPath fillRect:rect];
	
	for (i = 0; i < [apps count]; i++)
	{
		NSImage *tmpImage = [ws iconForFile:[[apps objectAtIndex:i] valueForKey:@"NSApplicationPath"]];
		NSData *cocoaData = [NSBitmapImageRep TIFFRepresentationOfImageRepsInArray: [tmpImage representations]];
//		NSData *cocoaData = [tmpImage TIFFRepresentation]; // leaks either way
		
		CFDataRef carbonData = (CFDataRef)cocoaData;
		CGImageSourceRef imageSourceRef = CGImageSourceCreateWithData(carbonData, NULL);
		CGImageRef cgImage = CGImageSourceCreateImageAtIndex(imageSourceRef, 0, NULL);
		
		
		CGContextSetInterpolationQuality([[NSGraphicsContext currentContext] graphicsPort], kCGInterpolationHigh);
		
		if (drag && dragLocation.x >= i * 21 + PREWIDTH && dragLocation.x < i * 21 + PREWIDTH + 20)
			CGContextSetBlendMode ([[NSGraphicsContext currentContext] graphicsPort], kCGBlendModeMultiply);
		else
			CGContextSetBlendMode ([[NSGraphicsContext currentContext] graphicsPort], kCGBlendModeNormal);

		CGContextDrawImage([[NSGraphicsContext currentContext] graphicsPort], CGRectMake(i * 21 + PREWIDTH, 0, 20, 20), cgImage);
		//	CGContextFlush([[NSGraphicsContext currentContext] graphicsPort]);
		CGImageRelease(cgImage);
		//CFRelease(imageSourceRef);
		//	[cocoaData release];
	}
	[image unlockFocus];
	[image drawAtPoint:NSMakePoint(0,0) fromRect:NSMakeRect(0,0,width,20) operation:NSCompositeCopy fraction:1.0];
	
	[image release];
	//NSLog(NSStringFromRect(rect));
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
	menuLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];

	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	NSArray *apps = [ws launchedApplications];
	NSDictionary *dict = [apps objectAtIndex:(menuLocation.x - PREWIDTH) / 21];	
	
	if (menuLocation.x > PREWIDTH && ((menuLocation.x <= 21*[apps count])-1 + PREWIDTH))
	{
		NSMenu *menu = [[NSMenu alloc] initWithTitle:@"haha"];
		[menu addItem:[[[NSMenuItem alloc] initWithTitle:[dict valueForKey:@"NSApplicationName"] action:NULL keyEquivalent:@""] autorelease]];
		[menu addItem:[NSMenuItem separatorItem]];
		[menu addItem:[[[NSMenuItem alloc] initWithTitle:@"Show in Finder" action:@selector(menuClicked:) keyEquivalent:@""] autorelease]];
		[menu addItem:[[[NSMenuItem alloc] initWithTitle:@"Hide" action:@selector(menuClicked:) keyEquivalent:@""] autorelease]];
		[menu addItem:[[[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(menuClicked:) keyEquivalent:@""] autorelease]];
		[menu addItem:[[[NSMenuItem alloc] initWithTitle:@"Force Quit" action:@selector(menuClicked:) keyEquivalent:@""] autorelease]];
		
		[NSMenu popUpContextMenu:menu withEvent:theEvent forView:self];
		
		[menu release];
	}
}

- (void)mouseUp:(NSEvent *)event
{
	unsigned int x = [event locationInWindow].x;
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	NSArray *apps = [ws launchedApplications];
	NSDictionary *dict = [apps objectAtIndex:(x - PREWIDTH) / 21];	

	if (x > PREWIDTH && ((x <= 21*[apps count])-1 + PREWIDTH))
	{	
		if ([event modifierFlags] & NSCommandKeyMask)
			[ws	selectFile:[dict valueForKey:@"NSApplicationPath"]
				inFileViewerRootedAtPath:[[dict valueForKey:@"NSApplicationPath"] stringByDeletingLastPathComponent]];
		else
		{	
			if ([event modifierFlags] & NSAlternateKeyMask)
			{
				ProcessSerialNumber psn;
				GetFrontProcess (&psn);	
				ShowHideProcess(&psn, false);
			}
			
			[ws launchApplication:[dict valueForKey:@"NSApplicationPath"]];
		}
	}
}

#pragma mark *** NSDraggingDestination protocol-methods ***

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
	drag = TRUE;
	dragLocation = [sender draggingLocation];
	[self setNeedsDisplay:YES];
	
	return NSDragOperationGeneric;
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
	BOOL update = FALSE;
	
	if (([sender draggingLocation].x > PREWIDTH) && (dragLocation.x > PREWIDTH))
	{
		if (((unsigned short)([sender draggingLocation].x - PREWIDTH) / 21) != ((unsigned short)(dragLocation.x - PREWIDTH) / 21))
			update = TRUE;
	}
	else if (([sender draggingLocation].x <= PREWIDTH) && (dragLocation.x > PREWIDTH))
		update = TRUE;
	else if (([sender draggingLocation].x > PREWIDTH) && (dragLocation.x <= PREWIDTH))
		update = TRUE;
	
	dragLocation = [sender draggingLocation];
	
	if (update)
		[self setNeedsDisplay:YES];
	
	return NSDragOperationGeneric;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
	drag = FALSE;
	[self setNeedsDisplay:YES];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	NSPasteboard *pboard;
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	NSArray *apps = [ws launchedApplications];
	unsigned int x = [sender draggingLocation].x;
	
	drag = FALSE;
	[self setNeedsDisplay:YES];
	
	if (x > PREWIDTH && ((x <= 21*[apps count])-1 + PREWIDTH))
	{
		NSDictionary *dict = [apps objectAtIndex:(x - PREWIDTH) / 21];
		
		pboard = [sender draggingPasteboard];
		
		if ([[pboard types] containsObject:NSFilenamesPboardType])
		{
			NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
			NSEnumerator *e = [files objectEnumerator];
			NSString *file;
			
			while ((file = [e nextObject]))
				[[NSWorkspace sharedWorkspace] openFile:file withApplication:[dict valueForKey:@"NSApplicationPath"]];
		}
		return YES;
	}
	return NO;
}
@end
