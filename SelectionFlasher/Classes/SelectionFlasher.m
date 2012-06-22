//
//  SelectionFlasher.m
//  SelectionFlasher
//
//  Created by CoreCode on 22.10.07.
/*	Copyright (c) 2006 - 2007 CoreCode
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import "SelectionFlasher.h"

@implementation SelectionFlasher

+ (void)initialize
{
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	
	[defaultValues setObject:[NSNumber numberWithInt:1] forKey:@"firstStart"];
	[defaultValues setObject:[NSNumber numberWithInt:100] forKey:@"hotKeyCode"]; 	// 100 = F8
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
						[[PTKeyCombo keyComboWithKeyCode: [[NSUserDefaults standardUserDefaults] integerForKey:@"hotKeyCode"]
											   modifiers: [[NSUserDefaults standardUserDefaults] integerForKey:@"hotKeyModifiers"]] retain]];			
	[hotKey setTarget: self];
	[hotKey setAction: @selector(hotKey:kind:)];
	
	[hotKeyTextField setStringValue:[[hotKey keyCombo] description]];
	
	[[PTHotKeyCenter sharedCenter] registerHotKey:hotKey];
}

- (IBAction)hotKey:(id)sender kind:(NSString *)kind
{			
	if ([kind isEqualToString:@"Down"])
	{
		int i;
		CFStringRef prev = (CFStringRef) CFPreferencesCopyValue((CFStringRef)@"AppleHighlightColor", (CFStringRef) @".GlobalPreferences", kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
		
		srandom(time(NULL));
		
		for (i = 0; i <= 10; i++)
		{
			float rand1 = RandomFloatBetween(0.0, 1.0);
			float rand2 = RandomFloatBetween(0.0, 1.0);
			float rand3 = RandomFloatBetween(0.0, 1.0);
			
			NSString *randomColor = [NSString stringWithFormat:@"%f %f %f", rand1, rand2, rand3];
			
			CFPreferencesSetValue((CFStringRef)@"AppleHighlightColor", randomColor, (CFStringRef) @".GlobalPreferences", kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
			CFPreferencesSetValue((CFStringRef)@"AppleOtherHighlightColor", randomColor, (CFStringRef) @".GlobalPreferences", kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
			CFPreferencesSynchronize((CFStringRef) @".GlobalPreferences", kCFPreferencesCurrentUser, kCFPreferencesAnyHost); 		
			[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"AppleColorPreferencesChangedNotification" object:nil];	
			usleep(100000);
		}
		
		CFPreferencesSetValue((CFStringRef)@"AppleHighlightColor", prev, (CFStringRef) @".GlobalPreferences", kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
		CFPreferencesSynchronize((CFStringRef) @".GlobalPreferences", kCFPreferencesCurrentUser, kCFPreferencesAnyHost); 		
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"AppleColorPreferencesChangedNotification" object:nil];	
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
	
	[panel setKeyCombo:[hotKey keyCombo]];
	[panel setKeyBindingName:@"SelectionFlasher HotKey"];
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