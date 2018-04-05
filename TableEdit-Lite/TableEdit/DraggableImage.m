//
//  DraggableImage.m
//  TableEdit-Lite
//
//  Created by CoreCode on 28.10.13.
/*    Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/


#import "GridTableView.h"
#import "DraggableImage.h"

@implementation DraggableImage


//- (id)initWithFrame:(NSRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        // Initialization code here.
//    }
//    return self;
//}
//
//- (void)drawRect:(NSRect)dirtyRect
//{
//	[super drawRect:dirtyRect];
//	
//    // Drawing code here.
//}

- (void)mouseDown:(NSEvent *)event
{
	LOGFUNC;
	//[self.chartContainerView removeFromSuperview];

    _dragging = YES;

    [[NSCursor closedHandCursor] push];
	[[self window] disableCursorRects];

    [self setNeedsDisplay: YES];
}


- (void)mouseDragged:(NSEvent *)theEvent
{
	LOGFUNC;

    if (_dragging)
	{
		CGFloat y =  self.invertedAxis ? [self frame].origin.y - [theEvent deltaY] : [self frame].origin.y + [theEvent deltaY];

		[self setFrameOrigin:NSMakePoint([self frame].origin.x + [theEvent deltaX], y)];


        [self autoscroll:theEvent];
    }

	[self setNeedsDisplay: YES];
}


- (void)mouseUp:(NSEvent *)event
{
	LOGFUNC;
    _dragging = NO;

    [self setNeedsDisplay: YES];

	[[NSCursor closedHandCursor] pop];
	[[self window] enableCursorRects];
	[[self window] resetCursorRects];

	[_dragDelegate selectionWasModifiedByUserDraggingTheKnob:self];

}
@end
