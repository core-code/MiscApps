//  MovieDocument.m
//  MovieDB
//
//  Created by CoreCode on 03.11.05.
/*	Copyright © 2017 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import "MovieDocument.h"
#import "InfoHelper.h"
#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

@implementation MovieDocument

- (void)awakeFromNib
{
	[progressIndicator setUsesThreadedAnimation:YES];

	// register for drag and drop
	[movieTableView registerForDraggedTypes:@[NSFilenamesPboardType]];
	[sourcesTableView registerForDraggedTypes:@[NSFilenamesPboardType]];
	sourcesTableView.target = self;
	sourcesTableView.doubleAction = @selector(sourcesTableDoubleClick:);

	NSSortDescriptor * sd = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
	movieTableView.sortDescriptors = @[sd];

	[super awakeFromNib];
}

- (NSString *)windowNibName
{
	return @"MovieDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController
{
	[super windowControllerDidLoadNib:windowController];

	// setup language list popup
	NSString *languages = [NSString stringWithContentsOfFile:[[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"language_list.txt"] encoding:NSUTF8StringEncoding error:NULL];
	[languageListPopUpButton addItemsWithTitles:[languages componentsSeparatedByString:@"\n"]];
	[languageListPopUpButton.menu insertItem:[NSMenuItem separatorItem] atIndex:5];

	// disable word wrap in imdb cast
	NSTextContainer *textContainer = castTextView.textContainer;
	NSSize theSize = textContainer.containerSize;
	theSize.width = 1.0e7;
	textContainer.containerSize = theSize;
	[textContainer setWidthTracksTextView:NO];
}

- (void)refresh:(NSArray *)movies
{
	[self doProgressSheet:YES];


	dispatch_apply(movies.count, dispatch_get_global_queue(0, 0), ^(size_t i) {
		//NSLog([movie valueForKey:@"imdb_title"]);
		Movie *movie = movies[i];

		if ([movie valueForKey:@"imdb_id"])
			[InfoHelper retrieveInfo:[movie valueForKey:@"imdb_id"] forMovie:movie];
		else
			asl_NSLog(ASL_LEVEL_ERR, @"Warning: couldn't refresh info for the following movie: %@", [movie valueForKey:@"imdb_title"]);

	});

	[self tableViewSelectionDidChange:nil];
	[self doProgressSheet:NO];

	[movieArrayController rearrangeObjects];
}

- (IBAction)lookupAction:(id)sender
{
	[ourIMDBSheetController lookupAction:sender];
}

- (IBAction)refreshAction:(id)sender
{
	[self refresh:@[movieArrayController.selection]];
}

- (IBAction)refreshAllAction:(id)sender
{
	[self refresh:[NSArray arrayWithArray:movieArrayController.arrangedObjects]];
}

- (IBAction)addMovieAction:(id)sender
{
	id newObject = [movieArrayController newObject];

	[movieArrayController insertObject:newObject atArrangedObjectIndex:0];
	[movieArrayController setSelectionIndex:0];



	[movieArrayController rearrangeObjects];
	[movieTableView scrollRowToVisible:movieTableView.selectedRow];

	[titleTextField selectText:self];
}

- (IBAction)addFileAction:(id)sender
{
	NSOpenPanel *panel = [NSOpenPanel openPanel];

	[panel setCanChooseDirectories:YES];
	//NSArray *array = [NSArray arrayWithObjects:@"avi", @"mpg", @"mpeg", @"ogg", @"ogm", @"wmv", @"mov", @"mp4", @"asf", @"rm", @"rmvb", @"mkv", @"dat", @"vob", @"ty", @"qt", @"fli", @"nuv", nil];

	[panel beginSheetModalForWindow:self.windowForSheet completionHandler:^(NSInteger result)
    {
        if (result == NSFileHandlingPanelOKButton)
        {
        	[InfoHelper addPathToObject:movieArrayController.selection
                               withPath:panel.URL.path
                     andFilesController:movieFilesArrayController];
        }
    }];
}


- (BOOL)textView:(NSTextView *)textView clickedOnLink:(id)link atIndex:(unsigned)charIndex
{
	return [[NSWorkspace sharedWorkspace] openURL:link];
}

- (IBAction)pluginAction:(NSString *)pluginName
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:pluginName withExtension:@"js" subdirectory:@"PlugIns"];

    JSContext *context = [[JSContext alloc] init];

    context[@"consoleLog"] = ^(NSString *message) { asl_NSLog(ASL_LEVEL_INFO, @"Javascript log: %@", message); };
    context[@"getAllMovies"] = ^() { return [movieArrayController.arrangedObjects valueForKeyPath:@"dictionaryRepresentation"]; };
    context[@"exportFile"] = ^(NSString *contents) {
        NSSavePanel *panel = NSSavePanel.savePanel;
        [panel beginSheetModalForWindow:self.windowForSheet completionHandler:^(NSInteger result)
         {
             if (result == NSFileHandlingPanelOKButton)
                 panel.URL.contents = contents.data;
         }];
    };
    [context evaluateScript:url.contents.string];

    JSValue *executeFunction = context[@"execute"];

    [executeFunction callWithArguments:@[movieArrayController, movieFilesArrayController]];
}

- (IBAction)flipAction:(NSButton *)sender
{
	NSRect r1 = self.windowForSheet.frame;

	if ([sender state]) // blend detail in
	{
		((NSButton *)sender).frame = NSMakeRect(17, 425, 13, 13);
		seperator.frame = NSMakeRect(38, 429, 719, 5);
		infoTextField.frame = NSMakeRect(18, 440, 745, 17);
		mainMovieList.frame = NSMakeRect(20, 468, r1.size.width - 40, r1.size.height - 566);

		[imdbBox setHidden:NO];
		[dataBox setHidden:NO];
	}
	else
	{
		((NSButton *)sender).frame = NSMakeRect(17, 13, 13, 13);
		seperator.frame = NSMakeRect(38, 17, 719, 5);
		infoTextField.frame = NSMakeRect(18, 28, 745, 17);
		mainMovieList.frame = NSMakeRect(20, 50, r1.size.width - 40, r1.size.height - 148);

		[imdbBox setHidden:YES];
		[dataBox setHidden:YES];
	}
}

- (NSDragOperation)tableView:(NSTableView *)tv
				validateDrop:(id <NSDraggingInfo>)info
				 proposedRow:(int)row
	   proposedDropOperation:(NSTableViewDropOperation)op
{
	if (tv == sourcesTableView && !movieArrayController.canRemove)
		return NSDragOperationNone;

	[tv setDropRow:row dropOperation:NSTableViewDropAbove]; 	// we want to put the object at, not over, the current row (contrast NSTableViewDropOn)
	return NSDragOperationCopy;
}

- (BOOL)tableView:(NSTableView *)tv
	   acceptDrop:(id <NSDraggingInfo>)info
			  row:(int)row
	dropOperation:(NSTableViewDropOperation)op
{
	if (row < 0)
	{
		row = 0;
	}

	// Can we get an URL?  If so, add a new row, configure it, then return.
	if ([[info draggingPasteboard].types indexOfObject:NSFilenamesPboardType] != NSNotFound)
	{
		NSArray *files = [[info draggingPasteboard] propertyListForType:NSFilenamesPboardType];
		for (id loopItem in files)
		{
			if (tv == sourcesTableView)
				[InfoHelper addPathToObject:movieArrayController.selection withPath:loopItem andFilesController:movieFilesArrayController];
			else
			{
				id newObject = [movieArrayController newObject];

				[movieArrayController insertObject:newObject atArrangedObjectIndex:row];

				if (![InfoHelper addPathToObject:newObject withPath:loopItem andFilesController:movieFilesArrayController])
				{
					[movieArrayController setSelectionIndex:row]; // set selected rows to those that were just copied

					[movieArrayController rearrangeObjects];
				}
				else
					[movieArrayController removeObject:newObject];

							// "new" -- returned with retain count of 1

			}
		}
		return YES;
	}

	return NO;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	if ([movieArrayController.selection valueForKey:@"imdb_title"] == nil)
	{
		[imdbBox setHidden:YES];
		[fetchButton setHidden:NO];
	}
	else
	{
		if (aNotification == nil)
		{
			[[imdbBox animator] setHidden:NO];
			[[fetchButton animator] setHidden:YES];

			[imdbTitleTextView.textStorage setAttributedString:[[NSValueTransformer valueTransformerForName:@"TitleLinkValueTransformer"] transformedValue:movieArrayController.selection]];
		}
		else
		{
			[imdbBox setHidden:NO];
			[fetchButton setHidden:YES];
		}
	}
	[movieTableView scrollRowToVisible:movieTableView.selectedRow];
}

- (void)sourcesTableDoubleClick:(id)sender
{
	[[NSWorkspace sharedWorkspace] openFile:[movieFilesArrayController.selection valueForKey:@"path"]];
}

- (void)doProgressSheet:(BOOL)start
{
	if (start)
	{
		[NSApp beginSheet:progressSheetWindow modalForWindow:self.windowForSheet modalDelegate:nil didEndSelector:nil contextInfo:nil];
		[progressIndicator startAnimation:self];
	}
	else
	{

		[progressIndicator stopAnimation:self];
		[NSApp endSheet:progressSheetWindow];
		[progressSheetWindow orderOut:self];
	}
}

- (void)printShowingPrintPanel:(BOOL)showPanels 
{
    // Obtain a custom view that will be printed
    NSView *printView = nil;

    NSURL *url = [[NSBundle mainBundle] URLForResource:@"ExportHTMLPlugin" withExtension:@"js"];

    JSContext *context = [[JSContext alloc] init];
    context[@"consoleLog"] = ^(NSString *message) { asl_NSLog(ASL_LEVEL_INFO, @"Javascript log: %@", message); };
    context[@"getAllMovies"] = ^()
    {
        return [movieArrayController.arrangedObjects valueForKeyPath:@"dictionaryRepresentation"];
    };
    [context evaluateScript:url.contents.string];


    JSValue *convertFunction = context[@"convert"];
    JSValue *htmlValue = [convertFunction callWithArguments:@[]];
    NSString *html = [htmlValue toString];



	self.printInfo.scalingFactor = 0.4;


	if (html)
	{
		NSSize ps = self.printInfo.paperSize;
		float lm = self.printInfo.leftMargin;
		float rm = self.printInfo.leftMargin;
		float tm = self.printInfo.topMargin;
		float bm = self.printInfo.bottomMargin;
	
		WebView *v = [[WebView alloc] initWithFrame:NSMakeRect(0, 0, (ps.width - lm - rm) / self.printInfo.scalingFactor, 500)];
		
		[v.mainFrame loadHTMLString:html baseURL:nil];
		
		while (v.loading)
		{
			@autoreleasepool {
			
				[v setNeedsDisplay:NO];
				[NSApp nextEventMatchingMask:NSAnyEventMask untilDate:[NSDate dateWithTimeIntervalSinceNow:1.0] inMode:NSDefaultRunLoopMode dequeue:YES];
			}
		}
		NSRect frame = v.frame;
		frame.size.height = v.mainFrame.frameView.documentView.frame.size.height + tm + bm;
		v.frame = frame;
		[v setNeedsDisplay:YES];
	
		
		printView = v;
	}
	
	if (!printView)
		return;
	
    // Construct the print operation and setup Print panel
    NSPrintOperation *op = [NSPrintOperation
							printOperationWithView:printView
							printInfo:self.printInfo];
    [op setShowPanels:showPanels];
    if (showPanels) {
        // Add accessory view, if needed
    }
	
    // Run operation, which shows the Print panel if showPanels was YES
    [self runModalPrintOperation:op
						delegate:nil
				  didRunSelector:NULL
					 contextInfo:NULL];
}
@end
