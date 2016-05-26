//
//  StartFromDiskImageHandler.m
//
//  Created by CoreCode on 25.07.10.
/*	Copyright (c) 2010 - 2012 CoreCode
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "ApplicationMovedHandler.h"
#import "Sparkle/SUUpdater.h"

extern SUUpdater *updater;
int bundleFileDescriptor;

void MoveCallbackFunction(ConstFSEventStreamRef streamRef,
						  void *clientCallBackInfo,
						  size_t numEvents,
						  void *eventPaths,
						  const FSEventStreamEventFlags eventFlags[],
						  const FSEventStreamEventId eventIds[])
{
	//char **paths = eventPaths;

	if (updater && [updater updateInProgress])
		return;


	for (size_t i = 0; i < numEvents; i++)
	{
		if ( eventFlags[i] == kFSEventStreamEventFlagRootChanged)
		{
	     //   printf("Change %llu in %s, flags %lu\n", eventIds[i], paths[i], eventFlags[i]);

			char *newPath = calloc(4096, sizeof(char));

			fcntl(bundleFileDescriptor, F_GETPATH, newPath);

			NSString *appname = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];




			[NSApp activateIgnoringOtherApps:YES];
			NSRunAlertPanel(appname,
							[NSString stringWithFormat:NSLocalizedString(@"%@ has been moved, but applications should never be moved while they are running.", nil), appname],
							[NSString stringWithFormat:NSLocalizedString(@"Restart %@", nil), appname], nil, nil);

		//	printf("new path: %s\n", newPath);

			NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%s", newPath]];
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
								[NSString stringWithFormat:NSLocalizedString(@"%@ could not restart itself. Please do so yourself.", nil), appname],
								NSLocalizedString(@"Quit", nil), nil, nil);
				[NSApp terminate:nil];
			}
		}
	}
}

@implementation ApplicationMovedHandler

+ (void)startMoveObservation
{
	CFStringRef mypath = (CFStringRef)[[NSBundle mainBundle] bundlePath];
	CFArrayRef pathsToWatch = CFArrayCreate(NULL, (const void **)&mypath, 1, NULL);
	void *callbackInfo = NULL;
	FSEventStreamRef stream;
	CFAbsoluteTime latency = 3.0;


	bundleFileDescriptor = open([[[NSBundle mainBundle] bundlePath] UTF8String], O_RDONLY, 0700);
	stream = FSEventStreamCreate(NULL,
								 &MoveCallbackFunction,
								 callbackInfo,
								 pathsToWatch,
								 kFSEventStreamEventIdSinceNow,
								 latency,
								 kFSEventStreamCreateFlagWatchRoot
								 );
    CFRelease(pathsToWatch);
	FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);

	FSEventStreamStart(stream);
}
@end
