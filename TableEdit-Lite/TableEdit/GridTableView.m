//
//  GridTableView.m
//  TableEdit-Lite
//
//  Created by CoreCode on 28/06/13.
/*    Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/



#import "GridTableView.h"
#import "AddressHelper.h"
#import "Document.h"
#import "DraggableImage.h"

NSString *processPasteForExcelMultiline(NSString *paste);

@interface GridTableView ()

	@property (nonatomic, weak) IBOutlet DraggableImage *dragCornerUpperLeft;
	@property (nonatomic, weak) IBOutlet DraggableImage *dragCornerLowerRight;
	@property (strong, nonatomic) NSMutableArray <Cell *> *selectedCellArray;
	@property (strong, nonatomic) NSMutableDictionary <NSString *, NSNumber *> *selectedCellMap;
	@property (strong, nonatomic) NSGradient *gradient;
	@property (strong, nonatomic) NSColor *selectionColor;
//	@property (assign, nonatomic) unichar rememberedCharacter;
	@property (strong, nonatomic) NSString *lastCopyString;
	@property (assign, nonatomic) coordinates lastCopyPosition;

	@property (assign, nonatomic) BOOL selectionUpdatesPrevented;
	@property (assign, nonatomic) BOOL optionDown;

	@property (assign, nonatomic) BOOL selectionIsSingleRect;
	@property (assign, nonatomic) CCIntRange2D selectionExtents;
@end



@implementation GridTableView

@dynamic selectedCells;

- (void)awakeFromNib
{
	self.selectedCellMap = makeMutableDictionary();
	self.gradient = [[NSGradient alloc] initWithColorsAndLocations:makeColor(0.667f, 0.667f, 0.667f, 1.0f), 0.0, [NSColor whiteColor], 1.0, nil];
	self.selectionColor = makeColor(0.343f, 0.562f, 1.0f, 1.0f);
	self.selectionExtents = (CCIntRange2D){{INT_MAX, INT_MAX}, {INT_MIN, INT_MIN}, {-1, -1}};


	for (DraggableImage *selectionDragKnob in @[_dragCornerUpperLeft, _dragCornerLowerRight])
	{
		[selectionDragKnob removeFromSuperview];
		selectionDragKnob.dragDelegate = self;
		selectionDragKnob.autoresizingMask =  NSViewMaxYMargin | NSViewMaxXMargin;
		selectionDragKnob.translatesAutoresizingMaskIntoConstraints = YES;
		selectionDragKnob.hidden = YES;
		
		[self.superview addSubview:selectionDragKnob positioned:NSWindowAbove relativeTo:nil];
	}
}

#pragma mark drawing

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];

    // we might get triggered while removing columns, when data is already gone, before removing further columns. just ignore that
    if (self.tableColumns.count-1 != _data.columnCount)
    {
        cc_log_error(@"Error: drawRect called with incorrect column count, probably during resize");
        return;
    }
        
	// calculate dirty cells for speedup
	NSInteger rowHeight = (NSInteger)[self rowHeight] + 2;
	NSInteger firstVisibleRow = MAX((NSInteger)dirtyRect.origin.y - 3, 0) / rowHeight, lastVisibleRow = ((NSInteger)dirtyRect.origin.y + (NSInteger)dirtyRect.size.height + 3) / rowHeight;
	lastVisibleRow = MIN(lastVisibleRow, [self.dataSource numberOfRowsInTableView:self] - 1); // if we are going to get variable height rows, this breaks
	NSInteger firstVisibleColumn = NSIntegerMax, lastVisibleColumn = self.tableColumns.count - 1, currentWidth = (NSInteger)[super frameOfCellAtColumn:0 row:0].size.width + 4;
	for (NSInteger column = 1; column <= lastVisibleColumn; column ++)
	{
        int widthOfCurrentColumn = (int) self.tableColumns[column].width;
        NSInteger leftExtent = currentWidth;
        NSInteger rightExtent = currentWidth + widthOfCurrentColumn;
		BOOL intersects = rightExtent > dirtyRect.origin.x && leftExtent < NSMaxX(dirtyRect);
		if (intersects && column < firstVisibleColumn) firstVisibleColumn = column;
		if (!intersects && column > firstVisibleColumn)
		{
			lastVisibleColumn = column-1;
			break;
		}

		currentWidth = rightExtent+3;
	}


	assert(firstVisibleColumn > 0);

	// draw borders
	for (NSInteger row = firstVisibleRow; row <= lastVisibleRow; row ++)
	{
		for (NSInteger colInTable = firstVisibleColumn; colInTable <= lastVisibleColumn; colInTable ++)
		{
			NSInteger colInData = colInTable-1;
			NSDictionary *a = _data.attributes[row][colInData]; // we had a crash here because colInData exceeds columns after column removal but the check at top should fix it
			NSNumber *left = a[kBackgroundBorderExistsLeftKey], *right = a[kBackgroundBorderExistsRightKey], *top = a[kBackgroundBorderExistsTopKey], *bottom = a[kBackgroundBorderExistsBottomKey];

			if (left || right || top || bottom)
			{

				NSRect cellRect = [super frameOfCellAtColumn:colInTable row:row];
//				if (!NSIntersectsRect(dirtyRect,  NSInsetRect(cellRect, -3, -3)))
//					continue;

				NSBezierPath *path = [NSBezierPath bezierPath];

				NSColor *borderColor = OBJECT_OR(a[kBackgroundBorderColorKey], NSColor.blackColor);

				if (left)
				{
					[borderColor setStroke];
					path.lineWidth = [a[kBackgroundBorderWidthKey] intValue]+1;
					[path moveToPoint:NSMakePoint(cellRect.origin.x - 1 - 0.5, cellRect.origin.y-1 )]; // top left
					[path lineToPoint:NSMakePoint(cellRect.origin.x  - 1 - 0.5, cellRect.origin.y + cellRect.size.height)]; // bottom left
				}

				if (right)
				{
					if (right.intValue == 1)
					{
						[borderColor setStroke];
						path.lineWidth = [a[kBackgroundBorderWidthKey] intValue]+1;
					}
					else
					{
						NSDictionary *a2 = _data.attributes[row][colInData+1];
						NSColor *borderColor2 = OBJECT_OR(a2[kBackgroundBorderColorKey], NSColor.blackColor);
						[borderColor2 setStroke];
						path.lineWidth = [a2[kBackgroundBorderWidthKey] intValue]+1;
					}

					[path moveToPoint:NSMakePoint(cellRect.origin.x + 1 + cellRect.size.width + 0.5, cellRect.origin.y-1 )]; // top right
					[path lineToPoint:NSMakePoint(cellRect.origin.x  + 1 + cellRect.size.width + 0.5, cellRect.origin.y + cellRect.size.height)]; // bottom right
				}

				if (top)
				{
					[borderColor setStroke];
					path.lineWidth = [a[kBackgroundBorderWidthKey] intValue]+1;
					[path moveToPoint:NSMakePoint(cellRect.origin.x - 1, MAX(0.0, cellRect.origin.y-1 - 0.5))];  // top left
					[path lineToPoint:NSMakePoint(cellRect.origin.x + 1 + cellRect.size.width, MAX(0.0, cellRect.origin.y-1 - 0.5))]; // top right
				}

				if (bottom)
				{
					if (bottom.intValue == 1)
					{
						[borderColor setStroke];
						path.lineWidth = [a[kBackgroundBorderWidthKey] intValue]+1;
					}
					else
					{
						NSDictionary *a2 = _data.attributes[row+1][colInData];
						NSColor *borderColor2 = OBJECT_OR(a2[kBackgroundBorderColorKey], NSColor.blackColor);
						[borderColor2 setStroke];
						path.lineWidth = [a2[kBackgroundBorderWidthKey] intValue]+1;
					}

					[path moveToPoint:NSMakePoint(cellRect.origin.x - 1, cellRect.origin.y+1 + cellRect.size.height - 0.5)];  // bottom left
					[path lineToPoint:NSMakePoint(cellRect.origin.x + 1 + cellRect.size.width, cellRect.origin.y+1 + + cellRect.size.height - 0.5)]; // bottom right
				}

				[path stroke];
			}
		}
	}

	// draw selection
	if (self.selectedCellArray)
	{
		for (Cell *c in self.selectedCellArray)
		{
			NSRect selectedCellRect = [super frameOfCellAtColumn:c.columnIndex row:c.rowIndex]; // this is the last performance "problem" in this method, well we could just store the bezierpath

			if (!NSIntersectsRect(dirtyRect,  NSInsetRect(selectedCellRect, -3, -3)))
				continue;

			[_selectionColor setStroke];

			if (![self.selectedCellMap valueForKey:[AddressHelper indicesToString:c.columnIndex-1 rowIndex:c.rowIndex]]) // left not selected - draw left edge
			{

				[NSBezierPath strokeLineFromPoint:NSMakePoint(selectedCellRect.origin.x - 3, selectedCellRect.origin.y + 3)
										  toPoint:NSMakePoint(selectedCellRect.origin.x - 3, selectedCellRect.origin.y + selectedCellRect.size.height - 1)];

				if ([self.selectedCellMap valueForKey:[AddressHelper indicesToString:c.columnIndex-1 rowIndex:c.rowIndex+1]]) // bottom left selected - stroke to left
				{
					[NSBezierPath strokeLineFromPoint:NSMakePoint(selectedCellRect.origin.x - 3, selectedCellRect.origin.y + selectedCellRect.size.height - 1)
											  toPoint:NSMakePoint(selectedCellRect.origin.x - 6, selectedCellRect.origin.y + selectedCellRect.size.height - 1)];
				}
				else if ([self.selectedCellMap valueForKey:[AddressHelper indicesToString:c.columnIndex rowIndex:c.rowIndex+1]]) // bottom selected - stroke to bottom
				{
					[NSBezierPath strokeLineFromPoint:NSMakePoint(selectedCellRect.origin.x - 3, selectedCellRect.origin.y + selectedCellRect.size.height - 1)
											  toPoint:NSMakePoint(selectedCellRect.origin.x - 3, selectedCellRect.origin.y + selectedCellRect.size.height + 5)];
				}
				else // stroke to right
				{
					[NSBezierPath strokeLineFromPoint:NSMakePoint(selectedCellRect.origin.x - 3, selectedCellRect.origin.y + selectedCellRect.size.height - 1)
											  toPoint:NSMakePoint(selectedCellRect.origin.x - 3, selectedCellRect.origin.y + selectedCellRect.size.height + 2)];
					[NSBezierPath strokeLineFromPoint:NSMakePoint(selectedCellRect.origin.x - 3, selectedCellRect.origin.y + selectedCellRect.size.height + 2)
											  toPoint:NSMakePoint(selectedCellRect.origin.x + 3, selectedCellRect.origin.y + selectedCellRect.size.height + 2)];
				}

			}

			if (![self.selectedCellMap valueForKey:[AddressHelper indicesToString:c.columnIndex+1 rowIndex:c.rowIndex]]) // right not selected - draw right edge
			{
				[NSBezierPath strokeLineFromPoint:NSMakePoint(selectedCellRect.origin.x + selectedCellRect.size.width + 3, selectedCellRect.origin.y + 0)
										  toPoint:NSMakePoint(selectedCellRect.origin.x + selectedCellRect.size.width + 3, selectedCellRect.origin.y + selectedCellRect.size.height - 4)];

				if ([self.selectedCellMap valueForKey:[AddressHelper indicesToString:c.columnIndex+1 rowIndex:c.rowIndex-1]]) // top right selected - stroke to right
				{
					[NSBezierPath strokeLineFromPoint:NSMakePoint(selectedCellRect.origin.x + selectedCellRect.size.width + 3, selectedCellRect.origin.y + 0)
											  toPoint:NSMakePoint(selectedCellRect.origin.x + selectedCellRect.size.width + 6, selectedCellRect.origin.y + 0)];
				}
				else if ([self.selectedCellMap valueForKey:[AddressHelper indicesToString:c.columnIndex rowIndex:c.rowIndex-1]]) // top selected - stroke to top
				{
					[NSBezierPath strokeLineFromPoint:NSMakePoint(selectedCellRect.origin.x + selectedCellRect.size.width + 3, selectedCellRect.origin.y + 0)
											  toPoint:NSMakePoint(selectedCellRect.origin.x + selectedCellRect.size.width + 3, selectedCellRect.origin.y - 6)];

				}
				else // stroke to left
				{
					[NSBezierPath strokeLineFromPoint:NSMakePoint(selectedCellRect.origin.x + selectedCellRect.size.width + 3, selectedCellRect.origin.y + 0)
								  toPoint:NSMakePoint(selectedCellRect.origin.x + selectedCellRect.size.width + 3, MAX(1, selectedCellRect.origin.y - 3))];
					[NSBezierPath strokeLineFromPoint:NSMakePoint(selectedCellRect.origin.x + selectedCellRect.size.width + 3, MAX(1, selectedCellRect.origin.y - 3))
								  toPoint:NSMakePoint(selectedCellRect.origin.x + selectedCellRect.size.width - 3, MAX(1, selectedCellRect.origin.y - 3))];
				}
			}

			if (![self.selectedCellMap valueForKey:[AddressHelper indicesToString:c.columnIndex rowIndex:c.rowIndex+1]]) // bottom not selected - draw bottom edge
			{
				[NSBezierPath strokeLineFromPoint:NSMakePoint(selectedCellRect.origin.x + 3, selectedCellRect.origin.y + selectedCellRect.size.height + 2)
										  toPoint:NSMakePoint(selectedCellRect.origin.x + selectedCellRect.size.width + 0, selectedCellRect.origin.y + selectedCellRect.size.height + 2)];

				if ([self.selectedCellMap valueForKey:[AddressHelper indicesToString:c.columnIndex+1 rowIndex:c.rowIndex+1]]) // bottom right selected - stroke to bottom
				{
					[NSBezierPath strokeLineFromPoint:NSMakePoint(selectedCellRect.origin.x + selectedCellRect.size.width + 0, selectedCellRect.origin.y + selectedCellRect.size.height + 2)
											  toPoint:NSMakePoint(selectedCellRect.origin.x + selectedCellRect.size.width + 0, selectedCellRect.origin.y + selectedCellRect.size.height + 5)];
				}
				else if ([self.selectedCellMap valueForKey:[AddressHelper indicesToString:c.columnIndex+1 rowIndex:c.rowIndex]]) // right selected - stroke to right
				{
					[NSBezierPath strokeLineFromPoint:NSMakePoint(selectedCellRect.origin.x + selectedCellRect.size.width + 0, selectedCellRect.origin.y + selectedCellRect.size.height + 2)
											  toPoint:NSMakePoint(selectedCellRect.origin.x + selectedCellRect.size.width + 6, selectedCellRect.origin.y + selectedCellRect.size.height + 2)];
				}
				else // stroke to top
				{
					[NSBezierPath strokeLineFromPoint:NSMakePoint(selectedCellRect.origin.x + selectedCellRect.size.width + 0, selectedCellRect.origin.y + selectedCellRect.size.height + 2)
											  toPoint:NSMakePoint(selectedCellRect.origin.x + selectedCellRect.size.width + 3, selectedCellRect.origin.y + selectedCellRect.size.height + 2)];


					[NSBezierPath strokeLineFromPoint:NSMakePoint(selectedCellRect.origin.x + selectedCellRect.size.width + 3, selectedCellRect.origin.y + selectedCellRect.size.height + 2)
											  toPoint:NSMakePoint(selectedCellRect.origin.x + selectedCellRect.size.width + 3, selectedCellRect.origin.y + selectedCellRect.size.height - 4)];
				}
			}
			if (![self.selectedCellMap valueForKey:[AddressHelper indicesToString:c.columnIndex rowIndex:c.rowIndex-1]]) // top not selected - draw top edge
			{
				[NSBezierPath strokeLineFromPoint:NSMakePoint(selectedCellRect.origin.x + 0, MAX(1, selectedCellRect.origin.y - 3))
										  toPoint:NSMakePoint(selectedCellRect.origin.x + selectedCellRect.size.width - 3, MAX(1, selectedCellRect.origin.y - 3))];

				if ([self.selectedCellMap valueForKey:[AddressHelper indicesToString:c.columnIndex-1 rowIndex:c.rowIndex-1]]) // top left selected - stroke to top
				{

					[NSBezierPath strokeLineFromPoint:NSMakePoint(selectedCellRect.origin.x - 0, selectedCellRect.origin.y - 3)
											  toPoint:NSMakePoint(selectedCellRect.origin.x - 0, selectedCellRect.origin.y - 6)];
				}
				else if ([self.selectedCellMap valueForKey:[AddressHelper indicesToString:c.columnIndex-1 rowIndex:c.rowIndex]]) // left selected - stroke to left
				{
					[NSBezierPath strokeLineFromPoint:NSMakePoint(selectedCellRect.origin.x + 0, MAX(1, selectedCellRect.origin.y - 3))
											  toPoint:NSMakePoint(selectedCellRect.origin.x - 6, MAX(1, selectedCellRect.origin.y - 3))];
				}
				else // stroke to bottom
				{
					[NSBezierPath strokeLineFromPoint:NSMakePoint(selectedCellRect.origin.x + 0, selectedCellRect.origin.y - 3)
											  toPoint:NSMakePoint(selectedCellRect.origin.x - 3, selectedCellRect.origin.y - 3)];
					[NSBezierPath strokeLineFromPoint:NSMakePoint(selectedCellRect.origin.x - 3, selectedCellRect.origin.y - 3)
											  toPoint:NSMakePoint(selectedCellRect.origin.x - 3, selectedCellRect.origin.y + 3)];
				}
			}
		}


		// draw selection knobs
//		if (self.selectionIsSingleRect)
//		{
//			[[NSColor lightGrayColor] setStroke];
//
//
//			NSRect r1 = [self frameOfCellAtColumn:(NSInteger)(NSMinX(self.selectionExtents)) row:(NSInteger)(NSMinY(self.selectionExtents))];
//			NSRect r2 = [self frameOfCellAtColumn:(NSInteger)(NSMaxX(self.selectionExtents)) row:(NSInteger)(NSMaxY(self.selectionExtents))];
//			NSRect selectionRect = NSUnionRect(r1,r2);
//
//            NSBezierPath *circleUpperLeftPath = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(selectionRect.origin.x-3, selectionRect.origin.y-3, 5, 5)];
//            [_gradient drawInBezierPath:circleUpperLeftPath angle:-90];
//			[[NSColor blackColor] setStroke];
//			[circleUpperLeftPath setLineWidth:0.5];
//			[circleUpperLeftPath stroke];
//
//
//            NSBezierPath *circleLowerRightPath = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(selectionRect.origin.x+selectionRect.size.width-2, selectionRect.origin.y+selectionRect.size.height-2, 5, 5)];
//            [_gradient drawInBezierPath:circleLowerRightPath angle:-90];
//			[[NSColor blackColor] setStroke];
//			[circleLowerRightPath setLineWidth:0.5];
//			[circleLowerRightPath stroke];
//		}
	}
}

- (void)drawGridInClipRect:(NSRect)clipRect
{
    NSRect lastRowRect = [self rectOfRow:self.numberOfRows-1];
	NSRect lastColumnRect = [self rectOfColumn:self.numberOfColumns-1];
    NSRect tableViewRect = NSMakeRect(0, 0, NSMaxX(lastColumnRect), NSMaxY(lastRowRect));
    NSRect finalClipRect = NSIntersectionRect(clipRect, tableViewRect);

    [super drawGridInClipRect:finalClipRect];
}

#pragma mark selection

- (void)selectionWasModifiedByUserDraggingTheKnob:(NSView *)sender
{
	LOGFUNC
	
	NSPoint center1Left = NSMakePoint(_dragCornerUpperLeft.frame.origin.x + _dragCornerUpperLeft.frame.size.width / 2 - 7, _dragCornerUpperLeft.frame.origin.y + _dragCornerUpperLeft.frame.size.height / 2);
	NSPoint center1Top = NSMakePoint(_dragCornerUpperLeft.frame.origin.x + _dragCornerUpperLeft.frame.size.width / 2, _dragCornerUpperLeft.frame.origin.y + _dragCornerUpperLeft.frame.size.height / 2 - 5);
	center1Left.y = MAX(0, center1Left.y);
	center1Top.y = MAX(-1, center1Top.y);
	NSUInteger c1 = [self columnAtPoint:center1Left]+1;
	NSUInteger r1 = [self rowAtPoint:center1Top]+1;

	assert(c1 != 0);


	NSPoint center2Left = NSMakePoint(_dragCornerLowerRight.frame.origin.x + _dragCornerLowerRight.frame.size.width / 2 + 7, _dragCornerLowerRight.frame.origin.y + _dragCornerLowerRight.frame.size.height / 2);
	NSPoint center2Top = NSMakePoint(_dragCornerLowerRight.frame.origin.x + _dragCornerLowerRight.frame.size.width / 2, _dragCornerLowerRight.frame.origin.y + _dragCornerLowerRight.frame.size.height / 2 + 5);
	NSUInteger c2 = [self columnAtPoint:center2Left]-1;
	NSUInteger r2 = [self rowAtPoint:center2Top]-1;


	r2 = MIN(r2, (NSUInteger) [self.dataSource numberOfRowsInTableView:self]-1);
	c2 = MIN(c2, (NSUInteger) self.tableColumns.count-1);


	//[_dragCornerLowerRight setFrameOrigin:NSMakePoint(NSMaxX(selectionRect)-2, NSMaxY(selectionRect)-3)];

	if (c1 <= c2 && r1 <= r2)
	{
		[[self window] makeFirstResponder:self];

		[self clearSelection:YES];

		[self addToSelection:r1
					  maxRow:r2
				   minColumn:c1
				   maxColumn:c2];
	}
	else
		[self updateSelectionInformation];

}

- (void)addToSelection:(NSInteger)row column:(NSInteger)col
{
	LOGFUNC
	[self addToSelection:row maxRow:row minColumn:col maxColumn:col];
}

- (void)addToSelection:(NSInteger)minRow maxRow:(NSInteger)maxRow minColumn:(NSInteger)minCol maxColumn:(NSInteger)maxCol
{
	LOGFUNCPARAM(makeString(@"minrow %li maxrow %li mincol %li, maxcol %li", (long)minRow, (long)maxRow, (long)minCol, (long)maxCol));

	assert(minRow <= maxRow);
	assert(minCol <= maxCol);

    if (!self.selectedCellArray)
        self.selectedCellArray = makeMutableArray();

	for (NSInteger r = minRow; r <= maxRow; r++)
	{
		for (NSInteger c = minCol; c <= maxCol; c++)
		{
			assert(IS_IN_RANGE(r, 0, [self.dataSource numberOfRowsInTableView:self]-1) &&
				   IS_IN_RANGE(c, 1, (NSInteger) self.tableColumns.count-1));

			Cell *cell = [Cell cellWithColumnIndex:c rowIndex:r column:self.tableColumns[c]];


			if (![self.selectedCellMap valueForKey:cell.cellName])
			{
				[self.selectedCellArray addObject:cell];
				self.selectedCellMap[cell.cellName] = @(YES);
			}
		}
	}

//	LOG(_selectedCellMap);
	[self updateSelectionInformation];
}


- (void)removeFromSelection:(NSInteger)row column:(NSInteger)col
{
	assert(IS_IN_RANGE(row, 0, [self.dataSource numberOfRowsInTableView:self]-1) &&
		   IS_IN_RANGE(col, 1, (NSInteger) self.tableColumns.count-1));


	LOGFUNC

	[self.selectedCellArray filter:^(Cell *c){ return !(c.rowIndex == row && c.columnIndex == col); }];
	if (!self.selectedCellArray.count)
		self.selectedCellArray = nil;

	[self.selectedCellMap removeObjectForKey:[AddressHelper indicesToString:col rowIndex:row]];
//	LOG(_selectedCellMap);
	[self updateSelectionInformation];
}

- (void)setSelection:(NSInteger)row column:(NSInteger)col
{
	LOGFUNCPARAM(makeString(@"row %li col %li", (long)row, (long)col));
	assert(IS_IN_RANGE(row, 0, [self.dataSource numberOfRowsInTableView:self]-1) &&
		   IS_IN_RANGE(col, 1, (NSInteger) self.tableColumns.count-1));


	[self.selectedCellArray removeAllObjects];
	[self.selectedCellMap removeAllObjects];

	[self addToSelection:row column:col];
}

- (void)clearSelection:(BOOL)suppressChangeNotification
{
	LOGFUNCPARAM(@(suppressChangeNotification));
	[self.selectedCellArray removeAllObjects];
	[self.selectedCellMap removeAllObjects];

	self.selectedCellArray = nil;

	if (!suppressChangeNotification) // this should be split in two parameters, one for updating selection and one for posting notification
		[self updateSelectionInformation];
}

- (void)addColumnToSelection:(NSInteger)col
{
	LOGFUNC
	[self addColumnsToSelection:col maxColumn:col];
}

- (void)addColumnsToSelection:(NSInteger)min maxColumn:(NSInteger)max
{
	LOGFUNCPARAM(makeString(@"min %li max %li", (long)min, (long)max));

	for (NSInteger col = min; col <= max; col++)
	{
		assert(IS_IN_RANGE(col, 1, (NSInteger) self.tableColumns.count-1));


		if (!self.selectedCellArray)
			self.selectedCellArray = makeMutableArray();

		for (int row = 0; row < [self.dataSource numberOfRowsInTableView:self]; row++)
		{
            @autoreleasepool
            {
                Cell *c = [Cell cellWithColumnIndex:col rowIndex:row column:self.tableColumns[col]];


                if (![self.selectedCellMap valueForKey:c.cellName])
                {
                    [self.selectedCellArray addObject:c];
                    self.selectedCellMap[c.cellName] = @(YES);
                }
            }

		}
	}

	[self updateSelectionInformation];
}


- (void)addRowToSelection:(NSInteger)row
{
	[self addRowsToSelection:row maxRow:row];
}

- (void)addRowsToSelection:(NSInteger)min maxRow:(NSInteger)max
{
	LOGFUNC

	for (NSInteger row = min; row <= max; row++)
	{
		assert(IS_IN_RANGE(row, 0, [self.dataSource numberOfRowsInTableView:self]-1));

		if (!self.selectedCellArray)
			self.selectedCellArray = makeMutableArray();

		for (NSUInteger col = 1; col < self.tableColumns.count; col++)
		{
			Cell *c = [Cell cellWithColumnIndex:col rowIndex:row column:self.tableColumns[col]];


            if (![self.selectedCellMap valueForKey:c.cellName])
            {
                [self.selectedCellArray addNewObject:c];
                self.selectedCellMap[c.cellName] = @(YES);
            }
		}
	//	LOG(_selectedCellMap);
	}

	[self updateSelectionInformation];
}

- (void)preventUpdateSelectionInformation
{
	self.selectionUpdatesPrevented = NO;
}

- (void)updateSelectionInformation
{
	LOGFUNC
	if (self.selectionUpdatesPrevented)
		return;

//    [self.selectedCellArray valueForKeyPath:@"files.@sum.length"]

	self.selectionExtents = (CCIntRange2D){{INT_MAX, INT_MAX}, {INT_MIN, INT_MIN}, {-1, -1}};
	if (self.selectedCellArray.count)
		self.selectionExtents = [self.selectedCellArray calculateExtentsOfPoints:^(Cell *c){return (CCIntPoint){c.columnIndex, c.rowIndex};}];

	NSUInteger requirementForFullRectSelection = (NSUInteger) ((self.selectionExtents.length.y+1.0)*(self.selectionExtents.length.x+1.0));
	self.selectionIsSingleRect = (self.selectedCellArray.count == requirementForFullRectSelection);

	LOGFUNCPARAM(makeString(@"se x%li|y%li|x%li|y%li|x%li|x%li  sisr %i sca %@", (long)self.selectionExtents.min.x,self.selectionExtents.min.y, self.selectionExtents.max.x, self.selectionExtents.max.y, self.selectionExtents.length.x,  self.selectionExtents.length.y, self.selectionIsSingleRect, [self.selectedCellArray joined:@" "]));

	// selection knobs
	BOOL shouldHideSelectionKnobs = !_selectionIsSingleRect || !_selectedCellArray || _selectedCellArray.empty; // problem is if it aint subview it doesn't move with scroll hmmmm
	_dragCornerLowerRight.hidden = shouldHideSelectionKnobs;
	_dragCornerUpperLeft.hidden = shouldHideSelectionKnobs;
	if (!shouldHideSelectionKnobs)
	{
        NSRect r1 = [super frameOfCellAtColumn:_selectionExtents.min.x row:_selectionExtents.min.y];
        NSRect r2 = [super frameOfCellAtColumn:_selectionExtents.max.x row:_selectionExtents.max.y];
        NSRect selectionRect = NSUnionRect(r1,r2);

		[_dragCornerUpperLeft setFrameOrigin:NSMakePoint(NSMinX(selectionRect)-5, NSMinY(selectionRect)-5)];
		[_dragCornerLowerRight setFrameOrigin:NSMakePoint(NSMaxX(selectionRect)-2, NSMaxY(selectionRect)-3)];
	}

	[self setNeedsDisplay];
	[self.delegate tableViewSelectionDidChange:nil];
}

#pragma mark events

- (void)selectAll:(id)sender
{
	LOGFUNC

	[self clearSelection:YES];

	[self addColumnsToSelection:1 maxColumn:self.tableColumns.count-1];
}

- (void)flagsChanged:(NSEvent *)event
{
	LOGFUNCPARAMA(@(event.modifierFlags));

    self.optionDown = (event.modifierFlags & NSEventModifierFlagOption) > 0;


    [self.document flagsChanged:event];

    [self setNeedsDisplay];

	//LOG(self.selectionString);
}

- (void)paste:(id)sender
{
    LOGFUNC

	if (!self.selectedCellArray.count)
		return;

    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    NSString *paste = [pasteBoard stringForType:NSStringPboardType];

    paste = processPasteForExcelMultiline(paste);

    if (paste)
    {
        // insert position
        NSInteger insertCol = 1, insertRow = 0;
        if (self.selectedCellArray)
        {
            insertCol = self.selectedCellArray[0].columnIndex;
            insertRow = self.selectedCellArray[0].rowIndex;
        }
        NSInteger row = insertRow;


        // determine how much we must resize and resize
        NSInteger pastedRows = 0, pastedCols = 0;
        for (NSString *line in paste.lines)
        {
            pastedRows ++;
            NSInteger colsAtThisRow = [line count:@"\t"] + 1;
            pastedCols = MAX(pastedCols, colsAtThisRow);
        }
        NSInteger newRows = MAX(0, insertRow + pastedRows - [self.dataSource numberOfRowsInTableView:self]);
        NSInteger newCols = MAX(0, insertCol + pastedCols - (NSInteger)self.tableColumns.count);
        BOOL needReload = newRows > 0 || newCols > 0;
        BOOL needTableColumnAdjustment = newCols > 0;
        while (newRows-- > 0) [_data insertRow:[self.dataSource numberOfRowsInTableView:self]];
        while (newCols-- > 0) [_data insertColumn:self.tableColumns.count-1];
        if (needTableColumnAdjustment)
            [_document fitTableColumsToData];
        else
            [_document movePlusRowButton];

     
        // now actually paste
        for (NSString *line in paste.lines)
        {
            assert(IS_IN_RANGE(row, 0, [self.dataSource numberOfRowsInTableView:self]-1));
            //if (IS_IN_RANGE(row, 0, [self.dataSource numberOfRowsInTableView:self]-1))
            {
                NSInteger col = insertCol-1;
                for (NSString *comp in [line componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\t"]])
                {
                    col++;

                    if (!comp.length)
                        continue;



                    assert(IS_IN_RANGE(col, 0, (NSInteger)self.tableColumns.count-1));
                    //if (IS_IN_RANGE(col, 0, (NSInteger)self.tableColumns.count-1))
                    {
                        NSString *pastePart = comp;
                        
                        assert(pastePart);
                        [self.dataSource tableView:self
                                    setObjectValue:pastePart
                                    forTableColumn:self.tableColumns[col]
                                               row:row];
                    }
                }
                row++;
            }
        }
        
        
        if (needReload)
            [self reloadData];
        else
            [self setNeedsDisplay];
    }
}

- (void)cut:(id)sender
{
    LOGFUNC
    [self copy:@"cut"];
}

- (void)copy:(id)sender
{
    LOGFUNC

    if (self.selectedCellArray)
    {
        BOOL formatted = [sender isKindOfClass:NSMenuItem.class] && (((NSMenuItem *)sender).tag == 1);
        NSMutableString *tmp = [NSMutableString new];

        for (NSInteger row = _selectionExtents.min.y; row <= _selectionExtents.max.y; row++)
        {
            for (NSInteger col = _selectionExtents.min.x; col <= _selectionExtents.max.x; col++)
            {
                NSString *key = [AddressHelper indicesToString:col rowIndex:row];

                if ([self.selectedCellMap valueForKey:key])
                {
                    NSString *currentValue = [self.dataSource tableView:formatted ? self : nil
                                              objectValueForTableColumn:self.tableColumns[col]
                                                                    row:row];

                    if ([sender isEqual:@"cut"])
                        [self.dataSource tableView:self
                                    setObjectValue:@""
                                    forTableColumn:self.tableColumns[col]
                                               row:row];

                    [tmp appendString:currentValue];
                }

                [tmp appendString:@"\t"];
            }
            [tmp appendString:@"\n"];
        }

        [tmp deleteCharactersInRange:NSMakeRange(tmp.length-2,2)];
        //LOG(tmp);
        self.lastCopyPosition = (coordinates) {_selectionExtents.min.x, _selectionExtents.min.y};
        self.lastCopyString = tmp;
		cc_log_debug(@"Info: remembering copy '%@' at c%li r%li", [_lastCopyString clamp:20], (long)_selectionExtents.min.x, (long)_selectionExtents.min.y);

		NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
        [pasteBoard declareTypes:@[NSStringPboardType] owner:nil];
        [pasteBoard setString:tmp
                      forType:NSStringPboardType];
    }
}

- (NSRect)frameOfCellAtColumn:(NSInteger)column row:(NSInteger)row
{ // this function exists solely to make text of 'merged cells' really span multiple columns
    NSRect merged  = [super frameOfCellAtColumn:column row:row];

    if (column == 0) return merged;
    if (row >= (NSInteger)_data.rowCount ) return merged;   // hope this fixes the 'NSTableViewDynamicToolTipManager' crash on 10.9


    BOOL isMergedWithNext = TRUE;

    while (isMergedWithNext)
    {
        if (column > (NSInteger)_data.columnCount)
            return merged;

        NSDictionary *a = _data.attributes[row][column-1];


        isMergedWithNext = ([a[kBackgroundBorderMergedKey] intValue] == 1 &&
                            [a[kBackgroundBorderExistsRightKey] intValue] == 1 &&
                            [a[kBackgroundBorderWidthKey] intValue] == 0);


        if (isMergedWithNext)
        {
            NSRect next = [super frameOfCellAtColumn:column+1 row:row];
            merged = NSUnionRect(merged, next);
        }

        column++;
    }

    return merged;
}

- (void)keyDown:(NSEvent *)event
{
	unichar character = event.charactersIgnoringModifiers.firstChar;
    LOGFUNCPARAMA(makeString(@"%@ [0x%04x] %lu ", [event characters], character, (unsigned long)event.modifierFlags));

    BOOL commandDown = (event.modifierFlags & NSEventModifierFlagCommand) > 0;
    BOOL shiftDown = (event.modifierFlags & NSEventModifierFlagShift) > 0;
    BOOL controlDown = (event.modifierFlags & NSEventModifierFlagControl) > 0;
    BOOL altDown = (event.modifierFlags & NSEventModifierFlagOption) > 0;
	BOOL nothingDown = !commandDown && !shiftDown && !controlDown && !altDown;
	BOOL nothingOrOnlyShiftDown = !commandDown && !controlDown && !altDown;

    if ((character >= NSInsertFunctionKey && character <= NSModeSwitchFunctionKey) && (character != NSDeleteFunctionKey))
        [super keyDown:event];
    else if (character == NSF1FunctionKey)
		[_document performSelector:@selector(validate)];
    else if (character == NSF3FunctionKey)
    {
        [_data _exportAttributeCSV:[cc.docURL add:@"atr.csv"]  delimiter:@"," encoding:NSUTF8StringEncoding];
    }
	else if (character == NSTabCharacter || character == NSBackTabCharacter)
	{
		NSInteger col = self.selectedCellArray[0].columnIndex;
		NSInteger row = self.selectedCellArray[0].rowIndex;


		if (shiftDown && !(col == 1 && row == 0)) // move back if not first
			col = col - 1;

		if (!shiftDown && !(col == (int)self.tableColumns.count - 1 && row == [self.dataSource numberOfRowsInTableView:self] - 1)) // move forward if not last
			col = col + 1;

		// go to prev/next row if at end
		if (col < 1)
		{
			col = (NSInteger)self.tableColumns.count - 1;
			row--;
		}
		else if (col > (NSInteger)self.tableColumns.count - 1)
		{
			col = 1;
			row++;
		}

//				row = CLAMP(row, 0, [self.dataSource numberOfRowsInTableView:self] - 1);


		if (col != self.selectedCellArray[0].columnIndex ||
			row != self.selectedCellArray[0].rowIndex)
		{
			[self setSelection:row
						column:col];


			[self setNeedsDisplay];
			[self.delegate tableViewSelectionDidChange:nil];

			[self scrollRowToVisible:row];
			[self scrollColumnToVisible:col == 1 ? 0 : col];
	//		[self editColumn:self.selectedCellArray[0].columnIndex
	//					 row:self.selectedCellArray[0].rowIndex
	//			   withEvent:nil select:YES];
		}
	}
	else if (commandDown && character == 'v') // paste
    {
        assert(0);
    }
	else if (commandDown && (character == 'c' || character == 'x')) // copy or cut
    {
        assert(0);
    }
    else if ((!commandDown && self.selectedCellArray && IS_IN_RANGE(character, NSUpArrowFunctionKey, NSRightArrowFunctionKey)) || // arrow keys or enter or return
			(character == NSEnterCharacter || character == NSCarriageReturnCharacter))
    {
		Cell *sc = self.selectedCellArray.lastObject;
		NSInteger row = sc.rowIndex;
		NSInteger col = sc.columnIndex;

		if ((character == NSEnterCharacter) || (character == NSCarriageReturnCharacter))
			shiftDown ? row -- : row ++;
		else if (character == NSUpArrowFunctionKey)
            row --;
		else if (character == NSDownArrowFunctionKey)
            row ++;
        else if (character == NSRightArrowFunctionKey)
			col++;
        else if (character == NSLeftArrowFunctionKey)
			col--;

        row = CLAMP(row, 0, [self.dataSource numberOfRowsInTableView:self] - 1);
        col = CLAMP(col, 1, (NSInteger)self.tableColumns.count - 1);

		if (!shiftDown || ((character == NSEnterCharacter) || (character == NSCarriageReturnCharacter)))
			[self setSelection:row column:col];
		else
			[self addToSelection:MIN(sc.rowIndex,row) maxRow:MAX(sc.rowIndex,row) minColumn:MIN(sc.columnIndex,col) maxColumn:MAX(sc.columnIndex,col)];

		[self scrollRowToVisible:row];
		[self scrollColumnToVisible:col == 1 ? 0 : col];

		[self setNeedsDisplay];
		[self.delegate tableViewSelectionDidChange:nil];
	}
    else if (nothingOrOnlyShiftDown && self.selectedCellArray.count == 1)
    {
        if (character == NSDeleteCharacter || character == NSBackspaceCharacter || character == NSDeleteFunctionKey)
        {
            [self.dataSource tableView:self
						setObjectValue:@""
						forTableColumn:self.selectedCellArray[0].column
								   row:self.selectedCellArray[0].rowIndex];
        }
		else
		{

//			cc_log(@"***** opening undo group ***************");
//			[self.undoManager beginUndoGrouping];
//			assert(!_hasOpenedUndoGroup);

//			[self.dataSource tableView:self
//						  setObjectValue:[event charactersIgnoringModifiers]
//						  forTableColumn:self.selectedCellArray[0].column
//									 row:self.selectedCellArray[0].rowIndex];

//			NSTextView *tv = [[self subviews][0] subviews][0];
//			tv.string = makeString(@"%c", character);
//			self.hasOpenedUndoGroup = YES;

//			NSText *fe = [self.window fieldEditor:YES forObject:self];
//			fe.string = makeString(@"%c", character);

//			self.rememberedCharacter = character;

			if ([self.delegate tableView:self shouldEditTableColumn:self.selectedCellArray[0].column row:self.selectedCellArray[0].rowIndex])
			{
				[self editColumn:self.selectedCellArray[0].columnIndex
							 row:self.selectedCellArray[0].rowIndex
					   withEvent:nil select:YES];

				NSText *fe = [self.window fieldEditor:YES forObject:self];
				fe.string = makeString(@"%c", character);
			}
		}


        [self setNeedsDisplay];
    }
	else if (nothingDown && self.selectedCellArray.count >= 1)
    {
		if (character == NSDeleteCharacter || character == NSBackspaceCharacter || character == NSDeleteFunctionKey)
		{
            [((Document *)self.dataSource) tableView:self
                                      setObjectValue:@""
                                            forCells:self.selectedCellArray];
		
			[self setNeedsDisplay];
		}
    }
    else
		[super keyDown:event];
}

- (void)mouseDown:(NSEvent *)event
{
	NSPoint p = [self convertPoint:event.locationInWindow fromView:nil];
	NSInteger columnAtPoint = [self columnAtPoint:p];
    BOOL commandDown = (event.modifierFlags & NSEventModifierFlagCommand) > 0;
    BOOL shiftDown = (event.modifierFlags & NSEventModifierFlagShift) > 0;

    LOGFUNCPARAMA(makeString(@"modifier %lu column %li", (unsigned long)event.modifierFlags, (long)columnAtPoint));

    if (columnAtPoint >= 0 && columnAtPoint < (int)self.tableColumns.count)
    {
        NSInteger row = [self rowAtPoint:p];
        NSInteger col = [self columnAtPoint:p];

		if (IS_IN_RANGE(row, 0, [self.dataSource numberOfRowsInTableView:self]-1) &&
			IS_IN_RANGE(col, 1, (NSInteger) self.tableColumns.count-1))
		{
			if (commandDown)
			{
				if (![self.selectedCellMap valueForKey:[AddressHelper indicesToString:col rowIndex:row]])
					[self addToSelection:row column:col];
				else
					[self removeFromSelection:row column:col];
			}
			else if (shiftDown)
			{
				Cell *sc = self.selectedCellArray.lastObject;

				if (!self.selectedCellArray)
					[self setSelection:row column:col];
				else
					[self addToSelection:MIN(sc.rowIndex,row) maxRow:MAX(sc.rowIndex,row) minColumn:MIN(sc.columnIndex,col) maxColumn:MAX(sc.columnIndex,col)];
			}
			else
				[self setSelection:row column:col];
		}
		else
		{
			if (IS_IN_RANGE(row, 0, [self.dataSource numberOfRowsInTableView:self]-1) &&
				 col == 0)
			{
				static NSInteger lastRow = -1;

				if (!commandDown && !shiftDown)
					[self clearSelection:YES];

				if (shiftDown && lastRow >= 0)
					[self addRowsToSelection:MIN(row, lastRow) maxRow:MAX(row, lastRow)];
				else
					[self addRowToSelection:row];

				lastRow = row;
			}
			else if (!commandDown && !shiftDown)
				[self clearSelection:NO];

//			if (self.selectedColumnIndexes.count)
//				[self.delegate tableViewSelectionDidChange:nil];
		}

		[self setNeedsDisplay];
		if (!shiftDown && !commandDown)
			[super mouseDown:event];
    }
    else
    {
		if (!commandDown && !shiftDown)
			[self clearSelection:NO];

		[self.delegate tableViewSelectionDidChange:nil];

        //[super mouseDown:event]; // the problem is that this only SOMETIMES posts the tableViewSelectionDidChange notification
        [self setNeedsDisplay];
    }
}

- (void)editColumn:(NSInteger)column row:(NSInteger)row withEvent:(nullable NSEvent *)event select:(BOOL)select
{
	LOGFUNCPARAM(@(select));
	[super editColumn:column row:row withEvent:event select:select];

	if (select)
	{
//		LOGFUNCPARAM(_selectedCellArray);
//		LOGFUNCPARAM(_selectedCellArray[0]);

		if (!_selectedCellArray.count)
		{
			cc_log_debug(@"Info: some cell started editing although we have no selection. We will try a fixup.");
			[self setSelection:row column:column];
		}
//		[self reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:_selectedCellArray[0].rowIndex]
//						columnIndexes:[NSIndexSet indexSetWithIndex:_selectedCellArray[0].columnIndex]];
	}
}
#pragma mark NSTextFieldDelegate

//- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor
//{
//	LOGFUNC
//
//	return YES;
//}
//- (BOOL)textShouldBeginEditing:(NSText *)textObject
//{
//	LOGFUNC
//	return YES;
//}
//
//- (BOOL)textShouldEndEditing:(NSText *)textObject
//{
//
//	LOGFUNC
//	return YES;
//}
//- (void)textDidChange:(NSNotification *)notification
//{
//
//	LOGFUNC
//}

#pragma mark NSTextViewDelegate

- (BOOL)textView:(NSTextView *)tv doCommandBySelector:(SEL)selector
{
    LOGFUNCPARAMA(NSStringFromSelector(selector));
	
	NSInteger row = self.selectedCellArray[0].rowIndex;
	NSInteger col = self.selectedCellArray[0].columnIndex;
    BOOL shiftDown = ([NSEvent modifierFlags] & NSEventModifierFlagShift) > 0;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wselector"

//    if ((aSelector == @selector(moveUp:) || (aSelector == @selector(moveDown:)) ||
//        (aSelector == @selector(moveLeft:)) || (aSelector == @selector(moveRight:))) &&
//        _document.editingColumn >= 0 && _document.editingRow >= 0)
//        return NO;

	if (selector == @selector(insertNewline:))
	{
		shiftDown ? row -- : row ++;
	}
//	else if (aSelector == @selector(moveUp:))
//	{
//		row --;
//	}
//	else if (aSelector == @selector(moveDown:))
//	{
//		row ++;
//	}
	else if (
//			 aSelector == @selector(moveLeft:) ||
			 selector == @selector(insertBacktab:))
	{
		if (!(col == 1 && row == 0)) // move back if not first
			col--;
	}
	else if (
//			 aSelector == @selector(moveRight:) ||
			 selector == @selector(insertTab:))
	{
		if (!(col == (int)self.tableColumns.count - 1 && row == [self.dataSource numberOfRowsInTableView:self] - 1))
			col++;
	}
	else
		return NO;

#pragma clang diagnostic pop


	//	col = CLAMP(col, 1, (NSInteger)self.tableColumns.count - 1);  // go to prev/next row if at end
	if (col < 1)
	{
		col = (NSInteger)self.tableColumns.count - 1;
		row--;
	}
	else if (col >(NSInteger)self.tableColumns.count - 1)
	{
		col = 1;
		row++;
	}


	row = CLAMP(row, 0, [self.dataSource numberOfRowsInTableView:self] - 1);



	[self setSelection:row column:col];
	[[self window] makeFirstResponder:self];

	[self setNeedsDisplay];
	[self.delegate tableViewSelectionDidChange:nil];
	
	[self scrollRowToVisible:row];
	[self scrollColumnToVisible:col == 1 ? 0 : col];


	return NO;
}

#pragma mark accessors

- (NSArray <Cell *> *)selectedCells
{
	return _selectedCellArray;
}

#pragma mark drag & drop

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
	LOGFUNC
	if ([self.delegate respondsToSelector:_cmd])
		[(id <NSDraggingDestination>)self.delegate prepareForDragOperation:sender];
	return YES;
}

- (void)draggingExited:(id < NSDraggingInfo >)sender
{
	LOGFUNC
	if (![self.delegate respondsToSelector:_cmd]) return;
	[(id <NSDraggingDestination>)self.delegate draggingExited:sender];
}

//- (void)concludeDragOperation:(id < NSDraggingInfo >)sender
//{
//	LOGFUNC
//	if (![self.delegate respondsToSelector:_cmd]) return;
//	if (![self.delegate respondsToSelector:_cmd]) return;
//}
//
//- (void)draggingEnded:(id < NSDraggingInfo >)sender
//{
//	LOGFUNC
//	if (![self.delegate respondsToSelector:_cmd]) return;
//	if (![self.delegate respondsToSelector:_cmd]) return;
//}

- (NSDragOperation)draggingUpdated:(id < NSDraggingInfo >)sender
{
	return [self.dataSource tableView:self validateDrop:sender proposedRow:0 proposedDropOperation:0];
}

//
//- (NSRect)frameOfCellAtColumn:(NSInteger)column row:(NSInteger)row
//{
//	NSRect newClipRect = [super frameOfCellAtColumn:column row:row];
//
//	if (column != 1)
//		return newClipRect;
//
//	newClipRect = NSUnionRect(newClipRect, [super frameOfCellAtColumn:4 row:row]);
//
//	return newClipRect;
//}

//- (void)drawRow:(int)inRow clipRect:(NSRect)inClipRect
//{
//	NSRect newClipRect = inClipRect;
//
//	newClipRect = NSUnionRect(newClipRect, [self frameOfCellAtColumn:4 row:inRow]);
//
//	[super drawRow:inRow clipRect:newClipRect];
//}

@end

//
//NSArray *sortedSelection = [self.selectedCellArray sortedArrayWithOptions:(NSSortOptions)0
//																usingComparator:^NSComparisonResult(Cell *c1, Cell *c2)
//	{
//		if (c1.rowIndex == c2.rowIndex) return c1.columnIndex > c2.columnIndex;
//		else return c1.rowIndex > c2.rowIndex;
//	}];


NSString *processPasteForExcelMultiline(NSString *paste)
{
    for (int i = -1; i < (int)paste.length-1; i++)
    {
        if (i >= (int)paste.length-1)
            break;


        unichar c1 = [paste characterAtIndex:MAX(0,i)];
        unichar c2 = [paste characterAtIndex:i+1];


        if (((c1 == '\n' || c1 == '\r' || c1 == '\t') && c2 == '\"') ||
            ((i == -1) && (c2 == '\"')))
        {

            NSMutableArray *tmp = makeMutableArray();

            for (unsigned int v = i+2; v < paste.length; v++)
            {
                unichar c3 = [paste characterAtIndex:v];

                if (c3 == '\t')
                    break;

                if (c3 == '\n' || c3 == '\r')
                    [tmp addObject:@(v)];

                if (c3 == '\"')
                {
                    paste = [paste stringByReplacingCharactersInRange:NSMakeRange(i+1, 1) withString:@" "];


                    for (NSNumber *del in tmp)
                        paste = [paste stringByReplacingCharactersInRange:NSMakeRange(del.intValue, 1) withString:@" "];

                    paste = [paste stringByReplacingCharactersInRange:NSMakeRange(v, 1) withString:@" "];
                    break;
                }
            }
        }
    }
    return paste;
}
