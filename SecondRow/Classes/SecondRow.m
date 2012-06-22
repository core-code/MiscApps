//
//  SecondRow.m
//  SecondRow
//
//  Created by CoreCode on 16.05.08.
/*	Copyright (c) 2008 CoreCode
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import "SecondRow.h"
#include "CGDisplay.h"

@implementation SecondRow

- (void)tellFrontRow:(int)command
{
	NSAppleScript			*scriptObject;
	NSDictionary			*errorDict;
	NSAppleEventDescriptor 	*returnDescriptor;
	
	if (command == kActivate)
		scriptObject = [[NSAppleScript alloc] initWithSource: @"tell application \"System Events\" \n key code 53 using command down \n end tell"];
	else if (command == kShutdown)
		scriptObject = [[NSAppleScript alloc] initWithSource: @"tell application \"System Events\" \n key code 53 \n end tell"];
	else // if (command == kKill)
		scriptObject = [[NSAppleScript alloc] initWithSource: @"do shell script \"killall 'Front Row'\""];
		
	returnDescriptor = [scriptObject executeAndReturnError: &errorDict];
	[scriptObject release];
	
	if (![returnDescriptor descriptorType])
		NSLog(@"Error: AppleScriptError: %@", [errorDict objectForKey: @"NSAppleScriptErrorMessage"]);
}

#pragma mark *** NSDistributedNotificationCenter observer-methods ***

- (void)frontRowDidShow:(NSNotification *)n
{
	if (actionNeeded == TRUE)
	{
		if (active == FALSE)	// 1
		{
			NSLog(@"1");
			active = TRUE;
			[self tellFrontRow:kShutdown];
		}
		else					// 3
		{
			NSLog(@"3");		
			active = FALSE;
		}
	}
}

- (void)frontRowDidHide:(NSNotification *)n
{
	if (actionNeeded == TRUE)
	{
		if (active == TRUE)		// 2
		{
			NSLog(@"2");		
			[self tellFrontRow:kKill];		
			switchDisplays();
			sleep(1);
			[self tellFrontRow:kActivate];		
		}
		else					// 4
		{
			NSLog(@"4");		
			switchDisplays();
			actionNeeded = FALSE;	
		}
	}
}

- (void)displayHWReconfiguredEvent:(NSNotification *)n
{
	NSLog(@"X");
	actionNeeded = TRUE;
}

#pragma mark *** NSApplication delegate-methods ***

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	active = FALSE;
	actionNeeded = TRUE;

	[(NSDistributedNotificationCenter *)[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(frontRowDidShow:) name:@"com.apple.FrontRow.FrontRowDidShow" object:NULL];	
	[(NSDistributedNotificationCenter *)[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(frontRowDidHide:) name:@"com.apple.FrontRow.FrontRowDidHide" object:NULL];	
	[(NSDistributedNotificationCenter *)[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(displayHWReconfiguredEvent:) name:@" com.apple.BezelServices.BMDisplayHWReconfiguredEvent" object:NULL];	
}
@end

int main(int argc, char *argv[])
{
	return NSApplicationMain(argc, (const char **) argv);
}