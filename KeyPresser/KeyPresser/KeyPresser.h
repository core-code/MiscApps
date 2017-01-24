//
//  KeyPresser.h
//  KeyPresser
//
//  Created by CoreCode on 22.09.05.
/*	Copyright © 2017 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import "PTHotKey.h"
#import "PTHotKeyCenter.h"
#import "PTKeyComboPanel.h"

@interface KeyPresser : NSObject
{
	IBOutlet NSPopUpButton *applications;
	IBOutlet NSTextField *interval;
	IBOutlet NSTextField *keytext;
	IBOutlet NSWindow *window;
	IBOutlet NSWindow *logsheet;
	IBOutlet NSTextView *logtext;
	IBOutlet NSButton *start;
	IBOutlet NSButton *set;
	
	NSTimer *timer;
	NSTimer *logtimer;
	int times;
	PTHotKey *hotKey;
	
	
	AXUIElementRef app;
}

- (IBAction)setKey:(id)sender;
- (IBAction)start:(id)sender;
- (IBAction)stopButtonAction:(id)sender;
@end