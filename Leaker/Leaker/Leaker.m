//
//  Leaker.m
//  Leaker
//
//  Created by CoreCode on 07.03.07.
/*	Copyright © 2017 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import "Leaker.h"
#import "ProcessUtilities.h"

@implementation NSString (SortCategory)

- (NSComparisonResult)myCompare:(NSString *)string {
    if (([self intValue] == 0) && (![self isEqualToString:@"0"]))	// we are string
	{
		if (([string intValue] == 0) && (![string isEqualToString:@"0"]))	// other is string too
			return [self compare:string];
		else																// other is number
			return NSOrderedDescending;
	}
	else															// we are number
	{
		if (([string intValue] == 0) && (![string isEqualToString:@"0"]))	// other is string
			return NSOrderedAscending;
		else																// other is number too
			return [[NSNumber numberWithInt:[self intValue]] compare:[NSNumber numberWithInt:[string intValue]]];
	}
}
@end

@implementation Leaker

- (void)awakeFromNib
{
	if (![[NSFileManager defaultManager] fileExistsAtPath:@"/usr/bin/leaks"])
	{	
		[[NSAlert alertWithMessageText:@"You must install the Developer Tools to use Leaker!" defaultButton:@"Quit" alternateButton:nil otherButton:nil informativeTextWithFormat:@""] runModal];
		[[NSApplication sharedApplication] terminate:self];
	}
	
	leaksNumber = 0;
	leakedBytes = 0;
	
	array = [[NSArray arrayWithObjects:	[NSMutableArray arrayWithCapacity:30],
										[NSMutableArray arrayWithCapacity:30],
										[NSMutableArray arrayWithCapacity:30],
										[NSMutableArray arrayWithCapacity:30], nil] retain];
	
	[progress startAnimation:self];

	[self getPIDs];
	[self getLeaks];
}

- (void)getLeaks
{
	static unsigned int i = 0;
	
	if (task != nil)
        [task release];

	if (output != nil)
		[output release];
	
	if (i >= [[array objectAtIndex:0] count])
	{
		int v;
		
		leaks = [[NSMutableArray alloc] initWithCapacity:30];
		v = [[array objectAtIndex:0] count];
		
		for (v--; v >= 0; v--)
		{
			[leaks addObject:[NSDictionary dictionaryWithObjectsAndKeys:	[[array objectAtIndex:0] objectAtIndex:v], @"pid",
																			[[array objectAtIndex:1] objectAtIndex:v], @"name",
																			[[array objectAtIndex:2] objectAtIndex:v], @"leaks",
																			[[array objectAtIndex:3] objectAtIndex:v], @"bytes",
																			nil]];
		}

		[array release];
		
		[leaksText setStringValue:[NSString stringWithFormat:@"%i", leaksNumber]];
		[bytesText setStringValue:[NSString stringWithFormat:@"%i", leakedBytes]];
		
		[progress stopAnimation:self];
		[panel close];
		[window makeKeyAndOrderFront:self];
		
		[table reloadData];
		return;
	}
	
	task = [[AMShellWrapper alloc]	initWithController:self
									inputPipe:nil
									outputPipe:nil
									errorPipe:nil
									workingDirectory:@"/"
									environment:nil
									arguments:[NSArray arrayWithObjects:@"/usr/bin/leaks", @"-nocontext", @"-nostacks", [[[array objectAtIndex:0] objectAtIndex:i] stringValue], nil]];

	output = [[NSMutableString alloc] init];

	i++;
	
	NS_DURING
		if (task)
		{
			[task setOutputStringEncoding:NSASCIIStringEncoding];
			
			[nameText setStringValue:[[array objectAtIndex:1] objectAtIndex:i-1]];
			
			[task startProcess];
		}
		else
			NSLog(@"Error: was not able to execute \"leaks\"");
	NS_HANDLER
		NSLog(@"Error %@: %@", [localException name], [localException reason]);
	NS_ENDHANDLER
}

- (void)getPIDs
{
	size_t i;
	size_t proc_count;
	kinfo_proc *processList = NULL;
	int proclist_result = GetBSDProcessList(&processList, &proc_count);
	
    if (0 != proclist_result)
		NSLog(@"Error: get_bsd_process_list failed with result: %i", proclist_result);
	
	
	for (i = 0; i < proc_count; i++)
	{
		if (processList[i].kp_proc.p_pid > 0)
		{
			if (![[NSString stringWithCString:processList[i].kp_proc.p_comm] isEqualToString:@"Leaker"])
			{
				[[array objectAtIndex:0] addObject:[NSNumber numberWithInt:processList[i].kp_proc.p_pid]];
				[[array objectAtIndex:1] addObject:[NSString stringWithCString:processList[i].kp_proc.p_comm]];
			}
		}
	}
}	

#pragma mark *** NSTableDataSource protocol-methods ***

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	if (leaks)
		return [leaks count];
	else
		return 0;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	return [(NSDictionary *)[leaks objectAtIndex:rowIndex] objectForKey:[aTableColumn identifier]];
}

- (void)tableView:(NSTableView *)aTableView sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
	NSArray *newDescriptors = [aTableView sortDescriptors];
	[leaks sortUsingDescriptors:newDescriptors];
	[table reloadData];
}

#pragma mark *** AMShellWrapperController protocol-methods ***

- (void)appendOutput:(NSString *)additionalOutput
{
	if (additionalOutput)
		[output appendString:additionalOutput];
}

- (void)appendError:(NSString *)additionalOutput
{
	if (additionalOutput)
		[output appendString:additionalOutput];
}

- (void)processStarted:(id)sender { }

- (void)processFinished:(id)sender withTerminationStatus:(int)resultCode
{
	NSArray *components = [output componentsSeparatedByString:@"\n"];

	if ([components count] > 1 && [[[components objectAtIndex:1] componentsSeparatedByString:@" "] count] > 4)
	{
		components = [[components objectAtIndex:1] componentsSeparatedByString:@" "];
		
		
		[[array objectAtIndex:2] addObject:[components objectAtIndex:2]];
		leaksNumber += [[components objectAtIndex:2] intValue];
		[[array objectAtIndex:3] addObject:[components objectAtIndex:5]];
		leakedBytes += [[components objectAtIndex:5] intValue];
	}
	else
	{		
		if ([output rangeOfString:@"privileges"].location != NSNotFound)
		{
			[[array objectAtIndex:2] addObject:@"privilege error"];
			[[array objectAtIndex:3] addObject:@"privilege error"];		
		}
		else if ([output rangeOfString:@"unknown"].location != NSNotFound)
		{
			[[array objectAtIndex:2] addObject:@"unknown error"];
			[[array objectAtIndex:3] addObject:@"unknown error"];						
		}
		else
		{
			[[array objectAtIndex:2] addObject:@"Big Problem"];
			[[array objectAtIndex:3] addObject:output];	
			NSLog(@"Error: \"leaks\" sent us this unrecogniseable output: %@ ", output);
		}

	}
	[self getLeaks];
}
@end

int main(int argc, const char *argv[]) { return NSApplicationMain(argc, argv); }