//
//  FingerMazeAppDelegate.m
//  FingerMaze
//
//  Created by CoreCode on 30.03.10.
/*	Copyright © 2017 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

#import "FingerMazeAppDelegate.h"
#import "FingerMazeViewController.h"
#import "Maze.h"
#import "Preferences.h"


@implementation FingerMazeAppDelegate

@synthesize window, fingerMazeViewController;

CGImageRef door;
CGImageRef duck;
Maze *maze;
Preferences *prefs;
NSArray *levelsNames;
NSArray *levelsCounts;

+ (void)initialize
{
	levelsNames = [NSArray arrayWithObjects:@"Free", @"Braid" , @"Perfect", @"Diagonal", @"Segment", @"Spiral", @"p_aldous", @"p_backtrack", @"p_binary", @"p_ellers", @"p_growing", @"p_hunt", @"p_kruskals", @"p_prims", @"p_recdivision", @"p_sidewinder", @"p_wilsons", @"Randomized", nil];
	levelsCounts = [NSArray arrayWithObjects:@(3), @(10), @(10), @(10) , @(10), @(10), @(10), @(10), @(10), @(10), @(10), @(10), @(10), @(10), @(10), @(10), @(10), @(3), nil];
	
	
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];

	for (NSString *levelName in levelsNames)
		[defaultValues setObject:[NSDictionary dictionary] forKey:levelName];

	[defaultValues setObject:[NSNumber numberWithBool:NO] forKey:@"IntroShown"];
	[defaultValues setObject:[NSNumber numberWithBool:NO] forKey:@"Frozen"];
	[defaultValues setObject:@"" forKey:@"FrozenPath"];
	[defaultValues setObject:[NSNumber numberWithInt:0] forKey:@"FrozenNum"];
	[defaultValues setObject:@"" forKey:@"FrozenLevel"];
    
    [defaultValues setObject:[NSNumber numberWithInt:1] forKey:@"TextureBackgrounds"];
	[defaultValues setObject:[NSNumber numberWithInt:1] forKey:@"ColorBackgrounds"];


	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	srandom((unsigned int)time(NULL));

	prefs = [[Preferences alloc] init];
	
	duck = [UIImage imageNamed:@"ente"].CGImage;
	CGImageRetain(duck);
	door = [UIImage imageNamed:@"door"].CGImage;
	CGImageRetain(door);
	
	window.rootViewController = fingerMazeViewController;


    [window makeKeyAndVisible];


	return YES;
}


- (void)applicationWillTerminate:(UIApplication *)application
{
	[maze freeze];
}
@end


//@implementation UINavigationController (IOS6Rotation)
//
//-(BOOL)shouldAutorotate
//{
//	return NO;
//}
//
//-(NSUInteger)supportedInterfaceOrientations
//{
//	return UIInterfaceOrientationMaskLandscape;
//}
//
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//	return UIInterfaceOrientationLandscapeRight;
//}
//@end
