//
//  KeyPresser.m
//  KeyPresser
//
//  Created by CoreCode on 22.09.05.
/*	Copyright (c) 2005 - 2007 CoreCode
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import "KeyPresser.h"

@implementation KeyPresser

+ (void)initialize
{
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	
	[defaultValues setObject:@"" forKey:@"SelectedTargetApplication"];
	[defaultValues setObject:@"10,0" forKey:@"SelectedInterval"];
	[defaultValues setObject:[NSNumber numberWithInt:3] forKey:@"hotKeyCode"];
	[defaultValues setObject:[NSNumber numberWithInt:0] forKey:@"hotKeyModifiers"];

	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}

- (void)applicationDidLaunch:(NSNotification *)notification
{
	[applications addItemWithTitle:[[notification userInfo] objectForKey:@"NSApplicationName"]];
}

- (void)applicationDidTerminate:(NSNotification *)notification
{
	[applications removeItemWithTitle:[[notification userInfo] objectForKey:@"NSApplicationName"]];
}

- (void)timerAction:(NSTimer *)theTimer
{
	AXError error;
	
	if ([[NSUserDefaults standardUserDefaults] integerForKey:@"hotKeyModifiers"] & cmdKey)
		error = AXUIElementPostKeyboardEvent (app, (CGCharCode)0, (CGKeyCode)55, true);
	if ([[NSUserDefaults standardUserDefaults] integerForKey:@"hotKeyModifiers"] & optionKey)
		error = AXUIElementPostKeyboardEvent (app, (CGCharCode)0, (CGKeyCode)58, true);
	if ([[NSUserDefaults standardUserDefaults] integerForKey:@"hotKeyModifiers"] & controlKey)
		error = AXUIElementPostKeyboardEvent (app, (CGCharCode)0, (CGKeyCode)59, true);
	if ([[NSUserDefaults standardUserDefaults] integerForKey:@"hotKeyModifiers"] & shiftKey)
		error = AXUIElementPostKeyboardEvent (app, (CGCharCode)0, (CGKeyCode)56, true);
	
	error = AXUIElementPostKeyboardEvent (app, (CGCharCode)0, (CGKeyCode)[[NSUserDefaults standardUserDefaults] integerForKey:@"hotKeyCode"], true);
	error = AXUIElementPostKeyboardEvent (app, (CGCharCode)0, (CGKeyCode)[[NSUserDefaults standardUserDefaults] integerForKey:@"hotKeyCode"], false);
	
	if ([[NSUserDefaults standardUserDefaults] integerForKey:@"hotKeyModifiers"] & cmdKey)
		error = AXUIElementPostKeyboardEvent (app, (CGCharCode)0, (CGKeyCode)55, false);
	if ([[NSUserDefaults standardUserDefaults] integerForKey:@"hotKeyModifiers"] & optionKey)
		error = AXUIElementPostKeyboardEvent (app, (CGCharCode)0, (CGKeyCode)58, false);
	if ([[NSUserDefaults standardUserDefaults] integerForKey:@"hotKeyModifiers"] & controlKey)
		error = AXUIElementPostKeyboardEvent (app, (CGCharCode)0, (CGKeyCode)59, false);
	if ([[NSUserDefaults standardUserDefaults] integerForKey:@"hotKeyModifiers"] & shiftKey)
		error = AXUIElementPostKeyboardEvent (app, (CGCharCode)0, (CGKeyCode)56, false);
	
	times ++;
}

- (void)logtimerAction:(NSTimer *)theTimer
{
	NSString *time = [[NSDate date] descriptionWithCalendarFormat:@"%H:%M:%S" timeZone:nil locale:nil];
	NSString *string =	[theTimer timeInterval] > 1.0 ?
		[NSString stringWithFormat:@"%@: Posted a key-press!\n", time] :
		[NSString stringWithFormat:@"%@: Posted %i key-presses in 1 second!\n", time, times];
	times = 0;
	
	NSRange theEnd = NSMakeRange([[logtext string] length],0);
	[logtext replaceCharactersInRange:theEnd withString:string];
	theEnd.location += [string length];
	[logtext scrollRangeToVisible:theEnd];
}

#pragma mark *** NSApplication delegate-methods ***

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	if (!AXAPIEnabled())
	{	
		[[NSAlert alertWithMessageText:@"You must 'Enable access for assistive devices' in Universal Access Preferences to use KeyPresser!" defaultButton:@"Quit" alternateButton:nil otherButton:nil informativeTextWithFormat:@""] runModal];
		[[NSApplication sharedApplication] terminate:self];
	}
	
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
														   selector:@selector(applicationDidTerminate:)
															   name:NSWorkspaceDidTerminateApplicationNotification object:nil];
		
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
														   selector:@selector(applicationDidLaunch:)
															   name:NSWorkspaceDidLaunchApplicationNotification object:nil];
	
	hotKey = [[PTHotKey alloc] initWithIdentifier: @"hotKey" keyCombo:
		[[PTKeyCombo keyComboWithKeyCode: [[NSUserDefaults standardUserDefaults] integerForKey:@"hotKeyCode"]
							   modifiers: [[NSUserDefaults standardUserDefaults] integerForKey:@"hotKeyModifiers"]] retain]];
	[hotKey setName: @"Test HotKey123"];
	
	NSArray *apps = [[NSWorkspace sharedWorkspace] launchedApplications];
	NSEnumerator *enumerator = [apps objectEnumerator];
	NSDictionary *appdict;
	
	while ((appdict = [enumerator nextObject]))
		[applications addItemWithTitle:[appdict objectForKey:@"NSApplicationName"]];

	[applications selectItemWithTitle:[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedTargetApplication"]];
	[interval setStringValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedInterval"]];
	[keytext setStringValue:[[hotKey keyCombo] description]];	

}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	
	if ((standardUserDefaults) && (![[applications titleOfSelectedItem] isEqualToString:@""]))
	{
		[standardUserDefaults setObject:[applications titleOfSelectedItem] forKey:@"SelectedTargetApplication"];
		[standardUserDefaults setObject:[interval stringValue] forKey:@"SelectedInterval"];
		[standardUserDefaults synchronize];
	}
}

#pragma mark *** IBAction action-methods ***

- (IBAction)setKey:(id)sender
{
	PTKeyComboPanel *panel = [PTKeyComboPanel sharedPanel];
	int result;
	
	[panel setKeyCombo:[hotKey keyCombo]];
	[panel setKeyBindingName:@"keypress to send"];
	result = [panel runModal];
	
	if (result == NSOKButton)
	{
		[hotKey setKeyCombo:[panel keyCombo]];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[[panel keyCombo] keyCode]] forKey:@"hotKeyCode"];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[[panel keyCombo] modifiers]] forKey:@"hotKeyModifiers"];
		
		[keytext setStringValue:[[hotKey keyCombo] description]];	
	}
}

- (IBAction)start:(id)sender
{
	times = 0;
	
	if ([applications indexOfSelectedItem] < 2)
	{
		NSRunAlertPanel(@"KeyPresser", @"Please choose a valid target application!", @"OK", nil, nil);
		return;
	}
	
	NSArray *apps = [[NSWorkspace sharedWorkspace] launchedApplications];
	NSEnumerator *enumerator = [apps objectEnumerator];
	NSDictionary *appdict;
	BOOL finished = FALSE;
	
	while ((appdict = [enumerator nextObject]))
	{
		if ([[appdict objectForKey:@"NSApplicationName"] isEqualToString:[applications titleOfSelectedItem]])
		{
			app = AXUIElementCreateApplication ([[appdict objectForKey:@"NSApplicationProcessIdentifier"] intValue]);
			finished = TRUE;
			break;
		}
	}
		
	if (!finished)
	{
		NSRunAlertPanel(@"KeyPresser", @"Please choose a valid target application!", @"OK", nil, nil);
		return;
	}
	if ([interval doubleValue] == 0.0)
	{
		NSRunAlertPanel(@"KeyPresser", @"Please choose a valid time interval!", @"OK", nil, nil);
		return;	
	}
	if ([[hotKey keyCombo] isClearCombo])
	{
		NSRunAlertPanel(@"KeyPresser", @"Please choose a valid keypress to send!", @"OK", nil, nil);
		return;	
	}
	
	[NSApp beginSheet:logsheet modalForWindow: window modalDelegate: nil didEndSelector: nil contextInfo: nil];

	timer = [NSTimer scheduledTimerWithTimeInterval:[interval doubleValue] target:self selector:@selector(timerAction:) userInfo:nil repeats:TRUE];
	logtimer = [NSTimer scheduledTimerWithTimeInterval: [interval doubleValue] < 1.0 ? 1 : [interval doubleValue] target:self selector:@selector(logtimerAction:) userInfo:nil repeats:TRUE];
}

- (IBAction)stopButtonAction:(id)sender
{
	
	[NSApp endSheet:logsheet];
	[logsheet orderOut:self];
	
	[timer invalidate];
	timer = nil;
	[logtimer invalidate];
	logtimer = nil;
}
@end

int main(int argc, char *argv[])
{
	return NSApplicationMain(argc, (const char **) argv);
}