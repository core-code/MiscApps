//
//  DragDestinationView.m
//  FilenameList
//
//  Created by CoreCode on 17.06.14.
/*	Copyright (c) 2016 CoreCode Limited
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */


#import "DragDestinationView.h"


@interface DragDestinationView ()

@property (assign, nonatomic) BOOL highlighted;

@end




@implementation DragDestinationView

- (instancetype)initWithFrame:(NSRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		[self registerForDraggedTypes:@[NSFilenamesPboardType]];
	}

	return self;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
	NSPasteboard *pb = [sender draggingPasteboard];
	NSString *type = [pb availableTypeFromArray:@[NSFilenamesPboardType]];

	if (type != nil)
	{
		_highlighted = YES;
		[self setNeedsDisplay:YES];
		return NSDragOperationCopy;
	}
	else
		return NSDragOperationNone;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
	_highlighted = NO;
	[self setNeedsDisplay:YES];
}

- (BOOL)prepareForDragOperation:(id)sender
{
	return YES;
}

- (BOOL)performDragOperation:(id)sender
{
	NSPasteboard *pboard = [sender draggingPasteboard];

	if (![[pboard types] containsObject:NSURLPboardType])
		return NO;

	NSURL *file = [NSURL URLFromPasteboard:pboard];

	_destinationPathControl.URL = file;

	[_destinationPathControl.target performSelector:_destinationPathControl.action
										 withObject:_destinationPathControl];

	return YES;
}

- (void)concludeDragOperation:(id )sender
{
	_highlighted = NO;
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
	NSRect bounds = [self bounds];

	if (_highlighted)
	{
		[[NSColor selectedControlColor] set];
		[NSBezierPath strokeRect:bounds];
		[NSBezierPath strokeRect:NSInsetRect(bounds,1.0,1.0)];
	}
}
@end
