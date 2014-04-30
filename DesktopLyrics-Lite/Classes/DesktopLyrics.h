//
//  DesktopLyrics.h
//  DesktopLyrics
//
//  Created by CoreCode on 26.09.06.
/*	Copyright (c) 2006 - 2012 CoreCode
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import "DesktopWindowController.h"
#import "JMApp.h"
#import "SGHotKey.h"


@interface DesktopLyrics : JMApp
{
	DesktopWindowController		*dwc;
	NSMutableArray				*screens;
	IBOutlet NSButton			*startButton;
	IBOutlet NSPanel			*prefsPanel;
	IBOutlet NSPopUpButton		*fontList;
	IBOutlet NSPopUpButton		*screenList;
	IBOutlet SRRecorderControl	*hotKeyToggleVisibilityControl, *hotKeyNextPageControl, *hotKeyPrevPageControl;

	SGHotKey					*hotKeyToggleVisibility, *hotKeyNextPage, *hotKeyPrevPage;
}

// *** NSTabView delegate-methods ***
- (void)tabView:(NSTabView *)tabView willSelectTabViewItem:(NSTabViewItem *)tabViewItem;

// *** NSNotificationCenter observer-methods ***
- (void)updateScreens:(id)sender;

// *** IBAction action-methods ***
- (IBAction)updateWindow:(id)sender;
- (IBAction)updateAppearance:(id)sender;
- (IBAction)update:(id)sender;
- (IBAction)updatecheckAction:(id)sender;
- (IBAction)invisibleAction:(id)sender;
- (IBAction)startAction:(id)sender;
- (IBAction)selectScreenAction:(id)sender;

// *** DesktopLyrics methods ***
- (void)transform;

@end
