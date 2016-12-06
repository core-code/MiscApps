//
//  WindowMover.m
//  WindowMover
//
//  Created by CoreCode on 09.09.09.
/*	Copyright (c) 2016 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import "WindowMover.h"

@implementation WindowMover

+ (void)initialize
{
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];

	[defaultValues setObject:[NSNumber numberWithInt:1] forKey:@"firstStart"];
	[defaultValues setObject:[NSNumber numberWithInt:122] forKey:@"hotKeyCode"]; 	// 122 = F1
	[defaultValues setObject:[NSNumber numberWithInt:NSCommandKeyMask] forKey:@"hotKeyModifiers"];

	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}

- (void)awakeFromNib
{
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


	hotKey = [[PTHotKey alloc] initWithIdentifier: @"hotKey" keyCombo:
						[PTKeyCombo keyComboWithKeyCode:[[NSUserDefaults standardUserDefaults] integerForKey:@"hotKeyCode"]
											  modifiers:[[NSUserDefaults standardUserDefaults] integerForKey:@"hotKeyModifiers"]]];
	[hotKey setTarget:self];
	[hotKey setAction:@selector(hotKey:kind:)];

	[hotKeyTextField setStringValue:[[hotKey keyCombo] description]];

	[[PTHotKeyCenter sharedCenter] registerHotKey:hotKey];
}

- (IBAction)hotKey:(id)sender kind:(NSString *)kind
{
	if ([kind isEqualToString:@"Down"])
	{
		Point p;
		GetGlobalMouse(&p);

		NSDictionary			*errorDict;
		NSAppleEventDescriptor 	*returnDescriptor;
		NSAppleScript			*scriptObject = [[NSAppleScript alloc] initWithSource: [NSString stringWithFormat:@"to |set position| for w to {x, y}\n	tell w to if exists then\n		set {l, t, r, b} to bounds\n		set bounds to {x, y, x + r - l, y + b - t}\n	end if\nend |set position|\n\ntell application \"System Events\"\n	set every_process to every process\n	repeat with i from 1 to the count of every_process\n		set a_process to item i of every_process\n		if frontmost of a_process is true then\n			set front_process to a_process\n		end if\n	end repeat\n	\nend tell\n\nactivate application (get name of front_process)\n|set position| for window 1 of application (get name of front_process) to {%u, %u}\n", p.h, p.v]];



		returnDescriptor = [scriptObject executeAndReturnError: &errorDict];
		[scriptObject release];

		if (![returnDescriptor descriptorType])
			NSLog(@"Error: AppleScriptError: %@", [errorDict objectForKey: @"NSAppleScriptErrorMessage"]);
	}
}

- (void)transform
{
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

	[panel setKeyCombo:[hotKey keyCombo]];
	[panel setKeyBindingName:@"WindowMover HotKey"];
	result = [panel runModal];

	if (result == NSOKButton)
	{
		[hotKey setKeyCombo:[panel keyCombo]];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[[panel keyCombo] keyCode]] forKey:@"hotKeyCode"];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[[panel keyCombo] modifiers]] forKey:@"hotKeyModifiers"];
		[[NSUserDefaults standardUserDefaults] synchronize];

		[[PTHotKeyCenter sharedCenter] registerHotKey:hotKey];
		[hotKeyTextField setStringValue:[[hotKey keyCombo] description]];
	}
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