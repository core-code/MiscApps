//
//  LaunchAppDelegate.m
//  LaunchHelper
//
//  Created by CoreCode on 12.04.12.
//  Copyright (c) 2012 CoreCode. All rights reserved.
//

#import "LaunchAppDelegate.h"

static NSString *restartWithPID;

@implementation LaunchAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{	
	NSString *appPath = [[[[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent] stringByDeletingLastPathComponent] stringByDeletingLastPathComponent] stringByDeletingLastPathComponent];
	
	if (restartWithPID)
	{
		while ([NSRunningApplication runningApplicationWithProcessIdentifier:[restartWithPID intValue]])
		{		
			[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
		}
	}
		
	[[NSWorkspace sharedWorkspace] launchApplication:appPath];


	[NSApp terminate:nil];
}

@end

int main(int argc, char *argv[])
{
	if (argc >= 2)
    {
        restartWithPID = [NSString stringWithUTF8String:argv[1]];

#if ! __has_feature(objc_arc)
		[restartWithPID retain];
#endif
    }
	
	return NSApplicationMain(argc, (const char **)argv);
}
