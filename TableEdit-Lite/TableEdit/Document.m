//
//  Document.m
//  TableEdit-Lite
//
//  Created by CoreCode on 28/06/13.
/*    Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/


#import "Document.h"
#import "DocumentData.h"
#import "AddressHelper.h"
#import "AppDelegate.h"
#import "FormatterHelper.h"
#import "FormulaResult.h"
#import "JMBlockFormatter.h"
#import "DraggableButton.h"
#import "PrintViewController.h"
#import "GridTableHeaderView.h"

NSCharacterSet *cellAddressForbiddenCharacterset;
NSDate *excelBaseDate;
NSCalendar *timezonelessCalendar;


@interface Document ()

@property (nonatomic, weak) IBOutlet DraggableButton *addRowButton;
@property (nonatomic, weak) IBOutlet DraggableButton *addColumnButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *plusRowConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *plusColumnConstraint;
@property (nonatomic, weak) IBOutlet NSPopover *popover;
@property (nonatomic, weak) IBOutlet NSView *chartContainerView;

@property (nonatomic, strong) NSFont *columnCellFont;
@property (nonatomic, assign) NSInteger lastSortColumn;
@property (nonatomic, assign) BOOL lastSortAscending;
@property (nonatomic, assign) NSInteger majorSystemVersion;

@property (nonatomic, assign) BOOL _shouldAutosizeAllColumns;
@property (nonatomic, assign) BOOL _isAutosizeOfMultipleColumns;

@property (nonatomic, strong) NSArray <NSString *>*fontFamilyNames;

@property (nonatomic, strong) NSDictionary *currentEditedGraph;


@property (nonatomic, assign) NSUInteger maxNewRows;
@property (nonatomic, assign) NSUInteger maxNewColumns;
@property (nonatomic, assign) NSUInteger newRows;
@property (nonatomic, assign) NSUInteger newColumns;
@property (nonatomic, assign) NSInteger editingRow;
@property (nonatomic, assign) NSInteger editingColumn;
@property (nonatomic, assign) NSInteger insertionRow;
@property (nonatomic, assign) NSInteger insertionColumn;
@property (nonatomic, readonly) BOOL validSelection;
@property (nonatomic, strong) DocumentData *data_;

@end



@implementation Document

@dynamic validSelection, maxNewRows, maxNewColumns;

- (id)init
{
	self = [super init];

	if (self)
	{
        LOGFUNC;
        
		_data_ = [[DocumentData alloc] initWithUndoManager:self.undoManager];


		_fontFamilyNames = [@[@"SYSTEM-FONT"] arrayByAddingObjectsFromArray:fontManager.availableFontFamilies];
		_lastSortColumn = -1;

        self.majorSystemVersion = [[NSProcessInfo processInfo] operatingSystemVersion].majorVersion;
	}
	return self;
}

- (NSString *)windowNibName
{
	return @"Document";
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError * _Nullable __autoreleasing *)outError
{
	LOGFUNC;VALIDATE;
	return [_data_ write];
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
	LOGFUNC;

//   #warning revert
//    dispatch_after_main(10, ^{
//        @throw ([NSException exceptionWithName:@"mimmi" reason:@"4" userInfo:nil]);
//    });
//    dispatch_after_main(10, ^{
//        assert(0);
//    });

//	self.undoManager.groupsByEvent = NO;

	AppDelegate *ad = (AppDelegate *)application.delegate;
	[ad closeWelcome:self];


//	[self.chartContainerView  unregisterDraggedTypes];
	[super windowControllerDidLoadNib:aController];


	[_tableView registerForDraggedTypes:@[NSStringPboardType]];
	_tableView.doubleAction = @selector(doubleClickInTableView:);
	_tableView.rowHeight = 19;
	_tableView.data = _data_;
	_tableView.document = self;
    GridTableHeaderView *gthv = [GridTableHeaderView new];
    gthv.document = self;
    _tableView.headerView = gthv;

	[self tableViewSelectionDidChange:nil];

    if (!_data_.columnCount)
	{
		self.newRows = 16;
		self.newColumns = 9;
	}
	else
	{
		self.newRows = _data_.rowCount;
		self.newColumns = _data_.columnCount;
	}

    [self.undoManager disableUndoRegistration];
    [self resizeClicked:nil]; // nil means: no need to end editing
    [self.undoManager enableUndoRegistration];

	if (__shouldAutosizeAllColumns && _data_.columnCount < 100)
	{
		[self autosizeColumnsWithIndices:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _data_.columnCount)]];
		[self makeWindowWideEnough];
	}

	// register undo observers
	{
		assert(notificationCenter);
		[notificationCenter addObserver:self
							   selector:@selector(willUndoChangeNotification:)
								   name:NSUndoManagerWillUndoChangeNotification object:self.undoManager];
		[notificationCenter addObserver:self
							   selector:@selector(willRedoChangeNotification:)
								   name:NSUndoManagerWillRedoChangeNotification object:self.undoManager];

		[notificationCenter addObserver:self
								selector:@selector(didUndoChangeNotification:)
									name:NSUndoManagerDidUndoChangeNotification object:self.undoManager];
		[notificationCenter addObserver:self
							   selector:@selector(didRedoChangeNotification:)
								   name:NSUndoManagerDidRedoChangeNotification object:self.undoManager];

		[notificationCenter addObserver:self
							   selector:@selector(didOpenUndoGroupNotification:)
								   name:NSUndoManagerDidOpenUndoGroupNotification object:self.undoManager];
		[notificationCenter addObserver:self
							   selector:@selector(didCloseUndoGroupNotification:)
								   name:NSUndoManagerDidCloseUndoGroupNotification object:self.undoManager];
	}


    
    VALIDATE;
}

- (void)dealloc
{
	LOGFUNC;


    if ([NSColorPanel sharedColorPanelExists])
        [NSColorPanel.sharedColorPanel close];
}

+ (BOOL)autosavesInPlace
{
	return YES;
}

#pragma mark excel

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError * __autoreleasing *)outError
{
	LOGFUNCPARAMA(self.fileURL.path);
	@try
	{
		if ([typeName isEqualToString:@"com.corecode.tableedit.spreadsheet"] || [typeName isEqualToString:@"TableEditDocument"])
        {
            BOOL result = [_data_ read:data];

            if (self.tableView)
            {
                cc_log(@"Warning: read performed on existing Document instance, this must have been the 'Revert Changes' feature");

                [self.tableView clearSelection:NO];
                [self movePlusRowButton];
                [self recreateTableColumns];
				[self reloadTableAndGraphs];
                
                VALIDATE;
            }

            return result;
        }
		else
		{
			if ([typeName hasPrefix:@"XLS"] || [typeName hasPrefix:@"XLT"])
			{
				if (![self importExcel:nil
								  data:data.bytes
								length:data.length
								action:importReplaceEverything
								   xml:!([typeName isEqualToString:@"XLS File"] || [typeName isEqualToString:@"XLT File"])])
					return NO;
			}
			else
			{
				NSString *delimiter;
				NSString *string = data.string;

				if ([typeName containsAny:@[@"TSV", @"TXT", @"TAB"]])
					delimiter = @"	";
				else
					delimiter = (([string countOccurencesOfString:@","] > [string countOccurencesOfString:@";"]) ? @"," : @";");

				if (![self importCSVString:string delimiter:delimiter action:importReplaceEverything])
					return NO;
			}

			self.fileURL = nil; // disassociate document from file; makes document "untitled"
			self.fileType = @"com.corecode.tableedit.spreadsheet"; 	// associate with primary file type
			return YES;
		}
	}
	@catch (id)
	{
		return NO;
	}
}

- (BOOL)importExcel:(NSURL *)file data:(const char *)source length:(NSUInteger)length action:(importChoice)action xml:(BOOL)xml
{
	LOGFUNCPARAM(file.path);
	BookHandle book = xml ? xlCreateXMLBook() : xlCreateBook();
	assert(book);
    xlBookSetKey(book, LIBXLNAME, LIBXLKEY);
	xlBookSetLocale(book,"UTF-8");

	BOOL result;
	if (file)
		result = xlBookLoad(book, file.path.UTF8String) > 0;
	else
		result = xlBookLoadRaw(book, source, (unsigned int)length) > 0;


	if (!result)
	{
		const char* error = xlBookErrorMessage(book);
		cc_log_error(@"ERROR: failed to import %@ as excel book: %@", file, @(error));
		xlBookRelease(book);
		return NO;
	}

	NSInteger count = xlBookSheetCount(book);
	NSUInteger selectedSheet = 0;

	if (count > 1)
	{
        NSMutableArray <NSString *>*validSheetNames = makeMutableArray();
        NSMutableArray <NSNumber *>*validSheetIndices = makeMutableArray();
        NSMutableArray <NSNumber *>*invalidSheetIndices = makeMutableArray();

		for (int i = 0; i < count; i++)
		{
			SheetHandle sheet = xlBookGetSheet(book, i);

			if (!sheet)
			{
				cc_log_error(@"ERROR: failed get sheet %i from %@", i, file);

				[invalidSheetIndices addObject:@(i)];
			}
            else
            {
                const char* sheetName = xlSheetName(sheet);
                assert(sheetName);
                [validSheetNames addObject:@(sheetName)];
                [validSheetIndices addObject:@(i)];
            }
		}

        if (!validSheetIndices.count)
        {
            cc_log_error(@"ERROR: cant open file %@ cause we found no valid sheet, only %lu invalid sheets", file, (unsigned long)invalidSheetIndices.count);
            xlBookRelease(book);
            return NO;
        }


		BOOL altDown = (NSEvent.modifierFlags & NSAlternateKeyMask) > 0;

//#warning revert
//		altDown = TRUE;

		if (!altDown)
        {
            NSString *message = @"Please select which sheet to import:";
            if (invalidSheetIndices.count)
                message = makeString(@"The file contains %lu invalid sheets. Please select one of the valid sheets to import:", (unsigned long)invalidSheetIndices.count);


            NSUInteger selectedValidSheet = 0;
            alert_selection_matrix(message, validSheetNames, @[@"OK"], &selectedValidSheet);
            selectedSheet = validSheetIndices[selectedValidSheet].integerValue;
        }
	}
	else if (count < 1)
	{
		cc_log_error(@"ERROR: got zero sheet count for %@", file);
		xlBookRelease(book);
		return NO;
	}


	@try
	{
		SheetHandle sheet = xlBookGetSheet(book, (int)selectedSheet);
		if (!sheet)
		{
			cc_log_error(@"ERROR: failed get sheet %lu from %@", (unsigned long)selectedSheet, file);
			xlBookRelease(book);
			return NO;
		}

		NSCalendar *calendar = NSCalendar.currentCalendar;
		NSDateComponents *components = NSDateComponents.new;
		char * fontNameBuffer = calloc(1, 128);

		int maxrows = xlSheetLastRow(sheet);
		int maxcols = xlSheetLastCol(sheet);

		NSMutableArray *data = makeMutableArray();
		NSMutableArray *attrs = makeMutableArray();

		for (int r = 0; r < maxrows; r++)
		{
			[data addObject:makeMutableArray()];
			[attrs addObject:makeMutableArray()];

			for (int c = 0; c < maxcols; c++)
			{
				@autoreleasepool
				{
					NSMutableArray *row = data.lastObject;
					NSMutableArray *attrow = attrs.lastObject;

					[row addObject:@""];
					[attrow addObject:makeMutableDictionary()];

					int type = xlSheetCellType(sheet, r, c);
					int isFormula = xlSheetIsFormula(sheet, r, c);
					int isDate = xlSheetIsDate(sheet, r, c);
					BOOL done = NO;
					assert(!((type != CELLTYPE_NUMBER) && isDate));


					if (isFormula)
					{
						const char *formula = xlSheetReadFormula(sheet, r, c, NULL);

	//					if (type != CELLTYPE_NUMBER)
	//						asl_NSLog(ASL_LEVEL_DEBUG, @"formula of type %i: %@", type, @(formula));

						if (formula)
						{
							NSString *str = [@"=" stringByAppendingString:@(formula)];

							assert(str);

							data[r][c] = str;
							done = YES;
						}
					}

					if (!done)
					{
						if (type == CELLTYPE_NUMBER)
						{
							double s = xlSheetReadNum(sheet, r, c, NULL);


							if (isDate)
							{
								int year, month, day, hour, min, sec, msec;

								int res = xlBookDateUnpack(book, s, &year, &month, &day, &hour, &min, &sec, &msec);

								if (res == 0)
								{
									NSString *str = @(s).stringValue;

									assert(str);

									data[r][c] = str;
								}
								else
								{
									components.year = year;
									components.month = month;
									components.day = day;
									components.hour = hour;
									components.minute = min;
									components.second = sec;

									NSDate *date = [calendar dateFromComponents:components];
									NSString *dateString = [date stringUsingFormat:@"dd.MM.yyyy HH:mm:ss"];

									assert(dateString);

									data[r][c] = dateString;
								}
							}
							else
							{
								NSString *str = @(s).stringValue;

								assert(str);

								data[r][c] = str;
							}
						}
						else if (type == CELLTYPE_STRING)
						{
							const char* s = xlSheetReadStr(sheet, r, c, NULL);
							if (s)
							{
								NSString *str = @(s);

								assert(str);

								data[r][c] = str;
							}
						}
						else if (type == CELLTYPE_BOOLEAN)
						{
							int s = xlSheetReadBool(sheet, r, c, NULL);

                            data[r][c] = s ? @"1" : @"0";
						}
						else if (type == CELLTYPE_BLANK || type == CELLTYPE_EMPTY)
						{

						}
						else if (type == CELLTYPE_ERROR) // TODO: should handle this properly
						{
							cc_log(@"Warning: CELLTYPE_ERROR for cell %i|%i in file: %@", r, c, file.path);
						}
						else
						{
							cc_log(@"Warning: unknown cell type (%i) for cell %i|%i in file: %@", type, r, c, file.path);
						}

						if (isFormula)
							cc_log(@"Warning: formula was empty type %i, recovered with value %@", type, data[r][c]);
					}

					FormatHandle format = xlSheetCellFormat(sheet, r, c);
					if (format)
					{
						FontHandle font = xlFormatFont(format);

						if (font)
						{
							NSMutableDictionary *attributes = attrow.lastObject;

							const char* fn = xlFontName(font);
							BOOL bold = (BOOL)xlFontBold(font);
							BOOL italic = (BOOL)xlFontItalic(font);
							char size = (char) OBJECT_OR(xlFontSize(font), 12);
							memcpy(fontNameBuffer, fn, strlen(fn));
							fontNameBuffer[strlen(fn)+0] = '|';
							fontNameBuffer[strlen(fn)+1] = bold ? 'b' : 'x';
							fontNameBuffer[strlen(fn)+2] = italic ? 'i' : 'y';
							fontNameBuffer[strlen(fn)+3] = '!' + size;
							fontNameBuffer[strlen(fn)+4] = 0;
							NSString *hash = @(fontNameBuffer);

							static NSMutableDictionary <NSString *, NSFont *> *fontCache;
							ONCE_PER_FUNCTION(^{ fontCache = makeMutableDictionary(); });
							NSFont *cellfont = fontCache[hash];

							if (!cellfont)
							{
								cellfont = [NSFont fontWithName:@(fn) size:size];
								if (!cellfont)
									cellfont = [NSFont systemFontOfSize:size];

								cellfont = [fontManager convertFont:cellfont toHaveTrait:bold ? NSBoldFontMask : NSUnboldFontMask];
								cellfont = [fontManager convertFont:cellfont toHaveTrait:italic ? NSItalicFontMask : NSUnitalicFontMask];

								assert(cellfont);

								if (hash) // font size > 90 has problems encoding in a char
									fontCache[hash] = cellfont;
							}


							attributes[kFontFontKey] = cellfont;

							int colorIndex = xlFontColor(font);
							int colors[65] = {0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0xDDDDDD, 0xFF0000, 0x00FF00, 0x0000FF, 0xFFFF00, 0xFF00FF, 0x00FFFF, 0x800000, 0x008000, 0x000080, 0x808000, 0x800080, 0x008080, 0xC0C0C0, 0x808080, 0x9999FF, 0x993366, 0xFFFFCC, 0xCCFFFF, 0x660066, 0xFF8080, 0x0066CC, 0xCCCCFF, 0x000080, 0xFF00FF, 0xFFFF00, 0x00FFFF, 0x800080, 0x800000, 0x008080, 0x0000FF, 0x00CCFF, 0xCCFFFF, 0xCCFFCC, 0xFFFF99, 0x99CCFF, 0xFF99CC, 0xCC99FF, 0xFFCC99, 0x3366FF, 0x33CCCC, 0x99CC00, 0xFFCC00, 0xFF9900, 0xFF6600, 0x666699, 0x969696, 0x003366, 0x339966, 0x003300, 0x333300, 0x993300, 0x993366, 0x333399, 0x333333, 0x000000, 0x000000};

							if (colorIndex > 0 && colorIndex < 65)
							{
                                static NSMutableDictionary <NSNumber *, NSColor *> *colorCache;
                                ONCE_PER_FUNCTION(^{ colorCache = makeMutableDictionary(); });
                                NSColor *colorObject = colorCache[@(colorIndex)];

                                if (!colorObject)
                                {
                                    int color = colors[colorIndex-1];
                                    int color_r = (color >> 16) & 0x0000FF;
                                    int color_g = (color >> 8) & 0x0000FF;
                                    int color_b = (color >> 0) & 0x0000FF;

                                    colorObject =  makeColor255(color_r, color_g, color_b, 255);
                                }

								assert(colorObject);
								attributes[kFontColorKey] = colorObject;
							}
						}
					}
				}
			}
		}
		[_data_ importData:data attributes:attrs action:action selection:_tableView.selectionExtents];
	}
	@catch (NSException *exception)
	{
		LOG(exception);
		[exception raise];
	}
	
	
	xlBookRelease(book);
	
	[self.undoManager removeAllActions];
	[self.tableView clearSelection:NO];
	[self recreateTableColumns];
	[self reloadTableAndGraphs];

	self._shouldAutosizeAllColumns = YES;


	return YES;
}

- (void)importCSV:(NSURL *)source delimiter:(NSString *)delimiter encoding:(NSStringEncoding)encoding action:(importChoice)action
{
	LOGFUNC;
	NSDate *pre = [NSDate date];
	NSString *string;
	NSError *err;

	if (encoding)
		string = [[NSString alloc] initWithContentsOfURL:source encoding:encoding error:&err];
	else
		string = [[NSString alloc] initWithContentsOfURL:source usedEncoding:NULL error:&err];

	if (!string)
	{
		if (encoding)
			cc_log(@"Warning: failed to import %@ using specified encoding, trying others", source);
		else
			cc_log(@"Warning: failed to import %@ using guessed encoding, trying another way", source);

		string = source.contents.string;

		if (!string)
		{
			cc_log_error(@"ERROR: still failed to import %@ as text, try fixing the text encoding using a good text editor before attempting import again", source);

			return;
		}
	}

	if ([[NSNull null] isEqual:delimiter])
	{
		if ([source.pathExtension.uppercaseString containsAny:@[@"TSV", @"TXT", @"TAB"]])
			delimiter = @"	";
		else
			delimiter = (([string countOccurencesOfString:@","] > [string countOccurencesOfString:@";"]) ? @"," : @";");
	}

	[self importCSVString:string delimiter:delimiter action:action];

	VALIDATE;
	cc_log(@"IMPORT took %.2fs for %i bytes", [[NSDate date] timeIntervalSinceDate:pre], (int)string.length);
}

- (BOOL)importCSVString:string delimiter:(NSString *)delimiter action:(importChoice)action
{
	LOGFUNC;
	NSArray <NSArray <NSString *> *> *data = [string parsedDSVWithDelimiter:delimiter];
	BOOL success = [_data_ importData:data attributes:nil action:action selection:_tableView.selectionExtents];

	
	[self.undoManager removeAllActions];
	[self.tableView clearSelection:NO];
	[self recreateTableColumns];
	[self reloadTableAndGraphs];

	self._shouldAutosizeAllColumns = YES;

	VALIDATE;
	return success;
}

+ (void)showImportPanel:(id)sender forWindow:(NSWindow *)window
{
	LOGFUNC;
	NSOpenPanel *panel = NSOpenPanel.openPanel;

	panel.allowedFileTypes = @[@"csv", @"txt", @"tsv", @"tab", @"xls", @"xlt", @"xlsx", @"xlsm", @"xlsb", @"xltm", @"xltx"];

	NSArray *top;
#ifndef DEBUG
	__unused
#endif
	BOOL loadSuccessful = [[NSBundle mainBundle] loadNibNamed:@"ImportOptionView" owner:sender topLevelObjects:&top];
	assert(loadSuccessful);
	top = [top filtered:^BOOL(id input) { return [input isKindOfClass:NSView.class]; }];
	NSView *accessoryView = top.firstObject;
	assert(accessoryView);

	if (!window) // hide option for choosing action since we HAVE to do a new document
	{
		[[[accessoryView assertedViewWithTag:12] superview] superview].hidden = YES;

		accessoryView.frame = NSInsetRect(accessoryView.frame, 0, 35);
	}
	panel.accessoryView = accessoryView;
    if (@available(macOS 10.11, *))
        panel.accessoryViewDisclosed = YES;

	id handler = ^(NSInteger result)
	{
		if (result == NSFileHandlingPanelOKButton)
		{
			NSArray <NSString *> *delimiters = @[(NSString *)[NSNull null], @",", @";", @"	", @":", @" "];
			NSArray <NSNumber *>*encodings = @[@0, @(NSUTF8StringEncoding), @(NSUnicodeStringEncoding), @(NSMacOSRomanStringEncoding), @(NSASCIIStringEncoding)];

			importChoice action = (importChoice)kImportActionKey.defaultInt;

			if (!window || action == importNewDocument)
			{
				[NSDocumentController.sharedDocumentController newDocument:sender];
				Document *newDocument = NSDocumentController.sharedDocumentController.currentDocument;

				if ([panel.URL.pathExtension hasPrefix:@"xls"] || [panel.URL.pathExtension hasPrefix:@"xlt"])
					[newDocument importExcel:panel.URL data:NULL length:0
									  action:importReplaceEverything
										 xml:!([panel.URL.pathExtension isEqualToString:@"xls"] || [panel.URL.pathExtension isEqualToString:@"xlt"])];
				else
					[newDocument importCSV:panel.URL
								 delimiter:delimiters[kImportDelimiterKey.defaultInt]
								  encoding:encodings[kImportEncodingKey.defaultInt].intValue
									action:importReplaceEverything];

				[newDocument updateChangeCount:NSChangeDone]; // else NSDocument won't save it when no other change is done before closing
			}
			else
			{
				if ([panel.URL.pathExtension hasPrefix:@"xls"] || [panel.URL.pathExtension hasPrefix:@"xlt"])
					[(Document *)sender importExcel:panel.URL data:NULL length:0
											 action:action
												xml:!([panel.URL.pathExtension isEqualToString:@"xls"] || [panel.URL.pathExtension isEqualToString:@"xlt"])];
				else
					[(Document *)sender importCSV:panel.URL
										delimiter:delimiters[kImportDelimiterKey.defaultInt]
										 encoding:encodings[kImportEncodingKey.defaultInt].intValue
										   action:action];

			}
		}
	};

	if (window)
		[panel beginSheetModalForWindow:window completionHandler:handler];
	else
		[panel beginWithCompletionHandler:handler];
}

#pragma mark responder actions (menu)

- (void)import:(id)sender
{
	LOGFUNCA;
	[Document showImportPanel:self forWindow:self.windowForSheet];
}

- (IBAction)fillIntoCell:(NSMenuItem *)sender
{
    LOGFUNCPARAMA(sender);

    if (_tableView.selectedCells.count == 0) {	NSBeep(); return; }

	[self.undoManager beginUndoGrouping];

	CCIntPoint offset = {0,0};

    if (sender.tag == 1) // down
		offset = (CCIntPoint){0, -1};
    else if (sender.tag == 2) // right
		offset = (CCIntPoint){-1, 0};
    else if (sender.tag == 3) // up
		offset = (CCIntPoint){0, 1};
    else if (sender.tag == 4) // left
		offset = (CCIntPoint){1, 0};
    else
        assert(0);

	[_tableView reloadData];

	for (Cell *cell in _tableView.selectedCells)
	{
        NSInteger column = cell.columnIndex-1 + offset.x;
        NSInteger row = cell.rowIndex + offset.y;
        
        NSString *valueToFill;
        if (row == -1) // special, fill column name
        {
            valueToFill = [AddressHelper columnIndexToString:column];;
        }
        else if (column == -1) // special, fill row name
        {
            
            valueToFill = @(row+1).stringValue;
        }
		else if (row < (NSInteger)_data_.rowCount && column < (NSInteger)_data_.columnCount)
        {
            valueToFill = _data_.data[row][column];
        }

		if (valueToFill.length)
			[self tableView:nil
			 setObjectValue:valueToFill
			 forTableColumn:cell.column
						row:cell.rowIndex];

	}


	// update table display
	[_tableView reloadData];


	[self.undoManager setActionName:@"Fill"];
	[self.undoManager endUndoGrouping];
}

- (IBAction)insertFormula:(NSMenuItem *)sender
{
    long operation = sender.tag / 10;
    NSArray *operationNames = @[@"", @"SUM", @"PRODUCT", @"MINIMUM", @"MAXIMUM", @""];
    if (_tableView.selectedCells.count == 0)
    {
        alert(@"Error", makeString(@"You need to select some cells containing numeric values to be able to calculate their %@", operationNames[operation]), @"OK", nil, nil);
        return;
    }

    long destcolumn = 0, destrow = 0;
    int direction = sender.tag % 10;
    if (direction == 0)
    {
        destcolumn = _tableView.selectedCells.lastObject.columnIndex;
        CCIntRange1D r = [_tableView.selectedCells calculateExtentsOfValues:^int(Cell *c) { return (int)c.rowIndex; }];
        destrow = r.max + 1;
    }
    else if (direction == 1)
    {
        destcolumn = _tableView.selectedCells.firstObject.columnIndex;
        CCIntRange1D r = [_tableView.selectedCells calculateExtentsOfValues:^int(Cell *c) { return (int)c.rowIndex; }];
        destrow = r.min - 1;
    }
    else if (direction == 2)
    {
        CCIntRange1D r = [_tableView.selectedCells calculateExtentsOfValues:^int(Cell *c) { return (int)c.columnIndex; }];
        destcolumn = r.max + 1;
        destrow = _tableView.selectedCells.lastObject.rowIndex;
    }
    else if (direction == 3)
    {
        CCIntRange1D r = [_tableView.selectedCells calculateExtentsOfValues:^int(Cell *c) { return (int)c.columnIndex; }];
        destcolumn = r.min + 1;
        destrow = _tableView.selectedCells.firstObject.rowIndex;
    }
    else
        assert(0);
    
    BOOL outOfRange = NO;
    if (destrow < 0) outOfRange = YES;
    if (destcolumn < 1)  outOfRange = YES;
    if (destrow >= (NSInteger)_data_.rowCount)outOfRange = YES;
    if (destcolumn-1 >= (NSInteger)_data_.columnCount) outOfRange = YES;
    if (outOfRange)
    {
        alert(@"Error", @"Can not insert the formula result at the selected place as that would be outside the table.", @"OK", nil, nil);
        return;
    }
    

    double result = 0.0;
    
    if (operation == 1)
    {
        double sum = 0;
        for (Cell *cell in _tableView.selectedCells)
        {
            NSString *cellValue = [self tableView:nil objectValueForTableColumn:cell.column row:cell.rowIndex];
            NSNumber *cellNumber = cellValue.numberValue;
            
            sum += cellNumber.doubleValue;
        }
        result = sum;
    }
    else if (operation == 2)
    {
        double product = 1;
        for (Cell *cell in _tableView.selectedCells)
        {
            NSString *cellValue = [self tableView:nil objectValueForTableColumn:cell.column row:cell.rowIndex];
            NSNumber *cellNumber = cellValue.numberValue;
            
            product *= cellNumber.doubleValue;
        }
        result = product;
    }
    else if (operation == 3)
    {
        double min = FLT_MAX;
        for (Cell *cell in _tableView.selectedCells)
        {
            NSString *cellValue = [self tableView:nil objectValueForTableColumn:cell.column row:cell.rowIndex];
            NSNumber *cellNumber = cellValue.numberValue;
            
            min = MIN(min, cellNumber.doubleValue);
        }
        result = min;
    }
    else if (operation == 4)
    {
        double max = FLT_MIN;
        for (Cell *cell in _tableView.selectedCells)
        {
            NSString *cellValue = [self tableView:nil objectValueForTableColumn:cell.column row:cell.rowIndex];
            NSNumber *cellNumber = cellValue.numberValue;
            
            max = MIN(max, cellNumber.doubleValue);
        }
        result = max;
    }
    else
        assert(0);

    
    [self tableView:nil
     setObjectValue:@(result).stringValue
     forTableColumn:_tableView.tableColumns[destcolumn]
                row:destrow];
    

    // update table display
    [self.tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:destrow]
                              columnIndexes:[NSIndexSet indexSetWithIndex:destcolumn]];
}
    
- (IBAction)insertIntoCell:(NSMenuItem *)sender
{
	LOGFUNCPARAMA(sender);

	if (_tableView.selectedCells.count == 0)  {	NSBeep(); return; }
    if ((sender.tag < 4) && (_tableView.selectedCells.count > 1)) {	NSBeep(); return; }


	[self.undoManager beginUndoGrouping];


    if (sender.tag == 4) // numbers
    {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Please enter values to generate numbers to fill into the selected cells.";

        [alert addButtonWithTitle:@"Insert Numbers"];
        [alert addButtonWithTitle:@"Cancel"];


        NSArray *obj;
        [NSBundle.mainBundle loadNibNamed:@"InsertNumbersView" owner:self topLevelObjects:&obj];

        NSView *view = [obj filtered:^BOOL(id input) { return [input isKindOfClass:NSView.class]; }][0];
        assert(view);
        [alert setAccessoryView:view];

        NSInteger selectedButton = [alert runModal];

        if (selectedButton == NSAlertFirstButtonReturn)
        {
            NSInteger first, rowplus, colplus;

            first = ((NSTextField *)[view viewWithTag:1]).integerValue;
            rowplus = ((NSTextField *)[view viewWithTag:2]).integerValue;
            colplus = ((NSTextField *)[view viewWithTag:3]).integerValue;


            Cell *firstCell = _tableView.selectedCells[0];

            for (Cell *cell in _tableView.selectedCells)
            {
                NSInteger rowdiff = cell.rowIndex - firstCell.rowIndex;
                NSInteger coldiff = cell.columnIndex - firstCell.columnIndex;

                NSInteger number = first + rowdiff * rowplus + coldiff * colplus;


                [self tableView:nil
                 setObjectValue:@(number).stringValue
                 forTableColumn:cell.column
                            row:cell.rowIndex];


                // update table display
                [self.tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:cell.rowIndex]
                                          columnIndexes:[NSIndexSet indexSetWithIndex:cell.columnIndex]];
            }
        }
    }
    else
    {
        NSString *insertText;

        if (sender.tag == 1) // date
            insertText = [[NSDate date] stringUsingDateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
        else if (sender.tag == 2) // time
            insertText = [[NSDate date] stringUsingDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterMediumStyle];
        else if (sender.tag == 3) // date & time
            insertText = [[NSDate date] stringUsingDateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle];
        else
            assert(0);

        [self tableView:nil
         setObjectValue:insertText
         forTableColumn:_tableView.selectedCells[0].column
                    row:_tableView.selectedCells[0].rowIndex];


        // update table display
        [self.tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:_tableView.selectedCells[0].rowIndex]
                                  columnIndexes:[NSIndexSet indexSetWithIndex:_tableView.selectedCells[0].columnIndex]];
    }


	[self.undoManager setActionName:@"Insert Date/Time"];
	[self.undoManager endUndoGrouping];
}

- (void)export:(id)sender
{
	LOGFUNCA;
	NSSavePanel *panel = NSSavePanel.savePanel;

	panel.extensionHidden = NO;

	NSArray *top;
#ifndef DEBUG
	__unused
#endif
	BOOL loadSuccessful = [[NSBundle mainBundle] loadNibNamed:@"ExportOptionView" owner:self topLevelObjects:&top];
	assert(loadSuccessful);
	top = [top filtered:^BOOL(id input) { return [input isKindOfClass:NSView.class]; }];
	NSView *accessoryView = top.firstObject;
	assert(accessoryView);
	panel.accessoryView = accessoryView;

	NSMatrix *m = [accessoryView viewWithTag:9];
	m.actionBlock = ^(NSMatrix *matrix)
	{
		NSArray <NSArray <NSString *>*>*fileTypes = @[@[@"csv", @"tab", @"tsv", @"txt"],
                                                      @[@"xls"],
                                                      @[@"xlsx", @"xlsm"],
                                                      @[@"pdf"],];

		panel.allowedFileTypes = fileTypes[matrix.selectedRow];
	};
    m.actionBlock(m);

    panel.nameFieldStringValue = self.displayName;
	NSWindow *window = self.windowForSheet;
	[panel beginSheetModalForWindow:window completionHandler:^(NSInteger result)
	 {
		 if (result == NSFileHandlingPanelOKButton)
		 {
			 NSPopUpButton *d = [accessoryView viewWithTag:10];
			 NSPopUpButton *e = [accessoryView viewWithTag:11];

			 NSArray <NSString *>*delimiters = @[@",", @";", @"	", @":", @" "];
			 NSArray <NSNumber *>*encodings = @[@(NSUTF8StringEncoding), @(NSUnicodeStringEncoding), @(NSMacOSRomanStringEncoding), @(NSASCIIStringEncoding)];

			 if (m.selectedRow == 0)
				 [self->_data_ exportCSV:panel.URL
							   delimiter:delimiters[d.indexOfSelectedItem]
								encoding:encodings[e.indexOfSelectedItem].intValue];
			 else if (m.selectedRow == 1)
				 [self->_data_ exportExcel:panel.URL xml:NO];
             else if (m.selectedRow == 2)
                 [self->_data_ exportExcel:panel.URL xml:YES];
             else if (m.selectedRow == 3)
                 [self->_data_ exportPDF:panel.URL withView:[self generatePrintView]];
             else
                 assert(0);
         }
	 }];
}


- (void)insertRow:(NSMenuItem *)sender
{
	LOGFUNCA;

	NSInteger insertLocation;
	BOOL insertAbove = (sender.tag == 1);



	if (!_tableView.selectedCells.count)
	{
		insertLocation = insertAbove ? 0 : _data_.rowCount;
	}
	else
	{
		CCIntRange1D r = [_tableView.selectedCells calculateExtentsOfValues:^int(Cell *c) { return (int)c.rowIndex; }];

		assert(r.min == [[_tableView.selectedCells valueForKeyPath:@"@min.rowIndex"] intValue]);
		assert(r.max == [[_tableView.selectedCells valueForKeyPath:@"@max.rowIndex"] intValue]);
		insertLocation = insertAbove ? r.min : r.max + 1;

		[_tableView reloadData];
		[_tableView clearSelection:NO];
	}


	[self.data_ insertRow:insertLocation];


//	[self fitTableColumsToData];
//	[self.tableView clearSelection:NO];
	[self movePlusRowButton];

	[self reloadTableAndGraphs];
}

- (void)insertColumn:(NSMenuItem *)sender
{
	LOGFUNCA;
	NSInteger insertLocation;
	BOOL insertBefore = (sender.tag == 1);

	if (!_tableView.selectedCells.count)
	{
		insertLocation = insertBefore ? 0 : _data_.columnCount;
	}
	else
	{
		CCIntRange1D r = [_tableView.selectedCells calculateExtentsOfValues:^int(Cell *c) { return (int)c.columnIndex; }];
		assert(r.min == [[_tableView.selectedCells valueForKeyPath:@"@min.columnIndex"] intValue]);
		assert(r.max == [[_tableView.selectedCells valueForKeyPath:@"@max.columnIndex"] intValue]);
		insertLocation = insertBefore ? r.min - 1 : r.max;

		[_tableView reloadData];
		[_tableView clearSelection:NO];
	}


	[self.data_ insertColumn:insertLocation];

	NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@""];
	column.width = 80;
	[_tableView addTableColumn:column];
	[_tableView moveColumn:_tableView.tableColumns.count-1 toColumn:insertLocation+1];


	[self fitTableColumsToData];
//	[self.tableView clearSelection:NO];
//	[self reloadTableAndGraphs];
}

- (void)sortColumn:(NSMenuItem *)sender
{
	LOGFUNCA;
	if (!_tableView.selectedCells.count) {	NSBeep(); return; }

	BOOL ascending = (sender.tag % 2 == 1) || (sender.tag % 2 == -1);
	NSMutableIndexSet *columnIndices = [NSMutableIndexSet new];
	NSMutableIndexSet *rowIndices = [NSMutableIndexSet new];

	// determine columns to sort and rows to apply sorting to
	[_tableView.selectedCells enumerateObjectsUsingBlock:^(Cell *c, NSUInteger idx, BOOL *stop)
	 {
		 [columnIndices addIndex:c.columnIndex];
		 [rowIndices addIndex:c.rowIndex];
	 }];

	if (!columnIndices.count) return;

	[columnIndices enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
	 {
		 [self->_data_ sortColumn:idx
                        ascending:ascending
                       rowsToSort:(sender.tag >= 10 ? rowIndices : nil)
                       wholeTable:(sender.tag < 0 ? NO : YES)];
	 }];


	self.editingColumn = -1;
	self.editingRow = -1;
	[self reloadTableAndGraphs];
}

- (void)sortColumn:(int)column sortAscending:(BOOL)ascending onlySelected:(BOOL)sortOnlySelectedRows wholeTable:(BOOL)wholeTable // called from the table header view (context menu)
{
	LOGFUNCA;
	NSMutableIndexSet *rowIndices = [NSMutableIndexSet new];

	if (sortOnlySelectedRows)
		[self.tableView.selectedCells enumerateObjectsUsingBlock:^(Cell *c, NSUInteger idx, BOOL *stop){ [rowIndices addIndex:c.rowIndex]; }];


	[self->_data_ sortColumn:column
                   ascending:ascending
                  rowsToSort:sortOnlySelectedRows ? rowIndices : nil
                  wholeTable:wholeTable];



	self.editingColumn = -1;
	self.editingRow = -1;
	[self reloadTableAndGraphs];
}

- (void)removeRows:(id)sender
{
    if (!_tableView.selectedCells.count) {	LOGFUNCA; NSBeep(); return; }

	[self.windowForSheet endEditingFor:nil];

	NSMutableIndexSet *rowIndices = [NSMutableIndexSet new];
	[_tableView.selectedCells enumerateObjectsUsingBlock:^(Cell *c, NSUInteger idx, BOOL *stop) { [rowIndices addIndex:c.rowIndex]; }]; // datachange

    if (rowIndices.count == _data_.rowCount) {    LOGFUNCA; NSBeep(); return; }

    LOGFUNCPARAMA(makeString(@" ri%@ rc%lu cc%lu", rowIndices.description, (unsigned long)_data_.rowCount, (unsigned long)_data_.columnCount));

	[self.data_ removeRows:rowIndices];

	// [self fitTableColumsToData];
	
	[self.tableView clearSelection:NO];
	[self reloadTableAndGraphs];

	[self movePlusRowButton];
    
    VALIDATE;
}

- (void)removeColumns:(id)sender
{
	if (!_tableView.selectedCells.count) {	LOGFUNCA; NSBeep(); return; }

	[self.windowForSheet endEditingFor:nil];

	NSMutableIndexSet *columnIndices = [NSMutableIndexSet new];

	[_tableView.selectedCells enumerateObjectsUsingBlock:^(Cell *c, NSUInteger idx, BOOL *stop) { [columnIndices addIndex:c.columnIndex-1]; }]; // datachange

    LOGFUNCPARAMA(makeString(@" ci%@ rc%lu cc%lu", columnIndices.description, (unsigned long)_data_.rowCount, (unsigned long)_data_.columnCount));

	[self.data_ removeColums:columnIndices];


	[self.tableView clearSelection:NO];
	NSArray *columnsToBeRemoved = [[_tableView.tableColumns subarrayFromIndex:1] objectsAtIndexes:columnIndices];

	for (NSTableColumn *column in columnsToBeRemoved)
	{
//		NSUInteger ci = [_tableView.tableColumns indexOfObject:column];
//
//		if ([self->_tableView isColumnSelected:ci])
//			[self->_tableView deselectColumn:ci];

		[self->_tableView removeTableColumn:column];
	}

	[self setupColumnTitles];

	[self movePlusColumnButton];
}

- (void)autosizeColumns:(id)sender
{
	if (!_tableView.selectedCells.count) {	LOGFUNCA; NSBeep(); return; }

	NSMutableIndexSet *columnIndices = [NSMutableIndexSet new];

	[_tableView.selectedCells enumerateObjectsUsingBlock:^(Cell *c, NSUInteger idx, BOOL *stop) { [columnIndices addIndex:c.columnIndex-1]; }];
    LOGFUNCPARAMA(columnIndices.description);

	[self autosizeColumnsWithIndices:columnIndices];
}

- (void)autosizeColumnsWithIndices:(NSIndexSet *)columnIndices
{
	LOGFUNCA;


	if (columnIndices.count > 1000)
	{
		cc_log(@"Warning: NOT going to autosize %lu columns", (unsigned long)columnIndices.count);
		NSBeep();
		return;
	}


	[self.undoManager beginUndoGrouping];
	[self.undoManager setActionName:@"Autosize Columns"];



	__isAutosizeOfMultipleColumns = YES;

	[columnIndices enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
	 {
		 NSTableColumn *co = self->_tableView.tableColumns[idx+1];

		 double max = 40;

		 for (NSUInteger i = 0; i < self->_data_.rowCount; i++)
			 max = MAX(max, [self->_tableView preparedCellAtColumn:idx+1 row:i].cellSize.width);

		 co.width = max+5;
	 }];

	[self.undoManager endUndoGrouping];

	__isAutosizeOfMultipleColumns = NO;

	[self movePlusColumnButton];
	[self saveColumnWidths];
	VALIDATE;

	[_tableView setNeedsDisplay];
}

- (void)moveRow:(id)sender
{
	LOGFUNCA;
	if (!_tableView.selectedCells.count) {	NSBeep(); return; }


	NSString *result;
	if (alert_input(@"Insert row number to move selected rows to:", @[@"OK", @"Cancel"], &result) == NSAlertFirstButtonReturn)
	{
		if (result.intValue < 1)
		{
			NSBeep();
			return;
		}

		if (result.integerValue == 666999666) // crash easter egg how nice
			@throw ([NSException exceptionWithName:@"squirrelsaregreat" reason:@"gonuts" userInfo:nil]);


		__block NSUInteger destinationRow = result.intValue-1;

		NSMutableIndexSet *rowIndices = [NSMutableIndexSet new];
		[_tableView.selectedCells enumerateObjectsUsingBlock:^(Cell *c, NSUInteger idx, BOOL *stop) { [rowIndices addIndex:c.rowIndex]; }];

		if (!(rowIndices.count == rowIndices.lastIndex - rowIndices.firstIndex + 1)) // we need it contignuous
		{
			NSBeep();
			return;
		}

		if (!(destinationRow > rowIndices.lastIndex || destinationRow < rowIndices.firstIndex))
		{
			NSBeep();
			return;
		}

		destinationRow = MIN(destinationRow, _data_.rowCount - rowIndices.count);


		[_tableView reloadData];
		[_tableView clearSelection:NO];
		
		[self.data_ moveRows:rowIndices toIndex:destinationRow];

		[_tableView setNeedsDisplay];

//		[self resize-Clicked:self];
	}
}

#pragma mark IBAction


- (IBAction)resizeClicked:(NSButton *)sender
{
	LOGFUNCPARAMA(makeString(@"old %lu|%lu new %lu|%lu", (unsigned long)self.data_.columnCount, (unsigned long)self.data_.rowCount, (unsigned long)_newColumns, (unsigned long)_newRows));

	if ((id)sender != nil)
		[sender.window endEditingFor:nil];


	[self.data_ resizeTable:(coordinates){_newColumns, _newRows}];

	[self fitTableColumsToData];
	[self.tableView clearSelection:NO];
	[self reloadTableAndGraphs];

	
	VALIDATE;
}


- (IBAction)addRow:(id)sender
{
	VALIDATE;
	BOOL optionDown = ([NSEvent modifierFlags] & NSAlternateKeyMask) != 0;
    LOGFUNCPARAMA(makeString(@" o%i rc%lu cc%lu", optionDown, (unsigned long)_data_.rowCount, (unsigned long)_data_.columnCount));

	if (optionDown)
	{
		[_tableView clearSelection:NO]; // could crash in tableViewSelectionDidChange _data_.attributes[_tableView.selectedCells[0].rowIndex]
        
        if (_data_.rowCount >= 2) // make sure last row isn't removed
            [self.data_ removeRows:[NSIndexSet indexSetWithIndex:_data_.rowCount-1]];
        else
            NSBeep();
    }
	else
		[self.data_ insertRow:_data_.rowCount];

	[self movePlusRowButton];
	[self reloadTableAndGraphs];

	VALIDATE;
}

- (IBAction)addColumn:(id)sender
{
	VALIDATE;

	[self.windowForSheet endEditingFor:nil]; // else we can have a crash e.g. when removing a column that has a cell currently editing

	BOOL optionDown = ([NSEvent modifierFlags] & NSAlternateKeyMask) != 0;
    LOGFUNCPARAMA(makeString(@" o%i rc%lu cc%lu", optionDown, (unsigned long)_data_.rowCount, (unsigned long)_data_.columnCount));

	if (optionDown)
	{
		[_tableView clearSelection:NO]; // could crash in tableViewSelectionDidChange _data_.attributes[_tableView.selectedCells[0].rowIndex]
        
        if (_data_.columnCount >= 2) // make sure last column isn't removed
            [self.data_ removeColums:[NSIndexSet indexSetWithIndex:_data_.columnCount-1]];
        else
            NSBeep();
	}
	else
		[self.data_ insertColumn:_data_.columnCount];


	[self fitTableColumsToData];
	[self reloadTableAndGraphs];

	VALIDATE;
}

//- (void)createNewColorPreset
//{
//    NSString *name;
//    NSInteger res = alert_input(@"Please enter a name for your new color preset.", @[@"OK", @"Cancel"], &name);
//
//    if (res == NSAlertSecondButtonReturn || !name.length)
//        return;
//
//    BOOL done = FALSE;
//    int num = 0;
//    while (!done)
//    {
//        num++;
//        NSColor *c = [NSColor blueColor];
//        alert_colorwell(makeString(@"Please select a Color for Color #%i of your new preset '%@'", num, name), @[@"Add Color", @"Finish"], &c);
//        LOG(c);
//    }
//}

#pragma mark NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return _data_.rowCount;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	//LOGFUNC;
	NSArray *tableColums = _tableView.tableColumns;
	NSInteger columnIndex = [tableColums indexOfObject:aTableColumn];

	if (!aTableView)
		return _data_.data[rowIndex][columnIndex-1];

	if (!columnIndex)
		return @(rowIndex+1).stringValue;
	else
	{
		if ((columnIndex) == self.editingColumn && rowIndex == self.editingRow)
		{
			LOGFUNC;

//			NSText *fe = [self.windowForSheet fieldEditor:NO forObject:_tableView];
//
//			if (fe)
//				return fe.string;
//			else
				return _data_.data[rowIndex][columnIndex-1];
		}



        // so valueForRow can throw a REF exception, we got a few reports. seems to happen on 10.10- ... perhaps system asks for drawing ..code is just to getm  ore info
        if (rowIndex >= (NSInteger)_data_.rowCount || (columnIndex-1) >= (NSInteger)_data_.columnCount)
        {
            cc_log_error(@"Error: tableView:objectValueForTableColumn:row: asked for inexistent cell ri %li drc %li ci %li dcc %li", rowIndex, _data_.rowCount, (columnIndex-1), _data_.columnCount);

            return @"";
        }


		NSString *d = [_data_ valueForRow:rowIndex column:columnIndex-1 throw:NO];


		NSDictionary *attributes = _data_.attributes[rowIndex][columnIndex-1];
		NSNumber *formatObject = attributes[kFormatTypeKey];
		if (formatObject && ![d isEqualTo:@""])
		{
			formatKind format = (formatKind) formatObject.intValue;

			if (format == formatString)
				return d.stringValue;
			else if (format == formatTime)
			{
				NSNumber *number = d.numberValue;

				if (number)
				{
					NSString *timeString = [FormatterHelper formattedStringFromTime:number
																			   type:(formatTimeKind)[attributes[kFormatTimeTypeKey] intValue]
																			 format:[attributes[kFormatTimeFormatKey] intValue]];

					return timeString;
				}
				else
				{
					cc_log_debug(@"Info: failed to create formatted time from: %@ at c%li r%li", d, (long)columnIndex, (long)rowIndex);
					return d;
				}
			}
			else if (format == formatDate)
			{
				NSDate *date = d.dateValue;

				if (date)
				{
					NSDateFormatterStyle datef = attributes[kFormatDateDateKey] ? [attributes[kFormatDateDateKey] intValue] : 2;
					NSDateFormatterStyle timef = attributes[kFormatDateTimeKey] ? [attributes[kFormatDateTimeKey] intValue ] : 0;
					NSString *dateString = [FormatterHelper formattedStringFromDate:date
																		  dateStyle:datef
																		  timeStyle:timef];

					return dateString;
				}
				else
				{
                    cc_log_debug(@"Info: failed to create formatted date from: %@ at c%li r%li", d, (long)columnIndex, (long)rowIndex);

					return d;
				}
			}
			else if (format == formatNumber)
			{
				NSNumber *number = d.numberValue;

				if (number)
				{
					return [FormatterHelper formattedStringFromNumber:number attributes:attributes];
				}
				else
				{
                    cc_log_debug(@"Info: failed to create formatted number from: %@ at c%li r%li", d, (long)columnIndex, (long)rowIndex);

					return d;
				}
			}
		}
		else
		{
            if ([d isKindOfClass:NSNumber.class])
			{	// we convert numbers to strings  because returning numbers displays thousend separators and returning d.stringValue uses non-localized . comma separator
				static NSNumberFormatter *nf;
				ONCE_PER_FUNCTION(^
				{
					nf = [NSNumberFormatter new];
					nf.numberStyle = kCFNumberFormatterDecimalStyle;
					nf.usesGroupingSeparator = NO;
				});
				return [nf stringFromNumber:(NSNumber *)d];
			}
			else
				return d;
		}
	}
	assert(0);
	return nil;
}

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	LOGFUNC;
	[self tableViewSelectionDidChange:nil];

	NSUInteger column = [tableView.tableColumns indexOfObject:tableColumn];

	if (!column) return NO;

	self.editingColumn = column;
	self.editingRow = row;

	[tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:row]
						 columnIndexes:[NSIndexSet indexSetWithIndex:column]];



	return YES;
}

- (void)tableView:(NSTableView *)tv setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	LOGFUNCA;
	VALIDATE;

	NSUInteger column = [_tableView.tableColumns indexOfObject:tableColumn]-1;
	[self _tableViewSetObjectValue:object column:column row:row];
}

- (void)_tableViewSetObjectValue:(id)object column:(NSInteger)column row:(NSInteger)row // this has to go to a private method because undo wouldn't work with the TC object reference
{
	LOGFUNC;


	NSString *oldvalue = _data_.data[row][column];
	if ([object isEqual:oldvalue])
		return;



	[self.undoManager beginUndoGrouping];
	[[self.undoManager prepareWithInvocationTarget:self] _tableViewSetObjectValue:oldvalue column:column row:row];
	[self.undoManager setActionName:@"Change Cell Content"];
	[self.undoManager endUndoGrouping];



	[_data_ writeData:object toCellAtRow:row column:column];



	self.editingColumn = -1;
	self.editingRow = -1;



//	if (_tableView.hasOpenedUndoGroup)
//	{
//		_tableView.hasOpenedUndoGroup = NO;
//		[self.undoManager endUndoGrouping];
//		cc_log(@"***** CLOSING undo group ***************");
//	}
	VALIDATE;
}

#pragma mark NSTableViewDelegate

- (NSCell *)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	if (tableColumn)
	{
		NSTextFieldCell *cell = [NSTextFieldCell new];

		cell.editable = YES;
		cell.allowsUndo = NO;
		cell.truncatesLastVisibleLine = YES;
		
		return cell;
	}
	else
		return nil;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectTableColumn:(NSTableColumn *)tableColumn
{
	LOGFUNCA;
	return [tableView.tableColumns indexOfObject:tableColumn] > 0;
}

- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn
{
	LOGFUNCA;
	BOOL shiftDown = (NSEvent.modifierFlags & NSShiftKeyMask) > 0;
	BOOL commandDown = (NSEvent.modifierFlags & NSCommandKeyMask) > 0;
	NSUInteger columnIndex = [tableView.tableColumns indexOfObject:tableColumn];
	static NSUInteger lastColumnIndex = 0;

	if (!shiftDown && !commandDown)
		[_tableView clearSelection:YES];
	if (columnIndex)
	{
		if (shiftDown && lastColumnIndex)
			[_tableView addColumnsToSelection:MIN(columnIndex, lastColumnIndex) maxColumn:MAX(columnIndex, lastColumnIndex)];
		else
			[_tableView addColumnToSelection:columnIndex];
	}
	else
		[_tableView selectAll:nil];

	lastColumnIndex = columnIndex;
}

- (void)tableViewColumnDidResize:(NSNotification *)not
{
	NSTableColumn *tc = not.userInfo[@"NSTableColumn"];
	CGFloat oldWidth = [not.userInfo[@"NSOldWidth"] doubleValue];
	CGFloat newWidth = tc.width;
	NSUInteger columnIndex = [_tableView.tableColumns indexOfObject:tc];
    LOGFUNCPARAMA(@(columnIndex));


	[[self.undoManager prepareWithInvocationTarget:self] resizeTableColumn:columnIndex fromWidth:newWidth toWidth:oldWidth];
	[self.undoManager setActionName:@"Resize Column"];

	if (!__isAutosizeOfMultipleColumns)
	{
		[self movePlusColumnButton];
		[self saveColumnWidths];
		VALIDATE;
	}
    
    [_tableView updateSelectionInformation];
}

- (void)resizeTableColumn:(NSUInteger)columnIndex fromWidth:(CGFloat)oldWidth toWidth:(CGFloat)newWidth
{
	LOGFUNC;

	NSTableColumn *tc = _tableView.tableColumns[columnIndex];

	tc.width = newWidth;

	[[self.undoManager prepareWithInvocationTarget:self] resizeTableColumn:columnIndex fromWidth:newWidth toWidth:oldWidth];
	[self.undoManager setActionName:@"Resize Column"];

	[self movePlusColumnButton];
	[self saveColumnWidths];
	VALIDATE;
}

- (void)tableViewSelectionDidChange:(NSNotification *)not
{
	if (not) LOGFUNCA;
	else LOGFUNC;

	//	[self toolbarPopoverClose:nil];

	[self willChangeValueForKey:@"validSelection"];
	self.editingColumn = -1;
	self.editingRow = -1;


	//    NSInteger selectedRow = [self.tableView selectedRow];
	//    [self.tableView deselectRow:selectedRow];

//    if (_tableView.selectedCells) // TODO: ???¿¿¿???
//    {
//        NSDictionary *attributes = _data_.attributes[_tableView.selectedCells[0].rowIndex][_tableView.selectedCells[0].columnIndex-1];
//
//        // font popup
//        int alignmentTable[] = {0, 2, 1, 3};
//        NSNumber *alignment = attributes[kFontAlignmentKey];
//        self.cellFontAlignmentIndex = alignment ? alignmentTable[alignment.intValue] : 0;
//
//
//        NSColor *color = attributes[kFontColorKey];
//        self.cellFontColor = OBJECT_OR(color, NSColor.blackColor);
//
//
//        NSFont *font = attributes[kFontFontKey];
//        self.cellFont = OBJECT_OR(font, [NSFont systemFontOfSize:12]);
//        self.fontSize = (NSInteger) self.cellFont.pointSize;
//        NSString *fontFamilyName = self.cellFont.familyName;
//        if ([fontFamilyName hasPrefix:@"."])
//            self.fontListIndex = 0;
//        else
//            self.fontListIndex = [self.fontFamilyNames indexOfObject:fontFamilyName];
//
//
//        // background popup
//        color = attributes[kBackgroundColorKey];
//        self.cellBackgroundColor = OBJECT_OR(color, NSColor.whiteColor);
//
//        color = attributes[kBackgroundBorderColorKey];
//        self.cellBorderColor = OBJECT_OR(color, NSColor.blackColor);
//        self.cellBorderWidth = [attributes[kBackgroundBorderWidthKey] shortValue];
//
//        // format popup
//        self.cellFormatKindIndex = [attributes[kFormatTypeKey] intValue];
//        self.cellFormatNumberKindIndex = [attributes[kFormatNumberTypeKey] intValue];
//        self.cellFormatNumberDecimals = [attributes[kFormatNumberDecimalsKey] intValue];
//        self.cellFormatNumberCustomNegativeFormat = [attributes[kFormatNumberCustomNegativeFormatKey] stringValue];
//        self.cellFormatNumberCustomPositiveFormat = [attributes[kFormatNumberCustomPositiveFormatKey] stringValue];
//        self.cellFormatNumberGrouping = [attributes[kFormatNumberGroupingKey] boolValue];
//        self.cellFormatNumberCurrency = [attributes[kFormatNumberCurrencyCurrencyKey] intValue];
//        self.cellFormatDateDateFormat = attributes[kFormatDateDateKey] ? [attributes[kFormatDateDateKey] intValue] : 2;
//        self.cellFormatDateTimeFormat = [attributes[kFormatDateTimeKey] intValue];
//    }
//    else
//    {
//        self.cellFontAlignmentIndex = -1;
//    }
	[self didChangeValueForKey:@"validSelection"];
}


- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	//LOGFUNC;
	NSTextFieldCell *aCell = cell;
	NSInteger column = [tableView.tableColumns indexOfObject:tableColumn];

	if (column == 0) // rowindex pseudo-cells
	{
		aCell.alignment = NSCenterTextAlignment;

		static NSColor *leftRowCellColor;
		ONCE_PER_FUNCTION(^{ leftRowCellColor = makeColor(0.96f, 0.96f, 0.96f, 1.0f); });

		aCell.backgroundColor = leftRowCellColor;
		aCell.drawsBackground = YES;
		aCell.font = _columnCellFont;


		return;
	}

    if (row >= (NSInteger)_data_.rowCount || (column-1) >= (NSInteger)_data_.columnCount)
    {
        cc_log_error(@"Error: tableView:willDisplayCell:forTableColumn:row: asked for nonexistent cell r %li drc %li c %li dcc %li", row, _data_.rowCount, column, _data_.columnCount);
        return;
    }
	NSString *cellString = aCell.stringValue;
    NSDictionary *attributes = _data_.attributes[row][column-1];
   
    
	if (cellString.length)
	{
		aCell.alignment = [attributes[kFontAlignmentKey] intValue];

		NSColor *color = attributes[kFontColorKey];
		if (color)
			aCell.textColor = color;

		NSFont *font = attributes[kFontFontKey];
		if (font)
			aCell.font = font;
	}


	NSColor *color = attributes[kBackgroundColorKey];
	if (color)
	{
		aCell.backgroundColor = color;
		aCell.drawsBackground = YES;
	}
	else
	{
		if (_data_.enableRowColors)
		{
			aCell.drawsBackground = YES;
			aCell.backgroundColor = row % 2 == 0 ? _data_.oddRowColor : _data_.evenRowColor;
		}

	}

	if (cellString.length && [cellString contains:@"\n"])
		aCell.stringValue = cellString = [cellString replaced:@"\n" with:@" "];
}

- (BOOL)tableView:(NSTableView *)tableView shouldReorderColumn:(NSInteger)columnIndex toColumn:(NSInteger)newColumnIndex
{
	LOGFUNCA;
	return columnIndex != 0 && newColumnIndex != 0;
}

- (void)tableView:(NSTableView *)tableView didDragTableColumn:(NSTableColumn *)tableColumn
{
	LOGFUNCA;
	unichar t = 'A';
	unichar oldHeader = tableColumn.headerCell.stringValue.firstCharacter;
	unsigned long oldPosition = oldHeader-t;
	unsigned long newPosition = [tableView.tableColumns indexOfObject:tableColumn]-1;


	[_data_ moveColumn:oldPosition toIndex:newPosition];

    [self.tableView clearSelection:NO];
	[self reloadTableAndGraphs];

	[self setupColumnTitles];

	VALIDATE;
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
	LOGFUNCA;

	return YES;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
	LOGFUNCA;

	self.insertionColumn = -1;
	self.insertionRow = -1;
	
	[self.tableView setNeedsDisplay];
}

- (BOOL)tableView:(NSTableView *)tv acceptDrop:(id <NSDraggingInfo>)info row:(NSInteger)unused dropOperation:(NSTableViewDropOperation)dropOperation
{
	LOGFUNCA;
	NSPoint p = [_tableView convertPoint:info.draggingLocation fromView:nil];
	NSInteger r;
	//NSTableColumn *c;
	NSPasteboard *pb = info.draggingPasteboard;
	NSString *str = [pb stringForType:NSPasteboardTypeString];

	self.insertionColumn = -1;
	self.insertionRow = -1;

	if (!str)
		return NO;


	NSInteger columnIndexAtPoint = [_tableView columnAtPoint:p];
	if (columnIndexAtPoint > 0 && columnIndexAtPoint < (int)_tableView.tableColumns.count)
	{
		r = [_tableView rowAtPoint:p];
		if (r < 0)
			return NO;

		//c = _tableView.tableColumns[columnIndexAtPoint];
	}
	else
		return NO;


	NSString *name = [AddressHelper indicesToString:columnIndexAtPoint rowIndex:r];
	if (![_tableView.selectedCellMap valueForKey:name])
	{
		for (NSString *line in str.lines)
		{
			if (IS_IN_RANGE((unsigned long)r, 0, _data_.rowCount - 1))
			{
				NSUInteger col = columnIndexAtPoint;
				for (NSString *comp in [line componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\t"]])
				{
					if (IS_IN_RANGE(col, 0, _data_.columnCount))
					{
						[self tableView:_tableView
						 setObjectValue:comp
						 forTableColumn:_tableView.tableColumns[col++]
									row:r];
					}
				}
				r++;
			}
		}

	//	[self tableView:_tableView setObjectValue:str forTableColumn:c row:r];

		return YES;
	}
	else
		return NO;
}


- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)ignore proposedDropOperation:(NSTableViewDropOperation)op
{
	LOGFUNCA;

	self.insertionColumn = -1;
	self.insertionRow = -1;
	[self.tableView setNeedsDisplay];

	[tv setDropRow:-1 dropOperation:NSTableViewDropOn];


	NSPasteboard *pb = info.draggingPasteboard;
	NSString *str = [pb stringForType:NSPasteboardTypeString];
	if ([str isEqualToString:@"=CHART(__SELECTED__)"])
		return NSDragOperationCopy;

	if (ignore >= (int)_data_.rowCount || ignore < 0)
		return NSDragOperationNone;


	NSPoint p = [_tableView convertPoint:info.draggingLocation fromView:nil];
	NSInteger r;
	//	NSTableColumn *c;
	NSInteger columnIndexAtPoint = [_tableView columnAtPoint:p];
	if (columnIndexAtPoint > 0 && columnIndexAtPoint < (int)_tableView.tableColumns.count)
	{
		r = [_tableView rowAtPoint:p];
		//		c = _tableView.tableColumns[columnIndexAtPoint];
		if (r >= 0)
		{
			//			selectedRow = r;
			//			selectedColumn = c;
			//			[_tableView setNeedsDisplay];

			NSString *name = [AddressHelper indicesToString:columnIndexAtPoint rowIndex:r];
			if (![_tableView.selectedCellMap valueForKey:name])
			{
				self.insertionColumn = columnIndexAtPoint;
				self.insertionRow = r;
			}
			else
				return NSDragOperationNone;

		}
		else
			return NSDragOperationNone;
	}
	else
		return NSDragOperationNone;


	//	NSLog(@"insertion %i %i", self.insertionRow, self.insertionColumn);
	return NSDragOperationCopy;
}

//- (BOOL)selectionShouldChangeInTableView:(NSTableView *)aTableView
//- (BOOL)tableView:(NSTableView *)tableView shouldTrackCell:(NSCell *)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
//- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row;
//- (NSIndexSet *)tableView:(NSTableView *)tableView selectionIndexesForProposedSelection:(NSIndexSet *)proposedSelectionIndexes;
//- (BOOL)tableView:(NSTableView *)tableView shouldSelectTableColumn:(NSTableColumn *)tableColumn;
//- (void)tableView:(NSTableView *)tableView mouseDownInHeaderOfTableColumn:(NSTableColumn *)tableColumn;
//- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn;
//- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row;
//- (NSString *)tableView:(NSTableView *)tableView toolTipForCell:(NSCell *)cell rect:(NSRectPointer)rect tableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row mouseLocation:(NSPoint)mouseLocation
//- (CGFloat)tableView:(NSTableView*)tableView sizeToFitWidthOfColumn:(NSInteger)column


- (void)flagsChanged:(NSEvent *)event
{
    [(DraggableButton *)self.addRowButton flagsChanged:event];
    [(DraggableButton *)self.addColumnButton flagsChanged:event];
}


#pragma mark NSWindowDelegate


- (void)window:(NSWindow *)window didDecodeRestorableState:(NSCoder *)state // only called for restored and not for opened document
{
	LOGFUNC;
	//[self generateMissingGraphViews];
}

- (void)windowDidResize:(NSNotification *)notification
{
//	LOGFUNC;
//	if (self.tableView.document == self)
//		ONCE_PER_OBJECT(self, (^{[self generateMissingGraphViews];})) // must be called after window size has been restored (but didDecodeRestorableState is not called in every case) and after windowControllerDidLoadNib
}

- (void)windowDidEndLiveResize:(NSNotification *)notification
{
	LOGFUNCA;

//	// when the window did resize, our graphs have a different frame since it is lower-left based, we need to update it
//	for (NSView *v in [chartContainerView subviews])
//	{
//		if ([v isKindOfClass:CPTGraphHostingView.class])
//		{
//			CPTGraphHostingView *view = (CPTGraphHostingView *)v;
//			NSDictionary *graph = [_data_ graphWithView:view];
//
//			assert(graph);
//			NSString *newFrame = NSStringFromRect(view.frame);
//
//			 [_data_ setGraph:graph value:newFrame forKey:@"frame"];
//		}
//	}
}

- (NSRect)windowWillUseStandardFrame:(NSWindow *)window defaultFrame:(NSRect)newFrame
{
	if (window)
		LOGFUNCA;
	else
		LOGFUNC;
	CGFloat newWidth = _plusColumnConstraint.constant - 4;
	CGFloat newHeight = _plusRowConstraint.constant + 80;
	NSRect r = NSMakeRect(self.windowForSheet.frame.origin.x,
                          self.windowForSheet.frame.origin.y + (self.windowForSheet.frame.size.height - newHeight),
						  MAX(newWidth,700),
                          newHeight);

	//[self windowDidResize:nil];

	return r;
}

//- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
//{
//	return _tableView.undoManager;
//}


#pragma mark resize panel bindings

+ (NSSet *)keyPathsForValuesAffectingIsNotShrinking
{
	return @[@"newRows", @"newColumns"].set;
}

- (IBAction)sliderFinished:(id)sender
{
	LOGFUNCA;
	NSEvent *event = application.currentEvent;
	BOOL endingDrag = event.type == NSLeftMouseUp;
	if (endingDrag)
	{
		[self willChangeValueForKey:@"maxNewRows"];
		[self didChangeValueForKey:@"maxNewRows"];
		[self willChangeValueForKey:@"maxNewColumns"];
		[self didChangeValueForKey:@"maxNewColumns"];
	}
}

- (BOOL)isNotShrinking
{
	return !(_data_.rowCount > _newRows || _data_.columnCount > _newColumns);
}

- (NSUInteger)maxNewRows
{
	return MAX3(100UL, _data_.rowCount * 3, _newRows * 3);
}

- (NSUInteger)maxNewColumns
{
	return MAX3(100UL, _data_.columnCount * 3, _newColumns * 3);
}

#pragma mark NSTextFieldDelegate

//- (void)controlTextDidBeginEditing:(NSNotification *)obj
//{
//	LOGFUNCA;
//
//}



- (void)controlTextDidChange:(NSNotification *)not
{
    LOGFUNCPARAMA(not.object);

	{
		NSTextView *view = not.userInfo[@"NSFieldEditor"];

        // update data model
        [self tableView:nil
         setObjectValue:view.string
         forTableColumn:_tableView.selectedCells[0].column
                    row:_tableView.selectedCells[0].rowIndex];
	}
}

- (BOOL)control:(NSControl*)control textView:(NSTextView*)textView doCommandBySelector:(SEL)commandSelector
{
	LOGFUNCA;
	VALIDATE;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wselector"

	if (commandSelector == @selector(insertTab:) || commandSelector == @selector(insertBacktab:))
	{
		[self.tableView textView:nil doCommandBySelector:commandSelector];
		return YES;
	}

#pragma clang diagnostic pop


	return NO;
}

#pragma mark Column Header Double Click Sorting

- (void)doubleClickInTableView:(id)sender
{
	LOGFUNCA;
	VALIDATE;
	NSInteger row = _tableView.clickedRow;
	NSInteger column = _tableView.clickedColumn;

	if(row == -1 && column > 0)
	{
		[_data_ sortColumn:column
                 ascending:!(self.lastSortColumn != column || self.lastSortAscending)
                rowsToSort:nil
                wholeTable:	((NSEvent.modifierFlags & NSShiftKeyMask) > 0) ? NO : YES];


		_lastSortAscending = (_lastSortColumn == column) ? !_lastSortAscending : FALSE;
		_lastSortColumn = column;

		self.editingColumn = -1;
		self.editingRow = -1;

		[self reloadTableAndGraphs];

		VALIDATE;
	}
}

#pragma mark NSUndoManager notifications

- (void)willUndoChangeNotification:(NSNotification *)not
{
#if defined(DEBUG) && !defined(FORCE_NOLOG)
	NSUndoManager *um = not.object;
	NSString *actionName = [[um.undoActionName stringByAppendingString:@" | "] stringByAppendingString:um.redoActionName];

	LOGFUNCPARAMA(actionName);
#endif

	[self.windowForSheet endEditingFor:nil];
}

- (void)willRedoChangeNotification:(NSNotification *)not
{
#if defined(DEBUG) && !defined(FORCE_NOLOG)
	NSUndoManager *um = not.object;
	NSString *actionName = [[um.undoActionName stringByAppendingString:@" | "] stringByAppendingString:um.redoActionName];

	LOGFUNCPARAM(actionName);
#endif

	[self.windowForSheet endEditingFor:nil];
}

- (void)didUndoChangeNotification:(NSNotification *)not
{
#if defined(DEBUG) && !defined(FORCE_NOLOG)
	NSUndoManager *um = not.object;
	NSString *actionName = [[um.undoActionName stringByAppendingString:@" | "] stringByAppendingString:um.redoActionName];

	LOGFUNCPARAM(actionName);
#endif

//
//	if ([actionName contains:@"Move Column"])
//		[self recreateTableColumns];
//	if ([actionName contains:@"Remove Row"] || [actionName contains:@"Insert Row"])
//	{
//		[self movePlusRowButton];
//		[self.tableView clearSelection:NO];
//	}
//	if ([actionName contains:@"Remove Column"] || [actionName contains:@"Insert Column"] || [actionName contains:@"Resize Table"])
//	{
//		[self recreateTableColumns];
//		[self.tableView clearSelection:NO];
//	}
//	if ([actionName contains:@"Add Graph"] || [actionName contains:@"Remove Graph"])
//	{
//		[self generateMissingGraphViews];
//		[_data_ updateAllCellDependencies];
//	}

	// TODO: more fine grained undo ... but the group names are overwritten!?


	[self.tableView clearSelection:NO];
	[self movePlusRowButton];
	[self recreateTableColumns];

	
	[self reloadTableAndGraphs];
	[self.tableView setNeedsDisplay:YES];


	LOGFUNCPARAM(@"OUT");

	VALIDATE;
}

- (void)didRedoChangeNotification:(NSNotification *)not
{
#if defined(DEBUG) && !defined(FORCE_NOLOG)
	NSUndoManager *um = not.object;
	NSString *actionName = [[um.undoActionName stringByAppendingString:@" | "] stringByAppendingString:um.redoActionName];

	LOGFUNCPARAM(actionName);
#endif

	[self didUndoChangeNotification:not];

	VALIDATE;
}

- (void)didOpenUndoGroupNotification:(NSNotification *)not
{
//#if defined(DEBUG) && !defined(FORCE_NOLOG)
//	NSUndoManager *um = not.object;
//	NSString *actionName = [[um.undoActionName stringByAppendingString:@" | "] stringByAppendingString:um.redoActionName];
//
//	LOGFUNCPARAM(actionName);
//#endif
}

- (void)didCloseUndoGroupNotification:(NSNotification *)not
{
//#if defined(DEBUG) && !defined(FORCE_NOLOG)
//	NSUndoManager *um = not.object;
//	NSString *actionName = [[um.undoActionName stringByAppendingString:@" | "] stringByAppendingString:um.redoActionName];
//
//	LOGFUNCPARAM(actionName);
//#endif
}


#pragma mark printing

//- (BOOL)preparePageLayout:(NSPageLayout *)pageLayout
//{
//	return YES;
//}

- (BOOL)shouldChangePrintInfo:(NSPrintInfo *)newPrintInfo
{
	[NSPrintInfo setSharedPrintInfo:newPrintInfo];
	return YES;
}

- (NSPrintOperation *)printOperationWithSettings:(NSDictionary *)printSettings error:(__autoreleasing NSError **)outError
{
	LOGFUNCA;
	NSPrintInfo *spi = NSPrintInfo.sharedPrintInfo;

//    kPrintSettingsHorizontalPaginationKey : @(NSFitPagination),
//    kPrintSettingsVerticalPaginationKey : @(NSAutoPagination),
//    kPrintSettingsHorizontallyCenteredKey : @YES,
//    kPrintSettingsVerticallyCenteredKey : @NO,
//    kPrintSettingsTopMarginKey : @(90),
//    kPrintSettingsBottomMarginKey : @(90),
//    kPrintSettingsLeftMarginKey : @(72),
//    kPrintSettingsRightMarginKey : @(72)}


	spi.horizontalPagination = kPrintSettingsHorizontalPaginationKey.defaultInt;
    spi.verticalPagination = kPrintSettingsVerticalPaginationKey.defaultInt;
	spi.horizontallyCentered = (BOOL)kPrintSettingsHorizontallyCenteredKey.defaultInt;
	spi.verticallyCentered = (BOOL)kPrintSettingsVerticallyCenteredKey.defaultInt;
    spi.topMargin = kPrintSettingsTopMarginKey.defaultInt;
    spi.bottomMargin = kPrintSettingsBottomMarginKey.defaultInt;
    spi.leftMargin = kPrintSettingsLeftMarginKey.defaultInt;
    spi.rightMargin = kPrintSettingsRightMarginKey.defaultInt;


    NSView *printView = [self generatePrintView];

	NSPrintOperation *printOperation = [NSPrintOperation printOperationWithView:printView printInfo:spi];
    NSPrintPanel *printPanel = printOperation.printPanel;

    PrintViewController *vc = [[PrintViewController alloc] initWithNibName:@"PrintOptionView" bundle:nil];

    [printPanel addAccessoryController:vc];
    
    return printOperation;
}

- (NSView *)generatePrintView
{
    // the charts can not be printed directly for some reason, we need to prerender them and add them with the prerendered table to a printview
    NSRect tableBounds = {0, 0, _plusColumnConstraint.constant, _plusRowConstraint.constant - _tableView.headerView.frame.size.height};// real table bounds can not be read from any content frame
    NSImage *tableImage = [[NSImage alloc] initWithData:[_tableView dataWithPDFInsideRect:tableBounds]];
    NSImageView *tableImageView = [[NSImageView alloc] initWithFrame:tableBounds]; // init with real content size of table
    tableImageView.image = tableImage;
    
    NSRect printBounds = tableBounds;

    NSView *printView = [[NSView alloc] initWithFrame:printBounds];
    [printView addSubview:tableImageView];    // add prerendered table
    [tableImageView setFrameOrigin:NSMakePoint(0, printBounds.size.height - tableBounds.size.height)];
    
    
    
    cc_log_debug(@"printBounds %@", NSStringFromRect(printBounds));
    
    

    
    return printView;
}
#pragma mark misc support

- (void)setNilValueForKey:(NSString *)key
{
	
}

#pragma mark helpers

- (void)makeWindowWideEnough
{
// FIXME: this is bugged when we have to many rows to fit
	LOGFUNC;

    if ((self.windowForSheet.styleMask & NSFullScreenWindowMask) == NSFullScreenWindowMask) // work around a bug where resizing the table in fullscreen with enough rows to fill the screen will fuck things up
        return;

    // make window bigger if needed
	NSRect r = [self windowWillUseStandardFrame:nil
								   defaultFrame:NSMakeRect(0, 0, 0, 0)];

	if (r.size.width > self.windowForSheet.frame.size.width || r.size.height > self.windowForSheet.frame.size.height)
	{
		NSScreen *s = self.windowForSheet.screen;

		[self.windowForSheet setFrame:CGRectMake(r.origin.x, r.origin.y,
												 MIN(s.frame.size.width-r.origin.x, r.size.width),
												 r.size.height)
							  display:YES];
	}
}

- (void)movePlusRowButton
{
	LOGFUNC;
	// move plus row button
	const NSSize unitSize = { 1.0, 1.0 };
	CGFloat factor = [_tableView convertSize:unitSize toView:nil].width;
	CGFloat rh = _tableView.rowHeight;
	_plusRowConstraint.constant = (_data_.rowCount *(rh+2.0)+25.0) * factor;
}

- (void)movePlusColumnButton
{
	LOGFUNC;

	long totalColumnWidth = [_tableView.tableColumns reduce:^int(NSTableColumn *column ) { return (int)column.width + 3; }];
	const NSSize unitSize = { 1.0, 1.0 };
	CGFloat factor = [_tableView convertSize:unitSize toView:nil].width;
	_plusColumnConstraint.constant = (totalColumnWidth + 4) * factor;
}

- (void)saveColumnWidths
{
	LOGFUNC;

	int i = 0;

	for (NSTableColumn *column in _tableView.tableColumns)
		if (i++ != 0)
			[_data_ setColumn:(i-2) value:@(column.width) forKey:@"width"];
}

//- (void)restoreColumnWidths
//{
//	LOGFUNC;
//
//	int i = 0;
//
//	for (NSTableColumn *column in _tableView.tableColumns)
//		if (i++ != 0)
//			column.width = [_data_.columns[i-2][@"width"] intValue];
//}
//- (void)printColumnWidth
//{
//	int i = 0;
//	for (NSTableColumn *column in _tableView.tableColumns)
//		if (i++ != 0)
//			cc_log_debug(@"%i: %i", i, [_data_.columns[i-2][@"width"] intValue]);
//}

- (void)validate
{
#ifdef DEBUG
	if (self.undoManager.isUndoing || self.undoManager.isRedoing)
		return;

	if (_tableView)
	{
		assert((_tableView.tableColumns.count-1) == _data_.columns.count);
		int i = 0;
		for (NSTableColumn *column in _tableView.tableColumns)
		{
			if (i++ != 0)
			{
				int widthInDataModel = [_data_.columns[i-2][@"width"] intValue];
				int widthInUserInterface = (int)column.width;
				assert(widthInDataModel == widthInUserInterface);
			}
		}
	}


	[_data_ validate];
#endif
}

- (void)reloadTableAndGraphs
{
	[_tableView reloadData];
}

- (void)recreateTableColumns
{
	LOGFUNC;
	// remove columns
	while (_tableView.tableColumns.count > 1)
	{
		NSTableColumn *lastColumn = _tableView.tableColumns.lastObject;
		[_tableView removeTableColumn:lastColumn];
	}
	[self fitTableColumsToData];
}

- (void)fitTableColumsToData
{
	LOGFUNC;

	NSUInteger columns = _data_.columnCount;

	if (!_tableView) return;

	// determine index font size
	NSArray <NSNumber *>*fontSizes = @[@(13),@(13),@(13),@(13),@(13),@(12),@(10),@(8),@(7),@(6),@(6),@(6),@(6),@(6),@(6),@(6)];
	int fontSize = fontSizes[@(_data_.rowCount).stringValue.length].intValue;
	self.columnCellFont = [NSFont systemFontOfSize:fontSize];

	// add columns
	while (_tableView.tableColumns.count < columns+1)
	{
		NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@""];
		column.width = 80;

		if (_data_.columns[_tableView.tableColumns.count-1][@"width"]) // restore width
			column.width = [_data_.columns[_tableView.tableColumns.count-1][@"width"] intValue];
		[_tableView addTableColumn:column];
	}

	// remove columns
	while (_tableView.tableColumns.count > columns+1)
	{
		NSTableColumn *lastColumn = _tableView.tableColumns.lastObject;
		[_tableView removeTableColumn:lastColumn];
	}


	[self setupColumnTitles];


	[self movePlusRowButton];
	[self movePlusColumnButton];
	[self saveColumnWidths];

	[self makeWindowWideEnough];

	//	NSButton *addButton = self.addColumnButton;
	//	NSTableColumn *lastTableColumn = _tableView.tableColumns.lastObject;
	//	NSDictionary *views = NSDictionaryOfVariableBindings(lastTableColumn, addButton);
	//
	//	[self.windowForSheet.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[lastTableColumn]-0-[addButton]"
	//																				 options:NSLayoutFormatAlignAllBaseline
	//																				 metrics:nil
	//																				   views:views]];

	VALIDATE;
}

- (void)setupColumnTitles
{
	// set column titles
	for (NSUInteger columnIndex = 1; columnIndex < _tableView.tableColumns.count; columnIndex++)
	{
		NSTableColumn *column = _tableView.tableColumns[columnIndex];
		NSTableHeaderCell *headerCell = column.headerCell;
		headerCell.stringValue = [AddressHelper columnIndexToString:columnIndex-1];
		headerCell.alignment = NSCenterTextAlignment;
	}
}

- (void)modifyAttributesOfSelectedCells:(void (^)(NSMutableDictionary *a))block
{
	LOGFUNC;


	// we could make it more efficient by allowing to set attributes for columns at once

	NSMutableIndexSet *rowIndices = [NSMutableIndexSet new];
	NSMutableIndexSet *columnIndices = [NSMutableIndexSet new];

	for (Cell *c in _tableView.selectedCells)
	{
//        cc_log_debug(@"setting attribute for cell %@", c.cellName);

		[_data_ modifyAttributesOfCell:c withBlock:block];


		[rowIndices addIndex:c.rowIndex];
		[columnIndices addIndex:c.columnIndex];
	}


	[self.tableView reloadDataForRowIndexes:rowIndices
							  columnIndexes:columnIndices];
}

- (BOOL)validSelection
{
	return _tableView.selectedCells.count > 0;
}
@end


int main(int argc, const char *argv[])
{
	{	// init globals
		cellAddressForbiddenCharacterset = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890$]["] invertedSet];


		NSTimeZone *tz = [NSTimeZone timeZoneForSecondsFromGMT:0];

		NSDateComponents *excelBaseDateComps = [[NSDateComponents alloc] init];
		excelBaseDateComps.month = 1;
		excelBaseDateComps.day = 1;
		excelBaseDateComps.hour = 00;
		excelBaseDateComps.minute = 00;
		excelBaseDateComps.timeZone = tz;
		excelBaseDateComps.year = 1900;


		timezonelessCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
		timezonelessCalendar.timeZone = tz;

		excelBaseDate = [timezonelessCalendar dateFromComponents:excelBaseDateComps];
	}

	return NSApplicationMain(argc, (const char **)argv);
}
