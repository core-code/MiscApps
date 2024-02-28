//
//  DocumentData.m
//  TableEdit-Lite
//
//  Created by CoreCode on 07.09.15.
/*    Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/


#import "DocumentData.h"
#import "AddressHelper.h"
#import "FormulaResult.h"

@interface DocumentData ()


@property (nonatomic, strong) NSMutableArray <NSMutableArray <NSString *>*> *data_;
@property (nonatomic, strong) NSMutableArray <NSMutableArray <NSMutableDictionary *>*> *attributes_;
@property (nonatomic, strong) NSMutableArray <NSMutableDictionary *> *columns_;
@property (nonatomic, strong) NSMutableArray <NSMutableDictionary *> *graphs_;

@property (nonatomic, strong) NSUndoManager *undoManager;
@property (nonatomic, strong) id receiver;

@end



@implementation DocumentData

@dynamic data, attributes, columns, graphs, rowCount, columnCount;


- (id)initWithUndoManager:(NSUndoManager *)undoManager
{
	self = [super init];

	if (self)
	{
		LOGFUNC

		_data_ = @[@[].mutableObject].mutableObject;
		_attributes_ = @[@[].mutableObject].mutableObject;
		_columns_ = @[].mutableObject;

		_graphs_ = makeMutableArray();


		_enableRowColors = (BOOL)kRowColorsEnabledKey.defaultInt;
		_oddRowColor = [NSUnarchiver unarchiveObjectWithData:kOddRowColorKey.defaultObject];
		_evenRowColor = [NSUnarchiver unarchiveObjectWithData:kEvenRowColorKey.defaultObject];


		_undoManager = undoManager;

	}

	return self;
}

- (void)dealloc
{
    LOGFUNC
	[notificationCenter removeObserver:self.receiver];
}

- (id)init
{
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (void)writeData:(id)data toCellAtRow:(NSUInteger)r column:(NSUInteger)c
{
	_data_[r][c] = data; // datawrite
}

- (void)setColumn:(NSUInteger)column value:(id)value forKey:(NSString *)key
{
	_columns_[column][key] = value;
}


#pragma mark read / write

void _up(NSMutableDictionary *cell, NSString *old, NSString *new) { id a = cell[old]; if (a) { cell[new] = a; [cell removeObjectForKey:old]; } }

- (BOOL)read:(NSData *)data
{
	LOGFUNC
	NSDate *pre = [NSDate date];
	NSData *uncompressedData = data.snappyDecompressed;
	if (!uncompressedData)
		return NO;
	NSDictionary *dict = [NSUnarchiver unarchiveObjectWithData:uncompressedData];

	if (!dict || ![dict isKindOfClass:NSDictionary.class])
		return NO;


	if (self.columnCount > 0 || self.rowCount != 1)
	{
		cc_log(@"Warning: read performed on existing Document instance, this must have been the 'Revert Changes' feature");
	}


	NSData *unarchivedData = dict[@"data"];

	_data_ = [NSJSONSerialization JSONObjectWithData:unarchivedData options:NSJSONReadingMutableContainers error:NULL];
	_attributes_ = dict[@"attributes"];
	_columns_ = dict[@"columns"];
	if (dict[@"graphs"])
		_graphs_ = [dict[@"graphs"] mapped:^id(NSDictionary *input) { return input.mutableObject; }].mutableObject;

	//			NSLog(@"GraphInfo: restored graphs %p %@", _graphs, _graphs.description);

	NSDictionary *properties = dict[@"properties"];
	if (properties)
	{
		_enableRowColors = [properties[@"enableRowColors"] boolValue];
		_oddRowColor = properties[@"oddRowColor"];
		_evenRowColor = properties[@"evenRowColor"];
	}

    NSNumber *fileVersion = dict[@"version"];

    if (fileVersion.intValue < 2)
    { // migrate
        cc_log(@"Warning: migrating old file to version 2");


        for (NSMutableArray <NSMutableDictionary *> *row in _attributes_)
        {
            for (NSMutableDictionary *cellattributes in row)
            {
                _up(cellattributes, @"format", kFormatTypeKey);
                _up(cellattributes, @"formatNumber", kFormatNumberTypeKey);

                if ([cellattributes[kFormatTypeKey] intValue] != formatString)
                {
                    int new = [cellattributes[kFormatTypeKey] intValue] + 1;

                    if (new > formatNumber)
                    {
                        new = formatNumber;
                        cc_log(@"Error: increased too much %@", cellattributes); // TODO: why is this hit?
                    }

                    cellattributes[kFormatTypeKey] = @(new);
                }

                _up(cellattributes, @"formatDecimals", kFormatNumberDecimalsKey);
                _up(cellattributes, @"formatGrouping", kFormatNumberGroupingKey);
                _up(cellattributes, @"formatCurrency", kFormatNumberCurrencyCurrencyKey);
                _up(cellattributes, @"formatCustomPositiveFormat", kFormatNumberCustomPositiveFormatKey);
                _up(cellattributes, @"formatCustomNegativeFormat", kFormatNumberCustomNegativeFormatKey);
                _up(cellattributes, @"formatDate", kFormatDateDateKey);
                _up(cellattributes, @"formatTime", kFormatDateTimeKey);



                _up(cellattributes, @"background", kBackgroundColorKey);
                _up(cellattributes, @"borderColor", kBackgroundBorderColorKey);
                _up(cellattributes, @"borderWidth", kBackgroundBorderWidthKey);
                _up(cellattributes, @"bordlerLeft", kBackgroundBorderExistsLeftKey);
                _up(cellattributes, @"borderRight", kBackgroundBorderExistsRightKey);
                _up(cellattributes, @"borderBottom", kBackgroundBorderExistsBottomKey);
                _up(cellattributes, @"borderTop", kBackgroundBorderExistsTopKey);
                _up(cellattributes, @"merged", kBackgroundBorderMergedKey);


                _up(cellattributes, @"font", kFontFontKey);
                _up(cellattributes, @"fontColor", kFontColorKey);
                _up(cellattributes, @"alignment", kFontAlignmentKey);
            }
        }
    }
    if (fileVersion.intValue < 3)
    { // migrate
        cc_log(@"Warning: migrating old file to version 3");


        for (NSMutableArray <NSMutableDictionary *> *row in _attributes_) // previously we did not make sure each attribute was an unique object which of course led to bugs
        {
            for (NSUInteger column = 0; column < row.count; column++)
            {
                NSMutableDictionary *currentAttributes = row[column];

                [row replaceObjectAtIndex:column withObject:currentAttributes.mutableCopy];
            }
        }
    }
    
    // check compatibility with lite
    NSMutableArray *usedProFeatures = makeMutableArray();
    if (_enableRowColors)
        [usedProFeatures addNewObject:@"Row Colors"];
    for (NSMutableArray <NSMutableDictionary *> *row in _attributes_) // previously we did not make sure each attribute was an unique object which of course led to bugs
    {
        for (NSUInteger column = 0; column < row.count; column++)
        {
            NSMutableDictionary *currentAttributes = row[column];
            // TODO differenciate:
            //cell content styling including fonts, font styles and sizes, font colors and text alignment
            //cell background styling including fill-colors and borders
            //cell formatting as currencies, date and time formats and different numbers formats like scientific or percentages
            if (currentAttributes.allKeys.count)
                [usedProFeatures addNewObject:@"Cell Attributes"];
        }
    }
    for (NSMutableArray <NSString *> *row in _data_) // previously we did not make sure each attribute was an unique object which of course led to bugs
    {
        for (NSUInteger column = 0; column < row.count; column++)
        {
            NSString *currentData = row[column];
            
            if ([currentData hasPrefix:@"="])
                [usedProFeatures addNewObject:@"Formulae / Functions"];
        }
    }
    if (_graphs_.count)
        [usedProFeatures addNewObject:@"Graphs / Charts"];
    if (usedProFeatures.count)
    {
        // TODO check forfloating header rows, adjustable row height, table scaling & magnification
        dispatch_after_main(1.0, ^
        {
            NSString *features = [usedProFeatures joined:@"\n"];
            
            NSInteger choice = alert(@"Compatibility Warning", makeString(@"This spreadsheet contains features not compatible with TableEdit-Lite:\n\n%@\n\nYou should consider either switching to the newest, paid version of TableEdit\nor use the latest old free version of TableEdit (v1.3), which supports all those features.", features),
                  @"Download free TableEdit 1.3", @"Buy newest TableEdit", @"Cancel");
            
            if (choice == NSAlertFirstButtonReturn)
                [@"https://www.corecode.io/downloads/tableedit_1.3.0.zip".URL open];
            else if (choice == NSAlertSecondButtonReturn)
                [@"https://itunes.apple.com/us/app/tableedit/id902476958?mt=12&at=1000lwks".URL open];
        });
    }
        
        
	cc_log(@"READ took %.2fs for %i bytes", [[NSDate date] timeIntervalSinceDate:pre], (int)data.length);


    VALIDATE;

	return	_data_ != nil &&
			_attributes_ != nil &&
			_columns_ != nil &&
			_data_.id != _attributes_ &&
			(id)_attributes_ != _columns_ &&
			(id)_data_ != _columns_;
}

- (NSData *)write
{
	LOGFUNC
	NSDate *pre = [NSDate date];

	NSData *serializedData = _data_.JSONData;
	NSArray *serializableGraphs = [_graphs_ mapped:^id(NSDictionary *input)
	{
		return [input dictionaryByRemovingKeys:@[@"plot", @"graph", @"graphView"]];
	}];
	NSDictionary *properties =  @{@"enableRowColors" : @(self.enableRowColors),
								  @"oddRowColor" : self.oddRowColor,
								  @"evenRowColor" : self.evenRowColor};

	NSDictionary *dict = @{@"data" : serializedData,
                           @"attributes" : _attributes_,
                           @"columns" : _columns_,
                           @"graphs" : serializableGraphs,
                           @"properties" : properties,
                           @"version" : @(3)};

	NSData *serializedEverything = [NSArchiver archivedDataWithRootObject:dict].snappyCompressed;


	cc_log(@"WRITE took %.2fs for %i bytes", [[NSDate date] timeIntervalSinceDate:pre], (int)serializedEverything.length);

	return serializedEverything;
}

#pragma mark import / export

- (BOOL)importData:(NSArray <NSArray <NSString *> *> *)importedData attributes:(NSArray <NSArray <NSMutableDictionary *>*> *)importedAttributes action:(importChoice)action selection:(CCIntRange2D)selection
{
	LOGFUNC
	NSUInteger importRow = 0, importColumn = 0;
	coordinates newTableSize = {0,0};

	assert(action != importNewDocument);
	if (action == importReplaceEverything)
	{
		_data_ = @[@[].mutableObject].mutableObject;
		_attributes_ = @[@[].mutableObject].mutableObject;
		_columns_ = @[].mutableObject;
		
		newTableSize.row = importedData.count + kPaddingRowsKey.defaultInt;
		newTableSize.column = [[importedData valueForKeyPath:@"@max.self.@count"] intValue] + kPaddingColumnsKey.defaultInt;
	}
	else
	{
		if (action == importReplaceAtSelection && selection.min.x != INT_MAX && selection.min.y != INT_MAX)
		{
			assert(selection.min.x > 0);
			assert(selection.min.y >= 0);
			assert(action == importReplaceAtSelection);

			importRow = selection.min.y;
			importColumn = selection.min.x-1;


			newTableSize.row = MAX(self.rowCount, importRow + importedData.count + kPaddingRowsKey.defaultInt);
			newTableSize.column = MAX(self.columnCount, importColumn + [[importedData valueForKeyPath:@"@max.self.@count"] unsignedIntegerValue] + kPaddingColumnsKey.defaultInt);
			
		}
		else // either action == importAppend or importReplaceAtSelection but we don't have selection, so treat as append too
		{
			importRow = _data_.count;

			newTableSize.row = importRow + importedData.count + kPaddingRowsKey.defaultInt;
			newTableSize.column = MAX(self.columnCount, [[importedData valueForKeyPath:@"@max.self.@count"] unsignedIntegerValue] + kPaddingColumnsKey.defaultInt);
		}
	}


	//	if (!_newColumns || !_newRows)
	//		return NO;



	[self resizeTable:newTableSize];

	NSUInteger row = importRow, column = importColumn;
	for (NSArray *rowData in importedData)
	{
		for (NSString *cellData in rowData)
		{
			_data_[row][column] = cellData; // datawrite

			if (importedAttributes)
				_attributes_[row][column] = importedAttributes[row-importRow][column-importColumn];

			column++;
		}
		row++;
		column = importColumn;
	}


    VALIDATE;

	return YES;
}

- (void)exportCSV:(NSURL *)destination delimiter:(NSString *)delimiter encoding:(NSStringEncoding)encoding
{
	LOGFUNC
	NSDate *pre = [NSDate date];
	NSMutableString *export = makeMutableString();

	for (NSArray *row in _data_)
	{
        for (NSString *obj in row)
        {
            if ([obj isKindOfClass:NSString.class] &&
                ([obj contains:delimiter] || [obj contains:@" "] || [obj contains:@"\""]))
            {
                [export appendString:@"\""];
                NSString *fieldStr = obj.stringValue;
                fieldStr = [fieldStr replaced:@"\"" with:@"\"\""];
                [export appendString:fieldStr];
                [export appendString:@"\""];
            }
            else
                [export appendString:obj.stringValue];
            
            [export appendString:delimiter];
        }

        [export deleteCharactersInRange:NSMakeRange(export.length-delimiter.length, delimiter.length)];
		[export appendString:@"\n"];
	}

    [export deleteCharactersInRange:NSMakeRange(export.length-1, 1)];

	[export writeToURL:destination atomically:YES encoding:encoding error:NULL];

	cc_log(@"EXPORT took %.2fs for %i bytes", [[NSDate date] timeIntervalSinceDate:pre], (int)export.length);
}

- (void)_exportAttributeCSV:(NSURL *)destination delimiter:(NSString *)delimiter encoding:(NSStringEncoding)encoding
{
    LOGFUNC
    NSDate *pre = [NSDate date];
    NSMutableString *export = makeMutableString();

    for (NSArray *row in _attributes_)
    {
        for (NSDictionary *obj in row)
        {
            [export appendString:[[obj.description replaced:delimiter with:@""] replaced:@"\n" with:@""]];
            [export appendString:delimiter];
        }

        [export deleteCharactersInRange:NSMakeRange(export.length-delimiter.length, delimiter.length)];
        [export appendString:@"\n"];
    }

    [export deleteCharactersInRange:NSMakeRange(export.length-1, 1)];

    [export writeToURL:destination atomically:YES encoding:encoding error:NULL];

    cc_log(@"EXPORT took %.2fs for %i bytes", [[NSDate date] timeIntervalSinceDate:pre], (int)export.length);
}

- (void)exportExcel:(NSURL *)destination xml:(BOOL)xml
{
	LOGFUNC
	BookHandle book = xml ? xlCreateXMLBook() : xlCreateBook();
	assert(book);
    xlBookSetKey(book, LIBXLNAME, LIBXLKEY);
	xlBookSetLocale(book,"UTF-8");

	SheetHandle sheet = xlBookAddSheet(book, "Sheet1", 0);

	assert(sheet);

    //xlSheetSplit(sheet, 3, 0); // TODO: maybe this is good for "TOP ROWS"

	int r = 0, c = 0;
	for (NSMutableArray *row in _data_)
	{
		c = 0;
		for (NSString *obj in row)
		{
			if (obj.stringValue.isFloatNumber)
				xlSheetWriteNum(sheet, r, c, obj.stringValue.doubleValue, NULL);
			else
				xlSheetWriteStr(sheet, r, c, obj.stringValue.UTF8String, NULL);
			c++;
		}
		r++;
	}

	xlBookSave(book, destination.path.UTF8String);
	xlBookRelease(book);
}

- (void)exportPDF:(NSURL *)destination withView:(NSView *)printView
{
    NSData *pdfData = [printView dataWithPDFInsideRect:printView.bounds];
    [pdfData writeToURL:destination atomically:YES];
}

#pragma mark modify

- (void)resizeTable:(coordinates)newSize
{
	LOGFUNC

	[_undoManager beginUndoGrouping];
	[_undoManager setActionName:@"Resize Table"];

	if (self.rowCount > newSize.row)
	{
		[self removeRows:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.rowCount - (self.rowCount - newSize.row), self.rowCount - newSize.row)]];
	}
	else if (self.rowCount < newSize.row)
	{
		NSUInteger additionalRowCount = newSize.row - self.rowCount;
		NSMutableArray<NSMutableArray<NSString *> *> *dataRows = makeMutableArray();
		NSMutableArray<NSMutableArray<NSMutableDictionary *> *> *attributeRows = makeMutableArray();

		for (NSUInteger i = 0; i < additionalRowCount; i++)
		{
			NSMutableArray<NSString *> *dataRow = makeMutableArray();
			NSMutableArray<NSMutableDictionary *> *attributeRow = makeMutableArray();

			for (NSUInteger v = 0; v < self.columnCount; v++)
			{
				[dataRow addObject:@""];
				[attributeRow addObject:makeMutableDictionary()];
			}

			[dataRows addObject:dataRow];
			[attributeRows addObject:attributeRow];
		}


		[self insertRowsWithData:dataRows
					  attributes:attributeRows
					   atIndices:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.rowCount, additionalRowCount)]];
	}

    assert(self.rowCount == newSize.row);

	if (self.columnCount > newSize.column)
	{
		[self removeColums:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.columnCount - (self.columnCount - newSize.column), self.columnCount - newSize.column)]];
	}
	else if (self.columnCount < newSize.column)
	{
		NSUInteger additionalColumnCount = newSize.column - self.columnCount;
		NSMutableArray<NSMutableArray<NSString *> *> *dataRows = makeMutableArray();
		NSMutableArray<NSMutableArray<NSMutableDictionary *> *> *attributeRows = makeMutableArray();

		for (NSUInteger i = 0; i < self.rowCount; i++)
		{
			NSMutableArray<NSString *> *dataRow = makeMutableArray();
			NSMutableArray<NSMutableDictionary *> *attributeRow = makeMutableArray();

			for (NSUInteger v = 0; v < additionalColumnCount; v++)
			{
				[dataRow addObject:@""];
				[attributeRow addObject:makeMutableDictionary()];
			}

			[dataRows addObject:dataRow];
			[attributeRows addObject:attributeRow];
		}

		NSMutableArray <NSMutableDictionary *> *newColumns = makeMutableArray();
		for (NSUInteger v = 0; v < additionalColumnCount; v++)
			[newColumns addObject:makeMutableDictionary()];



		[self insertColumns:newColumns
					   data:dataRows
				 attributes:attributeRows
				  atIndices:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.columnCount, additionalColumnCount)]];
	}

	[_undoManager setActionName:@"Resize Table"];
	[_undoManager endUndoGrouping];
}

- (void)removeRows:(NSIndexSet *)rowIndices
{
	LOGFUNCPARAM(makeString(@"%lu => %lu", (unsigned long)self.rowCount, self.rowCount - rowIndices.count));

	assert([rowIndices indexPassingTest:^BOOL(NSUInteger idx, BOOL * _Nonnull stop) { return idx >= self.rowCount; } ] == NSNotFound);



	NSArray <NSMutableArray <NSString *>*> *removedDataObjects = [_data_ objectsAtIndexes:rowIndices];
	NSArray <NSMutableArray <NSMutableDictionary *> *> *removedAttributeObjects = [_attributes_ objectsAtIndexes:rowIndices];


	[[_undoManager prepareWithInvocationTarget:self] insertRowsWithData:removedDataObjects
															 attributes:removedAttributeObjects
															  atIndices:rowIndices];
	if (![_undoManager.undoActionName contains:@"Resize Table"] && !self.undoManager.isUndoing)
		[_undoManager setActionName:@"Remove Row"];


	[_data_ removeObjectsAtIndexes:rowIndices];
	[_attributes_ removeObjectsAtIndexes:rowIndices];
}

- (void)removeColums:(NSIndexSet *)columnIndices
{
	LOGFUNCPARAM(makeString(@"%@  %lu => %lu", columnIndices.description, (unsigned long)self.columnCount, self.columnCount - columnIndices.count));

	assert([columnIndices indexPassingTest:^BOOL(NSUInteger idx, BOOL * _Nonnull stop) { return idx >= self.columnCount; } ] == NSNotFound);



	NSMutableArray *removedDataObjects = makeMutableArray();
	NSMutableArray *removedAttributeObjects = makeMutableArray();
	NSArray <NSMutableDictionary *> * removedColumnObjects;




	for (NSMutableArray *row in _data_)
	{
		[removedDataObjects addObject:[row objectsAtIndexes:columnIndices]];
		[row removeObjectsAtIndexes:columnIndices];
	}
	for (NSMutableArray *row in _attributes_)
	{
		[removedAttributeObjects addObject:[row objectsAtIndexes:columnIndices]];
		[row removeObjectsAtIndexes:columnIndices];
	}


	removedColumnObjects = [_columns_ objectsAtIndexes:columnIndices];
	[_columns_ removeObjectsAtIndexes:columnIndices];


	[[_undoManager prepareWithInvocationTarget:self] insertColumns:removedColumnObjects
															  data:removedDataObjects
														attributes:removedAttributeObjects
														 atIndices:columnIndices];

	if (![_undoManager.undoActionName contains:@"Resize Table"])
		[_undoManager setActionName:@"Remove Column"];

}

- (void)insertRowsWithData:(NSArray <NSMutableArray <NSString *>*> *)rowData
				attributes:(NSArray <NSMutableArray <NSMutableDictionary *> *> *)rowAttributes
				 atIndices:(NSIndexSet *)rowIndices
{	// just here for undoing...and resize table
	LOGFUNCPARAM(makeString(@"%lu => %lu", (unsigned long)self.rowCount, self.rowCount + rowIndices.count));

	[[_undoManager prepareWithInvocationTarget:self] removeRows:rowIndices];

#ifdef DEBUG
    for (NSArray *newRow in rowData) assert(newRow.count == self.columnCount); // TODO: this can trigger
    for (NSArray *newRow in rowAttributes) assert(newRow.count == self.columnCount);
    assert(rowData.count == rowIndices.count);
    assert(rowAttributes.count == rowIndices.count);
#endif

	[_data_ insertObjects:rowData atIndexes:rowIndices];
	[_attributes_ insertObjects:rowAttributes atIndexes:rowIndices];
}

- (void)insertColumns:(NSArray <NSMutableDictionary *> *)newColumnObjects
				 data:(NSArray <NSArray <NSString *>*> *)newDataObjects
		   attributes:(NSArray <NSArray <NSMutableDictionary *>*> *)newAttributeObjects
			atIndices:(NSIndexSet *)columnIndices
{	// just here for undoing...and resize table
	LOGFUNCPARAM(makeString(@"%lu => %lu", (unsigned long)self.columnCount, self.columnCount + columnIndices.count));

	[[_undoManager prepareWithInvocationTarget:self] removeColums:columnIndices];

    assert(newDataObjects.count == self.rowCount);
    assert(newAttributeObjects.count == self.rowCount);

    assert(newColumnObjects.count == columnIndices.count);


	for (NSUInteger row = 0; row < self.rowCount; row++)
	{
		[_data_[row] insertObjects:newDataObjects[row] atIndexes:columnIndices];
		[_attributes_[row] insertObjects:newAttributeObjects[row] atIndexes:columnIndices];
	}

	[_columns_ insertObjects:newColumnObjects atIndexes:columnIndices];
}

- (void)insertRow:(NSUInteger)insertLocation
{
	LOGFUNC

	[[_undoManager prepareWithInvocationTarget:self] removeRows:[NSIndexSet indexSetWithIndex:insertLocation]];
	[_undoManager setActionName:@"Insert Row"]; // this is never called as part of undo

	NSMutableArray *dataRow = makeMutableArray();
    NSMutableArray *attributeRow = makeMutableArray();

    if (insertLocation > 0)
    {
        for (NSMutableDictionary *attr in _attributes_[insertLocation-1])
            [attributeRow addObject:attr.mutableCopy]; // copy attributes of above row if available - make sure its a deep and mutable copy!
    }


	for (NSUInteger i = 0; i < self.columnCount; i++)
    {
        [dataRow addObject:@""];

        if (insertLocation == 0)
            [attributeRow addObject:makeMutableDictionary()];
    }

	[_data_ insertObject:dataRow atIndex:insertLocation]; // datachange
    [_attributes_ insertObject:attributeRow atIndex:insertLocation]; //attributechange
}

- (void)insertColumn:(NSUInteger)insertLocation
{
	LOGFUNC

	[[_undoManager prepareWithInvocationTarget:self] removeColums:[NSIndexSet indexSetWithIndex:insertLocation]];
	[_undoManager setActionName:@"Insert Column"]; // this is never called as part of undo


	for (NSUInteger row = 0; row < _data_.count; row++) // datachange
	{
		[_data_[row] insertObject:@"" atIndex:insertLocation];
		[_attributes_[row] insertObject:makeMutableDictionary() atIndex:insertLocation]; // attributechange
	}
	[_columns_ insertObject:makeMutableDictionary() atIndex:insertLocation];
}

- (void)moveColumn:(NSUInteger)columnIndex toIndex:(NSUInteger)destinationColumn
{
	LOGFUNCPARAM(makeString(@"from %li to %li", (long)columnIndex, (long)destinationColumn));

	[[_undoManager prepareWithInvocationTarget:self] moveColumn:destinationColumn toIndex:columnIndex];
	[_undoManager setActionName:@"Move Column"];

	for (NSMutableArray *row in self->_data_) // datachange
		 [row moveObjectAtIndex:columnIndex toIndex:destinationColumn];

	for (NSMutableArray *row in self->_attributes_) // datachange
		 [row moveObjectAtIndex:columnIndex toIndex:destinationColumn];


	[self->_columns_ moveObjectAtIndex:columnIndex toIndex:destinationColumn];

}

- (void)moveRows:(NSIndexSet *)rowIndices toIndex:(NSUInteger)destinationRow
{
	LOGFUNC



	[[_undoManager prepareWithInvocationTarget:self] moveRows:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(destinationRow, rowIndices.count)] toIndex:rowIndices.firstIndex];
	[_undoManager setActionName:@"Move Row"];

	// we gotta fuck around cause indices move when we move a row, so the naive approach would only work for moving a single row
	if (destinationRow < rowIndices.firstIndex)
		[rowIndices enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger idx, BOOL *stop)  // datachange
		 { // move to front
			 [self->_data_ moveObjectAtIndex:rowIndices.lastIndex toIndex:destinationRow];
			 [self->_attributes_ moveObjectAtIndex:rowIndices.lastIndex toIndex:destinationRow];
		 }];
	else if (destinationRow > rowIndices.lastIndex)
		[rowIndices enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger idx, BOOL *stop)  // datachange
		 {
			 [self->_data_ moveObjectAtIndex:idx toIndex:destinationRow+(idx-rowIndices.firstIndex)];
			 [self->_attributes_ moveObjectAtIndex:idx toIndex:destinationRow+(idx-rowIndices.firstIndex)];
		 }];
	else
		assert(0);
}

- (void)sortColumn:(NSUInteger)column ascending:(BOOL)ascending rowsToSort:(NSIndexSet *)rowIndices wholeTable:(BOOL)wholeTable
{
    LOGFUNCPARAM(makeString(@"%lu %i %@ %i", (unsigned long)column, ascending, rowIndices, wholeTable));
	assert(column > 0);

	BOOL *rowsToBeSorted = NULL;
	if (rowIndices)
	{
		rowsToBeSorted = calloc(1, sizeof(BOOL) * _data_.count);
		[rowIndices enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
		 {
			 rowsToBeSorted[idx] = TRUE;
		 }];
	}

	NSMutableArray <NSNumber *>*p = [NSMutableArray arrayWithCapacity:_data_.count];
	for (NSUInteger i = 0 ; i != _data_.count ; i++)
		[p addObject:@(i)];

	[p sortWithOptions:(NSSortOptions)0 usingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) // datachange
	 {
		 if (rowIndices && (!rowsToBeSorted[obj1.intValue] || !rowsToBeSorted[obj2.intValue]))
			 return obj1.intValue > obj2.intValue;


		 NSString *lhs = self->_data_[obj1.intValue][column-1];
		 NSString *rhs = self->_data_[obj2.intValue][column-1];
		 NSNumber *lhn = lhs.numberValue;
		 NSNumber *rhn = rhs.numberValue;

		 if (rhn && lhn)
			 return ascending ? lhn.floatValue > rhn.floatValue : lhn.floatValue < rhn.floatValue;
         else if ((lhs.length && !rhs.length) || // place empty rows always at the bottom
                  (!lhs.length && rhs.length))
             return (lhs.length && !rhs.length) ? NSOrderedAscending : NSOrderedDescending;
         else
			 return ascending ?
			 [lhs compare:rhs options:(NSStringCompareOptions)(NSCaseInsensitiveSearch | NSForcedOrderingSearch)] :
			 [rhs compare:lhs options:(NSStringCompareOptions)(NSCaseInsensitiveSearch | NSForcedOrderingSearch)];
	 }];


	if (wholeTable)
        [self _sortTableWithSort:p];
    else
        [self _sortSingleColumn:column-1 withSort:p];
}

- (void)__debugPrintColumn:(NSUInteger)column
{
#ifdef DEBUG
    for (NSArray *row in _data_)
    {
        cc_log_debug(@"%@", row[column]);
    }
#endif
}

- (void)_sortSingleColumn:(NSUInteger)column withSort:(NSArray <NSNumber *>*)p
{
    assert(p.count == self.rowCount);

    NSMutableArray <NSNumber *>*ip = [NSMutableArray arrayWithCapacity:_data_.count];
    for (NSUInteger i = 0 ; i != _data_.count ; i++)
        [ip addObject:@([p indexOfObject:@(i)])];

    [[_undoManager prepareWithInvocationTarget:self] _sortSingleColumn:column withSort:ip];
    [_undoManager setActionName:@"Sort Single Column"];



    NSMutableIndexSet *usedIndices = [NSMutableIndexSet new];

    [p enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop)
     {
         NSUInteger row = idx;
         NSUInteger newRow = obj.intValue;

         if (![usedIndices containsIndex:row])
         {
             id destinationData = self->_data_[newRow][column]; // datawrite
             self->_data_[newRow][column] = self->_data_[row][column];
             self->_data_[row][column] = destinationData;


             id destinationAttributes = self->_attributes_[newRow][column];
             self->_attributes_[newRow][column] = self->_attributes_[row][column];
             self->_attributes_[row][column] = destinationAttributes;

             [usedIndices addIndex:newRow];
         }
     }];
}

- (void)_sortTableWithSort:(NSArray <NSNumber *>*)p
{
	assert(p.count == self.rowCount);

	NSMutableArray <NSNumber *>*ip = [NSMutableArray arrayWithCapacity:_data_.count];
	for (NSUInteger i = 0 ; i != _data_.count ; i++)
		[ip addObject:@([p indexOfObject:@(i)])];

	[[_undoManager prepareWithInvocationTarget:self] _sortTableWithSort:ip];
	[_undoManager setActionName:@"Sort Table"];

	NSMutableArray *sortedData = [NSMutableArray arrayWithCapacity:_data_.count];
	NSMutableArray *sortedAttributes = [NSMutableArray arrayWithCapacity:_data_.count];

	[p enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop)
	{
		 [sortedData addObject:[self->_data_ objectAtIndex:obj.intValue]];
		 [sortedAttributes addObject:[self->_attributes_ objectAtIndex:obj.intValue]];
	}];


	_data_ = sortedData;
	_attributes_ = sortedAttributes;
}

- (void)setGraph:(NSDictionary *)graph value:(id)value forKey:(NSString *)key
{
	LOGFUNC
	if (!value)
		[(NSMutableDictionary *)graph removeObjectForKey:key];
	else
		[(NSMutableDictionary *)graph setValue:value forKey:key];
}


- (void)modifyAttributesOfCells:(NSArray <Cell *> *)cells inCellMap:(NSMutableDictionary <NSString *, NSNumber *> *)cellMap withBorder:(borderPlacement)border
{
	LOGFUNC
	// attributechange
	switch (border)
	{
		case borderNone:
		{
			for (Cell *c in cells)
			{
				NSMutableDictionary *a = _attributes_[c.rowIndex][c.columnIndex-1];
				[[_undoManager prepareWithInvocationTarget:self] setAttributesOfCell:c toDictionary:a.copy];

				[a removeObjectForKey:kBackgroundBorderExistsBottomKey];
				[a removeObjectForKey:kBackgroundBorderExistsTopKey];
				[a removeObjectForKey:kBackgroundBorderExistsLeftKey];
				[a removeObjectForKey:kBackgroundBorderExistsRightKey];

				if (c.columnIndex > 1)
				{
					NSMutableDictionary *a1 = _attributes_[c.rowIndex][c.columnIndex-2];
					[[_undoManager prepareWithInvocationTarget:self] setAttributesOfCell:[Cell cellWithColumnIndex:c.columnIndex-1 rowIndex:c.rowIndex column:nil]
																			toDictionary:a1.copy];

					[a1 removeObjectForKey:kBackgroundBorderExistsRightKey];
				}
				if (c.rowIndex > 0)
				{
					NSMutableDictionary *a2 = _attributes_[c.rowIndex-1][c.columnIndex-1];
					[[_undoManager prepareWithInvocationTarget:self] setAttributesOfCell:[Cell cellWithColumnIndex:c.columnIndex rowIndex:c.rowIndex-1 column:nil]
																			toDictionary:a2.copy];
					[a2 removeObjectForKey:kBackgroundBorderExistsBottomKey];
				}
			}
		}
			break;
		case borderAll:
		case borderInner:
		case borderHorizontal:
		{
			for (Cell *c in cells)
			{
				if ([cellMap valueForKey:[AddressHelper indicesToString:c.columnIndex+1 rowIndex:c.rowIndex]])
				{
					NSMutableDictionary *a = _attributes_[c.rowIndex][c.columnIndex-1];
					[[_undoManager prepareWithInvocationTarget:self] setAttributesOfCell:c toDictionary:a.copy];


					a[kBackgroundBorderExistsRightKey] = @(1);
				}
			}
		}
			if (border == borderHorizontal)
				break;
		case borderVertical:
		{
			for (Cell *c in cells)
			{
				if ([cellMap valueForKey:[AddressHelper indicesToString:c.columnIndex rowIndex:c.rowIndex+1]])
				{
					NSMutableDictionary *a = _attributes_[c.rowIndex][c.columnIndex-1];
					[[_undoManager prepareWithInvocationTarget:self] setAttributesOfCell:c toDictionary:a.copy];


					a[kBackgroundBorderExistsBottomKey] = @(1);
				}
			}
		}
			if (border == borderVertical || border == borderInner)
				break;
		case borderOuter:
		case borderLeft:
		{
			for (Cell *c in cells)
			{
				if (![cellMap valueForKey:[AddressHelper indicesToString:c.columnIndex-1 rowIndex:c.rowIndex]])
				{
					if (c.columnIndex > 1)
					{
						NSMutableDictionary *a1 = _attributes_[c.rowIndex][c.columnIndex-2];
						[[_undoManager prepareWithInvocationTarget:self] setAttributesOfCell:[Cell cellWithColumnIndex:c.columnIndex-1 rowIndex:c.rowIndex column:nil]
																				toDictionary:a1.copy];
						a1[kBackgroundBorderExistsRightKey] = @(2);
					}
					else
					{
						NSMutableDictionary *a = _attributes_[c.rowIndex][c.columnIndex-1];
						[[_undoManager prepareWithInvocationTarget:self] setAttributesOfCell:c toDictionary:a.copy];

						a[kBackgroundBorderExistsLeftKey] = @(1);
					}
				}
			}

		}
			if (border == borderLeft)
				break;
		case borderTop:
		{
			for (Cell *c in cells)
			{
				if (![cellMap valueForKey:[AddressHelper indicesToString:c.columnIndex rowIndex:c.rowIndex-1]])
				{
					if (c.rowIndex)
					{
						NSMutableDictionary *a1 = _attributes_[c.rowIndex-1][c.columnIndex-1];
						[[_undoManager prepareWithInvocationTarget:self] setAttributesOfCell:[Cell cellWithColumnIndex:c.columnIndex rowIndex:c.rowIndex-1 column:nil]
																				toDictionary:a1.copy];
						a1[kBackgroundBorderExistsBottomKey] = @(2);
					}
					else
					{
						NSMutableDictionary *a = _attributes_[c.rowIndex][c.columnIndex-1];
						[[_undoManager prepareWithInvocationTarget:self] setAttributesOfCell:c toDictionary:a.copy];

						a[kBackgroundBorderExistsTopKey] = @(1);
					}
				}
			}
		}
			if (border == borderTop)
				break;
		case borderRight: // right
		{
			for (Cell *c in cells)
			{
				if (![cellMap valueForKey:[AddressHelper indicesToString:c.columnIndex+1 rowIndex:c.rowIndex]])
				{
					NSMutableDictionary *a = _attributes_[c.rowIndex][c.columnIndex-1];
					[[_undoManager prepareWithInvocationTarget:self] setAttributesOfCell:c toDictionary:a.copy];

					a[kBackgroundBorderExistsRightKey] = @(1);
				}
			}
		}
			if (border == borderRight)
				break;
		case borderBottom:
		{
			for (Cell *c in cells)
			{
				if (![cellMap valueForKey:[AddressHelper indicesToString:c.columnIndex rowIndex:c.rowIndex+1]])
				{
					NSMutableDictionary *a = _attributes_[c.rowIndex][c.columnIndex-1];
					[[_undoManager prepareWithInvocationTarget:self] setAttributesOfCell:c toDictionary:a.copy];

					a[kBackgroundBorderExistsBottomKey] = @(1);
				}
			}
		}
			break;
	}
}

- (void)setAttributesOfCell:(Cell *)c toDictionary:(NSDictionary *)dict
{
	NSMutableDictionary *attributes = _attributes_[c.rowIndex][c.columnIndex-1];

	[[_undoManager prepareWithInvocationTarget:self] setAttributesOfCell:c toDictionary:attributes.copy];

	[attributes setDictionary:dict]; 	// attributechange
}

- (void)modifyAttributesOfCell:(Cell *)c withBlock:(void (^)(NSMutableDictionary *a))block
{
	NSMutableDictionary *attributes = _attributes_[c.rowIndex][c.columnIndex-1];

	[[_undoManager prepareWithInvocationTarget:self] setAttributesOfCell:c toDictionary:attributes.copy];

	block(attributes); 	// attributechange
}

- (void)setEnableRowColors:(BOOL)enableRowColors
{
	[[_undoManager prepareWithInvocationTarget:self] setEnableRowColors:_enableRowColors];
	[_undoManager setActionName:@"Toggle Row Colors"];
	_enableRowColors = enableRowColors;
}

- (void)setEvenRowColor:(NSColor *)evenRowColor
{
	[[_undoManager prepareWithInvocationTarget:self] setEvenRowColor:_evenRowColor];
	[_undoManager setActionName:@"Set Even Colors"];
	_evenRowColor = evenRowColor;
}

- (void)setOddRowColor:(NSColor *)oddRowColor
{
	[[_undoManager prepareWithInvocationTarget:self] setOddRowColor:_oddRowColor];
	[_undoManager setActionName:@"Set Odd Colors"];
	_oddRowColor = oddRowColor;
}

- (void)validate
{
#ifdef DEBUG
	if (self.undoManager.isUndoing || self.undoManager.isRedoing)
		return;

	LOGFUNC

	for (NSArray *row in _data_)
		assert(row.count == self.columnCount);
	for (NSArray *row in _attributes_)
		assert(row.count == self.columnCount);

    for (NSArray *row in _data_)
    {
        assert([row isKindOfClass:NSMutableArray.class]);
        for (id entry in row)
            assert([entry isKindOfClass:NSString.class]);
    }
 
    for (NSArray *row in _attributes_)
    {
        assert([row isKindOfClass:NSMutableArray.class]);
        for (id entry in row)
            assert([entry isKindOfClass:NSMutableDictionary.class]);
    }

    assert(self.columns.count == self.columnCount); // TODO: we crash here if we allow removing all rows


    // make sure each entry in attributes and dependencies is a distinct object

    {
        NSMutableDictionary *dict = makeMutableDictionary();
        for (NSUInteger c = 0; c < self.columnCount; c++)
        {
            for (NSUInteger r = 0; r < self.rowCount; r++)
            {
                id d =  _attributes_[r][c];
                NSString *dadr = makeString(@"%p", d);
                assert(dict[dadr] == nil);
                dict[dadr] = @1;
            }
        }
    }
#endif
}

#pragma mark accessors

- (NSString *)valueForRow:(NSUInteger)rowIndex column:(NSUInteger)columnIndex throw:(BOOL)throwOnCircular
{
	if (rowIndex >= self.rowCount || columnIndex >= self.columnCount)
		@throw ([NSException exceptionWithName:@"#REF!" reason:@(__LINE__).stringValue userInfo:nil]);

	NSString *d =  _data_[rowIndex][columnIndex];
	assert([d isKindOfClass:NSString.class]);

    return d;
}

- (NSArray <NSArray <NSString *>*> *)data
{
	return _data_;
}

- (NSArray <NSArray <NSDictionary *>*> *)attributes
{
	return _attributes_;
}


- (NSArray <NSDictionary *> *)columns
{
	return _columns_;
}

- (NSArray <NSDictionary *> *)graphs
{
	return _graphs_;
}


- (NSUInteger)rowCount
{
	return _data_.count;
}

- (NSUInteger)columnCount
{
	if (!_data_.count)
		return 0;
	return _data_[0].count;
}


- (void)_undoableSetData:(NSString *)newdata at:(coordinates)c
{
    NSString *olddata = _data_[c.row][c.column];

    [[_undoManager prepareWithInvocationTarget:self] _undoableSetData:olddata at:c];

    _data_[c.row][c.column] = newdata;
    
}
@end

