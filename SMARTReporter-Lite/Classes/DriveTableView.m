//
//  DriveTableView.m
//  SMARTReporter
//
//  Created by CoreCode on 02.11.09.
/*	Copyright (c) 2016 CoreCode Limited
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "DriveTableView.h"


@implementation DriveTableView // TODO: aborted test bugs?

- (void)updateTestResult:(NSTimer *)theTimer
{
	NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
	NSTask *task = [[NSTask alloc] init];
	NSPipe *taskPipe = [NSPipe pipe];
	NSFileHandle *fileHandle = [taskPipe fileHandleForReading];

	[task setCurrentDirectoryPath:resourcePath];
	[task setLaunchPath:[resourcePath stringByAppendingPathComponent:@"smartctl"]];
	[task setStandardOutput:taskPipe];
	[task setArguments:[NSArray arrayWithObjects:@"-l", @"selftest", [updateTestResultTimer userInfo], nil]];

	[task launch];
	[task waitUntilExit];

	NSData *data = [fileHandle readDataToEndOfFile];
	NSString *string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];


	[testView setString:string];

	[string release];
	[task release];

	{
		resourcePath = [[NSBundle mainBundle] resourcePath];
		task = [[NSTask alloc] init];
		taskPipe = [NSPipe pipe];
		fileHandle = [taskPipe fileHandleForReading];

		[task setCurrentDirectoryPath:resourcePath];
		[task setLaunchPath:[resourcePath stringByAppendingPathComponent:@"smartctl"]];
		[task setStandardOutput:taskPipe];
		[task setArguments:[NSArray arrayWithObjects:@"-c", [updateTestResultTimer userInfo], nil]];

		[task launch];
		[task waitUntilExit];

		data = [fileHandle readDataToEndOfFile];
		string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];


		if ([string rangeOfString:@"Self-test routine in progress"].location == NSNotFound)
		{
			[updateTestResultTimer invalidate];
			[updateTestResultTimer release];
			updateTestResultTimer = nil;

			if ([string rangeOfString:@"The self-test routine was aborted by"].location != NSNotFound)
				[testProgressField setStringValue:NSLocalizedString(@"The test has been aborted", nil)];
			else
				[testProgressField setStringValue:NSLocalizedString(@"No test in progress", nil)];

			[[contextualMenu itemAtIndex:1] setEnabled:TRUE];
			[[contextualMenu itemAtIndex:2] setEnabled:TRUE];		
		}
		else
		{
			NSString *ps = [[[string substringWithRange:[string lineRangeForRange:[string rangeOfString:@"% of test remaining."]]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]  stringByReplacingOccurrencesOfString:@"% of test remaining." withString:@""];

			int remaining = [ps intValue];
			[testProgressField setStringValue:[NSString stringWithFormat:@"%@ %i %@", NSLocalizedString(@"Progress:", nil), 100 - remaining, @"%"]];
		}

		[string release];
		[task release];
	}
}

#pragma mark *** NSNibAwaking protocol-methods ***

- (void)awakeFromNib
{
	NSString *font = (OS_IS_PRE_SNOW) ? @"Monaco" : @"Menlo";

	[testView setFont:[NSFont fontWithName:font size:10]];
	[attributesView setFont:[NSFont fontWithName:font size:10]];
}

#pragma mark *** NSTableView subclass-methods ***

- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
    NSInteger row = [self rowAtPoint:[self convertPoint:[theEvent locationInWindow] fromView:nil]];

    if( row != -1 )
	{
        [self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];

        return contextualMenu;
    }
	else
	{
        [self deselectAll:nil];
        return nil;
    }
}

#pragma mark *** <NSUserInterfaceValidations> protocol-methods ***

- (BOOL)validateUserInterfaceItem:(id < NSValidatedUserInterfaceItem >)anItem
{
	if ((anItem == [contextualMenu itemAtIndex:1]) || (anItem == [contextualMenu itemAtIndex:2]))
		return (updateTestResultTimer == nil);
	else
		return YES;
}


#pragma mark *** IBAction action-methods ***

- (IBAction)checkAttributesAction:(id)sender
{
	Drive *d = [driveList.drives objectAtIndex:[self selectedRow]];

	NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
	NSTask *task = [[NSTask alloc] init];
	NSPipe *taskPipe = [NSPipe pipe];
	NSFileHandle *fileHandle = [taskPipe fileHandleForReading];

	[task setCurrentDirectoryPath:resourcePath];
	[task setLaunchPath:[resourcePath stringByAppendingPathComponent:@"smartctl"]];
	[task setStandardOutput:taskPipe];
	[task setArguments:[NSArray arrayWithObjects:@"-T", @"permissive", @"-a", [NSString stringWithFormat:@"disk%@", [[d bsdnum] stringValue]], nil]];

	[task launch];
	[task waitUntilExit];

	NSData *data = [fileHandle readDataToEndOfFile];
	NSString *string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];

	[NSApp activateIgnoringOtherApps:YES];
	[attributesWindow makeKeyAndOrderFront:self];
	[attributesView setString:string];

	[string release];
	[task release];
}

- (IBAction)performTestAction:(id)sender
{
	Drive *d = [driveList.drives objectAtIndex:[self selectedRow]];
	
	if ([sender tag] <= 2)
	{
		NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
		NSTask *task = [[NSTask alloc] init];

		[task setCurrentDirectoryPath:resourcePath];
		[task setLaunchPath:[resourcePath stringByAppendingPathComponent:@"smartctl"]];
		[task setArguments:[NSArray arrayWithObjects:@"-T", @"permissive", @"-t", ([sender tag] == 1 ? @"short" : @"long"), [NSString stringWithFormat:@"disk%@", [[d bsdnum] stringValue]], nil]];

		[task launch];
		[task waitUntilExit];
		[task release];
	}

	[NSApp activateIgnoringOtherApps:YES];
	[testWindow makeKeyAndOrderFront:self];

    [longTestField setHidden:([sender tag] != 2)];
    [shortTestField setHidden:([sender tag] != 1)];

	
	[[contextualMenu itemAtIndex:1] setEnabled:FALSE];
	[[contextualMenu itemAtIndex:2] setEnabled:FALSE];
	
	[updateTestResultTimer invalidate];
	[updateTestResultTimer release];
	updateTestResultTimer = [[NSTimer scheduledTimerWithTimeInterval:([sender tag] == 2 ? 360.0 : 10.0) target:self selector:@selector(updateTestResult:) userInfo:[NSString stringWithFormat:@"disk%@", [[d bsdnum] stringValue]] repeats:YES] retain];
	[updateTestResultTimer fire];
}

#pragma mark *** NSWindow delegate-methods ***

- (void)windowWillClose:(NSNotification *)aNotification
{
	if (updateTestResultTimer != nil)
	{
		[NSApp activateIgnoringOtherApps:YES];
		NSRunAlertPanel(@"SMARTReporter",
							NSLocalizedString(@"Closing this window will not abort the selftest - you can't start other tests until this one has finished. You can later inspect the results of the finished selftest.", nil),
							NSLocalizedString(@"OK", nil),
						nil, nil);
	} 
}
@end
