//
//  AppDelegate.m
//  WindowTiler
//
/*	Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
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

	NSString *str61 = [NSString stringWithFormat:@"{{%i, %i}, {%i, %i}}", 0, 0, (int)[NSScreen mainScreen].frame.size.width/3, (int)[NSScreen mainScreen].frame.size.height/2];
	NSString *str62 = [NSString stringWithFormat:@"{{%i, %i}, {%i, %i}}", (int)[NSScreen mainScreen].frame.size.width/3, 0, (int)[NSScreen mainScreen].frame.size.width/3, (int)[NSScreen mainScreen].frame.size.height/2];
	NSString *str63 = [NSString stringWithFormat:@"{{%i, %i}, {%i, %i}}", (int)[NSScreen mainScreen].frame.size.width*2/3, 0, (int)[NSScreen mainScreen].frame.size.width/3, (int)[NSScreen mainScreen].frame.size.height/2];
	NSString *str64 = [NSString stringWithFormat:@"{{%i, %i}, {%i, %i}}", 0, (int)[NSScreen mainScreen].frame.size.height/2, (int)[NSScreen mainScreen].frame.size.width/3, (int)[NSScreen mainScreen].frame.size.height/2];
	NSString *str65 = [NSString stringWithFormat:@"{{%i, %i}, {%i, %i}}", (int)[NSScreen mainScreen].frame.size.width/3, (int)[NSScreen mainScreen].frame.size.height/2, (int)[NSScreen mainScreen].frame.size.width/3, (int)[NSScreen mainScreen].frame.size.height/2];
	NSString *str66 = [NSString stringWithFormat:@"{{%i, %i}, {%i, %i}}", (int)[NSScreen mainScreen].frame.size.width*2/3, (int)[NSScreen mainScreen].frame.size.height/2, (int)[NSScreen mainScreen].frame.size.width/3, (int)[NSScreen mainScreen].frame.size.height/2];


	NSDictionary *values = @{@(1) : @[str1], @(2) : @[str21, str22], @(3) : @[str31, str32, str33], @(4) : @[str41, str42, str43, str44], @(6) : @[str61, str62, str63, str64, str65, str66]};


	if ([app respondsToSelector:@selector(windows)])
	{
		SBElementArray *windows = [app performSelector:@selector(windows) withObject:nil];

		NSArray *strings = values[@(windows.count)];
		if (!strings)
		{
			NSLog(@"WindowTiler: wrong window count %lu", (unsigned long)windows.count);
			return;
		}

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
