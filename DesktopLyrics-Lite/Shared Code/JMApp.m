//
//  JMApp.m
//
//  Created by CoreCode on 11.08.10.
/*	Copyright (c) 2010 - 2012 CoreCode
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import "JMApp.h"

#import "StartFromDiskImageHandler.h"
#import "ApplicationMovedHandler.h"
#import "HostInformation.h"

NSUserDefaults *userDefaults;
SUUpdater *updater;

@implementation JMApp

- (id)init
{
	if ((self = [super init]))
	{
		[StartFromDiskImageHandler checkAndHandleDiskImageStart];

		[ApplicationMovedHandler startMoveObservation];

		userDefaults = [NSUserDefaults standardUserDefaults];


		updater = [[SUUpdater alloc] init];
		[updater setDelegate:self];
		[self setUpdateCheck:[userDefaults integerForKey:kUpdatecheckMenuindexKey]];
	}

	return self;
}

#pragma mark *** IBAction action-methods ***

- (IBAction)urlAction:(id)sender
{
	NSString *name = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];

	NSString *path = @"";

	switch ([sender tag])
	{
		case -1:
			path = [NSString stringWithFormat:@"mailto:feedback@corecode.at?subject=%@ Beta Signup&body=hello\ni would like to help development by testing beta releases. i am a knowledgable poweruser and will provide detailed bug- and regression reports.\nbye\n\nP.S: Hardware: %@ Software: %@", name, [HostInformation machineType], [[NSProcessInfo processInfo] operatingSystemVersionString]];
			break;
		case 0:
			path = [NSString stringWithFormat:@"%@%@%@%@_%@", @"https://www.paypal.com/xclick/business=donations%40corecode.at&item_name=", name, @"+Development&no_shipping=1&cn=Suggestions&tax=0&currency_code=EUR&lc=us&locale.x=", [(NSLocale *)[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode], [(NSLocale *)[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]];
			break;
		case 1:
			path = [NSString stringWithFormat:@"mailto:feedback@corecode.at?subject=%@ Feedback", name];
			break;
		case 2:
			path = [NSString stringWithFormat:@"https://www.corecode.at/%@/", [name lowercaseString]];
			break;
		case 3:
			path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Read Me.rtf"];
			break;
		case 4:
			path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"FAQ.rtf"];
			break;
		case 5:
			path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"History.rtf"];
			break;
	}

	if ([sender tag] < 3)
	{
		NSURL *url;

		if (labs([sender tag]) == 1)
			url = [NSURL URLWithString:[(NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)path, NULL, NULL, kCFStringEncodingUTF8) autorelease]];
		else
			url = [NSURL URLWithString:path];

		if (![[NSWorkspace sharedWorkspace] openURL:url])
			asl_NSLog(ASL_LEVEL_WARNING, @"Warning: [[NSWorkspace sharedWorkspace] openURL:url] failed");
	}
	else
	{
		if (![[NSWorkspace sharedWorkspace] openFile:path])
			asl_NSLog(ASL_LEVEL_WARNING, @"Warning: [[NSWorkspace sharedWorkspace] openFile:path] failed");
	}
}


- (IBAction)checkForUpdatesAction:(id)sender
{
	if (updater)
		[updater checkForUpdates:self];
	else
		asl_NSLog(ASL_LEVEL_WARNING, @"Warning: the sparkle updater is not available!");
}

#pragma mark *** SUUpdater delegate-methods ***

- (BOOL)updaterShouldPromptForPermissionToCheckForUpdates:(SUUpdater *)bundle
{
	return NO;
}

#pragma mark *** JMApp methods ***

- (void)setUpdateCheck:(NSInteger)intervalIndex
{
	NSTimeInterval newInterval = 0;

	if (intervalIndex == 0)
		newInterval = 86400;
	else if (intervalIndex == 1)
		newInterval = 2 * 86400;
	else if (intervalIndex == 2)
		newInterval = 7 * 86400;
	else if (intervalIndex == 3)
		newInterval = 14 * 86400;
	else if (intervalIndex == 4)
		newInterval = 28 * 86400;
	//else if (intervalIndex == 6)
	//	newInterval = 0;

	if (newInterval >= 0.1)
	{
		[updater setAutomaticallyChecksForUpdates:TRUE];
		[updater setUpdateCheckInterval:newInterval];
	}
	else
		[updater setAutomaticallyChecksForUpdates:FALSE];
}

@end
