//
//  DocumentData.h
//  TableEdit-Lite
//
//  Created by CoreCode on 07.09.15.
/*    Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/


#import "Cell.h"

@interface DocumentData : NSObject


- (instancetype)initWithUndoManager:(NSUndoManager *)undoManager;


// read / write
- (BOOL)read:(NSData *)data;
- (NSData *)write;

// import / export
- (BOOL)importData:(NSArray <NSArray <NSString *> *> *)importedData
		attributes:(NSArray <NSArray <NSMutableDictionary *>*> *)importedAttributes
			action:(importChoice)action
		 selection:(CCIntRange2D)selection;
- (void)exportCSV:(NSURL *)destination delimiter:(NSString *)delimiter encoding:(NSStringEncoding)encoding;
- (void)exportExcel:(NSURL *)destination xml:(BOOL)xml;
- (void)exportPDF:(NSURL *)destination withView:(NSView *)printView;


// modify table
- (void)resizeTable:(coordinates)newSize;
- (void)insertRow:(NSUInteger)insertLocation;
- (void)insertColumn:(NSUInteger)insertLocation;
- (void)removeRows:(NSIndexSet *)rowIndices;
- (void)removeColums:(NSIndexSet *)columnIndices;
- (void)moveColumn:(NSUInteger)columnIndex toIndex:(NSUInteger)destinationColumn;
- (void)moveRows:(NSIndexSet *)rowIndices toIndex:(NSUInteger)destinationRow;
- (void)sortColumn:(NSUInteger)column ascending:(BOOL)ascending rowsToSort:(NSIndexSet *)rowIndices wholeTable:(BOOL)wholeTable;

// write data
- (void)modifyAttributesOfCell:(Cell *)c withBlock:(void (^)(NSMutableDictionary *a))block;
- (void)modifyAttributesOfCells:(NSArray <Cell *> *)cells inCellMap:(NSMutableDictionary <NSString *, NSNumber *> *)cellMap withBorder:(borderPlacement)border;
- (void)writeData:(id)data toCellAtRow:(NSUInteger)r column:(NSUInteger)c;
- (void)setColumn:(NSUInteger)column value:(id)value forKey:(NSString *)key;



// private
- (void)_exportAttributeCSV:(NSURL *)destination delimiter:(NSString *)delimiter encoding:(NSStringEncoding)encoding;





// graphs
- (void)setGraph:(NSDictionary *)graph value:(id)value forKey:(NSString *)key;



// validate
- (void)validate;


// data
- (NSString *)valueForRow:(NSUInteger)rowIndex column:(NSUInteger)columnIndex throw:(BOOL)throwOnCircular;

@property (nonatomic, strong) NSArray <NSArray <NSDictionary *>*> *attributes;
@property (nonatomic, strong) NSArray <NSArray <NSString *>*>  *data;
@property (nonatomic, strong) NSArray <NSDictionary *> *columns;
@property (nonatomic, strong) NSArray <NSDictionary *> *graphs;

@property (nonatomic, assign) BOOL enableRowColors;
@property (nonatomic, strong) NSColor *oddRowColor;
@property (nonatomic, strong) NSColor *evenRowColor;

@property (nonatomic, readonly) NSUInteger rowCount;
@property (nonatomic, readonly) NSUInteger columnCount;

@end
