//
//  QTPresenter.m
//  QTPresenter
//
//  Created by CoreCode on 09.01.10.
/*	Copyright (c) 2016 CoreCode Limited
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "QTPresenter.h"

@implementation QTPresenter

@synthesize window;

- (void)appTerminated:(NSNotification *)notification
{
	if ([[[notification userInfo] objectForKey:@"NSApplicationName"] isEqualToString:@"QuickTime Player"])
		[NSApp terminate:self];
}

- (void)moveWindowAndPresent:(NSTimer *)timer
{
	NSRect rect = [[[NSScreen screens] lastObject] frame];
	
	NSDictionary			*errorDict;
	NSAppleEventDescriptor 	*returnDescriptor;
	NSAppleScript			*scriptObject = [[NSAppleScript alloc] initWithSource: [NSString stringWithFormat:@"to |set position| for w to {x, y}\n	tell w to if exists then\n		set {l, t, r, b} to bounds\n		set bounds to {x, y, x + r - l, y + b - t}\n	end if\nend |set position|\n\nactivate application \"QuickTime Player\"\n|set position| for window 1 of application \"QuickTime Player\" to {%i, %i}\n", (int)rect.origin.x, (int)rect.origin.y]];
	
	
	returnDescriptor = [scriptObject executeAndReturnError: &errorDict];
	[scriptObject release];
	
	if (![returnDescriptor descriptorType])
		NSLog(@"Error: AppleScriptError: %@", [errorDict objectForKey: @"NSAppleScriptErrorMessage"]);
	

    QuickTimePlayerXApplication *qt = [SBApplication applicationWithBundleIdentifier:@"com.apple.QuickTimePlayerX"];

    [[[qt documents] objectAtIndex:0] present];
	
	[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(progressTimer:) userInfo:NULL repeats:YES];	
}

- (void)progressTimer:(NSTimer *)timer
{
    QuickTimePlayerXApplication *qt = [SBApplication applicationWithBundleIdentifier:@"com.apple.QuickTimePlayerX"];

    if (![qt documents].count)
        return;
    
	double ct = [[[qt documents] objectAtIndex:0] currentTime], d =  [[[qt documents] objectAtIndex:0] duration];
	
		
	[infoText setStringValue:[NSString stringWithFormat:@"%i:%i:%i / %i:%i:%i", (int)ct / 3600, (int)(ct / 60) % 60, (int)ct % 60, (int)d / 3600, (int)(d / 60) % 60, (int)d % 60, nil]];
}

#pragma mark *** NSApplication delegate-methods ***

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self 
														   selector:@selector(appTerminated:) 
															   name:NSWorkspaceDidTerminateApplicationNotification 
															 object:nil];
	
	QuickTimePlayerXApplication *qt = [SBApplication applicationWithBundleIdentifier:@"com.apple.QuickTimePlayerX"];
	
	[qt open:filename];
	
	[(QuickTimePlayerXDocument *)[[qt documents] objectAtIndex:0] play];
	
	[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(moveWindowAndPresent:) userInfo:NULL repeats:NO];
	
	return YES;
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(progressTimer:) userInfo:NULL repeats:YES];
}
@end


int main(int argc, char *argv[])
{
	return NSApplicationMain(argc, (const char **) argv);
}
