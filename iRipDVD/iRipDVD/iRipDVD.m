//
//  iRipDVD.m
//  iRipDVD
//
//  Created by CoreCode on Sat Mar 01 2003.
/*	Copyright (c) 2003 CoreCode
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
/*
 *	TODO 1.0:
 *		debug error messages
 *		more accurate bitrate calculation
 *		long delay, spinning wheel
 *		bug not enough space
 *		test language selection
 *		test vlelim, vcelim, lumi_mask, dark_mask
 *
 *	TODO 1.1/2.0:
 *		optimize (mem+cpu)
 *		customizable movie size
 *		error log file
 *		batch encoding
 *		options: manual crop / track / chapter / ...
 *		SMP-support
 *		subtitles
 *		HIG-ify
 *		split up in OO class design
 */

#import "iRipDVD.h"

@implementation iRipDVD

+ (void)initialize
{
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];

	[defaultValues setObject:@"NO" forKey:@"autostart"];
	[defaultValues setObject:@"notify me" forKey:@"finished"];
	[defaultValues setObject:@"en" forKey:@"language"];
	[defaultValues setObject:@"112" forKey:@"audio"];
	[defaultValues setObject:@"560" forKey:@"width"];
	[defaultValues setObject:@"700MB" forKey:@"size"];
	[defaultValues setObject:@"0" forKey:@"animated"];
	[defaultValues setObject:@"1" forKey:@"fast"];
	[defaultValues setObject:@"1" forKey:@"preview"];
	[defaultValues setObject:@"0" forKey:@"vob"];
	[defaultValues setObject:@"YES" forKey:@"start"];
	[defaultValues setObject:NSHomeDirectory() forKey:@"open"];
	[defaultValues setObject:NSHomeDirectory() forKey:@"save"];

	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}

- (id)init
{
	self = [super init];

	task = nil;
	state = 0;
	[self removeTempFiles];
	taskOutput = [[NSMutableString alloc] init];

	return self;
}

- (void)awakeFromNib
{
	[language selectItemWithTitle:[[NSUserDefaults standardUserDefaults] objectForKey:@"language"]];
	[audio selectItemWithTitle:[[NSUserDefaults standardUserDefaults] objectForKey:@"audio"]];
	[width selectItemWithTitle:[[NSUserDefaults standardUserDefaults] objectForKey:@"width"]];
	[size selectItemWithTitle:[[NSUserDefaults standardUserDefaults] objectForKey:@"size"]];
	[animated setState:[[[NSUserDefaults standardUserDefaults] objectForKey:@"animated"] intValue]];
	[quality setIntValue:[[[NSUserDefaults standardUserDefaults] objectForKey:@"fast"] intValue]];
	[preview setState:[[[NSUserDefaults standardUserDefaults] objectForKey:@"preview"] intValue]];
	[dvd setState:![[[NSUserDefaults standardUserDefaults] objectForKey:@"vob"] intValue]];
	[vob setState:[[[NSUserDefaults standardUserDefaults] objectForKey:@"vob"] intValue]];
}

- (void)cleanup
{
	[status setStringValue:@""];
	[progress stopAnimation:self];
	[progress setIndeterminate:TRUE];
	[convert setTitle:@"Convert"];
	[menuitem setTitle:@"Convert"];

	[devicePath release];
	devicePath = nil;
	[languageNumber release];
	languageNumber = nil;
	[crop release];
	crop = nil;
	[bitrate release];
	bitrate = nil;
	[filename release];
	filename = nil;
	[vobfile release];
	vobfile = nil;
	state = 0;
	track = 0;
	length = 0;
	[taskOutput setString:@""];

	[self removeTempFiles];

	[animated setEnabled:TRUE];
	[audio setEnabled:TRUE];
	[language setEnabled:TRUE];
	[size setEnabled:TRUE];
	[width setEnabled:TRUE];
	[preview setEnabled:TRUE];
	[quality setEnabled:TRUE];
	[vob setEnabled:TRUE];
	[dvd setEnabled:TRUE];

	[[NSUserDefaults standardUserDefaults] setObject:[language titleOfSelectedItem] forKey:@"language"];
	[[NSUserDefaults standardUserDefaults] setObject:[audio titleOfSelectedItem] forKey:@"audio"];
	[[NSUserDefaults standardUserDefaults] setObject:[width titleOfSelectedItem] forKey:@"width"];
	[[NSUserDefaults standardUserDefaults] setObject:[size titleOfSelectedItem] forKey:@"size"];
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld", (long)[animated state]] forKey:@"animated"];
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld", (long)[preview state]] forKey:@"preview"];
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", [quality intValue]] forKey:@"fast"];
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld", (long)[vob state]] forKey:@"vob"];
}

- (void)removeTempFiles
{
	remove([[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/frameno.avi"] fileSystemRepresentation]);
	remove([[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@ "/divx2pass.log"] fileSystemRepresentation]);
}

- (void)start
{
	NSSavePanel *sp = [NSSavePanel savePanel];
	int runResult;

	if ([preview state] != NSOnState)
		runResult = [sp runModalForDirectory:[[NSUserDefaults standardUserDefaults] objectForKey:@"save"] file:@"Movie.avi"];
	else
		runResult = [sp runModalForDirectory:[[NSUserDefaults standardUserDefaults] objectForKey:@"save"] file:@"Preview.avi"];

	if (runResult != NSOKButton)
		return;

	[[NSUserDefaults standardUserDefaults] setObject:[sp directory] forKey:@"save"];
	filename = [sp filename];
	[filename retain];
	[self removeTempFiles];
	task = [[TaskWrapper alloc] initWithController:self arguments:[NSArray arrayWithObjects:@"/sbin/mount",nil]];
	[task startProcess];
	[progress startAnimation:self];
	[convert setTitle:@"Stop"];
	[menuitem setTitle:@"Stop"];
	[status setStringValue:@"Determining DVD-drive..."];

	[language setEnabled:FALSE];
	[audio setEnabled:FALSE];
	[width setEnabled:FALSE];
	[size setEnabled:FALSE];
	[animated setEnabled:FALSE];
	[preview setEnabled:FALSE];
	[quality setEnabled:FALSE];
	[vob setEnabled:FALSE];
	[dvd setEnabled:FALSE];
}

- (void)quit { [[NSApplication sharedApplication] terminate:self]; }

- (void)done
{
	[self cleanup];
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"finished"] isEqualToString:@"notify me"])
		[[NSApplication sharedApplication] requestUserAttention:NSCriticalRequest];

	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"finished"] isEqualToString:@"quit"])
	{
		NSTimer *timer;
		timer = [[NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(quit) userInfo:nil repeats:NO] retain];
	}
	else
	{
		[status setStringValue:@"Done!"];

		if (first == TRUE)
			NSRunAlertPanel(@"Note", @"To play Movies created with iRipDVD with QuickTime you have to use the DivX plugin (http://www.divx.com/divx/mac/). If you get an error from the QuickTime Player launch the DivX Decoder Configuration application and set 'Use DivX Avi Importer'.", @"OK", nil, nil);
	}
}

- (IBAction)endSheet:(id)sender
{
	if ([[sender title] isEqualToString:@"OK"])
	{
		if (([minutes intValue] >= 240) || ([minutes intValue] <= 0))
			NSRunAlertPanel(@"Error", @"The running time (minutes) of the movie should be a number (only digits) between 0 and 240.", @"OK", nil, nil);
		else
		{
			[sheet orderOut:sender];
			[NSApp endSheet:sheet returnCode:1];
		}
	}
	else
	{
		[sheet orderOut:sender];
		[NSApp endSheet:sheet returnCode:0];
	}
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contectInfo
{
	if (returnCode == 1)
	{
		length = [minutes intValue] * 60;
		[self start];
	}
}

#pragma mark *** NSWindow delegate-methods ***

- (BOOL)windowShouldClose:(id)sender
{
	if (state != 0)
		if (NSRunAlertPanel(@"Quit", @"Encoding is in progress. Do you really want to quit?", @"Yes", @"Cancel", nil) == NSAlertAlternateReturn)
			return NO;
			
	if (task != nil)
	{
		state = 99;
		[task stopProcess];
		task = nil;
	}
	
	[self cleanup];
	return YES;
}

#pragma mark *** IBAction action-methods ***

- (IBAction)preferences:(id)sender
{
	if (!preferenceController)
		preferenceController = [[PreferenceController alloc] init];
	[preferenceController showWindow:self];
}

- (IBAction)convert:(id)sender
{
	if (task != nil)	// stop
	{
		state = 99;
		[task stopProcess];
		task = nil;
		[self cleanup];
	}
	else	// convert
	{
		if ([vob state] == NSOnState)// && (vobfile != nil))
		{
			int result;
			NSArray *fileTypes = [NSArray arrayWithObjects:@"VOB", @"vob", @"Vob", nil];
			NSOpenPanel *oPanel = [NSOpenPanel openPanel];

			[oPanel setAllowsMultipleSelection:NO];
			result = [oPanel runModalForDirectory:[[NSUserDefaults standardUserDefaults] objectForKey:@"open"] file:nil types:fileTypes];

			if (result == NSOKButton)
			{
				NSArray *filesToOpen = [oPanel filenames];
				vobfile = [filesToOpen objectAtIndex:0];
				[[NSUserDefaults standardUserDefaults] setObject:[oPanel directory] forKey:@"open"];
				[vobfile retain];
				[NSApp beginSheet:sheet modalForWindow:window modalDelegate:self didEndSelector: @selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
			}
			else
				return;
		}
		else
			[self start];
	}
}

#pragma mark *** NSApplication delegate-methods ***

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	first = FALSE;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"start"])
	{
		first = TRUE;
		[[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"start"];
	}
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)file
{
	NSRange range1 = [file rangeOfString:@"/Volumes/"];
	
	if ([[file pathExtension] localizedCaseInsensitiveCompare:@"VOB"] == NSOrderedSame)
	{
		if (vobfile != file)
		{
			[vobfile release];
			vobfile = [file copy];
		}
		[vob setState:NSOnState];
		[dvd setState:NSOffState];
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"autostart"])
		{
			[NSApp beginSheet:sheet modalForWindow:window modalDelegate:self didEndSelector: @selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
			return YES;
		}
	}
	else if (range1.location == 0)
	{
		NSRange range2 = [[file substringFromIndex:9] rangeOfString:@"/"];
		if (range2.location == NSNotFound)
		{
			[dvd setState:NSOnState];
			[vob setState:NSOffState];
			if ([[NSUserDefaults standardUserDefaults] boolForKey:@"autostart"])
			{
				[self start];
				return YES;
			}
		}
	}
	return NO;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication { return YES; }

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	if (state != 0)
		if (NSRunAlertPanel(@"Quit", @"Encoding is in progress. Do you really want to quit?", @"Yes", @"Cancel", nil) == NSAlertAlternateReturn)
			return NSTerminateCancel;
			
	if (task != nil)
	{
		state = 99;
		[task stopProcess];
		task = nil;
	}
	
	[self cleanup];
	return NSTerminateNow;
}

#pragma mark *** TaskWrapperController protocol-methods ***

- (void)appendOutput:(NSString *)output
{
	static int times = 0;

	if (state != 8)
	{
		NSRange range;

		if (output != NULL)
			[taskOutput appendString:output];
		
		times++;

		if (((state >= 4) && (state <= 6)) && ([taskOutput length] > 600) && (times % 50 == 0))
		{
			range.location = 0;
			range.length = [taskOutput length] - 600;
			[taskOutput deleteCharactersInRange:range];
		}
		
		// NSLog(output);

		if (state == 2)
		{
			range = [taskOutput rangeOfString:@"DEMUXER"];
			if (range.location != NSNotFound)
				[task stopProcess];
		}
		else if ((state >= 4) && (state <= 6))
		{
			int i;
			
			range = [taskOutput rangeOfString:@"Pos:" options:NSBackwardsSearch];
			if (range.location != NSNotFound)
			{
				range.length = range.location;
				range.location = 0;
				range = [taskOutput rangeOfString:@"Pos:" options:NSBackwardsSearch range:range];
				if (range.location != NSNotFound)
				{
					i = range.location + range.length;
					while ([taskOutput characterAtIndex:i] != '.')
						i++;
					
					range.location = range.location + range.length;
					range.length = i - range.location;
					i = [[taskOutput substringWithRange:range] intValue];
					if ([preview state] != NSOnState)
						[progress setDoubleValue: (double) ((double) i / (double) (length - 1.0)) * 100];
					else
						[progress setDoubleValue: (double) ((double) i / 14.0) * 100];
				}
			}
		}
	}
}

- (void)processStarted { }

- (void)processFinished
{
	NSRange range;
	int i;
	
	[task autorelease];
	task = nil;

	if (state == 0)
	{
		// NSLog(@"1: mount done, start tracklength dedect");
		range.location = 0;
		range.length = [taskOutput length];
		
		if ([vob state] != NSOnState)
		{
			do
			{
				range = [taskOutput rangeOfString:@"(local, nodev, nosuid, read-only)" options:0 range:range];
				if (range.location != NSNotFound)
				{
					BOOL found = FALSE;

					i = range.location - 2;
					while ([taskOutput characterAtIndex:i] != '/')
						i--;
					while ([taskOutput characterAtIndex:i] != ' ')
						i--;
					
					range.location = i + 1;
					i = range.location;
					while ([taskOutput characterAtIndex:i] != '(')
						i++;
					i--;
					range.length = i - range.location;
					if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/VIDEO_TS", [taskOutput substringWithRange:range]] isDirectory:&found] && found)
					{
						i = range.location;
						while ([taskOutput characterAtIndex:i] != '\n')
							i--;
						
						range.location = i + 6;
						i = range.location;
						while ([taskOutput characterAtIndex:i] != ' ')
							i++;
						
						range.length = i - range.location;
						if (devicePath != nil)
							[devicePath release];
						devicePath = [NSString stringWithFormat:@"/dev/r%@", [taskOutput substringWithRange:range]];
						[devicePath retain];
						range.location = NSNotFound;
					}
					else
					{
						i = range.location;
						while ([taskOutput characterAtIndex:i] != '\n')
							i++;
						range.location = i;
						range.length = [taskOutput length] - range.location;
					}
				}
			} while (range.location != NSNotFound);
			
			if (devicePath == nil)
			{
				[self cleanup];
				if (NSRunAlertPanel(@"Warning", @"Could not find the DVD-drive. Please stop or insert a DVD (and wait until it is mounted!) and retry.", @"Stop", @"Retry", nil) != NSAlertDefaultReturn)
					[self convert:self];
				return;
			}
		}
		task = [[TaskWrapper alloc] initWithController:self arguments:[NSArray arrayWithObjects:[[NSBundle mainBundle] pathForResource:@"ifo_time" ofType:nil], devicePath, nil]];
		[task startProcess];
		[status setStringValue:@"Determining track-length..."];
	}
	else if (state == 1)
	{
		NSArray *lines;
		
		// NSLog(@"2: tracklength dedect done, start language dedect");
		if ([vob state] != NSOnState)
		{
			lines = [taskOutput componentsSeparatedByString:@"\n"];
			for (i = 0; i < ([lines count] - 1); i++)
			{
				int h, m, s, sum;
				range.location = 0;
				range.length = 2;
				h = [[[lines objectAtIndex:i] substringWithRange:range] intValue];
				range.location = 3;
				m = [[[lines objectAtIndex:i] substringWithRange:range] intValue];
				range.location = 6;
				s = [[[lines objectAtIndex:i] substringWithRange:range] intValue];
				sum = h*3600 + m*60 +s;
				if (sum > length)
				{
					length = sum;
					track = i;
				}

			}
			track++;
			task = [[TaskWrapper alloc] initWithController:self arguments:[NSArray arrayWithObjects:[[NSBundle mainBundle] pathForResource:@"mplayer" ofType:nil], @"-v", [NSString stringWithFormat:@"dvd://%d", track], @"-dvd-device", devicePath, nil]];
		}
		else
		{
			task = [[TaskWrapper alloc] initWithController:self arguments:[NSArray arrayWithObjects:[[NSBundle mainBundle] pathForResource:@"mplayer" ofType:nil], @"-v", [NSString stringWithCString:[vobfile fileSystemRepresentation]], nil]];
		}
		
		[task startProcess];
		[status setStringValue:@"Determining language..."];
	}
	else if (state == 2)
	{
		NSMutableArray *args = [NSMutableArray arrayWithObjects:[[NSBundle mainBundle] pathForResource:@"mencoder" ofType:nil], @"-o", @"/dev/null", @"-ss", [NSString stringWithFormat:@"%ld", length/10], @"-endpos", @"10", @"-ovc", @"lavc", @"-vop", @"cropdetect,scale", @"-zoom", @"-xy", [width titleOfSelectedItem], @"-oac", @"copy", nil];

		// NSLog(@"3: language dedect done, start crop dedect");
		if ([vob state] != NSOnState)
		{
			BOOL done = FALSE;
			
			range.location = 0;
			range.length = [taskOutput length];
			
			while (done == FALSE)
			{
				range = [taskOutput rangeOfString:[NSString stringWithFormat:@"language: %@ aid: ", [language titleOfSelectedItem]] options:0 range:range];
				if (range.location == NSNotFound)
					done = TRUE;
				else
				{
					i = range.location;
					while ([taskOutput characterAtIndex:i] != '(')
						i--;
					i -= 4;

					if (([taskOutput characterAtIndex:i] == 'd') 
						&& ([taskOutput characterAtIndex:i + 1] == 't') 
						&& ([taskOutput characterAtIndex:i + 2 ] == 's'))
					{
						range.location += 10;
						range.length = [taskOutput length] - range.location;
					}
					else
					{
						done = TRUE;
						range.location = range.location + range.length;
						range.length = 3;
						
						languageNumber = [taskOutput substringWithRange:range];
					}
				}
			}
			if (range.location == NSNotFound)
			{
				done = FALSE;
				range.location = 0;
				range.length = [taskOutput length];
				while (done == FALSE)
				{
					range = [taskOutput rangeOfString:@"audio format: " options:0 range:range];
					
					if (range.location != NSNotFound)
					{
						i = range.location + range.length;
						if (([taskOutput characterAtIndex:i] == 'd')
							&& ([taskOutput characterAtIndex:i + 1] == 't')
							&& ([taskOutput characterAtIndex:i + 2] == 's'))
						{
							range.location += 10;
							range.length = [taskOutput length] - range.location;
						}
						else
						{
							done = TRUE;
							while ([taskOutput characterAtIndex:i] != '\n')
								i++;
							range.location = i - 3;
							range.length = 3;
							languageNumber = [taskOutput substringWithRange:range];
							NSLog(@"%@", taskOutput);
							NSRunAlertPanel(@"Warning", @"%@", [NSString stringWithFormat:@"Could not find the selected language code. We assume %@.", languageNumber], @"Continue", nil, nil);
						}
					}
					else
					{
						NSLog(@"%@", taskOutput);
						[self cleanup];
						NSRunAlertPanel(@"Error", @"This DVD doesn't contain a non-DTS audio-track and thus vialotes the DVD-spec. Because there is no open-source DTS-decoder we can't encode this DVD.", @"Stop", nil, nil);
						return;
					}
				}
			}
			[languageNumber retain];
		}

		if ([vob state] != NSOnState)
			[args addObjectsFromArray:[NSArray arrayWithObjects: [NSString stringWithFormat:@"dvd://%d", track], @"-dvd-device", devicePath, nil]];
		else
			[args addObject:[NSString stringWithCString:[vobfile fileSystemRepresentation]]];
		
		task = [[TaskWrapper alloc] initWithController:self arguments:args];
		[task startProcess];
		[status setStringValue:@"Determining crop-values..."];
	}
	else if (state == 3)
	{
		NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
		NSMutableArray *args = [NSMutableArray arrayWithObjects:[[NSBundle mainBundle] pathForResource:@"mencoder" ofType:nil], @"-o", @"frameno.avi", @"-ovc", @"frameno", @"-oac", @"mp3lame", @"-lameopts", [NSString stringWithFormat:@"abr:br=%@:vol=3", [audio titleOfSelectedItem]], nil];
		NSEnumerator *enumerator;
		id key;
		int highest = 0;
		
		// NSLog(@"4: crop dedect done, start audio+bitrate");
		range.location = 0;
		range.length = [taskOutput length];
		do
		{
			range = [taskOutput rangeOfString:@"-vop crop=" options:0 range:range];
			if (range.location != NSNotFound)
			{
				i = range.location;
				while ([taskOutput characterAtIndex:i] != '\n')
					i++;
				
				range.location += 5;
				range.length = i - range.location - 1;
				if ([dict objectForKey:[taskOutput substringWithRange:range]] == nil)
					[dict setObject:[NSNumber numberWithInt:1] forKey:[taskOutput substringWithRange:range]];
				else
					[dict setObject:[NSNumber numberWithInt:[[dict objectForKey:[taskOutput substringWithRange:range]] intValue] + 1] forKey:[taskOutput substringWithRange:range]];
				range.location += range.length;
				range.length = [taskOutput length] - range.location;
			}
		} while (range.location != NSNotFound);
		
		if ([dict count] == 0)
		{
			NSLog(@"%@", taskOutput);
			[self cleanup];
			range = [taskOutput rangeOfString:@"Cannot open file/device."];
			if (range.location != NSNotFound)
				NSRunAlertPanel(@"Error", @"This DVD seems to be damaged.", @"Stop", nil, nil);
			else
				NSRunAlertPanel(@"Error", @"Could not find the cropdedect output. This may be a 'field-coded' DVD, which mencoder (iRipDVD's MPEG4-engine) doesn't support.", @"Stop", nil, nil);
			return;
		}
		
		enumerator = [dict keyEnumerator];
		while ((key = [enumerator nextObject]))
		{
			if ([[dict objectForKey:key] intValue] > highest)
			{
				highest = [[dict objectForKey:key] intValue];
				crop = key;
			}
		}
		[crop retain];

		if ([preview state] == NSOnState)
			[args addObjectsFromArray:[NSArray arrayWithObjects:@"-ss", @"300", @"-endpos", @"15", nil]];
		if ([vob state] != NSOnState)
			[args addObjectsFromArray:[NSArray arrayWithObjects:@"-aid", languageNumber, [NSString stringWithFormat:@"dvd://%d", track], @"-dvd-device", devicePath, nil]];
		else
			[args addObject:[NSString stringWithCString:[vobfile fileSystemRepresentation]]];
		
		task = [[TaskWrapper alloc] initWithController:self arguments:args];
		[task startProcess];
		[status setStringValue:@"Encoding audio..."];
		[progress setIndeterminate:FALSE];
		[progress stopAnimation:self];
	}
	else if (state == 4)
	{
		NSMutableArray *args = [NSMutableArray arrayWithObjects:[[NSBundle mainBundle] pathForResource:@"mencoder" ofType:nil], @"-o", @"/dev/null", @"-nosound", @"-oac", @"copy", @"-ovc", @"lavc", @"-vop", [NSString stringWithFormat:@"%@,scale", crop], @"-zoom", @"-xy", [width titleOfSelectedItem], @"-sws", @"2", @"-lavcopts", nil];
		NSString *options;
		int calculatedBitrate;
		
		// NSLog(@"5: audio+bitrate done, start pass 1");
		if ([[size titleOfSelectedItem] isEqualToString:@"650MB"])
			calculatedBitrate = ((650 * 1024 * 8 - [[audio titleOfSelectedItem] intValue] * length) / length);
		else if ([[size titleOfSelectedItem] isEqualToString:@"700MB"])
			calculatedBitrate = ((700 * 1024 * 8 - [[audio titleOfSelectedItem] intValue] * length) / length);
		else if ([[size titleOfSelectedItem] isEqualToString:@"800MB"])
			calculatedBitrate = ((800 * 1024 * 8 - [[audio titleOfSelectedItem] intValue] * length) / length);
		else if ([[size titleOfSelectedItem] isEqualToString:@"2 x 650MB"])
			calculatedBitrate = ((2 * 650 * 1024 * 8 - [[audio titleOfSelectedItem] intValue] * length) / length);
		else if ([[size titleOfSelectedItem] isEqualToString:@"2 x 700MB"])
			calculatedBitrate = ((2 * 700 * 1024 * 8 - [[audio titleOfSelectedItem] intValue] * length) / length);
		else //if ([[size titleOfSelectedItem] isEqualToString:@"2 x 800MB"])
			calculatedBitrate = ((2 * 800 * 1024 * 8 - [[audio titleOfSelectedItem] intValue] * length) / length);
		
		if ([preview state] != NSOnState)
		{
			range = [taskOutput rangeOfString:[NSString stringWithFormat:@"Recommended video bitrate for %@", [size titleOfSelectedItem]]];
			if (range.location == NSNotFound)
			{
				NSLog(@"%@", taskOutput);
				NSRunAlertPanel(@"Warning", @"Could not find a bitrate recommendation. We are using our own calculated value, which may be inaccurate.", @"Continue", nil, nil);
				bitrate = [NSString stringWithFormat:@"%d", calculatedBitrate];
			}
			else
			{
				range.location = range.location + range.length + 5;
				
				i = range.location;
				while ([taskOutput characterAtIndex:i] != '\n')
					i++;
				
				range.length = i - range.location;
				bitrate = [taskOutput substringWithRange:range];
			}
		}
		else
			bitrate = [NSString stringWithFormat:@"%d", calculatedBitrate];
		
		[bitrate retain];

		options = @"vcodec=mpeg4:vqscale=2:vpass=1";
		if ([animated state] != NSOnState)
		{
			if ([quality intValue] == 2)
				options = [options stringByAppendingString:@":vhq:v4mv:trell:vb_qfactor=1.25:vb_qoffset=0.6:vmax_b_frames=1:precmp=2:cmp=2:subcmp=2:vlelim=-4:vcelim=9:lumi_mask=0.05:dark_mask=0.01"];
			else if ([quality intValue] == 1)
				options = [options stringByAppendingString:@":vhq:v4mv:vlelim=-4:vcelim=9:lumi_mask=0.05:dark_mask=0.01"];
			else
				options = [options stringByAppendingString:@":vlelim=-4:vcelim=9:lumi_mask=0.05:dark_mask=0.01"];
		}
		else
		{
			if ([quality intValue] == 2)
				options = [options stringByAppendingString:@":vhq:v4mv:trell:precmp=1:cmp=1:subcmp=1:predia=3:dia=3"];
			else if ([quality intValue] == 1)
				options = [options stringByAppendingString:@":vhq:v4mv:precmp=1:cmp=1:subcmp=1"];
			else
				options = [options stringByAppendingString:@":precmp=1:cmp=1:subcmp=1"];
		}
		
		[args addObject:options];
		
		if ([preview state] == NSOnState)
			[args addObjectsFromArray:[NSArray arrayWithObjects:@"-ss", @"300", @"-endpos", @"15", nil]];
		if ([vob state] != NSOnState)
			[args addObjectsFromArray:[NSArray arrayWithObjects: [NSString stringWithFormat:@"dvd://%d", track], @"-dvd-device", devicePath, nil]];
		else
			[args addObject:[NSString stringWithCString:[vobfile fileSystemRepresentation]]];
		
		task = [[TaskWrapper alloc] initWithController:self arguments:args];
		[task startProcess];
		[progress setDoubleValue: 0.0];
		[status setStringValue:@"Encoding video (1/2)..."];
	}
	else if (state == 5)
	{
		NSMutableArray *args = [NSMutableArray arrayWithObjects:[[NSBundle mainBundle] pathForResource:@"mencoder" ofType:nil], @"-o", [NSString stringWithCString:[filename fileSystemRepresentation]], @"-oac", @"copy", @"-ovc", @"lavc", @"-vop", [NSString stringWithFormat:@"%@,scale", crop], @"-zoom", @"-xy", [width titleOfSelectedItem], @"-sws", @"2", @"-lavcopts", nil];
		NSString *options;
		
		//NSLog(@"6: pass 1 done, start pass 2");
		options = [NSString stringWithFormat:@"vcodec=mpeg4:vbitrate=%@:vpass=2:vqmin=2:vqmax=15", bitrate];
		if ([animated state] != NSOnState)
		{
			if ([quality intValue] == 2)
				options = [options stringByAppendingString:@":vhq:v4mv:trell:vb_qfactor=1.25:vb_qoffset=0.6:vmax_b_frames=1:precmp=2:cmp=2:subcmp=2:vlelim=-4:vcelim=9:lumi_mask=0.05:dark_mask=0.01"];
			else if ([quality intValue] == 1)
				options = [options stringByAppendingString:@":vhq:v4mv:vlelim=-4:vcelim=9:lumi_mask=0.05:dark_mask=0.01"];
			else
				options = [options stringByAppendingString:@":vlelim=-4:vcelim=9:lumi_mask=0.05:dark_mask=0.01"];
		}
		else
		{
			if ([quality intValue] == 2)
				options = [options stringByAppendingString:@":vhq:v4mv:trell:precmp=1:cmp=1:subcmp=1:predia=3:dia=3"];
			else if ([quality intValue] == 1)
				options = [options stringByAppendingString:@":vhq:v4mv:precmp=1:cmp=1:subcmp=1"];
			else
				options = [options stringByAppendingString:@":precmp=1:cmp=1:subcmp=1"];
		}
		
		[args addObject:options];
		
		if ([preview state] == NSOnState)
			[args addObjectsFromArray:[NSArray arrayWithObjects:@"-ss", @"300", @"-endpos", @"15", nil]];
		if ([vob state] != NSOnState)
			[args addObjectsFromArray:[NSArray arrayWithObjects: [NSString stringWithFormat:@"dvd://%d", track], @"-dvd-device", devicePath, nil]];
		else
			[args addObject:[NSString stringWithCString:[vobfile fileSystemRepresentation]]];
		
		task = [[TaskWrapper alloc] initWithController:self arguments:args];
		[task startProcess];
		[progress setDoubleValue: 0.0];
		[status setStringValue:@"Encoding video (2/2)..."];
	}
	else if (state == 6)
	{
		//NSLog(@"7: pass 2 done, optionally start split 1");
		if (([[size titleOfSelectedItem] characterAtIndex:0] == '2') && ([preview state] != NSOnState))
		{
			NSString *ext = [filename pathExtension];
			int bytepos;
			
			if ([[size titleOfSelectedItem] isEqualToString:@"2 x 650MB"])
				bytepos = 649;
			else if ([[size titleOfSelectedItem] isEqualToString:@"2 x 700MB"])
				bytepos = 699;
			else //if ([[size titleOfSelectedItem] isEqualToString:@"2 x 800MB"])
				bytepos = 799;

			task = [[TaskWrapper alloc] initWithController:self arguments:[NSArray arrayWithObjects:[[NSBundle mainBundle] pathForResource:@"mencoder" ofType:nil], @"-ovc", @"copy", @"-oac", @"copy", @"-endpos", [NSString stringWithFormat:@"%dMB", bytepos], @"-o", [NSString stringWithCString:[[[filename stringByDeletingPathExtension] stringByAppendingFormat:@" (CD1).%@", ext] fileSystemRepresentation]], [NSString stringWithCString: [filename fileSystemRepresentation]], nil]];
			[task startProcess];
			[progress setDoubleValue: 0.0];
			[progress setIndeterminate:TRUE];
			[progress startAnimation:self];
			[status setStringValue:@"Splitting movie (1/2)..."];
		}
		else
		{
			[self done];
			return;
		}
	}
	else if (state == 7)
	{
		NSString *ext = [filename pathExtension];
		
		//NSLog(@"8: split 1 done, start split 2");
		range = [taskOutput rangeOfString:@"Pos:" options:NSBackwardsSearch];
		if (range.location != NSNotFound)
		{
			range.location = range.location + range.length;
			range.length = 0;
			if ([taskOutput characterAtIndex:range.location] == ' ')
				while ([taskOutput characterAtIndex:range.location] == ' ')
					range.location++;
			while ([taskOutput characterAtIndex:range.location + range.length] != '.')
				range.length++;
		}
		else
		{
			NSLog(@"%@", taskOutput);
			[self cleanup];
			NSRunAlertPanel(@"Error", @"Could not determine the length of the first splitted video part.", @"Stop", nil, nil);
			return;
		}
		
		task = [[TaskWrapper alloc] initWithController:self arguments:[NSArray arrayWithObjects:[[NSBundle mainBundle] pathForResource:@"mencoder" ofType:nil], @"-ovc", @"copy", @"-oac", @"copy", @"-ss", [taskOutput substringWithRange:range], @"-o", [NSString stringWithCString:[[[filename stringByDeletingPathExtension] stringByAppendingFormat:@" (CD2).%@", ext] fileSystemRepresentation]], [NSString stringWithCString:[filename fileSystemRepresentation]], nil]];
		[task startProcess];
		[progress setDoubleValue: 0.0];
		[progress setIndeterminate:TRUE];
		[progress startAnimation:self];
		[status setStringValue:@"Splitting movie (2/2)..."];
	}
	else if (state == 8)
	{
		//NSLog(@"9: done");
		remove([filename fileSystemRepresentation]);
		[self done];
		return;
	}
	[taskOutput setString:@""];
	state++;
}
@end

/*{
	 OSErr nErr = noErr;
	 short nFileRefNum;
	 FSRef myFSRef;
	 FSSpec myFSSpecPtr;
	
	 nErr = FSPathMakeRef ([vobfile fileSystemRepresentation], &myFSRef, NULL);
	 if (nErr == noErr)
		 nErr = FSGetCatalogInfo (&myFSRef, kFSCatInfoNone, NULL, NULL, &myFSSpecPtr, NULL);
	 if (nErr != noErr)
	 {
		 NSLog(taskOutput);
		 [self cleanup];
		 NSRunAlertPanel(@"Error", @"Could not analyze the VOB file.", @"Stop", nil, nil);
		 return;
	 }
	
	 nErr = EnterMovies();
	 if (nErr == noErr)
		 nErr = OpenMovieFile(&myFSSpecPtr, &nFileRefNum, fsRdPerm);
	 if (nErr == noErr)
	 {
		 short			nResID = 0;
		 Str255			strName;
		 Boolean		bWasChanged;
		 Movie movie = NULL;
		
		 nErr = NewMovieFromFile(&movie, nFileRefNum, &nResID, strName, newMovieActive, &bWasChanged);
		 if (nErr == noErr)
		 {
			 length = GetMovieDuration(movie) / GetMovieTimeScale(movie);
			 CloseMovieFile(nFileRefNum);
			 ExitMovies();
		 }
	 }
	 if (nErr != noErr)
	 {
		 NSLog(taskOutput);
		 [self cleanup];
		 NSRunAlertPanel(@"Error", @"Could not analyze the VOB file.", @"Stop", nil, nil);
		 return;
	 }
 }*/

int main(int argc, const char *argv[]) { return NSApplicationMain(argc, argv); }
