//
//  AppDelegate.m
//  VersionsManagerDiagnosisTool
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
		alert_apptitled(@"Sorry the VersionsManagerDiagnosisTool can only be run from an Admin user account.", @"Quit", nil, nil);
		exit(1);
	}
}

- (void)perform
{
	tmpPath = [makeTempFolder() stringByAppendingString:@"/"];
	tmpURL = tmpPath.fileURL;
	asl_NSLog_debug(@"%@", tmpPath);

//	[tmpURL add:@"system_profiler"].contents = [@[@"/usr/sbin/system_profiler", @"-xml", @"-detailLevel", @"full"] runAsTask].data;


	// Create authorization reference
	OSStatus status;
	AuthorizationRef authorizationRef;

	// AuthorizationCreate and pass NULL as the initial
	// AuthorizationRights set so that the AuthorizationRef gets created
	// successfully, and then later call AuthorizationCopyRights to
	// determine or extend the allowable rights.
	// http://developer.apple.com/qa/qa2001/qa1172.html
	status = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &authorizationRef);
	if (status != errAuthorizationSuccess)
	{
		alert_apptitled(@"Can't proceed to get diagnosis without admin rights", @"OK", nil, nil);
		exit(1);
	}

	// kAuthorizationRightExecute == "system.privilege.admin"
	AuthorizationItem right = {kAuthorizationRightExecute, 0, NULL, 0};
	AuthorizationRights rights = {1, &right};
	AuthorizationFlags flags = kAuthorizationFlagDefaults | kAuthorizationFlagInteractionAllowed |
	kAuthorizationFlagPreAuthorize | kAuthorizationFlagExtendRights;

	// Call AuthorizationCopyRights to determine or extend the allowable rights.
	status = AuthorizationCopyRights(authorizationRef, &rights, NULL, flags, NULL);
	if (status != errAuthorizationSuccess)
	{
		alert_apptitled(@"AuthorizationCopyRights failed", @"OK", nil, nil);
		exit(1);
	}

	asl_NSLog_debug(@"gonna defaults");

	{ // -In terminal, run this command: “sudo defaults write com.apple.revisiond log.level -int 7 && sudo killall revisiond”

		char *tool = "/usr/bin/defaults";
		char *args[] = {"write", "com.apple.revisiond", "log.level", "-int", "7", NULL};
		FILE *pipe = NULL;

		status = AuthorizationExecuteWithPrivileges(authorizationRef, tool, kAuthorizationFlagDefaults, args, &pipe);
		if (status != errAuthorizationSuccess)
		{
			alert_apptitled(@"AuthorizationExecuteWithPrivileges failed", @"OK", nil, nil);
			exit(1);
		}
		else
		{
			char myReadBuffer[128];
			NSMutableString *result = makeMutableString();
			for(;;)
			{
				long bytesRead = read(fileno(pipe), myReadBuffer, sizeof (myReadBuffer));
				if (bytesRead < 1)
					break;
				else
				{
					NSString *appendstring = [[NSString alloc] initWithBytes:myReadBuffer length:bytesRead encoding:NSUTF8StringEncoding];
					if (appendstring)
						[result appendString:appendstring];
				}
			}
			[tmpURL add:@"defaultsresult"].contents = result.data;
		}
	}
	asl_NSLog_debug(@"gonna revisiond");


	{ // -In terminal, run this command: “sudo defaults write com.apple.revisiond log.level -int 7 && sudo killall revisiond”
		NSString *pid = [@[@"/usr/bin/pgrep", @"revisiond"] runAsTask].trimmedOfWhitespaceAndNewlines;


		char *tool = "/bin/kill";
		char *args[] = {pid.UTF8String, NULL};
		FILE *pipe = NULL;

		status = AuthorizationExecuteWithPrivileges(authorizationRef, tool, kAuthorizationFlagDefaults, args, &pipe);
		if (status != errAuthorizationSuccess)
		{
			alert_apptitled(@"AuthorizationExecuteWithPrivileges failed", @"OK", nil, nil);
			exit(1);
		}
		else
		{
			char myReadBuffer[128];
			NSMutableString *result = makeMutableString();
			for(;;)
			{
				long bytesRead = read(fileno(pipe), myReadBuffer, sizeof (myReadBuffer));
				if (bytesRead < 1)
					break;
				else
				{
					NSString *appendstring = [[NSString alloc] initWithBytes:myReadBuffer length:bytesRead encoding:NSUTF8StringEncoding];
					if (appendstring)
						[result appendString:appendstring];
				}
			}
			[tmpURL add:@"killallresult"].contents = result.data;
		}
	}


	asl_NSLog_debug(@"gonna check broken versions");


	[tmpURL add:@"broken_fileversions"].contents = [self broken].data;


	asl_NSLog_debug(@"gonna sysdiagnose");

	[fileManager createDirectoryAtURL:[tmpURL add:@"sysdiagnose"]
		  withIntermediateDirectories:YES attributes:nil error:NULL];
	{ // -In terminal, run this command “sudo sysdiagnose -f <directory to store results>”
		char *tool = "/usr/bin/sysdiagnose";
		char *args[] = {"-l", "-b", "-f", [tmpURL add:@"sysdiagnose"].path.UTF8String, NULL};
		FILE *pipe = NULL;

		status = AuthorizationExecuteWithPrivileges(authorizationRef, tool, kAuthorizationFlagDefaults, args, &pipe);
		if (status != errAuthorizationSuccess)
		{
			alert_apptitled(@"AuthorizationExecuteWithPrivileges failed", @"OK", nil, nil);
			exit(1);
		}
		else
		{
			char myReadBuffer[128];
			NSMutableString *result = makeMutableString();
			for(;;)
			{
				asl_NSLog_debug(@"gonna read");

				long bytesRead = read(fileno(pipe), myReadBuffer, sizeof (myReadBuffer));
				if (bytesRead < 1)
					break;
				else
				{
					NSString *appendstring = [[NSString alloc] initWithBytes:myReadBuffer length:bytesRead encoding:NSASCIIStringEncoding];
					asl_NSLog_debug(@"got %@", appendstring);

					if (appendstring)
					{
						[result appendString:appendstring];

						if ([appendstring contains:@"Press 'Enter' to continue"])
						{
							char myWriteBuffer[] = {13, EOF};

							asl_NSLog_debug(@"gonna enter");

							write(fileno(pipe), &myWriteBuffer, 2); // fake enter press

							asl_NSLog_debug(@"did enter");
						}
					}
				}
			}
			[tmpURL add:@"sysdiagnoseresult"].contents = result.data;
		}
	}


	asl_NSLog_debug(@"gonna xar");

	{ // xar

		char *tool = "/usr/bin/xar";
		char *args[] = {"-c", "-f", [tmpURL add:@"DocumentRevisions.xar"].path.UTF8String, "/.DocumentRevisions-V100/db-V1", "/.DocumentRevisions-V100/LibraryStatus", "/.DocumentRevisions-V100/metadata", NULL};
		FILE *pipe = NULL;

		status = AuthorizationExecuteWithPrivileges(authorizationRef, tool, kAuthorizationFlagDefaults, args, &pipe);
		if (status != errAuthorizationSuccess)
		{
			alert_apptitled(@"AuthorizationExecuteWithPrivileges failed", @"OK", nil, nil);
			exit(1);
		}
		else
		{
			char myReadBuffer[128];
			NSMutableString *result = makeMutableString();
			for(;;)
			{
				long bytesRead = read(fileno(pipe), myReadBuffer, sizeof (myReadBuffer));
				if (bytesRead < 1)
					break;
				else
				{
					NSString *appendstring = [[NSString alloc] initWithBytes:myReadBuffer length:bytesRead encoding:NSUTF8StringEncoding];
					if (appendstring)
						[result appendString:appendstring];
				}
			}
			[tmpURL add:@"xarresult"].contents = result.data;
		}
	}



	{ // ls

		char *tool = "/bin/ls";
		char *args[] = {"-laR", "/.DocumentRevisions-V100/", NULL};
		FILE *pipe = NULL;

		status = AuthorizationExecuteWithPrivileges(authorizationRef, tool, kAuthorizationFlagDefaults, args, &pipe);
		if (status != errAuthorizationSuccess)
		{
			alert_apptitled(@"AuthorizationExecuteWithPrivileges failed", @"OK", nil, nil);
			exit(1);
		}
		else
		{
			char myReadBuffer[128];
			NSMutableString *result = makeMutableString();
			for(;;)
			{
				long bytesRead = read(fileno(pipe), myReadBuffer, sizeof (myReadBuffer));
				if (bytesRead < 1)
					break;
				else
				{
					NSString *appendstring = [[NSString alloc] initWithBytes:myReadBuffer length:bytesRead encoding:NSUTF8StringEncoding];
					if (appendstring)
					{
						[result appendString:appendstring];
					}
				}
			}
			[tmpURL add:@"DocumentRevisionsFileList.txt"].contents = result.data;
		}
	}


	asl_NSLog_debug(@"gonna defaults AGAIN");

	{ // -In terminal, run this command: “sudo defaults delete com.apple.revisiond log.level”

		char *tool = "/usr/bin/defaults";
		char *args[] = {"delete", "com.apple.revisiond", "log.level", NULL};
		FILE *pipe = NULL;

		status = AuthorizationExecuteWithPrivileges(authorizationRef, tool, kAuthorizationFlagDefaults, args, &pipe);
		if (status != errAuthorizationSuccess)
		{
			alert_apptitled(@"AuthorizationExecuteWithPrivileges failed", @"OK", nil, nil);
			exit(1);
		}
		else
		{
			char myReadBuffer[128];
			NSMutableString *result = makeMutableString();
			for(;;)
			{
				long bytesRead = read(fileno(pipe), myReadBuffer, sizeof (myReadBuffer));
				if (bytesRead < 1)
					break;
				else
				{
					NSString *appendstring = [[NSString alloc] initWithBytes:myReadBuffer length:bytesRead encoding:NSUTF8StringEncoding];
					if (appendstring)
						[result appendString:appendstring];
				}
			}
			[tmpURL add:@"defaultsresult2"].contents = result.data;
		}
	}



	BOOL done = false;
	int times = 0;
	while (!done) // wait for sysdiagnose to finish
	{
		NSArray <NSURL *> *dc = [tmpURL add:@"sysdiagnose"].dirContents;
		NSArray <NSURL *> *dcf = [dc filtered:^BOOL(NSURL *input) { return [input.path hasSuffix:@"tar.gz"]; }];
		done = (dcf.count > 0);
		times++;
		if (!done && times > 200)
			done = TRUE;
		sleep(1);
	}

	NSTask *task = [NSTask new];
	[task setLaunchPath:@"/usr/bin/tar"];
	[task setCurrentDirectoryPath:[tmpURL URLByDeletingLastPathComponent].path];
	[task setArguments:@[@"czf", @"CCdiagnosis.tgz", [tmpURL lastPathComponent]]];
	[task launch];
	[task waitUntilExit];




	[self.box1 setHidden:YES];
	[self.box2 setHidden:NO];


}

- (IBAction)reveal:(id)sender
{
	NSURL *attachment = [[tmpURL URLByDeletingLastPathComponent] add:@"CCdiagnosis.tgz"];

	[workspace activateFileViewerSelectingURLs:@[attachment]];
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

- (NSString *)broken
{
	NSMutableString *tmp = makeMutableString();
	NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:[NSURL fileURLWithPath:@"~".stringByExpandingTildeInPath]
															 includingPropertiesForKeys:@[NSURLIsRegularFileKey, NSURLIsPackageKey]
																				options:(NSDirectoryEnumerationOptions)0 errorHandler:nil];

	for (NSURL *file in enumerator)
	{
		@autoreleasepool
		{
			NSError *error;
			NSNumber *isRegularFile = nil, *isPackage;


			if (![file getResourceValue:&isRegularFile forKey:NSURLIsRegularFileKey error:&error] ||
				![file getResourceValue:&isPackage forKey:NSURLIsPackageKey error:&error])
			{


			}
			else if (isRegularFile.boolValue || isPackage.boolValue)
			{
				NSArray *otherVersions = [NSFileVersion otherVersionsOfItemAtURL:file];

				for (NSFileVersion *ov in otherVersions)
				{
					NSString *path = ov.URL.path;

					if (!path)
					{
						[tmp appendString:makeString(@"Warning: file (%@) version (%@) is NIL: localizedName: %@ localzesNameOfSavingComputer: %@ modificationDate: %@ persistentIdentifier: %@ conflict: %i resolved: %i discardable: %i hasLocalContents: %i hasThumbnail: %i\n", file, ov.description, ov.localizedName, ov.localizedNameOfSavingComputer,  ov.modificationDate, ov.persistentIdentifier, ov.conflict, ov.resolved, ov.discardable, ov.hasLocalContents, ov.hasThumbnail)];

					}
					else if (path &&
							 (![[NSFileManager defaultManager] fileExistsAtPath:path] ||
							  ![[NSFileManager defaultManager] isReadableFileAtPath:path]))
					{
						[tmp appendString:makeString(@"Warning: file (%@) version (%@) NOT accessible (%@): localizedName: %@ localzesNameOfSavingComputer: %@ modificationDate: %@ persistentIdentifier: %@ conflict: %i resolved: %i discardable: %i hasLocalContents: %i hasThumbnail: %i\n", file, ov.description, path, ov.localizedName, ov. localizedNameOfSavingComputer,  ov.modificationDate, ov.persistentIdentifier, ov.conflict, ov.resolved, ov.discardable, ov.hasLocalContents, ov.hasThumbnail)];
					}
				}
			}
		}
	}
	return tmp;
}
@end
