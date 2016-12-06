//
//  OmniExpose.m
//  OmniExpose
//
//  Created by CoreCode on 25.02.06.
/*	Copyright (c) 2016 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import "OmniExpose.h"

//TODO: watch for all events that can exit expose, mouse impossible?
//TODO: hot corners
//TODO: determine used hotcorners & expose keycombo

@implementation OmniExpose

+ (void)initialize
{
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];

	[defaultValues setObject:@"1" forKey:@"keyCombinationEnabled"];
	[defaultValues setObject:[NSNumber numberWithInt:1] forKey:@"firstStart"];
	[defaultValues setObject:[NSNumber numberWithInt:100] forKey:@"ourHotKeyCode"]; 	// 100 = F8
	[defaultValues setObject:[NSNumber numberWithInt:101] forKey:@"theirHotKeyCode"];	// 101 = F9
	[defaultValues setObject:[NSNumber numberWithInt:32768] forKey:@"ourHotKeyModifiers"];
	[defaultValues setObject:[NSNumber numberWithInt:32768] forKey:@"theirHotKeyModifiers"];

	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}

- (void)awakeFromNib
{
	isDown = FALSE;
	longDown = TRUE;
	hidden = [NSMutableArray new];

	// handle hiding/showing of UI
	if (([[NSUserDefaults standardUserDefaults] integerForKey:@"firstStart"] == 1) || ((GetCurrentKeyModifiers() & (optionKey | rightOptionKey)) != 0))
	{
		[self transform];
		[window makeKeyAndOrderFront:nil];
	}
	if ([[NSUserDefaults standardUserDefaults] integerForKey:@"firstStart"] == 1)
	{
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"firstStart"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}

	// setup&register hotkeys, populate textfields
	ourHotKey = [[PTHotKey alloc] initWithIdentifier: @"ourHotKey" keyCombo:
						[[PTKeyCombo keyComboWithKeyCode: [[NSUserDefaults standardUserDefaults] integerForKey:@"ourHotKeyCode"]
											   modifiers: [[NSUserDefaults standardUserDefaults] integerForKey:@"ourHotKeyModifiers"]] retain]];
											   theirHotKey = [[PTHotKey alloc] initWithIdentifier: @"theirHotKey" keyCombo:
								[[PTKeyCombo keyComboWithKeyCode: [[NSUserDefaults standardUserDefaults] integerForKey:@"theirHotKeyCode"]
													   modifiers: [[NSUserDefaults standardUserDefaults] integerForKey:@"theirHotKeyModifiers"]] retain]];

	[ourHotKey setTarget: self];
	[ourHotKey setAction: @selector(hotKey:kind:)];

	[ourHotKeyTextField setStringValue:[[ourHotKey keyCombo] description]];
	[theirHotKeyTextField setStringValue:[[theirHotKey keyCombo] description]];

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"keyCombinationEnabled"]	== TRUE)
		[[PTHotKeyCenter sharedCenter] registerHotKey:ourHotKey];
}

- (void)hotKey:(id)sender kind:(NSString *)kind
{
	NSLog([kind isEqualToString:@"Down"] ? @"hotKeyDown::" : @"hotKeyUp::");
	NSLog(longDown ? @"  longdown: TRUE" : @"  longdown: FALSE");
	NSLog(isDown ? @"  isDown: TRUE" : @"  isDown: FALSE");

	if ([kind isEqualToString:@"Down"])
	{
		isDown = TRUE;

		if (longDown == FALSE) // down of second shortdown
		{
			longDown = TRUE;
		}
		else  // down of longdown und down of first shortdown
		{
			[self showHidden];
			longDown = FALSE;
			[self performSelector: @selector(delayed:) withObject:sender afterDelay: 0.2];
		}
	}
	else
	{
		isDown = FALSE;

		if (longDown == TRUE) // up of longdown and second shortdown
		{
			CGPostKeyboardEvent((CGCharCode)0, [[theirHotKey keyCombo] keyCode], false);
			[self hideHidden];
		}
	}
}

- (void)delayed:(id)sender
{
	//NSLog(isDown ? @"longDown = down:" : @"longDown = up");
	longDown = isDown;

	CGPostKeyboardEvent((CGCharCode)0, [[theirHotKey keyCombo] keyCode], true);
}

- (void)showHidden
{
	ProcessSerialNumber nextProcessToKill = {kNoProcess, kNoProcess};
	ProcessSerialNumber ourPSN;
	OSErr error;

	Boolean processIsUs;

	GetCurrentProcess(&ourPSN);

	do
	{
		error = GetNextProcess(&nextProcessToKill);

		if (error == noErr)
		{
			//First check if its us
			SameProcess(&ourPSN, &nextProcessToKill, &processIsUs);

			if (processIsUs == FALSE)
			{
				if (!IsProcessVisible(&nextProcessToKill))
				{
					[hidden addObject:[NSNumber numberWithUnsignedLong:nextProcessToKill.highLongOfPSN]];
					[hidden addObject:[NSNumber numberWithUnsignedLong:nextProcessToKill.lowLongOfPSN]];

					error = ShowHideProcess(&nextProcessToKill, TRUE);
					if  (error != noErr)
						NSLog(@"ERROR1");
					if (IsProcessVisible(&nextProcessToKill))
						NSLog(@"ERROR2");
				}
			}
		}
	}
	while (error == noErr);
}

- (void)hideHidden
{
	ProcessSerialNumber frontPSN;

	GetFrontProcess (&frontPSN);

	while ([hidden count] > 1)
	{
		unsigned long lowLongOfPSN = [[hidden lastObject] unsignedLongValue];
		[hidden removeLastObject];
		unsigned long highLongOfPSN = [[hidden lastObject] unsignedLongValue];
		[hidden removeLastObject];

		ProcessSerialNumber showPSN = {highLongOfPSN, lowLongOfPSN};
		Boolean result;

		SameProcess(&frontPSN, &showPSN, &result);

		if (!result)
			ShowHideProcess(&showPSN, FALSE);
	}
}

- (void)transform
{
	if ((GetCurrentKeyModifiers() & (optionKey | rightOptionKey)) != 0)
	{
		[[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"invisible"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}

	ProcessSerialNumber psn;

	GetCurrentProcess(&psn);
	TransformProcessType(&psn, kProcessTransformToForegroundApplication);
	SetFrontProcess(&psn);
}

#pragma mark *** IBAction action-methods ***

- (IBAction)hotKeyAction:(id)sender
{
	PTKeyComboPanel *panel = [PTKeyComboPanel sharedPanel];
	int result;
	BOOL isTheir = [(NSButton *)sender tag];

	[panel setKeyCombo:isTheir ? [theirHotKey keyCombo] : [ourHotKey keyCombo]];
	[panel setKeyBindingName:isTheir ? @"Expose HotKey" : @"OmniExpose HotKey"];
	result = [panel runModal];

	if (result == NSOKButton)
	{
		[(isTheir ? theirHotKey : ourHotKey) setKeyCombo:[panel keyCombo]];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[[panel keyCombo] keyCode]] forKey:isTheir ? @"theirHotKeyCode" : @"ourHotKeyCode"];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[[panel keyCombo] modifiers]] forKey:isTheir ? @"theirHotKeyModifiers" : @"ourHotKeyModifiers"];
		[[NSUserDefaults standardUserDefaults] synchronize];

		if (!isTheir)
		{
			[[PTHotKeyCenter sharedCenter] registerHotKey:ourHotKey];
			[ourHotKeyTextField setStringValue:[[ourHotKey keyCombo] description]];
		}
		else
			[theirHotKeyTextField setStringValue:[[theirHotKey keyCombo] description]];
	}
}

- (IBAction)toggleKeyAction:(id)sender
{
	if ([sender state] == NSOnState)
		[[PTHotKeyCenter sharedCenter] registerHotKey:ourHotKey];
	else
		[[PTHotKeyCenter sharedCenter] unregisterHotKey:ourHotKey];
}

#pragma mark *** NSApplication delegate-methods ***

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
	if (([[NSUserDefaults standardUserDefaults] integerForKey:@"firstStart"] == 0))
	{
		[self transform];
		[window makeKeyAndOrderFront:nil];
	}
	return FALSE;
}
@end

int main(int argc, char *argv[])
{
	return NSApplicationMain(argc, (const char **) argv);
}