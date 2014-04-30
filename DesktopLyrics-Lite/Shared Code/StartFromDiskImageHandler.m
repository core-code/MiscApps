//
//  StartFromDiskImageHandler.m
//
//  Created by Julian Mayer on 25.07.10.
/*	Copyright (c) 2010 - 2012 A. Julian Mayer
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "StartFromDiskImageHandler.h"


@implementation StartFromDiskImageHandler

+ (void)checkAndHandleDiskImageStart
{
	NSString *appname = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];

	if ([[[NSBundle mainBundle] bundlePath] hasPrefix:[NSString stringWithFormat:@"/Volumes/%@/", appname]])
	{
		[NSApp activateIgnoringOtherApps:YES];
		if (NSRunAlertPanel(appname,
							[NSString stringWithFormat:NSLocalizedString(@"%@ can't operate properly when started from the disk image.", nil), appname],
							NSLocalizedString(@"Move to the Applications folder", nil),
							NSLocalizedString(@"Quit", nil), nil) == NSOKButton)
		{
			if ([[NSFileManager defaultManager] copyItemAtPath:[NSString stringWithFormat:@"/Volumes/%@/%@/", appname, appname] toPath:[NSString stringWithFormat:@"/Applications/%@/", appname] error:NULL])
			{
				system([[NSString stringWithFormat:@"(sleep 10;hdiutil unmount /Volumes/%@/)&", appname] UTF8String]);

				NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"/Applications/%@/%@.app", appname, appname]];
				LSLaunchURLSpec launchSpec;
				launchSpec.appURL = (CFURLRef)url;
				launchSpec.itemURLs = NULL;
				launchSpec.passThruParams = NULL;
				launchSpec.asyncRefCon = NULL;
				launchSpec.launchFlags = kLSLaunchDefaults | kLSLaunchNewInstance;


				OSErr err = LSOpenFromURLSpec(&launchSpec, NULL);
				if (err == noErr)
					[NSApp terminate:nil];
				else
				{
					[NSApp activateIgnoringOtherApps:YES];
					NSRunAlertPanel(appname,
									[NSString stringWithFormat:NSLocalizedString(@"%@ has successfully copied itself to the Applications folder, please start it from there.", nil), appname],
									NSLocalizedString(@"Quit", nil), nil, nil);
					[NSApp terminate:nil];
				}
			}
			else
			{
				[NSApp activateIgnoringOtherApps:YES];
				NSRunAlertPanel(appname,
								[NSString stringWithFormat:NSLocalizedString(@"%@ could not copy itself to the Applications folder, most likely an old copy exists there already. Please do so yourself.", nil), appname],
								NSLocalizedString(@"Quit", nil), nil, nil);
				[NSApp terminate:nil];
			}
		}
		else
			[NSApp terminate:self];
	}
}
@end