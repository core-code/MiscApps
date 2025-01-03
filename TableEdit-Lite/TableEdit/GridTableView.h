//
//  GridTableView.h
//  TableEdit-Lite
//
//  Created by CoreCode on 28/06/13.
/*    Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/



@class Document;
@class DocumentData;
@class Cell;
#import "DraggableImage.h"

@interface GridTableView : NSTableView <SelectionKnobDragDelegate>


@property (weak, nonatomic) Document *document;
@property (weak, nonatomic) DocumentData *data;
@property (readonly, nonatomic) NSArray <Cell *> *selectedCells;
@property (readonly, nonatomic) NSMutableDictionary <NSString *, NSNumber *> *selectedCellMap;
@property (readonly, nonatomic) BOOL selectionIsSingleRect;
@property (readonly, nonatomic) CCIntRange2D selectionExtents;
@property (readonly, nonatomic) BOOL optionDown;
//@property (assign, nonatomic) BOOL hasOpenedUndoGroup;

- (void)addColumnToSelection:(NSInteger)col;
- (void)addColumnsToSelection:(NSInteger)min maxColumn:(NSInteger)max;
- (void)addRowToSelection:(NSInteger)row;
- (void)addRowsToSelection:(NSInteger)min maxRow:(NSInteger)max;
- (void)clearSelection:(BOOL)suppressChangeNotification;
- (void)preventUpdateSelectionInformation;
- (void)updateSelectionInformation;

@end

