//
//  SMARTReporter.m
//  SMARTReporter
//
//  Created by CoreCode on Sat Feb 28 2004.
/*	Copyright (c) 2016 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */


#import <Growl/Growl.h>
#import "SMARTReporter.h"
#import "CrashReporter.h"
#import "LoginItemManager.h"
#import "HostInformation.h"
#import "ValidEmailValueTransformer.h"


@implementation SMARTReporter

@synthesize firstStart, raidCheckStatusText, ioErrorCheckStatusText, smartStatusText;

#pragma mark *** NSObject subclass-methods ***

+ (void)initialize
{
    ValidEmailValueTransformer *vt = [[[ValidEmailValueTransformer alloc] init] autorelease];

	[NSValueTransformer setValueTransformer:vt forName:@"ValidEmailValueTransformer"];

	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];

	// notification values
	[defaultValues setObject:[NSNumber numberWithInt:1] forKey:kGrowlKey];
	[defaultValues setObject:[NSNumber numberWithInt:1] forKey:kPopupKey];
	[defaultValues setObject:[NSNumber numberWithInt:0] forKey:kExecuteKey];
	[defaultValues setObject:[NSNumber numberWithInt:0] forKey:kEmailKey];
	[defaultValues setObject:@"" forKey:kExecutenameKey];
	// mail values
	[defaultValues setObject:[NSNumber numberWithInt:0] forKey:kEmail_settingsKey];
	[defaultValues setObject:[NSNumber numberWithInt:25] forKey:kSmtp_portKey];
	[defaultValues setObject:@"~/Library/Logs/SMARTReporter.log" forKey:kLog_filenameKey];
	[defaultValues setObject:NSLocalizedString(@"The S.M.A.R.T.-data for the drive %D on the machine %N (hostname: %H ipv4-address: %4 ipv6-address: %6 MAC-address: %M) indicates an impending drive-failure!\n\nPlease follow the instructions in the 'What to do when SMARTReporter predicts a failure' section in SMARTReporter's FAQ as soon as possible.", nil) forKey:kMail_bodyKey];
	[defaultValues setObject:NSLocalizedString(@"TEST E-Mail from SMARTReporter", nil) forKey:kTest_mail_headerKey];
	[defaultValues setObject:NSLocalizedString(@"SMARTReporter Failure Notice", nil) forKey:kError_mail_headerKey];
	// appearance values
	[defaultValues setObject:[NSNumber numberWithInt:2] forKey:kLookKey];
	[defaultValues setObject:[NSNumber numberWithInt:0] forKey:kIconsetKey];
	[defaultValues setObject:[NSNumber numberWithInt:0] forKey:kUse_rediconKey];
	// behaviour values
	[defaultValues setObject:[NSNumber numberWithInt:0] forKey:kDontcheckwhenonbatteryKey];
	[defaultValues setObject:[NSNumber numberWithInt:0] forKey:kUse_logfilelimitKey];
	[defaultValues setObject:[NSNumber numberWithInt:1024] forKey:kLogfilelimit_kbKey];
	[defaultValues setObject:[NSNumber numberWithInt:1] forKey:kRAIDNotPopupKey];
	// misc values
	[defaultValues setObject:[NSNumber numberWithInt:1] forKey:kFirstStartKeychainKey];
	[defaultValues setObject:[NSNumber numberWithInt:4] forKey:kUpdatecheckMenuindexKey];
	[defaultValues setObject:[NSNumber numberWithInt:1] forKey:kIOErrorCheckKey];
	// shared code values
	[defaultValues setObject:[NSNumber numberWithInt:0] forKey:kUse_authenticationKey];
 	[defaultValues setObject:[NSDate dateWithString:@"2007-03-12 00:00:00 +0000"] forKey:kLastCrashDateKey];
 	[defaultValues setObject:[NSNumber numberWithInt:0] forKey:kNeverCheckCrashesKey];
	
	unsigned long long size = [[[[NSFileManager defaultManager] fileAttributesAtPath:IOERRORCHECKLOGFILE traverseLink:YES] objectForKey:NSFileSize] unsignedLongLongValue];
	[defaultValues setObject:[NSNumber numberWithUnsignedLongLong:size] forKey:kIOErrorCheckLastCheckFilesizeKey];

	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}

- (void)dealloc
{
	[statusItem release];
	[driveList release];

	statusItem = nil;
	driveList = nil;
	
	[self setSmartStatusText:nil];
	[self setIoErrorCheckStatusText:nil];
	[self setRaidCheckStatusText:nil];
	
	[super dealloc];
}

#pragma mark *** NSApplication delegate-methods ***

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
	if (statusItem == nil)
		[self configurationAction:self];

	return FALSE;
}

- (void)applicationDidBecomeActive:(NSNotification *)aNotification
{
	if (statusItem == nil)
	{
		// setup the menu icon
		if ((([userDefaults integerForKey:kLookKey] != 0)) || ((GetCurrentKeyModifiers() & (optionKey | rightOptionKey)) != 0))
		{
			statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];

			[statusItem setHighlightMode:YES];
			[statusItem setMenu:theMenu];
			[statusItem setEnabled:YES];

			[self setMenuIcon:kSmartJustRedisplay];
		}
	}
	
	[self updateTooltip];
}

#pragma mark *** NSNibAwaking protocol-methods ***

- (void)awakeFromNib
{	
	[self setSmartStatusText:NSLocalizedString(@"S.M.A.R.T. status not yet determined", nil)];
	
	if ([userDefaults boolForKey:kCheckRAIDKey])
		[self setRaidCheckStatusText:NSLocalizedString(@"R.A.I.D. check not yet performed", nil)];
	else
		[self setRaidCheckStatusText:NSLocalizedString(@"R.A.I.D. status check disabled", nil)];
	
	if ([userDefaults boolForKey:kIOErrorCheckKey])
		[self setIoErrorCheckStatusText:NSLocalizedString(@"I/O Error check not yet performed", nil)];
	else
		[self setIoErrorCheckStatusText:NSLocalizedString(@"I/O Error check disabled", nil)];
	

	if ([userDefaults boolForKey:kFirstStartKeychainKey])
	{
		NSString *pass = [userDefaults stringForKey:@"auth_pass"];

		if (pass && [pass length])
		{
			asl_NSLog_debug(@"awakeFromNib SecKeychainAddInternetPassword");
			OSStatus status = SecKeychainAddInternetPassword(
															 NULL,																	// SecKeychainRef keychain,
															 (UInt32)[[userDefaults stringForKey:@"smtp_server"] length],			// UInt32 serverNameLength,
															 [[userDefaults stringForKey:@"smtp_server"] UTF8String],				// const char *serverName,
															 0,																		// UInt32 securityDomainLength,
															 NULL,																	// const char *securityDomain,
															 (UInt32)[[userDefaults stringForKey:@"auth_user"] length],				// UInt32 accountNameLength,
															 [[userDefaults stringForKey:@"auth_user"] UTF8String],					// const char *accountName,
															 0,																		// UInt32 pathLength,
															 "",																	// const char *path,
															 [userDefaults integerForKey:kSmtp_portKey],                            // UInt16 port,
															 kSecProtocolTypeSMTP,													// SecProtocolType protocol,
															 kSecAuthenticationTypeDefault,											// SecAuthType authType,
															 (UInt32)[pass length],													// UInt32 passwordLength,
															 [pass UTF8String],														// const void *passwordData,
															 NULL																	// SecKeychainItemRef *itemRef
															 );

			if (status)
				asl_NSLog(ASL_LEVEL_ERR, @"Error: SMARTReporter could not save the e-mail password for custom settings in the keychain: %li", (long)status);

			[userDefaults setObject:@"" forKey:@"auth_pass"];
		}

		[userDefaults setObject:[NSNumber numberWithBool:FALSE] forKey:kFirstStartKeychainKey];
		[userDefaults synchronize];
	}
	if ([userDefaults boolForKey:kEmail_settingsKey] && [[userDefaults stringForKey:@"smtp_server"] length] && [[userDefaults stringForKey:@"auth_user"] length])
	{
		asl_NSLog_debug(@"awakeFromNib SecKeychainFindInternetPassword");
		UInt32 passwordLength = 0;
		void *password = NULL;
		SecKeychainFindInternetPassword(
										NULL,																	// SecKeychainRef keychain,
										(UInt32)[[userDefaults stringForKey:@"smtp_server"] length],			// UInt32 serverNameLength,
										[[userDefaults stringForKey:@"smtp_server"] UTF8String],				// const char *serverName,
										0,																		// UInt32 securityDomainLength,
										NULL,																	// const char *securityDomain,
										(UInt32)[[userDefaults stringForKey:@"auth_user"] length],				// UInt32 accountNameLength,
										[[userDefaults stringForKey:@"auth_user"] UTF8String],					// const char *accountName,
										0,																		// UInt32 pathLength,
										"",																		// const char *path,
										[userDefaults integerForKey:kSmtp_portKey],								// UInt16 port,
										kSecProtocolTypeSMTP,													// SecProtocolType protocol,
										kSecAuthenticationTypeDefault,											// SecAuthType authType,


										&passwordLength,                 // UInt32 *passwordLength,
										&password,                    // void **passwordData,
										NULL                            // SecKeychainItemRef *itemRef
										);
	}


	if ([NSProcessInfo instancesRespondToSelector:@selector(disableSuddenTermination)])
		[[NSProcessInfo processInfo] disableSuddenTermination];

	if ([userDefaults boolForKey:kIOErrorCheckKey] &&
		(![[NSFileManager defaultManager] isReadableFileAtPath:IOERRORCHECKLOGFILE]))
	{
		asl_NSLog(ASL_LEVEL_WARNING, @"Warning: I/O-Error check is enabled but current user does not have admin rights. Disabling the check.");

		[userDefaults setBool:FALSE forKey:kIOErrorCheckKey];
		[userDefaults synchronize];
	}

	[GrowlApplicationBridge setGrowlDelegate:((id <GrowlApplicationBridgeDelegate,NSObject>)@"")];


	NSString *filename = [[userDefaults stringForKey:kLog_filenameKey] stringByExpandingTildeInPath];

	if (([[NSFileManager defaultManager] fileExistsAtPath:filename]) && [userDefaults boolForKey:kUse_logfilelimitKey])
	{
		unsigned long long filesize = [[[[NSFileManager defaultManager] attributesOfItemAtPath:filename error:NULL] objectForKey:@"NSFileSize"] unsignedLongLongValue];
		unsigned long long filesizelimit = [userDefaults integerForKey:kLogfilelimit_kbKey] * 1024;

		if (filesize > filesizelimit)
		{
			NSFileHandle *fh = [NSFileHandle fileHandleForUpdatingAtPath:filename];

			[fh seekToFileOffset:(filesize - filesizelimit)];

			NSData *data = [fh readDataToEndOfFile];

			[fh seekToFileOffset:0];

			[fh writeData:data];

			[fh truncateFileAtOffset:filesizelimit];
			[fh synchronizeFile];
			[fh closeFile];
		}
	}

	// setup the menu icon
	statusItem = nil;
	[self applicationDidBecomeActive:nil];


	// load or create and refresh our drive list
	if ([[NSFileManager defaultManager] fileExistsAtPath:DRIVE_DATA_FILE])
	{
		@try
		{
			driveList = [[NSKeyedUnarchiver unarchiveObjectWithFile:DRIVE_DATA_FILE] retain];

			[self setFirstStart:FALSE];

			[driveList refreshDriveList:self];

			if ([NSProcessInfo instancesRespondToSelector:@selector(enableSuddenTermination)])
				[[NSProcessInfo processInfo] enableSuddenTermination];

			return;
		}
		@catch (NSException *e)
		{
			asl_NSLog(ASL_LEVEL_WARNING, @"Warning: Exception occured: %@", [e description]);
		}
	}
	else
		asl_NSLog(ASL_LEVEL_WARNING, @"Warning: no drive data file at: %@", DRIVE_DATA_FILE);

	[self setFirstStart:TRUE];

	AddLoginItem();

	driveList = [[DriveList alloc] init];

	[driveList refreshDriveList:self];

	if ([NSProcessInfo instancesRespondToSelector:@selector(enableSuddenTermination)])
		[[NSProcessInfo processInfo] enableSuddenTermination];
}

#pragma mark *** IBAction action-methods ***

- (IBAction)configurationAction:(id)sender
{
	asl_NSLog_debug(@"configurationAction: called");

	if (sender != driveList) // prevent possible infinite loops
		[driveList refreshDriveList:nil];

	[NSApp activateIgnoringOtherApps:YES];
	[[driveList window] makeKeyAndOrderFront:self];
	
	if ([NSProcessInfo instancesRespondToSelector:@selector(disableSuddenTermination)])
		[[NSProcessInfo processInfo] disableSuddenTermination];
}

- (IBAction)displayAction:(id)sender
{
	NSString *filename = [[userDefaults stringForKey:kLog_filenameKey] stringByExpandingTildeInPath];

	if (YES != [[NSWorkspace sharedWorkspace] openFile:filename withApplication:@"Console.app"])
	{
		[NSApp activateIgnoringOtherApps:YES];
		NSRunAlertPanel(@"SMARTReporter",
		                [NSString stringWithFormat:NSLocalizedString(@"Could not open Console.app to open the log file. View it manually at '%@'.", nil), filename],
		                NSLocalizedString(@"OK", nil), nil, nil);
	}
}

- (IBAction)aboutAction:(id)sender
{
	[NSApp activateIgnoringOtherApps:YES];
	[[NSApplication sharedApplication] orderFrontStandardAboutPanel:nil];
}

- (IBAction)quitAction:(id)sender
{
	[[NSApplication sharedApplication] terminate:self];
}

#pragma mark *** SMARTReporter methods ***

- (void)setMenuIcon:(smartResult)num
{
	asl_NSLog_debug(@"setMenuIcon %i", num);

	static smartResult savednum = kSmartNoData;

	if (num != kSmartJustRedisplay)
		savednum = num;
	else
		num = savednum;

	if (statusItem != nil)
	{
		if ([userDefaults integerForKey:kLookKey] == 1)
		{
			NSDictionary *stringAttributes;

			if (num == kSmartFailing)
				stringAttributes = [NSDictionary dictionaryWithObject:[NSColor redColor] forKey:NSForegroundColorAttributeName];
			else if (num == kSmartVerified)
				stringAttributes = [NSDictionary dictionaryWithObject:[NSColor greenColor] forKey:NSForegroundColorAttributeName];
			else // (num == kSmartNoData)
				stringAttributes = [NSDictionary dictionaryWithObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];

			NSAttributedString *as = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%C", 0x2022] attributes:stringAttributes];

			[statusItem setAttributedTitle:as];
			[statusItem setImage:nil];

			[as release];
		}
		else
		{
			NSImage *image;
			NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"Icons/%d", [userDefaults integerForKey:kIconsetKey]]];

			if (num == kSmartFailing)
			{
				if ([userDefaults boolForKey:kUse_rediconKey] &&
				    ([userDefaults integerForKey:kIconsetKey] != 0) &&
				    ([userDefaults integerForKey:kIconsetKey] != 3) &&
				    ([userDefaults integerForKey:kIconsetKey] != 6))
				{
					if ([userDefaults integerForKey:kIconsetKey] < 3)
						path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Icons/0"];
					else
						path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Icons/3"];
				}

				image = [[NSImage alloc] initWithContentsOfFile:[path stringByAppendingPathComponent:kFailingImageString]];
			}
			else if (num == kSmartVerified)
				image = [[NSImage alloc] initWithContentsOfFile:[path stringByAppendingPathComponent:kVerifiedImageString]];
			else // (num == kSmartNoData)
				image = [[NSImage alloc] initWithContentsOfFile:[path stringByAppendingPathComponent:kNoDataImageString]];

			[statusItem setImage:image];
			[statusItem setTitle:@""];

			[image release];
		}
	}
}

- (void)updateTooltip
{
	[statusItem setToolTip:[NSString stringWithFormat:@"SMARTReporter v%@\n\n%@\n%@\n%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"], smartStatusText, ioErrorCheckStatusText, raidCheckStatusText]];
}
@end