//
//  iRipCD.m
//  iRipCD
//
//  Created by CoreCode on Son Aug 18 2002.
/*	Copyright (c) 2002 - 2003, 2007 CoreCode
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
/*
 *	TODO:
 *		tagging: freedb/musicbrainz lookup or from existing files
 */

#import "iRipCD.h"

@implementation iRipCD

+ (void)initialize
{
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];

	[defaultValues setObject:@"" forKey:@"lamePath"];
	[defaultValues setObject:@"--preset standard (VBR 180-220 kbps)" forKey:@"bitrate"];

	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}

- (id)init
{
	self = [super init];

	task = nil;
	timer = nil;
	destpath = @"";
	taskOutput = [[NSMutableString alloc] init];
	fileList = [[NSMutableArray alloc] initWithCapacity:15];

	[[NSApp delegate] setMaster:self];

	return self;
}

- (void)awakeFromNib
{
	// [windowOutlet makeKeyAndOrderFront:nil];
	[filesTextFieldOutlet setMaster:self];
	[optionsPopupOutlet selectItemWithTitle:[[NSUserDefaults standardUserDefaults] objectForKey:@"bitrate"]];
}

- (void)cleanup
{
	[progressOutlet stopAnimation:self];
	[encodeButtonOutlet setTitle:@"Convert"];
	[filesTextFieldOutlet setStringValue:@""];
	
	[filesTextFieldOutlet setEnabled:YES];
	[optionsPopupOutlet setEnabled:YES];

	[[NSUserDefaults standardUserDefaults] setObject:[optionsPopupOutlet titleOfSelectedItem] forKey:@"bitrate"];
}

- (NSString *)makeUniqueFilename:(NSString *)name
{
	int i = 0;
	NSString *unique;
	if ([[NSFileManager defaultManager] fileExistsAtPath:name])
	{
		do
		{
			i++;
			unique = [[[name stringByDeletingPathExtension] stringByAppendingFormat:@" %i",i] stringByAppendingPathExtension:@"mp3"];
		} while ([[NSFileManager defaultManager] fileExistsAtPath:unique]);
		return unique;
	}
	else
		return name;
}

- (void)filesWereDragged:(NSTimer *)aTimer
{
	NSMutableArray *array = [timer userInfo];
	[self setFilesToArray:array];
	[array removeAllObjects];
	[timer invalidate];
	timer = NULL;
}

- (void)setFilesToArray:(NSArray *)array
{
	int i, count = [array count];

	[fileList removeAllObjects];
	
	for (i = 0; i < count; i++)
	{
		BOOL isDir;
		
		if ([[NSFileManager defaultManager] fileExistsAtPath:[array objectAtIndex:i] isDirectory:&isDir])
		{
			if (isDir == TRUE)
			{
				NSString *file;
				NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:[array objectAtIndex:i]];
				
				while ((file = [dirEnum nextObject]))
				{	
					NSString *lowercaseext = [[file pathExtension] lowercaseString];
					
					if (([lowercaseext isEqualToString: @"wav"]) || ([lowercaseext isEqualToString: @"aiff"]))
					{
						[fileList addObject:[[array objectAtIndex:i] stringByAppendingPathComponent:file]];
					}
				}			
			}
			else
			{
				[fileList addObject:[array objectAtIndex:i]];
			}
		}
	}
	
	if ([fileList count] == 0)
		[filesTextFieldOutlet setStringValue:@""];
	else if ([fileList count] == 1)
		[filesTextFieldOutlet setStringValue:[array objectAtIndex:0]];
	else
		[filesTextFieldOutlet setStringValue:[NSString stringWithFormat:@"%d files", [fileList count]]];
	
	if ([fileList count] > 0)
	{
		[encodeButtonOutlet setEnabled:YES];
		[selectButtonOutlet setEnabled:TRUE];
		[sourceMatrixOutlet selectCellAtRow:1 column:0];
	}
}

- (void)setLamePath:(NSString *)path
{
	[path retain];
	[lamePath release];
	lamePath = path;
}

#pragma mark *** IBAction action-methods ***

- (IBAction)encodeAction:(id)sender
{
	if (task != nil)	// stop
	{
		[task stopProcess];
		task = nil;
		[self cleanup];
	}
	else				// convert
	{
		NSArray *list = [[NSArray alloc] initWithObjects:@"hifi", @"cd", @"studio", @"medium", @"standard", @"extreme", @"insane", nil];
		NSString *mp3path, *path = [[NSUserDefaults standardUserDefaults] objectForKey:@"lamePath"];

		if (([[sourceMatrixOutlet selectedCell] tag] == 0) && ([fileList count] == 0))
		{			
			NSArray * array = [[NSWorkspace sharedWorkspace] mountedRemovableMedia];
			unsigned int i, count = [array count];
			BOOL foundCD = FALSE;
			
			if (count == 0)
			{
				[self cleanup];
				NSRunAlertPanel(@"Error", @"No CD seems to be inserted", @"Stop", nil, nil);
				return;
			}
			
			for (i = 0; i < count; i++)
			{
				NSArray *contents = [[NSFileManager defaultManager] directoryContentsAtPath:[array objectAtIndex:i]];
				NSEnumerator *enumerator = [contents objectEnumerator];
				NSString *file;
					
				while ((file = [enumerator nextObject]))
				{
					if ([[file pathExtension] isEqualToString: @"aiff"])
					{
						foundCD = TRUE;
						[fileList addObject:[[array objectAtIndex:i] stringByAppendingPathComponent:file]];
					}
				}
				
				if (foundCD)
					break;
			}
			
			if (!foundCD)
			{
				[self cleanup];
				NSRunAlertPanel(@"Error", @"No CD seems to be inserted", @"Stop", nil, nil);
				return;
			}				
		}
		
		if ([path isEqualToString:@""])
			path = [[NSBundle mainBundle] pathForResource:@"lame" ofType:@""];
	
		if ([destpath isEqualToString:@""])
		{
			int result;
			NSOpenPanel *oPanel = [NSOpenPanel openPanel];
			[oPanel setAllowsMultipleSelection:NO];
			[oPanel setCanChooseDirectories:YES];
			[oPanel setCanChooseFiles:NO];
			result = [oPanel runModalForDirectory:NSHomeDirectory() file:nil types:nil];
			if (result == NSOKButton)
				destpath = [[oPanel filename] retain];
			else
				return;
		}
		
		mp3path = [self makeUniqueFilename:[destpath stringByAppendingFormat:@"/%@", [[[[fileList objectAtIndex:0] stringByDeletingPathExtension] stringByAppendingPathExtension:@"mp3"] lastPathComponent]]];

		task = [[TaskWrapper alloc] initWithController:self arguments:[NSArray arrayWithObjects:path, @"--preset", [list objectAtIndex:[optionsPopupOutlet indexOfSelectedItem]], [fileList objectAtIndex:0], mp3path, nil]];
	  	
		[progressOutlet startAnimation:self];
		
		[task startProcess];

		[encodeButtonOutlet setTitle:@"Stop"];

		[filesTextFieldOutlet setEnabled:NO];
		[optionsPopupOutlet setEnabled:NO];

		[list release];
	}
}

- (IBAction)setSourceAction:(id)sender
{
	if ([[sourceMatrixOutlet selectedCell] tag] == 1) // FILES
	{
		[selectButtonOutlet setEnabled:TRUE];
		[encodeButtonOutlet setEnabled:FALSE];
	}
	else // CD
	{
		[selectButtonOutlet setEnabled:FALSE];
		[encodeButtonOutlet setEnabled:YES];

		[self setFilesToArray:[NSArray array]];
	}
}

- (IBAction)showPreferencePanelAction:(id)sender
{
	if (!preferenceController)
		preferenceController = [[PreferenceController alloc] init];
	[preferenceController showWindow:self];
}

- (IBAction)selectFilesAction:(id)sender
{
	int result;
	NSOpenPanel *oPanel = [NSOpenPanel openPanel];

	[oPanel setAllowsMultipleSelection:YES];
	[oPanel setCanChooseDirectories:YES];
	[oPanel setCanChooseFiles:YES];
	result = [oPanel runModalForDirectory:NSHomeDirectory() file:nil types:nil];
	if (result == NSOKButton)
	{
		NSArray *filesToOpen = [oPanel filenames];

		[self setFilesToArray:filesToOpen];
	}
}

#pragma mark *** TaskWrapperController protocol-methods ***

- (void)processStarted
{
}

- (void)processFinished
{
	[task autorelease];
	task = nil;
	
	[fileList removeObjectAtIndex:0];
	
	if ([fileList count] > 0)
	{
		[filesTextFieldOutlet setStringValue:[NSString stringWithFormat:@"%d files remaining to encode...", [fileList count]]];
		[self encodeAction:nil];
	}
	else
		[self cleanup];
	
	[taskOutput setString:@""];
}

- (void)appendOutput:(NSString *)output
{
	[taskOutput appendString:output];
	
	//NSLog(output);
}

#pragma mark *** NSApplication delegate-methods ***

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return YES;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	if (task != nil)
		if (NSRunAlertPanel(@"Quit", @"Encoding is in progress. Do you really want to quit?", @"Yes", @"Cancel", nil) == NSAlertAlternateReturn)
			return NSTerminateCancel;
			
	return NSTerminateNow;
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
	static NSMutableArray *list = NULL;
	
	if (!timer || (timer && ![timer isValid]))
	{
		list = [NSMutableArray array];
		timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(filesWereDragged:) userInfo:list repeats:NO];
	}
	[list addObject:filename];
	
	return YES;
}
@end

int main(int argc, const char *argv[])
{
	return NSApplicationMain(argc, argv);
}