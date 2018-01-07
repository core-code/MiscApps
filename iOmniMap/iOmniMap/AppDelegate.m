//
//  AppDelegate.m
//  iOmniMap
//
//  Created by CoreCode on 21.12.11.
/*	Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

#import "AppDelegate.h"

//@interface AppDelegate ()
//@end

@implementation AppDelegate

//@synthesize window = _window;

+ (void)initialize
{
	[[NSUserDefaults standardUserDefaults] registerDefaults:@{@"OmniMaps" : @[]}];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	cc = [CoreLib new];
	
	[[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:130.0/295.0 green:175.0/295.0 blue:180.0/295.0 alpha:1.0]];


	BOOL haveFullMap = FALSE;
    NSArray *maps = @"OmniMaps".defaultArray;
	
    for (NSDictionary *m in maps)
        if (m[@"fullLatitude"])
            haveFullMap = TRUE;

	if (haveFullMap)
		((UITabBarController *)self.window.rootViewController).selectedIndex = 2;
	else if ([maps count])
		((UITabBarController *)self.window.rootViewController).selectedIndex = 1;
	else
		((UITabBarController *)self.window.rootViewController).selectedIndex = 3;

    return YES;
}
@end

