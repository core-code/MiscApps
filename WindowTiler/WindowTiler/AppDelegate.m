//
//  AppDelegate.m
//  WindowTiler
//
//  Copyright © 2015 corecode. All rights reserved.
//

#import "AppDelegate.h"
#import <ScriptingBridge/ScriptingBridge.h>

@interface GenericWindow : SBObject

@property NSRect bounds;  // The bounding rectangle of the window.


@end


@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSLog(@"WindowTiler running");
	sleep(1);
	SBApplication *app = [SBApplication applicationWithBundleIdentifier:[NSWorkspace sharedWorkspace].frontmostApplication.bundleIdentifier];

	assert(app);

	NSString *str1 = [NSString stringWithFormat:@"{{0, 0}, {%i, %i}}", (int)[NSScreen mainScreen].frame.size.width, (int)[NSScreen mainScreen].frame.size.height];
	NSString *str21 = [NSString stringWithFormat:@"{{0, 0}, {%i, %i}}", (int)[NSScreen mainScreen].frame.size.width/2, (int)[NSScreen mainScreen].frame.size.height];
	NSString *str22 = [NSString stringWithFormat:@"{{%i, 0}, {%i, %i}}", (int)[NSScreen mainScreen].frame.size.width/2, (int)[NSScreen mainScreen].frame.size.width/2, (int)[NSScreen mainScreen].frame.size.height];
	NSString *str31 = [NSString stringWithFormat:@"{{0, 0}, {%i, %i}}", (int)[NSScreen mainScreen].frame.size.width/2, (int)[NSScreen mainScreen].frame.size.height/2];
	NSString *str32 = [NSString stringWithFormat:@"{{%i, 0}, {%i, %i}}", (int)[NSScreen mainScreen].frame.size.width/2, (int)[NSScreen mainScreen].frame.size.width/2, (int)[NSScreen mainScreen].frame.size.height/2];
	NSString *str33 = [NSString stringWithFormat:@"{{0, %i}, {%i, %i}}", (int)[NSScreen mainScreen].frame.size.height/2, (int)[NSScreen mainScreen].frame.size.width, (int)[NSScreen mainScreen].frame.size.height/2];

	NSString *str41 = [NSString stringWithFormat:@"{{%i, %i}, {%i, %i}}", 0, 0, (int)[NSScreen mainScreen].frame.size.width/2, (int)[NSScreen mainScreen].frame.size.height/2];
	NSString *str42 = [NSString stringWithFormat:@"{{%i, %i}, {%i, %i}}", (int)[NSScreen mainScreen].frame.size.width/2, 0, (int)[NSScreen mainScreen].frame.size.width/2, (int)[NSScreen mainScreen].frame.size.height/2];
	NSString *str43 = [NSString stringWithFormat:@"{{%i, %i}, {%i, %i}}", 0, (int)[NSScreen mainScreen].frame.size.height/2, (int)[NSScreen mainScreen].frame.size.width/2, (int)[NSScreen mainScreen].frame.size.height/2];
	NSString *str44 = [NSString stringWithFormat:@"{{%i, %i}, {%i, %i}}", (int)[NSScreen mainScreen].frame.size.width/2, (int)[NSScreen mainScreen].frame.size.height/2, (int)[NSScreen mainScreen].frame.size.width/2, (int)[NSScreen mainScreen].frame.size.height/2];


	NSDictionary *values = @{@(1) : @[str1], @(2) : @[str21, str22], @(3) : @[str31, str32, str33], @(4) : @[str41, str42, str43, str44]};


	if ([app respondsToSelector:@selector(windows)])
	{
		SBElementArray *windows = [app performSelector:@selector(windows) withObject:nil];

		NSArray *strings = values[@(windows.count)];
		int i = 0;

		for (GenericWindow *window in windows)
		{
			if ([window respondsToSelector:@selector(bounds)] && [window respondsToSelector:@selector(setBounds:)])
			{
				window.bounds = NSRectFromString(strings[i]);
				NSLog(@"WindowTiler: using rect %@", strings[i]);

				i++;
			}
			else
				NSLog(@"WindowTiler: no bounds");
		}
	}
	else
		NSLog(@"WindowTiler: no windows");


	[[NSWorkspace sharedWorkspace].frontmostApplication activateWithOptions:NSApplicationActivateAllWindows|NSApplicationActivateIgnoringOtherApps];

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		exit(1);
	});
}


@end


int main(int argc, const char * argv[]) {
	return NSApplicationMain(argc, argv);
}
