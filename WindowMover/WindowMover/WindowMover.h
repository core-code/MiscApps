//
//  WindowMover.h
//  WindowMover
//
//  Created by CoreCode on 09.09.09.
/*	Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import "PTHotKey.h"
#import "PTHotKeyCenter.h"
#import "PTKeyComboPanel.h"
#include <unistd.h>

@interface WindowMover : NSObject
{
	IBOutlet NSWindow *window;
	IBOutlet NSTextField *hotKeyTextField;
	PTHotKey *hotKey;
}

- (IBAction)hotKeyAction:(id)sender;
- (void)transform;
@end

static __inline__ float RandomFloatBetween(float a, float b)
{
	return a + (b - a) * ((float)random() / (float) LONG_MAX);
}