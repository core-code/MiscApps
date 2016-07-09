//
//  AppDelegate.m
//  CoreCodeDiagnosisTool
//
//  Created by Julian Mayer on 09.01.13.
//  Copyright (c) 2013 CoreCode. All rights reserved.
//

#import "AppDelegate.h"
#import "JMEmailSender.h"
#import "JMHostInformation.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	cc = [CoreLib new];

	[self.progress startAnimation:self];
	[self.progress setUsesThreadedAnimation:YES];
	[self performSelector:@selector(perform) withObject:nil afterDelay:0.1];

	if (![JMHostInformation isUserAdmin])
	{
		alert_apptitled(@"Sorry the CoreCodeDiagnosisTool can only be run from an Admin user account.", @"Quit", nil, nil);
		exit(1);
	}
}

- (void)perform
{
	tmpPath = [makeTempFolder() stringByAppendingString:@"/"];
	tmpURL = tmpPath.fileURL;

	[fileManager copyItemAtPath:[@"~/Library/Logs/DiagnosticReports/" stringByExpandingTildeInPath]
						 toPath:[tmpPath stringByAppendingString:@"DR"] error:NULL];

	[fileManager copyItemAtPath:[@"/private/var/log/system.log" stringByExpandingTildeInPath]
						 toPath:[tmpPath stringByAppendingString:@"system.log"] error:NULL];

	[fileManager copyItemAtPath:[@"/private/var/log/system.log.0.gz" stringByExpandingTildeInPath]
						 toPath:[tmpPath stringByAppendingString:@"system.log.0.gz"] error:NULL];

	[fileManager copyItemAtPath:[@"/private/var/log/system.log.1.gz" stringByExpandingTildeInPath]
						 toPath:[tmpPath stringByAppendingString:@"system.log.1.gz"] error:NULL];

	{
		NSURL *path = @"~/Library/Preferences/".expanded.fileURL;
		for (NSString *p in [path.path.dirContents filteredUsingPredicateString:@"self BEGINSWITH[cd] 'com.corecode'"])
			[fileManager copyItemAtURL:[path add:p] toURL:[tmpURL add:p] error:NULL];
	}


	[tmpURL add:@"lsof"].contents = [@[@"/usr/sbin/lsof", @"-c", @"SMART"] runAsTask].data;
	[tmpURL add:@"ps"].contents = [@[@"/bin/ps", @"ax"] runAsTask].data;
	[tmpURL add:@"loginItems"].contents = [self loginItems].data;
	[tmpURL add:@"system_profiler"].contents = [@[@"/usr/sbin/system_profiler", @"-xml", @"-detailLevel", @"full"] runAsTask].data;
	[tmpURL add:@"ioreg"].contents = [@[@"/usr/sbin/ioreg", @"-l", @"-w", @"0"] runAsTask].data;
	[tmpURL add:@"diskutil"].contents = [@[@"/usr/sbin/diskutil", @"list"] runAsTask].data;
	for (int i = 0; i < 16; i++)
		[tmpURL add:makeString(@"diskutil%i", i)].contents = [@[@"/usr/sbin/diskutil", @"info", makeString(@"disk%i", i)] runAsTask].data;






	NSTask *task = [NSTask new];
	[task setLaunchPath:@"/usr/bin/tar"];
	[task setCurrentDirectoryPath:[tmpURL URLByDeletingLastPathComponent].path];
	[task setArguments:@[@"czf", @"CCdiagnosis.tgz", [tmpURL lastPathComponent]]];
	[task launch];
	[task waitUntilExit];




	[self.box1 setHidden:YES];
	[self.box2 setHidden:NO];
	

}
- (IBAction)send:(id)sender
{
	NSURL *attachment = [[tmpURL URLByDeletingLastPathComponent] add:@"CCdiagnosis.tgz"];
	
	if ([JMEmailSender sendMailWithScriptingBridge:@"hello corecode,\nhelpful files to diagnose product problems are attached.\nbye\n\n "
										   subject:@"CoreCode Diagnose Files"
                                                to:@"feedback@corecode.at"
										   timeout:60
										attachment:attachment.path] == kSMTPSuccess)
	{
		NSRunAlertPanel(@"Result", @"Sending succeeded. You can look into your Mail.app outbox", @"OK", nil, nil);
	}
	else
	{
		[fileManager copyItemAtURL:attachment
							 toURL:@"~/Desktop/CCdiagnosis.tgz".expanded.uniqueFile.fileURL
							 error:NULL];


		NSRunAlertPanel(@"Result", @"Sending failed. Send the file yourself to <feedback@corecode.at>, it is now on your desktop.", @"OK", nil, nil);
	}

	[fileManager removeItemAtURL:tmpURL error:NULL];
}


- (NSString *)loginItems
{
	UInt32 outSnapshotSeed;
	LSSharedFileListRef list = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
	NSMutableString *tmp = [NSMutableString new];

	if (list)
	{
		NSArray *array = (__bridge NSArray *) LSSharedFileListCopySnapshot(list, &outSnapshotSeed);

		if (array)
		{
			for (id item in array)
			{
				CFURLRef url = NULL;
				OSStatus status = LSSharedFileListItemResolve((__bridge LSSharedFileListItemRef)item, kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes, &url, NULL);

				if (status == noErr)
				{
					[tmp appendFormat:@"item %@\n", [(__bridge NSURL *)url path]];
				}


				if (url != NULL)
					CFRelease(url);
			}
			CFRelease((__bridge CFTypeRef)(array));
		}
		else
			asl_NSLog(ASL_LEVEL_WARNING, @"Warning: _IsLoginItem : LSSharedFileListCopySnapshot delivered NULL list!");

		CFRelease(list);
	}
	else
		asl_NSLog(ASL_LEVEL_WARNING, @"Warning: _IsLoginItem : LSSharedFileListCreate delivered NULL list!");

	return tmp;
}
@end
