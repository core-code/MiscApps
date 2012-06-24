//
//  AppDelegate.m
//  MountMenu
//
//  Created by CoreCode on 07.03.12.
/*	Copyright (c) 2012 CoreCode
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize menu;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	disks = [[NSMutableArray alloc] init];
	
	statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	
	[statusItem setEnabled:YES];
	
	[statusItem setImage:[NSImage imageNamed:@"icon"]];
	[statusItem setMenu:menu];
}

- (void)menuWillOpen:(NSMenu *)_menu
{
	NSMutableArray *localVolumes = [NSMutableArray array];
	[localVolumes addObject:[[NSFileManager defaultManager] displayNameAtPath:@"/"]];
	for (NSString *s in [[NSWorkspace sharedWorkspace] mountedLocalVolumePaths])
	{
		if ([s hasPrefix:@"/Volumes/"])
		{
			[localVolumes addObject:[s substringFromIndex:9]];
		}
	}
	
//	NSLog([localVolumes description]);
	 
	
	[disks removeAllObjects];
	
	NSTask *task = [[NSTask alloc] init];
	NSPipe *taskPipe = [NSPipe pipe];
	NSFileHandle *fileHandle = [taskPipe fileHandleForReading];
	
	[task setCurrentDirectoryPath:@"/usr/sbin/"];
	[task setLaunchPath:@"/usr/sbin/diskutil"];
	[task setStandardOutput:taskPipe];
	[task setArguments:[NSArray arrayWithObjects:@"list", nil]];
	
	[task launch];
	[task waitUntilExit];
	
	NSData *data = [fileHandle readDataToEndOfFile];
	NSString *string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	NSArray *array = [string componentsSeparatedByString:@"\n"];
	
	for (NSString *line in array)
	{
		if (([line rangeOfString:@"Apple_HFS"].location != NSNotFound) ||
			([line rangeOfString:@"Microsoft Basic Data"].location != NSNotFound))
		{		
			NSArray *lineComponents = [line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			NSArray *info = [lineComponents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
			NSString *name = [[line substringWithRange:NSMakeRange(33, 23)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			NSUInteger i = [localVolumes indexOfObject:name];
			
			NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:name, @"name",
																			[[[info objectAtIndex:[info count]-3] stringByAppendingString:[info objectAtIndex:[info count]-2]] stringByReplacingOccurrencesOfString:@"*" withString:@""], @"size", 
																			[info objectAtIndex:[info count]-1], @"disk", 
																			[NSNumber numberWithInt: (i == NSNotFound) ? 0 : 1], @"mounted", nil];
			
			[disks addObject:dict];
		}
	}
	
	while ([[menu itemAtIndex:0] tag])
		[menu removeItemAtIndex:0];
	
	int i = 1;
	for (NSDictionary *disk in disks)
	{
		BOOL mounted = [[disk objectForKey:@"mounted"] intValue];
		NSString *title = [NSString stringWithFormat:@"%@: %@ %@ %@", (mounted ? @"Unmount" : @"Mount"), [disk objectForKey:@"name"],  [disk objectForKey:@"size"], [disk objectForKey:@"disk"]];
		NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:@selector(itemClicked:) keyEquivalent:@""];
		[item setTag:i++];
		[menu insertItem:item atIndex:0];
	}
}


- (void)itemClicked:(id)sender
{
	NSDictionary *d = [disks objectAtIndex:[sender tag]-1];
//	NSLog([d description]);
	BOOL mounted = [[d objectForKey:@"mounted"] intValue];
	NSTask *task = [[NSTask alloc] init];
//	NSPipe *taskPipe = [NSPipe pipe];
//	NSFileHandle *fileHandle = [taskPipe fileHandleForReading];
	
	[task setCurrentDirectoryPath:@"/usr/sbin/"];
	[task setLaunchPath:@"/usr/sbin/diskutil"];
//	[task setStandardOutput:taskPipe];
   [task setArguments:[NSArray arrayWithObjects:mounted ? @"unmount" : @"mount", [d objectForKey:@"disk"], nil]];
	
	[task launch];
	[task waitUntilExit];
	
//	NSData *data = [fileHandle readDataToEndOfFile];
//	NSString *string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
//	NSLog(string);
}
@end
