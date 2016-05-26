//
//  MyTextField.m
//  iRipCD
//
//  Created by CoreCode on Son Aug 19 2002.
/*	Copyright (c) 2002 - 2003 CoreCode
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import "MyTextField.h"
#import "iRipCD.h"

@implementation MyTextField

- (void)awakeFromNib
{
	[self registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
}

- (void)setMaster:(id)newmaster
{
	master = newmaster;
}

#pragma mark *** NSDraggingDestination protocol-methods ***

- (unsigned int)draggingEntered:(id <NSDraggingInfo>)sender
{
	if ([sender draggingSource] != self)
	{
		NSColor *aColor = [NSColor lightGrayColor];
		NSPasteboard *pb = [sender draggingPasteboard];
		NSString *type = [pb availableTypeFromArray:[NSArray arrayWithObject:NSFilenamesPboardType]];

		if (type != nil)
		{
			[self setBackgroundColor:aColor];
			[self setEditable:NO];
			[self setNeedsDisplay:YES];
			return NSDragOperationGeneric;
		}
	}
	return NSDragOperationNone;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
	NSColor *aColor = [NSColor whiteColor];

	[self setEditable:YES];
	[self setBackgroundColor:aColor];
	[self setNeedsDisplay:YES];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	NSPasteboard *pb = [sender draggingPasteboard];
	NSColor *aColor = [NSColor whiteColor];
	NSString *type = [pb availableTypeFromArray:[NSArray arrayWithObject:NSFilenamesPboardType]];
	NSArray *array = [[pb stringForType:type] propertyList];

	[master setFilesToArray:array];

	[self setBackgroundColor:aColor];
	[self setEditable:YES];
	[self setNeedsDisplay:YES];
	return YES;
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
	return YES;
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
	[self draggingExited:sender];
}
@end