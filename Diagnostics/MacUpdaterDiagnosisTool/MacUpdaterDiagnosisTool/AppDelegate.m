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
#import "JMSUDiskImageUnarchiver.h"
#import "JMSUDiskImageUnarchiverDbg.h"

NSMutableString *globalOutput;

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	cc = [CoreLib new];

    globalOutput = makeMutableString();
    
	[self.progress startAnimation:self];
	[self.progress setUsesThreadedAnimation:YES];
	[self performSelector:@selector(perform) withObject:nil afterDelay:0.1];

	if (![JMHostInformation isUserAdmin])
	{
		alert_apptitled(@"Sorry the MacUpdaterDiagnosisTool can only be run from an Admin user account.", @"Quit", nil, nil);
		exit(1);
	}
}


- (void)runTest
{
    __block int method1Result = 0;
    __block int method2Result = 0;
    __block int method3Result = 0;
    __block int method4Result = 0;


    dispatch_async_back(^
    {
        let tmpFile = makeTempFilepath(@"dmg");
        [fileManager copyItemAtPath:@"debug_image_test.dmg".resourcePath toPath:tmpFile error:NULL];
        let extractionError = [[[JMSUDiskImageUnarchiver alloc] initWithArchivePath:tmpFile decryptionPassword:nil] unarchive];
        if (extractionError)
            method1Result = 2;
        else
            method1Result = 1;
    });
    dispatch_after_back(2.0, ^
    {
        let tmpFile = makeTempFilepath(@"dmg");
        [fileManager copyItemAtPath:@"debug_image_test.dmg".resourcePath toPath:tmpFile error:NULL];
        let extractionError = [[[JMSUDiskImageUnarchiverDbg alloc] initWithArchivePath:tmpFile decryptionPassword:nil] unarchive];
        if (extractionError)
            method2Result = 2;
        else
            method2Result = 1;
    });
    dispatch_after_back(3.0, ^
    {
        let archivePath = makeTempFilepath(@"dmg");
        [fileManager copyItemAtPath:@"debug_image_test.dmg".resourcePath toPath:archivePath error:NULL];
        NSString *mountPoint;
        do
        {
            CFUUIDRef uuid = CFUUIDCreate(NULL);
            if (uuid)
            {
                NSString *uuidString = CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
                if (uuidString)
                {
                    mountPoint = [@"/Volumes" stringByAppendingPathComponent:uuidString];
                }
                CFRelease(uuid);
            }
        }
        while ([[NSURL fileURLWithPath:mountPoint] checkResourceIsReachableAndReturnError:NULL]);


        NSInteger status;
        NSString *output = [@[@"/usr/bin/hdiutil", @"attach", archivePath, @"-mountpoint", mountPoint, /*@"-noverify",*/ @"-nobrowse", @"-noautoopen", @"-verbose"] runAsTaskWithTerminationStatus:&status usePolling:NO];
        if (status)
            method3Result = 2;
        else
            method3Result = 1;
        [globalOutput appendFormat:@"3:%@", output];

        NSTask *task = [[NSTask alloc] init];
        task.launchPath = @"/usr/bin/hdiutil";
        task.arguments = @[@"detach", mountPoint, @"-force"];
        task.standardOutput = [NSPipe pipe];
        task.standardError = [NSPipe pipe];
        
        @try {
            [task launch];
        } @catch (NSException *exception) {
            [globalOutput appendFormat:@"Failed to unmount %@ Exception: %@", mountPoint, exception];
        }
    });

    dispatch_after_back(4.0, ^
    {
        let archivePath = makeTempFilepath(@"dmg");
        [fileManager copyItemAtPath:@"debug_image_test.dmg".resourcePath toPath:archivePath error:NULL];
        NSString *mountPoint;
        do
        {
            CFUUIDRef uuid = CFUUIDCreate(NULL);
            if (uuid)
            {
                NSString *uuidString = CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
                if (uuidString)
                {
                    mountPoint = [@"/Volumes" stringByAppendingPathComponent:uuidString];
                }
                CFRelease(uuid);
            }
        }
        while ([[NSURL fileURLWithPath:mountPoint] checkResourceIsReachableAndReturnError:NULL]);


        NSInteger status;
        NSString *output = [@[@"/usr/bin/hdiutil", @"attach", archivePath, @"-mountpoint", mountPoint, /*@"-noverify",*/ @"-nobrowse", @"-noautoopen", @"-verbose"] runAsTaskWithTerminationStatus:&status usePolling:YES];
          [globalOutput appendFormat:@":%@", output];

        if (status)
            method4Result = 2;
        else
            method4Result = 1;
    });
    
    dispatch_async_back(^
    {
        int times = 0;
        BOOL finished = 0;
        while (!finished && times < 180)
        {
            finished = method1Result && method2Result && method3Result && method4Result;
            
            if (!finished)
                [NSThread sleepForTimeInterval:1.0];
            
            times++;
        }
        [globalOutput appendFormat:@"done %i %i %i %i", method1Result, method2Result, method3Result, method4Result];
        
        
        if (method1Result == 1 &&
            method2Result == 1 &&
            method3Result == 1  &&
            method4Result == 1 )
            self->dmgResult =  @"succ";
        
        else
            self->dmgResult =  makeString(@"some of the checks failed: %i %i %i %i", method1Result, method2Result, method3Result, method4Result);
    });
}

- (void)perform
{
    [self runTest];
    
    while (!self->dmgResult)
    {
        sleep(1);
    }
    sleep(1);
    
    let basePath = makeTempDirectory();


    tmpPath = [@[basePath, @"folder"].path stringByAppendingString:@"/"];
    
    [fileManager createDirectoryAtPath:tmpPath
           withIntermediateDirectories:YES attributes:nil error:nil];
    
    
	tmpURL = tmpPath.fileURL;
	cc_log_debug(@"%@", tmpPath);

    [tmpURL add:@"dmg_test"].contents = self->dmgResult.data;
    [tmpURL add:@"dmg_output"].contents = globalOutput.data;

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
    
    
    [fileManager copyItemAtPath:[@"~/Library/Preferences/com.corecode.MacUpdater.plist" stringByExpandingTildeInPath]
                         toPath:[tmpPath stringByAppendingString:@"com.corecode.MacUpdater.plist"] error:NULL];

    [tmpURL add:@"LaunchDaemonsDir"].contents = [@[@"/bin/ls", @"-la", @"/Library/LaunchDaemons/"] runAsTask].data;
    [tmpURL add:@"PrivilegedHelperToolsDir"].contents = [@[@"/bin/ls", @"-la", @"/Library/PrivilegedHelperTools/"] runAsTask].data;
    [tmpURL add:@"ExtensionDir"].contents = [@[@"/bin/ls", @"-la", @"/Library/Extensions/"] runAsTask].data;

	[tmpURL add:@"ps"].contents = [@[@"/bin/ps", @"ax"] runAsTask].data;
    [tmpURL add:@"top"].contents = [@[@"/usr/bin/top", @"-l1"] runAsTask].data;
    let sysprofile = [@[@"/usr/sbin/system_profiler", @"-xml", @"-detailLevel", @"full"] runAsTask];
    [tmpURL add:@"system_profiler.spx"].contents = [sysprofile splitAfterFull:@"<?xml version"].data;
	[tmpURL add:@"ioreg"].contents = [@[@"/usr/sbin/ioreg", @"-l", @"-w", @"0"] runAsTask].data;

    // apple requests
    //log show —debug —info —last boot > log.txt’
    // but this is several gigabyte (!)
    // and
    //spindump
    // but this requires root

    {
        NSURL *path = @"~/Library/Application Support/MacUpdater/".expanded.fileURL;
        for (NSString *p in path.path.directoryContents)
            if (![path add:p].fileIsDirectory)
                [fileManager copyItemAtURL:[path add:p] toURL:[tmpURL add:p] error:NULL];
    }
    
    NSMutableString *im = [NSMutableString new];
    for (NSString *path in @[@"/Library/InputManagers", @"~/Library/InputManagers".stringByExpandingTildeInPath])
        for (NSString *content in path.directoryContents)
             [im appendString:content];
    [tmpURL add:@"inputmanagers"].contents = im.data;


    BOOL connectionOK_GH = [@"https://raw.githubusercontent.com/core-code/MiscApps/master/Diagnostics/connectiontest.txt".URL.download.string contains:@"successful"];
    BOOL connectionOK_MU = [@"https://macupdater.net/macupdater/connectiontest.txt".URL.download.string contains:@"successful"];
    BOOL connectionOK_CC = [@"https://www.corecode.io/macupdater/connectiontest.txt".URL.download.string contains:@"successful"];

    [tmpURL add:@"connectiontest"].contents = makeString(@"connectiontest %i %i %i", connectionOK_GH, connectionOK_MU, connectionOK_CC).data;

    [tmpURL add:@"curl_gh"].contents = [@[@"/usr/bin/curl", @"-m", @"30", @"-v", @"https://raw.githubusercontent.com/core-code/MiscApps/master/Diagnostics/connectiontest.txt"] runAsTask].data;
    [tmpURL add:@"curl_mu"].contents = [@[@"/usr/bin/curl", @"-m", @"30", @"-v", @"https://macupdater.net/macupdater/connectiontest.txt"] runAsTask].data;
    [tmpURL add:@"curl_cc"].contents = [@[@"/usr/bin/curl", @"-m", @"30", @"-v", @"https://www.corecode.io/macupdater/connectiontest.txt"] runAsTask].data;
    [tmpURL add:@"nscurl_gh"].contents = [@[@"/usr/bin/nscurl", @"-m", @"30", @"-i", @"-v", @"https://raw.githubusercontent.com/core-code/MiscApps/master/Diagnostics/connectiontest.txt"] runAsTask].data;
    [tmpURL add:@"nscurl_mu"].contents = [@[@"/usr/bin/nscurl", @"-m", @"30", @"-i", @"-v", @"https://macupdater.net/macupdater/connectiontest.txt"] runAsTask].data;
    [tmpURL add:@"nscurl_cc"].contents = [@[@"/usr/bin/nscurl", @"-m", @"30", @"-i", @"-v", @"https://www.corecode.io/macupdater/connectiontest.txt"] runAsTask].data;
    

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
@end
