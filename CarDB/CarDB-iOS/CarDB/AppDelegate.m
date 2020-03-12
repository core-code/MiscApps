//
//  AppDelegate.m
//  CarDB
//
//  Created by CoreCode on 25.04.14.
//  Copyright © 2018 CoreCode Limited. All rights reserved.
//

#import "AppDelegate.h"
#import "MMViewController.h"



@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  	cc = [CoreLib new];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
   MMViewController *vc =  [[MMViewController alloc] init];

	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    return YES;
}
@end

@implementation UINavigationBar (customNav)
- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize newSize = CGSizeMake(self.frame.size.width,40);
    return newSize;
}
@end
