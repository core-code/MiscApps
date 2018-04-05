//
//  Document.h
//  TableEdit-Lite
//
//  Created by CoreCode on 28/06/13.
/*    Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/


#import "GridTableView.h"

@class DraggableCPTGraphHostingView;


@interface Document : NSDocument <NSTextFieldDelegate, NSTableViewDataSource, NSTableViewDelegate
#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_12
, CALayerDelegate>
#else
>
#endif

@property (nonatomic, weak) IBOutlet GridTableView *tableView;

+ (void)showImportPanel:(id)sender forWindow:(NSWindow *)window;
- (IBAction)addRow:(id)sender;
- (IBAction)addColumn:(id)sender;
- (void)fitTableColumsToData;
- (void)sortColumn:(int)column sortAscending:(BOOL)ascending onlySelected:(BOOL)sortOnlySelectedRows wholeTable:(BOOL)wholeTable;
- (void)movePlusColumnButton;
- (void)movePlusRowButton;
- (void)flagsChanged:(NSEvent *)event;

@property (nonatomic, readonly) NSInteger editingRow;
@property (nonatomic, readonly) NSInteger editingColumn;




@end
