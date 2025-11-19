//
//  AppDelegate.m
//  FilenameMatch
//
//  Created by CoreCode on 17.06.14.
/*	Copyright © 2018 CoreCode Limited
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "AppDelegate.h"
#import "DragDestinationView.h"

@interface AppDelegate ()

@property (unsafe_unretained, nonatomic) IBOutlet NSTextView *textView;
@property (weak) IBOutlet NSPathControl *dirToRenamePathControl;
@property (weak) IBOutlet NSPathControl *dirToMatchPathControl;
@property (weak) IBOutlet DragDestinationView *dirToRenameDragView;
@property (weak) IBOutlet DragDestinationView *dirToMatchDragView;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	cc = [CoreLib new];
	_dirToRenameDragView.destinationPathControl = _dirToRenamePathControl;
	_dirToMatchDragView.destinationPathControl = _dirToMatchPathControl;
}

- (BOOL)pathControl:(NSPathControl *)pathControl acceptDrop:(id <NSDraggingInfo>)info;
{
	NSPasteboard *pboard = [info draggingPasteboard];

	if (![[pboard types] containsObject:NSURLPboardType])
		return NO;

	NSURL *file = [NSURL URLFromPasteboard:pboard];
    if (!file.fileIsDirectory)
        return NO;
	pathControl.URL = file;
	[self updatePreview];
	return YES;
}

- (IBAction)choose:(id)sender
{
	[self updatePreview];
}

- (IBAction)cancel:(id)sender
{
	[application terminate:nil];
}

- (void)updatePreview
{
    NSArray <NSURL *> *sourcenamesToMatch = [_dirToMatchPathControl.URL.directoryContents filtered:^BOOL(NSURL *i) { return ![i.path containsString:@"/."]; }].id;
    NSArray <NSURL *> *filenamesToRename = [_dirToRenamePathControl.URL.directoryContents filtered:^BOOL(NSURL *i) { return ![i.path containsString:@"/."]; }].id;
    sourcenamesToMatch = [sourcenamesToMatch sortedArrayUsingComparator:^(NSURL *a, NSURL *b)
    { return [a.lastPathComponent compare:b.lastPathComponent options:NSNumericSearch|NSForcedOrderingSearch]; }].id;
    filenamesToRename = [filenamesToRename sortedArrayUsingComparator:^(NSURL *a, NSURL *b)
    { return [a.lastPathComponent compare:b.lastPathComponent options:NSNumericSearch|NSForcedOrderingSearch]; }].id;


	if (!_dirToMatchPathControl.URL || !_dirToRenamePathControl.URL)
	{
		return;
	}


	if (filenamesToRename.count != sourcenamesToMatch.count)
	{
		_textView.string = makeString(@"Directory has %lu files but source dir lists %lu names.", (unsigned long)filenamesToRename.count, (unsigned long)sourcenamesToMatch.count);
	}
	else
	{
		NSMutableString *tmp = [NSMutableString new];

		int i = 0;
		for (NSURL *file in filenamesToRename)
		{
			[tmp appendString:makeString(@"%@ => %@\n", file.lastPathComponent, sourcenamesToMatch[i++].lastPathComponent)];
		}

		_textView.string = tmp;
	}
}

- (IBAction)continue:(id)sender
{
    NSArray <NSURL *> *sourcenamesToMatch = [_dirToMatchPathControl.URL.directoryContents filtered:^BOOL(NSURL *i) { return ![i.path containsString:@"/."]; }].id;
	NSArray <NSURL *> *filenamesToRename = [_dirToRenamePathControl.URL.directoryContents filtered:^BOOL(NSURL *i) { return ![i.path containsString:@"/."]; }].id;
    sourcenamesToMatch = [sourcenamesToMatch sortedArrayUsingComparator:^(NSURL *a, NSURL *b)
    { return [a.lastPathComponent compare:b.lastPathComponent options:NSNumericSearch|NSForcedOrderingSearch]; }].id;
    filenamesToRename = [filenamesToRename sortedArrayUsingComparator:^(NSURL *a, NSURL *b)
    { return [a.lastPathComponent compare:b.lastPathComponent options:NSNumericSearch|NSForcedOrderingSearch]; }].id;


	if (filenamesToRename.count != sourcenamesToMatch.count || !_dirToMatchPathControl.URL || !_dirToRenamePathControl.URL)
	{
		NSBeep();
		return;
	}


	int i = 0;
    NSError *lastError;
	for (NSURL *file in filenamesToRename)
    {
		NSError *err;
		NSURL *newURL = [[file URLByDeletingLastPathComponent] URLByAppendingPathComponent:sourcenamesToMatch[i++].lastPathComponent];
		[fileManager moveItemAtURL:file toURL:newURL error:&err];
        if (err) lastError = err;
	}
    
    if (lastError)  alert_apptitled(makeString(@"Error moving files: %@", lastError.localizedDescription), @"D'oh", nil, nil);
    else            alert_apptitled(@"Renaming successfull", @"Awesome", nil, nil);
}

@end

int main(int argc, const char * argv[])
{
	return NSApplicationMain(argc, argv);
}
