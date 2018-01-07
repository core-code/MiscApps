//  MovieDocument.h
//  MovieDB
//
//  Created by CoreCode on 03.11.05.
/*	Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import "Movie.h"
#import "IMDBSheetController.h"

@interface MovieDocument : NSPersistentDocument
{
	IBOutlet NSArrayController		*movieArrayController;
	IBOutlet NSArrayController		*movieFilesArrayController;
	
	
	IBOutlet IMDBSheetController	*ourIMDBSheetController;

	IBOutlet NSTextField			*titleTextField;
	IBOutlet NSTextView				*castTextView, *imdbTitleTextView;
	IBOutlet NSWindow				*progressSheetWindow;
	IBOutlet NSPopUpButton			*languageListPopUpButton;

	IBOutlet NSProgressIndicator	*progressIndicator;

	IBOutlet NSBox					*seperator;
	IBOutlet NSTextField			*infoTextField;
	IBOutlet NSButton				*fetchButton;
	IBOutlet NSBox					*imdbBox;
	IBOutlet NSBox					*dataBox;
	IBOutlet NSTableView			*movieTableView, *sourcesTableView;
	IBOutlet NSScrollView			*mainMovieList;
}

- (IBAction)addMovieAction:(id)sender;
- (IBAction)addFileAction:(id)sender;
- (IBAction)pluginAction:(id)plugin;
- (IBAction)lookupAction:(id)sender;
- (IBAction)refreshAction:(id)sender;
- (IBAction)refreshAllAction:(id)sender;
- (IBAction)flipAction:(id)sender;
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification;
- (NSDragOperation)tableView:(NSTableView *)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op;
- (BOOL)tableView:(NSTableView *)tv acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)op;
- (void)doProgressSheet:(BOOL)start;
@end
