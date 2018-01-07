//
//  PreferenceController.m
//  iRipCD
//
//  Created by CoreCode on Tue Sep 03 2002.
/*	Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import "PreferenceController.h"


@implementation PreferenceController

- (id)init
{
	self = [super initWithWindowNibName:@"Preferences"];
	return self;
}

- (void)windowDidLoad
{
	NSDictionary *environment = [[NSProcessInfo processInfo] environment];
	NSString *commonlist = @"/bin/powerpc-apple-darwin:/usr/X11R6/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/sw/bin:/sw/sbin:";
	NSString *pathlist = [environment objectForKey:@"PATH"];
	NSArray *commonItems = [commonlist componentsSeparatedByString:@":"];
	NSArray *pathItems = [pathlist componentsSeparatedByString:@":"];
	NSString *path;
	BOOL duplicate;
	unsigned int i, h;

	for (i = 0; i < [commonItems count]; i++)
	{
		path = [[commonItems objectAtIndex:i] stringByAppendingString:@"/lame"];
		if ([[NSFileManager defaultManager] fileExistsAtPath:path])
			[versionsPopupOutlet addItemWithTitle:path];
	}

	for (i = 0; i < [pathItems count]; i++)
	{
		duplicate = FALSE;
		for (h = 0; h < [commonItems count]; h++)
		{
			if ([[pathItems objectAtIndex:i] isEqualToString:[commonItems objectAtIndex:h]])
				duplicate = TRUE;
		}
		if (!duplicate)
		{
			path = [[pathItems objectAtIndex:i] stringByAppendingString:@"/lame"];
			if ([[NSFileManager defaultManager] fileExistsAtPath:path])
				[versionsPopupOutlet addItemWithTitle:path];
		}
	}
}

- (IBAction)save:(id)sender
{
	if ([versionsPopupOutlet indexOfSelectedItem] == 0)
		[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"lamePath"];
	else
		[[NSUserDefaults standardUserDefaults] setObject:[versionsPopupOutlet titleOfSelectedItem] forKey:@"lamePath"];
	[self close];
}

- (IBAction)close:(id)sender
{
	[[self window] close];
}
@end