//
//  DesktopWindow.m
//  DesktopLyrics
//
//  Created by CoreCode on 26.09.06.
/*	Copyright (c) 2006 - 2012 CoreCode
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import "DesktopWindow.h"



@implementation DesktopWindow

#pragma mark *** NSWindow subclass-methods ***

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)windowStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation
{
	self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];

	return self;
}

#pragma mark *** NSNibAwaking protocol-methods ***

- (void)awakeFromNib
{
	NSClipView		*clipView;
	NSScrollView 	*scrollView;

	[self setBackgroundColor: [NSColor clearColor]];
	[self setOpaque:NO];
	[self setCanHide:NO];
	[self setAlphaValue:1.0];

	if (![self hasShadow]) // this is a bit hacky we set shadow only for the lyrics window, because the button window wants clicks
	{
		[self setIgnoresMouseEvents:YES];
//		ChangeWindowAttributes([self windowRef], kWindowIgnoreClicksAttribute, kWindowNoAttributes); // these are disabled because they don't exist in 64 bit, but they don't seem to be needed anyway!? not even the cocoa call
//		int setAttr[] = { kHIWindowBitIgnoreClicks, 0 };
//		HIWindowChangeAttributes([self windowRef], setAttr, NULL);
	}
	else
	{
		[nextButton setBordered:YES];
		[prefButton setBordered:YES];
	}
	[self setHasShadow:NO];

	clipView = (NSClipView *)[outputArea superview];
	[clipView setDrawsBackground:NO];
	[clipView setCopiesOnScroll:NO];

	scrollView = (NSScrollView *)[clipView superview];
	[scrollView setDrawsBackground:NO];
	[scrollView setBorderType:NSNoBorder];
	[scrollView setHasVerticalScroller:NO];

	[outputArea setDrawsBackground:NO];
}
@end
