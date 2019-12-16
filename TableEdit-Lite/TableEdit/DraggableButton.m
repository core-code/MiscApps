//
//  DraggableButton.m
//  TableEdit-Lite
//
//  Created by CoreCode on 18.02.14.
/*    Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/


#import "DraggableButton.h"
#import "Document.h"

@interface DraggableButton ()

@property (assign, nonatomic) BOOL dragging;
@property (strong, nonatomic) NSEvent *oldEvent;
//@property (assign, nonatomic) CGRect oldFrame;
@property (assign, nonatomic) CGFloat oldConstant;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *constraint;

@end



@implementation DraggableButton


//- (id)initWithFrame:(NSRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        // Initialization code here.
//		[self registerForDraggedTypes:@[NSStringPboardType]];
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
    LOGFUNC
    _dragging = YES;

    [[NSCursor closedHandCursor] push];
	[[self window] disableCursorRects];

    [self setNeedsDisplay: YES];

//	[super mouseDown:event];
	self.oldEvent = event;
    self.oldConstant = self.constraint.constant;

	[self setImagePosition:NSImageLeft];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    LOGFUNC
    if (_dragging)
	{
		if (self.tag == 1)
		{
            self.constraint.constant = MAX(self.constraint.constant + theEvent.deltaX, self.oldConstant);


			self.title = makeString(@"%i", (int)(self.constraint.constant - self.oldConstant) / 80);
		}
		else
		{
            self.constraint.constant = MAX(self.constraint.constant + theEvent.deltaY, self.oldConstant);

			self.title = makeString(@"%i", (int)(self.constraint.constant - self.oldConstant) / 21);
		}

		[self autoscroll:theEvent];
    }

    self.needsUpdateConstraints=YES;
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)event
{
    LOGFUNC
	[self setImagePosition:NSImageOnly];
	self.title = @"";

	int addCount =	(self.tag == 1) ?
					((int)(self.constraint.constant - self.oldConstant) / 80):
					((int)(self.constraint.constant - self.oldConstant) / 21);
    
	Document *doc = [NSDocumentController.sharedDocumentController currentDocument];
	if (!addCount)
	{
		if (self.tag == 1)
			[doc movePlusColumnButton];
		else
			[doc movePlusRowButton];


//		[doc fitTableColumsToData];
		[doc.windowForSheet.contentView setNeedsLayout:YES];
	}
	else
	{
		for (int i = 0; i < addCount; i++)
		{
			if (self.tag == 1)
				[doc addColumn:nil];
			else
				[doc addRow:nil];
		}
	}
	[doc.tableView reloadData];


    _dragging = NO;

    [self setNeedsDisplay: YES];

	[NSCursor.closedHandCursor pop];
	[self.window enableCursorRects];
	[self.window resetCursorRects];

	
	if (ABS(self.oldEvent.locationInWindow.x - event.locationInWindow.x) < 2 &&
        ABS(self.oldEvent.locationInWindow.y - event.locationInWindow.y) < 2)
	{
		[super mouseDown:event];
		[super mouseUp:event];
	}
}

- (void)flagsChanged:(NSEvent *)event
{
//  LOGFUNC
    BOOL optionDown = (event.modifierFlags & NSEventModifierFlagOption) > 0;


    if (self.dragging && optionDown) return;


    self.image = optionDown ? @"NSRemoveTemplate".namedImage : @"NSAddTemplate".namedImage;
}
@end
