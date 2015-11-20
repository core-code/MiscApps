//
//  AppDelegate.m
//  FilenameList
//
//  Created by CoreCode on 17.06.14.
/*	Copyright (c) 2014 CoreCode
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "AppDelegate.h"
#import "DragDestinationView.h"

@interface AppDelegate ()

@property (unsafe_unretained, nonatomic) IBOutlet NSTextView *textView;
@property (weak) IBOutlet NSPathControl *dirPathControl;
@property (weak) IBOutlet NSPathControl *txtPathControl;
@property (assign) int literalSearchOption;
@property (weak) IBOutlet DragDestinationView *dirDragView;
@property (weak) IBOutlet DragDestinationView *txtDragView;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	cc = [CoreLib new];
	_dirDragView.destinationPathControl = _dirPathControl;
	_txtDragView.destinationPathControl = _txtPathControl;
}

- (BOOL)pathControl:(NSPathControl *)pathControl acceptDrop:(id <NSDraggingInfo>)info;
{
	NSPasteboard *pboard = [info draggingPasteboard];

	if (![[pboard types] containsObject:NSURLPboardType])
		return NO;

	NSURL *file = [NSURL URLFromPasteboard:pboard];
	if (pathControl == _dirPathControl)
	{
		if (!file.fileIsDirectory)
			return NO;
	}
	else if (pathControl == _txtPathControl)
	{
		if (file.fileIsDirectory)
			return NO;
	}
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
	NSArray <NSString *> *names = _txtPathControl.URL.contents.string.trimmedOfWhitespaceAndNewlines.lines;
	NSArray <NSURL *> *filenames = [_dirPathControl.URL.dirContents filtered:^BOOL(NSURL *input)
	{
		 return ![input.path contains:@"/."];
	}].id;
	filenames = [filenames sortedArrayUsingComparator:^(NSURL *a, NSURL *b)
	{
		return [a.lastPathComponent compare:b.lastPathComponent options:(_literalSearchOption ? NSLiteralSearch : NSNumericSearch)|NSForcedOrderingSearch];
	}].id;

	if (!_txtPathControl.URL || !_dirPathControl.URL)
	{
		return;
	}


	if (filenames.count != names.count)
	{
		_textView.string = makeString(@"Directory has %lu files but file lists %lu names.", (unsigned long)filenames.count, (unsigned long)names.count);
	}
	else
	{
		NSMutableString *tmp = [NSMutableString new];

		int i = 0;
		for (NSURL *file in filenames)
		{
			[tmp appendString:makeString(@"%@ => %@\n", file.lastPathComponent, names[i++])];
		}

		_textView.string = tmp;
	}
}

- (IBAction)continue:(id)sender
{
	NSArray <NSString *> *names = _txtPathControl.URL.contents.string.lines;
	NSArray <NSURL *> *filenames = [_dirPathControl.URL.dirContents filtered:^BOOL(NSURL *input)
	{
		return ![input.path contains:@"/."];
	}].id;


	if (filenames.count != names.count || !_txtPathControl.URL || !_dirPathControl.URL)
	{
		NSBeep();
		return;
	}

	filenames = [filenames sortedArrayUsingComparator:^(NSURL *a, NSURL *b)
	{
		 return [a.lastPathComponent compare:b.lastPathComponent options:(_literalSearchOption ? NSLiteralSearch : NSNumericSearch)|NSForcedOrderingSearch];
	}].id;

	int i = 0;
	for (NSURL *file in filenames)
    {
		NSError *err;
		NSURL *newURL = [[file URLByDeletingLastPathComponent] URLByAppendingPathComponent:names[i++]];
		[fileManager moveItemAtURL:file toURL:newURL error:&err];
	}
}

@end

int main(int argc, const char * argv[])
{
	return NSApplicationMain(argc, argv);
}
