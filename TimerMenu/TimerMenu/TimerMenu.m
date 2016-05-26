//
//  TimerMenu.m
//  TimerMenu
//
//  Created by CoreCode on 27.03.08.
/*	Copyright (c) 2008 CoreCode
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import "TimerMenu.h"

@implementation TimerMenu

+ (void)initialize
{
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];

	[defaultValues setObject:[NSNumber numberWithInt:0] forKey:@"time"];	

	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}


-(void)awakeFromNib
{
	statusItem = nil;
	
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
	
	[statusItem setHighlightMode:YES];
	[statusItem setEnabled:YES];
	[statusItem setMenu:menu];
	[statusItem setTitle:@"Off"];
	
	timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTarget:) userInfo:NULL repeats:YES];
}

- (void)timerTarget:(NSTimer*)timer
{	
	if (![[statusItem title] isEqualToString:@"Off"])
	{
		[[NSUserDefaults standardUserDefaults] setInteger:([[NSUserDefaults standardUserDefaults] integerForKey:@"time"] + 1) forKey:@"time"];
		
//		NSTimeZone *storedTimeZone = [NSTimeZone defaultTimeZone];
//		[NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
//		
//		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] initWithDateFormat:@"%Hh %Mm %Ss" allowNaturalLanguage:NO];
//		NSString *string = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[[NSUserDefaults standardUserDefaults] integerForKey:@"time"]]];
//	
//		[dateFormatter release];
//	
//		[NSTimeZone setDefaultTimeZone:storedTimeZone];
//					
		int secs = [[NSUserDefaults standardUserDefaults] integerForKey:@"time"];
		int hours = secs / 3600;
		int minutes = (secs % 3600) / 60;
		[statusItem setTitle:[NSString stringWithFormat:@"%ih %im", hours, minutes]];
	}
}

#pragma mark *** IBAction action-methods ***

- (IBAction)switchAction:(id)sender
{
	if ([[statusItem title] isEqualToString:@"Off"])
		[statusItem setTitle:@""];	
	else
		[statusItem setTitle:@"Off"];
}

- (IBAction)resetAction:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"time"];
}
@end

int main(int argc, char *argv[]) { return NSApplicationMain(argc,  (const char **) argv); }