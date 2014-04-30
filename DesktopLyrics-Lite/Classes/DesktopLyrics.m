//
//  DesktopLyrics.m
//  DesktopLyrics
//
//  Created by CoreCode on 26.09.06.
/*	Copyright (c) 2006 - 2012 CoreCode
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import "DesktopLyrics.h"
#import "CrashReporter.h"
#import "LoginItemManager.h"
#import "SGHotKeyCenter.h"


@implementation DesktopLyrics

#pragma mark *** NSObject subclass-methods ***

+ (void)initialize
{
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];

	// shadow values
	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:kTextShadowKey];
	[defaultValues setObject:[NSArchiver archivedDataWithRootObject:[NSColor blackColor]] forKey:kTextShadowColorDataKey];
	[defaultValues setObject:[NSNumber numberWithDouble:0.0] forKey:kTextShadowOffsetHorizontalKey];
	[defaultValues setObject:[NSNumber numberWithDouble:0.0]forKey:kTextShadowOffsetVerticalKey];
	[defaultValues setObject:[NSNumber numberWithDouble:10.0] forKey:kTextShadowBlurRadiusKey];
	// font values
	[defaultValues setObject:[[NSFont boldSystemFontOfSize:12] fontName] forKey:kTextFontNameKey];
	[defaultValues setObject:[NSNumber numberWithDouble:18.0] forKey:kTextFontSizeKey];
	[defaultValues setObject:[NSNumber numberWithDouble:9.0] forKey:kTextFontSizeMinimumKey];
	// color values
	[defaultValues setObject:[NSArchiver archivedDataWithRootObject:[NSColor whiteColor]] forKey:kTextColorDataKey];
	[defaultValues setObject:[NSArchiver archivedDataWithRootObject:[NSColor clearColor]] forKey:kWindowBackgroundColorDataKey];
	// lyrics behaviour values
	[defaultValues setObject:@"#a - #t" forKey:kSonginfoKey];
	[defaultValues setObject:[NSNumber numberWithInt:1] forKey:kAutoTurnKey];
	[defaultValues setObject:[NSNumber numberWithInt:1] forKey:kPrependAlsoWhenEmptyKey];
	[defaultValues setObject:[NSNumber numberWithInt:1] forKey:kPrependSonginfoKey];
	[defaultValues setObject:[NSNumber numberWithInt:0] forKey:kDisplayLyricsWhilePausedKey];
	[defaultValues setObject:[NSNumber numberWithInt:0] forKey:kHideInstrumentalKey];
	// placement values
	[defaultValues setObject:[NSNumber numberWithInt:1] forKey:kSubstractDockKey];
	[defaultValues setObject:[NSNumber numberWithInt:0] forKey:kIndentTopKey];
	[defaultValues setObject:[NSNumber numberWithInt:0] forKey:kIndentBottomKey];
	[defaultValues setObject:[NSNumber numberWithInt:0] forKey:kIndentLeftKey];
	[defaultValues setObject:[NSNumber numberWithInt:0] forKey:kIndentRightKey];
	[defaultValues setObject:[NSNumber numberWithInt:0] forKey:kTextVerticalAlignmentKey];
	[defaultValues setObject:[NSNumber numberWithInt:0] forKey:kTextHorizontalAlignmentKey];
	[defaultValues setObject:[NSNumber numberWithInt:0] forKey:kScreenKey];
	// misc values
	[defaultValues setObject:[NSNumber numberWithInt:0] forKey:kInvisibleKey];
	[defaultValues setObject:[NSNumber numberWithInt:1] forKey:kFirstStartKey];
	[defaultValues setObject:[NSNumber numberWithInt:2] forKey:kUpdatecheckMenuindexKey];
	// ui less options
 	[defaultValues setObject:[NSNumber numberWithInt:0] forKey:kHiddenOptionLyricsOnTopKey];

	// shared code values
 	[defaultValues setObject:[NSDate dateWithString:@"2007-03-12 00:00:00 +0000"] forKey:kLastCrashDateKey];
 	[defaultValues setObject:[NSNumber numberWithInt:0] forKey:kNeverCheckCrashesKey];

	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}

- (id)init
{
	if ((self = [super init]))
	{
		if ((![userDefaults integerForKey:kInvisibleKey]) || ((GetCurrentKeyModifiers() & (optionKey | rightOptionKey)) != 0))
			[self transform];

		[NSColor setIgnoresAlpha:NO];

		screens = [[NSMutableArray alloc] init];
		dwc = [[DesktopWindowController alloc] init];

		[(NSNotificationCenter *)[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateScreens:) name:NSApplicationDidChangeScreenParametersNotification object:nil];
	}

	return self;
}

- (void)dealloc
{
	[dwc release];
	[screens release];

	dwc = nil;
	screens = nil;

	[super dealloc];
}

#pragma mark *** NSNibAwaking protocol-methods ***

- (void)awakeFromNib
{	
	[self updateScreens:nil];

	[fontList removeAllItems];
	NSMutableArray *fonts = [NSMutableArray arrayWithArray:[[[NSFontManager sharedFontManager] availableFonts] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
	[fonts removeObjectsInArray:[NSArray arrayWithObjects:@".Keyboard", @"AquaKana", @"AquaKana-Bold", @"LastResort", @"Symbol", @"Webdings", @"Wingdings-Regular", @"Wingdings2", @"Wingdings3", @"ZapfDingbatsITC", nil]];
	[fontList addItemsWithTitles:fonts];
	[fontList selectItemWithTitle:[userDefaults objectForKey:kTextFontNameKey]];

	if (IsLoginItem())
		[startButton setState:NSOnState];

	[self tabView:nil willSelectTabViewItem:nil];

	if ([userDefaults integerForKey:kFirstStartKey])
	{
		[NSApp activateIgnoringOtherApps:YES];
		NSRunAlertPanel(@"DesktopLyrics", NSLocalizedString(@"Welcome to DesktopLyrics. This seems to be the first time you start DesktopLyrics. The preferences-window will be opened.", nil), NSLocalizedString(@"OK", nil), nil, nil);
		[prefsPanel makeKeyAndOrderFront:self];
		[userDefaults setInteger:0 forKey:kFirstStartKey];
	}

	CheckAndReportCrashes(@"crashreports@corecode.at", [NSArray arrayWithObjects:@"[Desktop", @"[iTunes", @"[SU", @"LoginItem", @"[NSException", @"uncaught exception", nil]);


	SGKeyCombo *keyCombo;

	keyCombo = [[[SGKeyCombo alloc] initWithPlistRepresentation:[userDefaults objectForKey:kHotKeyToggleVisibilityCombo]] autorelease];
	hotKeyToggleVisibility = [[SGHotKey alloc] initWithIdentifier:kHotKeyToggleVisibilityCombo keyCombo:keyCombo target:self action:@selector(hotKeyToggleVisibilityPressed:)];
	[[SGHotKeyCenter sharedCenter] registerHotKey:hotKeyToggleVisibility];
	[hotKeyToggleVisibilityControl setKeyCombo:SRMakeKeyCombo(hotKeyToggleVisibility.keyCombo.keyCode, [hotKeyToggleVisibilityControl carbonToCocoaFlags:hotKeyToggleVisibility.keyCombo.modifiers])];

	keyCombo = [[[SGKeyCombo alloc] initWithPlistRepresentation:[userDefaults objectForKey:kHotKeyNextPageCombo]] autorelease];
	hotKeyNextPage = [[SGHotKey alloc] initWithIdentifier:kHotKeyNextPageCombo keyCombo:keyCombo target:self action:@selector(hotKeyNextPagePressed:)];
	[[SGHotKeyCenter sharedCenter] registerHotKey:hotKeyNextPage];
	[hotKeyNextPageControl setKeyCombo:SRMakeKeyCombo(hotKeyNextPage.keyCombo.keyCode, [hotKeyNextPageControl carbonToCocoaFlags:hotKeyNextPage.keyCombo.modifiers])];

	keyCombo = [[[SGKeyCombo alloc] initWithPlistRepresentation:[userDefaults objectForKey:kHotKeyPrevPageCombo]] autorelease];
	hotKeyPrevPage = [[SGHotKey alloc] initWithIdentifier:kHotKeyNextPageCombo keyCombo:keyCombo target:self action:@selector(hotKeyPrevPagePressed:)];
	[[SGHotKeyCenter sharedCenter] registerHotKey:hotKeyPrevPage];
	[hotKeyPrevPageControl setKeyCombo:SRMakeKeyCombo(hotKeyPrevPage.keyCombo.keyCode, [hotKeyPrevPageControl carbonToCocoaFlags:hotKeyPrevPage.keyCombo.modifiers])];
}

#pragma mark *** NSApplication delegate-methods ***

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
	if ([userDefaults integerForKey:kInvisibleKey])
		[self transform];

	return FALSE;
}

#pragma mark *** NSTabView delegate-methods ***

- (void)tabView:(NSTabView *)tabView willSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	NSRect prefFrame = [prefsPanel frame];
	float prefHeight = prefFrame.size.height;
	float prefX = prefFrame.origin.x;
	float prefY = prefFrame.origin.y;

	if ([tabView indexOfTabViewItem:tabViewItem] == 0)
		[prefsPanel setFrame:NSMakeRect(prefX, prefY + (prefHeight - 360), 375, 360) display:YES animate:YES];
	else if ([tabView indexOfTabViewItem:tabViewItem] == 1)
		[prefsPanel setFrame:NSMakeRect(prefX, prefY + (prefHeight - 406), 375, 406) display:YES animate:YES];
	else if ([tabView indexOfTabViewItem:tabViewItem] == 2)
		[prefsPanel setFrame:NSMakeRect(prefX, prefY + (prefHeight - 488), 375, 488) display:YES animate:YES];
	else
		[prefsPanel setFrame:NSMakeRect(prefX, prefY + (prefHeight - 320), 375, 320) display:YES animate:YES];
}

#pragma mark *** NSNotificationCenter observer-methods ***

- (void)updateScreens:(id)sender
{
	NSArray			*allScreens = [NSScreen screens];
	NSScreen		*currentScreen;
	BOOL			added = NO;

	[screens removeAllObjects];
	while ([screenList numberOfItems] > 2)
		[screenList removeItemAtIndex:[screenList numberOfItems] - 1];


	for (currentScreen in allScreens)
	{
		NSNumber *num = [[currentScreen deviceDescription] objectForKey:@"NSScreenNumber"];

		if (num)
		{
			[screens addObject:num];
			[screenList addItemWithTitle:[NSString stringWithFormat:@"%@ #%i (%i x %i)", NSLocalizedString(@"Screen", nil), (int)[screenList numberOfItems] - 2, (uint16_t)[currentScreen frame].size.width, (uint16_t)[currentScreen frame].size.height]];


			if ([num isEqualToNumber:[userDefaults objectForKey:kScreenKey]])
			{
				[screenList selectItemAtIndex:[screenList numberOfItems] - 1];
				added = YES;
			}
		}
	}

	if ((added == NO) && [userDefaults integerForKey:kScreenKey] && [userDefaults objectForKey:kScreenKey])
	{
		[screenList addItemWithTitle:[NSString stringWithFormat:@"%@ #%i", NSLocalizedString(@"Unavailable Screen", nil), (uint16_t)[userDefaults integerForKey:kScreenKey]]];
		[screens addObject:[userDefaults objectForKey:kScreenKey]];
	}

	if (sender != nil)
		[dwc updateWindow:sender];
}

#pragma mark *** IBAction action-methods ***

- (IBAction)updateWindow:(id)sender
{
	[dwc updateWindow:sender];
	[userDefaults synchronize];
}

- (IBAction)updateAppearance:(id)sender
{
	[dwc updateAppearance:sender];
	[userDefaults synchronize];
}

- (IBAction)update:(id)sender
{
	[dwc forceUpdate];
	[userDefaults synchronize];
}

- (IBAction)updatecheckAction:(id)sender
{
	[self setUpdateCheck:[sender indexOfSelectedItem]];
}

- (IBAction)invisibleAction:(id)sender
{
	if ([(NSButton *)sender state] == NSOnState)
	{
		[userDefaults synchronize];

		[NSApp activateIgnoringOtherApps:YES];
		if (NSRunAlertPanel(@"DesktopLyrics", NSLocalizedString(@"DesktopLyrics needs to be restarted for this option to take effect. Hold down alt (option) during application launch to get the interface back.", nil), NSLocalizedString(@"Restart now", nil), NSLocalizedString(@"Restart later", nil), nil) == NSAlertDefaultReturn)
		{
			NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];

			LSLaunchURLSpec launchSpec;
			launchSpec.appURL = (CFURLRef)url;
			launchSpec.itemURLs = NULL;
			launchSpec.passThruParams = NULL;
			launchSpec.asyncRefCon = NULL;
			launchSpec.launchFlags = kLSLaunchDefaults | kLSLaunchNewInstance;

			OSErr err = LSOpenFromURLSpec(&launchSpec, NULL);
			if (err == noErr)
				[NSApp terminate:nil];
			else
				NSRunAlertPanel(@"DesktopLyrics", NSLocalizedString(@"DesktopLyrics could not restart itself automatically. Please restart it yourself when it is convenient for you.", nil), NSLocalizedString(@"OK", nil), nil, nil);
		}
	}
}

- (IBAction)startAction:(id)sender
{
	if ([(NSButton *)sender state] == NSOnState)
		AddLoginItem();
	else
		RemoveLoginItem();
}

- (IBAction)selectScreenAction:(id)sender
{
	NSNumber *newScreenNumber;

	if ([sender indexOfSelectedItem] == 0)
		newScreenNumber = [NSNumber numberWithInt:0];
	else
		newScreenNumber = [screens objectAtIndex:[sender indexOfSelectedItem] - 2];

	if (![newScreenNumber isEqualToNumber:[userDefaults objectForKey:kScreenKey]])
	{
		[userDefaults setObject:newScreenNumber forKey:kScreenKey];
		[dwc updateWindow:sender];
	}
}


#pragma mark *** ShortcutRecorder delegate-methods ***

- (BOOL)shortcutRecorder:(SRRecorderControl *)recorder isKeyCode:(NSInteger)keyCode andFlagsTaken:(NSUInteger)flags reason:(NSString **)aReason
{
	return NO;
}

- (void)shortcutRecorder:(SRRecorderControl *)recorder keyComboDidChange:(KeyCombo)newKeyCombo
{
    SGKeyCombo *keyCombo = [SGKeyCombo keyComboWithKeyCode:[recorder keyCombo].code modifiers:[recorder cocoaToCarbonFlags:[recorder keyCombo].flags]];

	if (recorder == hotKeyToggleVisibilityControl)
	{
		[hotKeyToggleVisibility setKeyCombo:keyCombo];
        [[SGHotKeyCenter sharedCenter] registerHotKey:hotKeyToggleVisibility];
		[userDefaults setObject:[keyCombo plistRepresentation] forKey:kHotKeyToggleVisibilityCombo];
	}
	else if (recorder == hotKeyNextPageControl)
	{
		[hotKeyNextPage setKeyCombo:keyCombo];
        [[SGHotKeyCenter sharedCenter] registerHotKey:hotKeyNextPage];
		[userDefaults setObject:[keyCombo plistRepresentation] forKey:kHotKeyNextPageCombo];
	}
	else if (recorder == hotKeyPrevPageControl)
	{
		[hotKeyPrevPage setKeyCombo:keyCombo];
        [[SGHotKeyCenter sharedCenter] registerHotKey:hotKeyPrevPage];
		[userDefaults setObject:[keyCombo plistRepresentation] forKey:kHotKeyPrevPageCombo];
	}

	[userDefaults synchronize];
}

#pragma mark *** DesktopLyrics methods ***

- (void)transform
{
	if ((GetCurrentKeyModifiers() & (optionKey | rightOptionKey)) != 0)
	{
		[userDefaults setInteger:0 forKey:kInvisibleKey];
		[userDefaults synchronize];
	}

	ProcessSerialNumber psn;

	GetCurrentProcess(&psn);
	TransformProcessType(&psn, kProcessTransformToForegroundApplication);
	SetFrontProcess(&psn);
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	[self updateWindow:aNotification];
}

- (void)hotKeyToggleVisibilityPressed:(id)sender
{
	[dwc toggleVisibility];
}

- (void)hotKeyNextPagePressed:(id)sender
{
	[dwc nextPageClicked:sender];
}

- (void)hotKeyPrevPagePressed:(id)sender
{
	[dwc prevPageClicked:sender];
}
@end
