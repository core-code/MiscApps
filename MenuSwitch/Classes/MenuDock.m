//
//  MenuDock.m
//  MenuDock
//
//  Created by CoreCode on 23.02.06.
/*	Copyright (c) 2006 - 2007 CoreCode
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import "MenuDock.h"
#import "MenuDockView.h"

@implementation MenuDock

- (void)awakeFromNib
{
	statusItem = nil;
	
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
	
	[statusItem setHighlightMode:YES];
	[statusItem setEnabled:YES];
	
	[statusItem setView:[[MenuDockView new] autorelease]];

	[statusItem setTitle:nil];
	
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector: @selector(updateMenuIcon:) name:NSWorkspaceDidTerminateApplicationNotification object:nil];
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector: @selector(updateMenuIcon:) name:NSWorkspaceDidLaunchApplicationNotification object:nil];
}

- (void)updateMenuIcon:(NSNotification *)notification
{
	[(MenuDockView *)[statusItem view] updateSize];
	[[statusItem view] setNeedsDisplay:YES];
}
@end

int main(int argc, char *argv[])
{
	return NSApplicationMain(argc, (const char **) argv);
}