//
//  PreferenceController.m
//  iRipDVD
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
	[finished selectItemWithTitle:[[NSUserDefaults standardUserDefaults] objectForKey:@"finished"]];
	[autostart setState:[[NSUserDefaults standardUserDefaults] boolForKey:@"autostart"]];
}

- (IBAction)save:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setObject:[finished titleOfSelectedItem] forKey:@"finished"];
	if ([autostart state] == NSOnState)
		[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"autostart"];
	else
		[[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"autostart"];

	[[self window] close];
}
@end