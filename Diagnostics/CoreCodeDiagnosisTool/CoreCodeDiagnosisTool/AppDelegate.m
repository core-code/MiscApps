//
//  AppDelegate.m
//  MacUpdaterDiagnosisTool
//
//  Created by CoreCode on 09.01.13.
/*	Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
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
		alert_apptitled(@"Sorry the MacUpdaterDiagnosisTool can only be run from an Admin user account.", @"Quit", nil, nil);
		exit(1);
	}
}

- (void)perform
{
	tmpPath = [makeTempDirectory() stringByAppendingString:@"/"];
	tmpURL = tmpPath.fileURL;
	cc_log_debug(@"%@", tmpPath);


	[fileManager copyItemAtPath:[@"/private/var/log/system.log" stringByExpandingTildeInPath]
						 toPath:[tmpPath stringByAppendingString:@"system.log"] error:NULL];

	[fileManager copyItemAtPath:[@"/private/var/log/system.log.0.gz" stringByExpandingTildeInPath]
						 toPath:[tmpPath stringByAppendingString:@"system.log.0.gz"] error:NULL];

	[fileManager copyItemAtPath:[@"/private/var/log/system.log.1.gz" stringByExpandingTildeInPath]
						 toPath:[tmpPath stringByAppendingString:@"system.log.1.gz"] error:NULL];


    {
        [fileManager createDirectoryAtPath:@[tmpPath, @"DR"].path withIntermediateDirectories:YES attributes:nil error:nil];
        NSURL *path1 = @"/Library/Logs/DiagnosticReports/".fileURL;
        NSURL *path2 = @"~/Library/Logs/DiagnosticReports/".expanded.fileURL;
        for (NSURL *p in [path1.directoryContents arrayByAddingObjectsFromArray:path2.directoryContents])
            if ([p.contents.string contains:@"corecode"])
                [fileManager copyItemAtURL:p
                                     toURL:@[tmpPath, @"DR", p.lastPathComponent].path.fileURL
                                     error:NULL];
    }
    
	{
		NSURL *path = @"~/Library/Preferences/".expanded.fileURL;
		for (NSString *p in [path.path.directoryContents filteredUsingPredicateString:@"self BEGINSWITH[cd] 'com.corecode'"])
			[fileManager copyItemAtURL:[path add:p] toURL:[tmpURL add:p] error:NULL];
	}
	{
		NSURL *path = @"~/Library/Containers/".expanded.fileURL;
		for (NSString *p in [path.path.directoryContents filteredUsingPredicateString:@"self BEGINSWITH[cd] 'com.corecode'"])
			[fileManager copyItemAtURL:[path add:p] toURL:[tmpURL add:p] error:NULL];
	}


	[tmpURL add:@"lsof"].contents = [@[@"/usr/sbin/lsof", @"-c", @"SMART"] runAsTask].data;
	[tmpURL add:@"ps"].contents = [@[@"/bin/ps", @"ax"] runAsTask].data;
    [tmpURL add:@"top"].contents = [@[@"/usr/bin/top", @"-l1"] runAsTask].data;
	[tmpURL add:@"loginItems"].contents = [self loginItems].data;
	[tmpURL add:@"system_profiler"].contents = [@[@"/usr/sbin/system_profiler", @"-xml", @"-detailLevel", @"full"] runAsTask].data;
	[tmpURL add:@"ioreg"].contents = [@[@"/usr/sbin/ioreg", @"-l", @"-w", @"0"] runAsTask].data;
	[tmpURL add:@"diskutil"].contents = [@[@"/usr/sbin/diskutil", @"list"] runAsTask].data;
	for (int i = 0; i < 16; i++)
		[tmpURL add:makeString(@"diskutil%i", i)].contents = [@[@"/usr/sbin/diskutil", @"info", makeString(@"disk%i", i)] runAsTask].data;


    NSMutableString *im = [NSMutableString new];
    for (NSString *path in @[@"/Library/InputManagers", @"~/Library/InputManagers".stringByExpandingTildeInPath])
        for (NSString *content in path.directoryContents)
             [im appendString:content];
    [tmpURL add:@"inputmanagers"].contents = im.data;





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
                                                to:@"feedback@corecode.io"
										   timeout:60
										attachment:attachment.path] == kSMTPSuccess)
	{
		alert(@"Result", @"Sending succeeded. You can look into your Mail.app outbox", @"OK", nil, nil);
	}
	else
	{
		[fileManager copyItemAtURL:attachment
							 toURL:@"~/Desktop/CCdiagnosis.tgz".expanded.uniqueFile.fileURL
							 error:NULL];


		alert(@"Result", @"Sending failed. Send the file yourself to <feedback@corecode.io>, it is now on your desktop.", @"OK", nil, nil);
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
			cc_log_error(@"Warning: _IsLoginItem : LSSharedFileListCopySnapshot delivered NULL list!");

		CFRelease(list);
	}
	else
		cc_log_error(@"Warning: _IsLoginItem : LSSharedFileListCreate delivered NULL list!");

	return tmp;
}
@end
