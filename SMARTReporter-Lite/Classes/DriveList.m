//
//  DriveList.m
//  SMARTReporter
//
//  Created by CoreCode on Sat Feb 28 2004.
/*	Copyright (c) 2016 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import <Growl/Growl.h>
#import "DriveList.h"
#import "SMARTReporter.h"
#import "LoginItemManager.h"
#import "HostInformation.h"

aslclient client = NULL;
@implementation DriveList

@synthesize drives, isGrowlInstalled;

#pragma mark *** NSObject subclass-methods ***

- (id)init
{
	lastPollTime = time(NULL);
	
	self = [super initWithWindowNibName:@"Configuration"];
	
	delegate = nil;
	
	drives = [[NSMutableArray alloc] initWithCapacity:3];
	
	[self logfileAction:self];
	
	asl_NSLog_debug(@"SMARTReporter version %@ started up!", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]);
	
	[self toggleIOErrorCheckAction:self];
	[self toggleRAIDErrorCheckAction:self];

	return self;
}

- (void)dealloc
{
	[(NSNotificationCenter *)[NSNotificationCenter defaultCenter]
	 removeObserver:self
	 name:NSApplicationWillTerminateNotification
	 object:NSApp];
	
	[drives release];
	
	delegate = nil;
	drives = nil;
	
	[ioerrorTimer invalidate];
	[ioerrorTimer release];
	ioerrorTimer = nil;
	
	[raiderrorTimer invalidate];
	[raiderrorTimer release];
	raiderrorTimer = nil;
	
	[super dealloc];
}

#pragma mark *** NSResponder subclass-methods ***

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (void)keyDown:(NSEvent *)theEvent
{
	// paranoiac useless test
	if ([[self window] isVisible]) {
		// tests if command-key is hold down
		if (NSCommandKeyMask & [theEvent modifierFlags]) {
			if ([[theEvent charactersIgnoringModifiers] isEqualToString:@"w"]) {
				[self windowWillClose:nil];
				[[self window] orderOut:nil];
				return;
			}
			if ([[theEvent charactersIgnoringModifiers] isEqualToString:@"q"]) {
				[NSApp terminate:nil];
				return;
			}
		}
		
		NSBeep(); // reproduces Mac Menu behavior :)
	}
}

#pragma mark *** NSCoding protocol-methods ***

- (id)initWithCoder:(NSCoder *)coder
{
	self = [self init];
	
	[self setDrives:[coder decodeObjectForKey:@"drives"]]; // retain]];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:drives forKey:@"drives"];
}

#pragma mark *** NSNibAwaking protocol-methods ***

- (void)awakeFromNib
{
	
	[(NSNotificationCenter *)[NSNotificationCenter defaultCenter]
										  addObserver:self
											 selector:@selector(willTerminate:)
												 name:NSApplicationWillTerminateNotification
											   object:NSApp];
	
	[self iconAction:self];

	[drivetable deselectRow:0];

	if (IsLoginItem())
		[startbutton setState:NSOnState];

	[self setIsGrowlInstalled:[GrowlApplicationBridge isGrowlRunning]];

	[emailUsernameTextField setDelegate:self];
	[emailPasswordTextField setDelegate:self];

}

#pragma mark *** IBAction action-methods ***

- (IBAction)logfileAction:(id)sender
{
	//#ifndef DEBUG
	//freopen([[[userDefaults stringForKey:kLog_filenameKey] stringByExpandingTildeInPath] fileSystemRepresentation], "a", stderr);
	if (!client)
		client = asl_open(/*ident*/ NULL, /*facility*/ NULL, /*options*/ 0U);
	
	int fd = open([[[userDefaults stringForKey:kLog_filenameKey] stringByExpandingTildeInPath] fileSystemRepresentation], O_WRONLY | O_CREAT | O_APPEND, 0644);
	asl_add_log_file(client, fd);
	//close(fd);
	//#endif
}

- (IBAction)updatecheckAction:(id)sender
{
	[delegate setUpdateCheck:[sender indexOfSelectedItem]];
}

- (IBAction)invisibleAction:(id)sender
{
	[userDefaults synchronize];
	
	[NSApp activateIgnoringOtherApps:YES];
	if (NSRunAlertPanel(@"SMARTReporter", NSLocalizedString(@"SMARTReporter needs to be restarted for this option to take effect. Hold down alt (option) during application launch to get the menu-item back.", nil), NSLocalizedString(@"Restart now", nil), NSLocalizedString(@"Restart later", nil), nil) == NSAlertDefaultReturn)
	{
		NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
		
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
			NSRunAlertPanel(@"SMARTReporter", NSLocalizedString(@"SMARTReporter could not restart itself automatically. Please restart it yourself when it is convenient for you.", nil), NSLocalizedString(@"OK", nil), nil, nil);
	}
}

- (IBAction)iconAction:(id)sender
{
	NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"Icons/%d", [iconmenu indexOfSelectedItem]]];
	
	if (([iconmenu indexOfSelectedItem] == 1) || ([iconmenu indexOfSelectedItem] == 2) || ([iconmenu indexOfSelectedItem] == 4) || ([iconmenu indexOfSelectedItem] == 5))
	{
		[redbutton setEnabled:YES];
		[redbutton setState:[userDefaults boolForKey:kUse_rediconKey]];
	}
	else
    {
		[redbutton setEnabled:NO];
		[redbutton setState:NSOnState];
	}
	
	[verifiedview setImage:[[[NSImage alloc] initWithContentsOfFile:[path stringByAppendingPathComponent:kVerifiedImageString]] autorelease]];
	[unknownview setImage:[[[NSImage alloc] initWithContentsOfFile:[path stringByAppendingPathComponent:kNoDataImageString]] autorelease]];
	
	if ([redbutton state] != NSOnState)
		path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"Icons/%d", [iconmenu indexOfSelectedItem]]];
	else
	{
		if ([iconmenu indexOfSelectedItem] < 3)
			path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Icons/0"];
		else if ([iconmenu indexOfSelectedItem] < 6)
			path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Icons/3"];
		else
			path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Icons/6"];
	}
	
	[failingview setImage:[[[NSImage alloc] initWithContentsOfFile:[path stringByAppendingPathComponent:kFailingImageString]] autorelease]];
	
	[delegate setMenuIcon:kSmartJustRedisplay];
}


- (IBAction)configureAction:(id)sender
{
	if ([[userDefaults stringForKey:@"auth_user"] length] && [[userDefaults stringForKey:@"smtp_server"] length])
	{
		[self getPassword];
	}
	
	[NSApp activateIgnoringOtherApps:YES];
	[emailpanel makeKeyAndOrderFront:self];
}

- (IBAction)commitAction:(id)sender
{
	if (![[NSUserDefaultsController sharedUserDefaultsController] commitEditing])
		asl_NSLog(ASL_LEVEL_WARNING, @"Warning: shared user defaults controller could not commit editing");
}

- (IBAction)sendAction:(id)sender
{
	[progressindicator startAnimation:self];
	
	[self commitAction:self];
	[self updatePassword:nil];
	
	[sendbutton setEnabled:FALSE];
	[self sendMail:nil testMode:YES];
}

- (IBAction)startAction:(id)sender
{
	if ([sender state] == NSOnState)
		AddLoginItem();
	else
		RemoveLoginItem();
}

- (IBAction)selectApplicationAction:(id)sender
{
	NSOpenPanel *oPanel = [NSOpenPanel openPanel];
	
	[oPanel setAllowsMultipleSelection:NO];
	
	if ([oPanel runModal] == NSOKButton)
	{
		NSURL *aFile = [[oPanel URLs] objectAtIndex:0];
		
		[userDefaults setObject:[aFile path] forKey:@"executepath"];
		[userDefaults setObject:[[aFile path] lastPathComponent] forKey:kExecutenameKey];
	}
	
	[executemenu selectItemAtIndex:0];
}

- (IBAction)toggleIOErrorCheckAction:(id)sender
{
	if ([userDefaults boolForKey:kIOErrorCheckKey])
	{
		if ((![[NSFileManager defaultManager] isReadableFileAtPath:IOERRORCHECKLOGFILE]))
		{
			[NSApp activateIgnoringOtherApps:YES];
			
			NSRunAlertPanel(@"SMARTReporter", NSLocalizedString(@"Sorry, the I/O error check can only be enabled for Admin-users.", nil), NSLocalizedString(@"OK", nil), nil, nil);
			
			
			[userDefaults setBool:FALSE forKey:kIOErrorCheckKey];
			[userDefaults synchronize];
		}
		else
			ioerrorTimer = [[NSTimer scheduledTimerWithTimeInterval:60 * 10  target:self selector:@selector(ioErrorCheck:) userInfo:NULL repeats:YES] retain];
	}
	else if (ioerrorTimer != nil)
	{
		[ioerrorTimer invalidate];
		[ioerrorTimer release];
		ioerrorTimer = nil;
	}
}

- (IBAction)toggleRAIDErrorCheckAction:(id)sender
{
	if ([userDefaults boolForKey:kCheckRAIDKey])
	{
		raiderrorTimer = [[NSTimer scheduledTimerWithTimeInterval:60 * 10  target:self selector:@selector(raidErrorCheck:) userInfo:NULL repeats:YES] retain];
	}
	else if (raiderrorTimer != nil)
	{
		[raiderrorTimer invalidate];
		[raiderrorTimer release];
		raiderrorTimer = nil;
	}
}

#pragma mark *** NSTabView delegate-methods ***

- (void)tabView:(NSTabView *)tabView willSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	NSRect prefFrame = [[self window] frame];
	float prefHeight = prefFrame.size.height;
	float prefX = prefFrame.origin.x;
	float prefY = prefFrame.origin.y;

	if ([tabView indexOfTabViewItem:tabViewItem] == 0)
		[[self window] setFrame:NSMakeRect(prefX, prefY + (prefHeight - 572), 500, 572) display:YES animate:YES];
	else if ([tabView indexOfTabViewItem:tabViewItem] == 1)
		[[self window] setFrame:NSMakeRect(prefX, prefY + (prefHeight - 353), 500, 353) display:YES animate:YES];
	else
		[[self window] setFrame:NSMakeRect(prefX, prefY + (prefHeight - 478), 500, 478) display:YES animate:YES];
}

#pragma mark *** NSTableView delegate-methods ***
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
//	NSLog(@" %i", [drivetable selectedColumn]);
//	if ([drivetable selectedColumn] == 5)
		[drivetable editColumn:5 row:[drivetable selectedRow] withEvent:nil select:YES];
}
	 
#pragma mark *** NSController delegate-methods ***

- (void)controlTextDidEndEditing:(NSNotification *)aNotification
{
	if ([aNotification object] == emailUsernameTextField)
		[self getPassword];
	else
		[self updatePassword:self];

}

#pragma mark *** NSNotification target-methods ***

- (void)willTerminate:(NSNotification *)noti
{
	if ([[self window] isVisible])
	{		
		[self writeDriveDataFile];
		[self commitAction:self];
	}
}

#pragma mark *** NSWindow delegate-methods ***

- (void)windowWillClose:(NSNotification *)aNotification
{
	if ([NSProcessInfo instancesRespondToSelector:@selector(enableSuddenTermination)])
		[[NSProcessInfo processInfo] enableSuddenTermination];
	
	[self writeDriveDataFile];
	[self commitAction:self];
	
	for (Drive *drive in drives)
		[drive updateTimer];
	
	[NSApp hide:self]; // this is buggy but...
}

#pragma mark *** DriveList methods ***

- (void)getPassword
{
	NSString						*pass;
	UInt32 passwordLength = 0;
	void *password = NULL;
	asl_NSLog_debug(@"getPassword SecKeychainAddInternetPassword");
	OSStatus status = SecKeychainFindInternetPassword(
													  NULL,																	// SecKeychainRef keychain,
													  (UInt32)[[userDefaults stringForKey:@"smtp_server"] length],			// UInt32 serverNameLength,
													  [[userDefaults stringForKey:@"smtp_server"] UTF8String],				// const char *serverName,
													  0,																	// UInt32 securityDomainLength,
													  NULL,																	// const char *securityDomain,
													  (UInt32)[[userDefaults stringForKey:@"auth_user"] length],			// UInt32 accountNameLength,
													  [[userDefaults stringForKey:@"auth_user"] UTF8String],				// const char *accountName,
													  0,																	// UInt32 pathLength,
													  "",																	// const char *path,
													  [userDefaults integerForKey:kSmtp_portKey],                           // UInt16 port,
													  kSecProtocolTypeSMTP,													// SecProtocolType protocol,
													  kSecAuthenticationTypeDefault,										// SecAuthType authType,
													  &passwordLength,                 // UInt32 *passwordLength,
													  &password,                    // void **passwordData,
													  NULL                            // SecKeychainItemRef *itemRef
													  );

	if (status || !passwordLength)
	{
		//NSRunAlertPanel(@"SMARTReporter", NSLocalizedString(@"SMARTReporter could not obtain the e-mail password from the keychain and therefore won't be able to send an e-mail. Please make sure the keychain is unlocked and you give SMARTReporter permission to obtain the password.", nil), NSLocalizedString(@"OK", nil), nil, nil);

		[emailPasswordTextField setStringValue:@""];
	}
	else
	{

		pass = [[[NSString alloc] initWithBytes:(const void *)password length:passwordLength encoding:NSUTF8StringEncoding] autorelease];
		[emailPasswordTextField setStringValue:pass];
	}
}

- (IBAction)updatePassword:(id)sender
{
	[userDefaults synchronize];


	NSString			*pass = [emailPasswordTextField stringValue];

	if (![[userDefaults stringForKey:@"smtp_server"] length] || ![[userDefaults stringForKey:@"auth_user"] length] || ! [pass length])
		return;
																														 
	asl_NSLog_debug(@"updatePassword SecKeychainAddInternetPassword");
	OSStatus status = SecKeychainAddInternetPassword(
													 NULL,																	// SecKeychainRef keychain,
													 (UInt32)[[userDefaults stringForKey:@"smtp_server"] length],			// UInt32 serverNameLength,
													 [[userDefaults stringForKey:@"smtp_server"] UTF8String],				// const char *serverName,
													 0,																		// UInt32 securityDomainLength,
													 NULL,																	// const char *securityDomain,
													 (UInt32) [[userDefaults stringForKey:@"auth_user"] length],			// UInt32 accountNameLength,
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

	if (status == errSecDuplicateItem)
	{
		SecKeychainItemRef itemRef;

		asl_NSLog_debug(@"updatePassword SecKeychainFindInternetPassword");
		status = SecKeychainFindInternetPassword(
														  NULL,																	// SecKeychainRef keychain,
														  (UInt32)[[userDefaults stringForKey:@"smtp_server"] length],			// UInt32 serverNameLength,
														  [[userDefaults stringForKey:@"smtp_server"] UTF8String],				// const char *serverName,
														  0,																	// UInt32 securityDomainLength,
														  NULL,																	// const char *securityDomain,
														  (UInt32)[[userDefaults stringForKey:@"auth_user"] length],			// UInt32 accountNameLength,
														  [[userDefaults stringForKey:@"auth_user"] UTF8String],				// const char *accountName,
														  0,																	// UInt32 pathLength,
														  "",																	// const char *path,
														  [userDefaults integerForKey:kSmtp_portKey],                           // UInt16 port,
														  kSecProtocolTypeSMTP,													// SecProtocolType protocol,
														  kSecAuthenticationTypeDefault,										// SecAuthType authType
														  0,                 // UInt32 *passwordLength,
														  NULL,                    // void **passwordData,
														  &itemRef                            // SecKeychainItemRef *itemRef
														  );

		if (status)
			asl_NSLog(ASL_LEVEL_ERR, @"Error: SMARTReporter could not get the e-mail password of the account used for e-mail sending: %li", (long)status);
		else
		{
			asl_NSLog_debug(@"updatePassword SecKeychainItemModifyAttributesAndData");
			status = SecKeychainItemModifyAttributesAndData (
														 itemRef,         // the item reference
														 NULL,            // no change to attributes
														 (UInt32)[pass length],  // length of password
														 [pass UTF8String]         // pointer to password data
														 );

			if (status)
				asl_NSLog(ASL_LEVEL_ERR, @"Error: SMARTReporter could update the e-mail password of the account used for e-mail sending: %li", (long) status);
		}
	}
}

- (void)doWelcome
{
	[NSApp activateIgnoringOtherApps:YES];
	
	NSRunAlertPanel(@"SMARTReporter",
					NSLocalizedString(@"Welcome to SMARTReporter. This seems to be the first time you start SMARTReporter. The preferences-window will be opened.", nil),
					NSLocalizedString(@"OK", nil), nil, nil);
	
	[delegate configurationAction:self];
}

- (void)refreshDriveList:(id)del
{
	kern_return_t				kernResult;
	CFMutableDictionaryRef		matchingDict;
	io_iterator_t				iter;
	BOOL						added = FALSE, removed = FALSE;

	asl_NSLog_debug(@"driveDescription at refreshDriveList start: %@", [drives description]);

	if (del != nil)
		delegate = del;

	matchingDict = IOServiceMatching(kIOBlockStorageDeviceClass);
	if (matchingDict != NULL)
	{
		kernResult = IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDict, &iter);

		if ((KERN_SUCCESS == kernResult) && (iter != 0) && [self detectDrives:iter])
			added = TRUE;
	}


	NSMutableArray	*invalidDrives = [NSMutableArray array];

	for (Drive *drive in drives)
	{
		[drive setDriveList:self];
		
		if ([[drive smart] isEqualToString:@""]) // This is for the case that a disk is in the list that is no longer valid
		{
			asl_NSLog_debug(@"Drive %@ no longer valid, removing", [drive description]);
			removed = TRUE;
			[invalidDrives addObject:drive];
		}
		else if ([drive timer] == nil)
		{
			asl_NSLog_debug(@"Drive %@ valid, creating timer", [drive description]);
			[drive createTimer];
		}
		else
		{
			asl_NSLog_debug(@"Drive %@ valid, timer created previously", [drive description]);
		}
	}

	if (removed == TRUE)
		[[self mutableArrayValueForKey:@"drives"] removeObjectsInArray:invalidDrives];

	for (Drive *drive in drives)
		[drive notifyIfDriveIsFailing];
	[self setMenuIconIfFailing];

	if ((added == TRUE) && (del != nil) && ([del firstStart] == TRUE) && ![userDefaults boolForKey:@"_EnterpriseDeployment_DisableWelcome"])
	{
		[self performSelector:@selector(doWelcome) withObject:nil afterDelay:0.0]; // work around voice over bug rdar://9255484

	}
	else if (added || removed)
		[self writeDriveDataFile];

	asl_NSLog_debug(@"driveDescription at refreshDriveList end: %@", [drives description]);
}

- (BOOL)detectDrives:(io_iterator_t)iter
{
	BOOL new = FALSE;
	io_object_t object;

	while ((object = IOIteratorNext(iter)))
	{
		Boolean		hasSMART1 = FALSE, hasSMART2 = FALSE;
		CFTypeRef	data;

		data = IORegistryEntryCreateCFProperty(object, CFSTR(kIOPropertySMARTCapableKey), kCFAllocatorDefault, 0);
		if (data)
		{
			asl_NSLog_debug(@"detectDrives found SMART Capable");
			hasSMART1 = CFBooleanGetValue((CFBooleanRef) data);
			CFRelease(data);
		}

		data = IORegistryEntryCreateCFProperty(object, CFSTR(kIOUserClientClassKey), kCFAllocatorDefault, 0); // is this only on OLD OSes so?
		if (data)
		{
			asl_NSLog_debug(@"detectDrives found kIOUserClientClassKey");
			hasSMART2 = [(NSString *)data isEqualToString:@"ATASMARTUserClient"];
			CFRelease(data);
		}

		if (hasSMART1 || hasSMART2)
		{
			SInt64 si64 = 0;
			Drive *drive;

			drive = [[Drive alloc] init];

			data = IORegistryEntrySearchCFProperty(object, kIOServicePlane, CFSTR("Model"), kCFAllocatorDefault, kIORegistryIterateRecursively | kIORegistryIterateParents);
			if (data)
			{
				asl_NSLog_debug(@"Device Model: %@", (NSString *) data);
				[drive setModel:[(NSString *)data stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
				CFRelease(data);
			}
			else
			{
				data = IORegistryEntrySearchCFProperty(object, kIOServicePlane, CFSTR("device model"), kCFAllocatorDefault, kIORegistryIterateRecursively | kIORegistryIterateParents);
				if (data)
				{
					asl_NSLog_debug(@"Device Model: %@", (NSString *) data);
					[drive setModel:[(NSString *)data stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
					CFRelease(data);
				}
				else
				{
					data = IORegistryEntrySearchCFProperty(object, kIOServicePlane, CFSTR("Product Name"), kCFAllocatorDefault, kIORegistryIterateRecursively | kIORegistryIterateParents);
					if (data)
					{
						asl_NSLog_debug(@"Device Model: %@", (NSString *) data);
						[drive setModel:[(NSString *)data stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
						CFRelease(data);
					}
					else
					asl_NSLog(ASL_LEVEL_ERR, @"Error: couldn't get device model");
				}
			}

			data = IORegistryEntrySearchCFProperty(object, kIOServicePlane, CFSTR("Serial Number"), kCFAllocatorDefault, kIORegistryIterateRecursively | kIORegistryIterateParents);
			if (data)
			{
				asl_NSLog_debug(@"Serial Number: %@", (NSString *) data);
				[drive setSerial:[(NSString *)data stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
				CFRelease(data);
			}
			else
			{
				data = IORegistryEntrySearchCFProperty(object, kIOServicePlane, CFSTR("device serial"), kCFAllocatorDefault, kIORegistryIterateRecursively | kIORegistryIterateParents);
				if (data)
				{
					asl_NSLog_debug(@"Serial Number: %@", (NSString *) data);
					[drive setSerial:[(NSString *)data stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
					CFRelease(data);
				}
				else
					asl_NSLog(ASL_LEVEL_ERR, @"Error: couldn't get serial number");
			}

			data = IORegistryEntrySearchCFProperty(object, kIOServicePlane, CFSTR("Size"), kCFAllocatorDefault, kIORegistryIterateRecursively);
			if (data)
			{
				CFNumberGetValue(data, kCFNumberSInt64Type, &si64);
				[drive setSize:[NSString stringWithFormat:@"%d GB", (int) (si64 / 1000000000)]];
				CFRelease(data);
			}
			else
				asl_NSLog(ASL_LEVEL_ERR, @"Error: couldn't get size");

			data = IORegistryEntrySearchCFProperty(object, kIOServicePlane, CFSTR("BSD Name"), kCFAllocatorDefault, kIORegistryIterateRecursively);
			if (data)
			{
				asl_NSLog_debug(@"BSD Name: %@", (NSString *)data);

				if ([(NSString *)data hasPrefix:@"disk"] && ([(NSString *)data length] >= 5))
				{
					NSInteger num = [[(NSString *)data substringFromIndex:4] integerValue];

					[drive setBsdnum:[NSNumber numberWithInteger:num]];
					[drive setName:[HostInformation nameForDevice:num]];
				}
				else
					asl_NSLog(ASL_LEVEL_ERR, @"Error: bsd name doesn't look good %@", (NSString *) data);

				CFRelease(data);
			}
			else
				asl_NSLog(ASL_LEVEL_ERR, @"Error: couldn't get bsd name");

			if ([drive bsdnum] && [drive size] && [drive name])
			{
				NSUInteger di = [self indexOfDriveEqualToDrive:drive];

				if (di != NSNotFound)
				{
					asl_NSLog_debug(@"Drive already exists, replacing");
					[[drives objectAtIndex:di] setBsdnum:[drive bsdnum]];
					[(Drive *)[drives objectAtIndex:di] setSize:[drive size]];
					[(Drive *)[drives objectAtIndex:di] setName:[drive name]];
					[[drives objectAtIndex:di] getSMARTData];

				}
				else
				{
					asl_NSLog_debug(@"Drive is new, inserting");
					new = TRUE;
					[drive getSMARTData];
					[[self mutableArrayValueForKey:@"drives"] insertObject:drive atIndex:0];
				}
			}
			else
			{
				io_name_t devName;
				io_string_t service, usb;

				IORegistryEntryGetName(object, devName);
				IORegistryEntryGetPath(object, kIOServicePlane, service);
				IORegistryEntryGetPath(object, kIOUSBPlane, usb);

				
				asl_NSLog(ASL_LEVEL_ERR, @"Error: skipping drive because of errors - details: tDevice-name = %s\n \tDevice-path in IOService plane = %s\n \tDevice-path in IOUSB plane = %s\n", devName, service, usb);
			}
			[drive release];
		}
		else
		{
			asl_NSLog_debug(@"detectDrives both SMART values false");
		}

		IOObjectRelease(object);
	}
	IOObjectRelease(iter);

	return new;
}

- (void)setMenuIconIfFailing
{
	BOOL failure = FALSE;
	static BOOL firsttime = TRUE;
	static BOOL savedstate;
	int watchedDrives = 0;
	int failingDrives = 0;

	for (Drive *drive in drives)
	{
		if ([drive watch] == TRUE)
			watchedDrives++;
		
		if (([drive watch] == TRUE) && ([drive status] == kSmartFailing))
		{
			failure = TRUE;
			failingDrives++;
		}
	}

	if (firsttime == TRUE)
	{
		firsttime = FALSE;
		savedstate = !failure;
	}

	if (savedstate != failure)
	{
		if (failure == TRUE)
			[delegate setMenuIcon:kSmartFailing];
		else
			[delegate setMenuIcon:kSmartVerified];
		
		savedstate = failure;
	}
	
	if (failure)
		[delegate setSmartStatusText:[NSString stringWithFormat:NSLocalizedString(@"S.M.A.R.T. status: %i of %i drives FAILING", nil), failingDrives, watchedDrives]];
	else
		[delegate setSmartStatusText:[NSString stringWithFormat:NSLocalizedString(@"S.M.A.R.T. status: all %i watched drives OK", nil), watchedDrives]];
	[delegate updateTooltip];
}

- (NSUInteger)indexOfDriveEqualToDrive:(Drive *)otherDrive
{
	for (Drive *drive in drives)
	{
		if (([[drive model] isEqualToString:[otherDrive model]]) && ([[drive serial] isEqualToString:[otherDrive serial]]))
			return [drives indexOfObject:drive];
	}

	return NSNotFound;
}


- (void)writeDriveDataFile
{
	if (![NSKeyedArchiver archiveRootObject:self toFile:DRIVE_DATA_FILE])
	{
		[NSApp activateIgnoringOtherApps:YES];
		NSRunAlertPanel(@"SMARTReporter", [NSString stringWithFormat:NSLocalizedString(@"Error!\nCould not write to file '%@'. Please check Permissions.", nil), DRIVE_DATA_FILE], NSLocalizedString(@"OK", nil), nil, nil);
	}
}

- (NSString *)stringWithReplacedPlaceholders:(NSString *)input testMode:(BOOL)testmode drive:(Drive *)drive
{
	CFStringRef cfs = CSCopyMachineName();

	NSString *output;
	if (testmode)
		output = [input stringByReplacingOccurrencesOfString:@"%D" withString:@"JUST_A_TEST" options:0 range:NSMakeRange(0, [input length])];
	else
		output = [input stringByReplacingOccurrencesOfString:@"%D" withString:[drive description] options:0 range:NSMakeRange(0, [input length])];
	
	output = [output stringByReplacingOccurrencesOfString:@"%N" withString:(cfs ? (NSString *)cfs : @"") options:0 range:NSMakeRange(0, [output length])];
	output = [output stringByReplacingOccurrencesOfString:@"%4" withString:[HostInformation ipAddress:false] options:0 range:NSMakeRange(0, [output length])];
	output = [output stringByReplacingOccurrencesOfString:@"%6" withString:[HostInformation ipAddress:true] options:0 range:NSMakeRange(0, [output length])];
	output = [output stringByReplacingOccurrencesOfString:@"%M" withString:[HostInformation macAddress] options:0 range:NSMakeRange(0, [output length])];
	output = [output stringByReplacingOccurrencesOfString:@"%H" withString:[HostInformation ipName] options:0 range:NSMakeRange(0, [output length])];
	
	if (cfs)
		CFRelease(cfs);
	
	return output;
}

- (void)sendMail:(Drive *)drive testMode:(BOOL)testmode
{
	NSString *header;
	NSString *body;
	uint16_t timeout;


	if (testmode == TRUE)
	{
		header = [self stringWithReplacedPlaceholders:[userDefaults stringForKey:kTest_mail_headerKey] testMode:testmode drive:drive];
		timeout = 10;
		body = [self stringWithReplacedPlaceholders:[NSLocalizedString(@"This is just a TEST!\nContents of e-mail-test below:\n\n", nil)
													 stringByAppendingString:[userDefaults stringForKey:kMail_bodyKey]] testMode:testmode drive:drive];
	}
	else
	{
		header = [self stringWithReplacedPlaceholders:[userDefaults stringForKey:kError_mail_headerKey] testMode:testmode drive:drive];
		timeout = 80;
		body = [self stringWithReplacedPlaceholders:[userDefaults stringForKey:kMail_bodyKey] testMode:testmode drive:drive];
	}


	



	smtpResult result;

	if ([userDefaults boolForKey:kEmail_settingsKey])
	{
		NSString						*pass = @"";
		UInt32 passwordLength = 0;
		void *password = NULL;
		OSStatus status = SecKeychainFindInternetPassword(
														  NULL,																	// SecKeychainRef keychain,
														  (UInt32)[[userDefaults stringForKey:@"smtp_server"] length],			// UInt32 serverNameLength,
														  [[userDefaults stringForKey:@"smtp_server"] UTF8String],				// const char *serverName,
														  0,																	// UInt32 securityDomainLength,
														  NULL,																	// const char *securityDomain,
														  (UInt32)[[userDefaults stringForKey:@"auth_user"] length],			// UInt32 accountNameLength,
														  [[userDefaults stringForKey:@"auth_user"] UTF8String],				// const char *accountName,
														  0,																	// UInt32 pathLength,
														  "",																	// const char *path,
														  [userDefaults integerForKey:kSmtp_portKey],                           // UInt16 port,
														  kSecProtocolTypeSMTP,													// SecProtocolType protocol,
														  kSecAuthenticationTypeDefault,										// SecAuthType authType,
														  &passwordLength,                 // UInt32 *passwordLength,
														  &password,                    // void **passwordData,
														  NULL                            // SecKeychainItemRef *itemRef
														  );

		if (status || !passwordLength)
			asl_NSLog(ASL_LEVEL_CRIT, @"Critical: SMARTReporter could not obtain the e-mail password from the keychain and therefore won't be able to send an e-mail. Please make sure the keychain is unlocked and you give SMARTReporter permission to obtain the password.");
		else
			pass = [[[NSString alloc] initWithBytes:(const void *)password length:passwordLength encoding:NSUTF8StringEncoding] autorelease];

		result = [JMEmailSender	sendMailWithMailCore: body
											 subject: header
											  server: [userDefaults stringForKey:@"smtp_server"]
												port: [userDefaults integerForKey:kSmtp_portKey]
												from: [userDefaults stringForKey:@"email_source"]
												  to: [userDefaults stringForKey:@"emailaddress"]
												auth:[[NSUserDefaults standardUserDefaults] boolForKey:kUse_authenticationKey]
												 tls:[[NSUserDefaults standardUserDefaults] boolForKey:kUse_encryptionKey]
											username:[[NSUserDefaults standardUserDefaults] stringForKey:@"auth_user"]
											password:pass];
	}
	else
		result = [JMEmailSender	sendMailWithScriptingBridge: body
										subject: header
                                        timeout: timeout
											 to: [userDefaults stringForKey:@"emailaddress"]];

	if (result != kSuccess)
	{
		NSString *msg;

		if (testmode == TRUE)
			msg = NSLocalizedString(@"The E-Mail delivery failed!\n", nil);
		else
			msg = NSLocalizedString(@"The E-Mail failure notification delivery failed!\n", nil);

		switch (result)
		{
			default:
			case kScriptingBridgeFailure:
				msg = [msg stringByAppendingString:NSLocalizedString(@"Delivery using Mail.app settings didn't seem to be successful so you should use manual configuration.", nil)];
				break;
			case kMailCoreFailure:
				msg = [msg stringByAppendingString:NSLocalizedString(@"Please check the e-mail settings.", nil)];
				break;
			case kToNilFailure:
				msg = [msg stringByAppendingString:NSLocalizedString(@"Delivery can't proceed because you've set no address to deliver to.", nil)];
				break;
			case kFromNilFailure:
				msg = [msg stringByAppendingString:NSLocalizedString(@"Delivery can't proceed because you've set no address to deliver from.", nil)];
				break;
		}

		[NSApp activateIgnoringOtherApps:YES];
		NSRunAlertPanel(@"SMARTReporter", msg, NSLocalizedString(@"OK", nil), nil, nil);
	}

	[sendbutton setEnabled:TRUE];

	[progressindicator stopAnimation:self];
}

- (void)setTooltipIOErrorOK
{
	[delegate setIoErrorCheckStatusText:[NSString stringWithFormat:NSLocalizedString(@"I/O Error check (%@): all %i watched drives OK", nil), [[NSDate date] descriptionWithCalendarFormat:@"%H:%M" timeZone:nil locale:nil], [drives count]]];
	[delegate updateTooltip];
}

- (void)ioErrorCheck:(NSTimer*)theTimer
{
#ifdef DEBUG
	NSDate *pre = [NSDate date];
#endif
	FILE *f = fopen([IOERRORCHECKLOGFILE UTF8String], "rb");
	
	if (f == NULL)
	{
		asl_NSLog(ASL_LEVEL_WARNING, @"Warning: could not open the system logfile %@ for checking for I/O-Errors. Errno: %i", IOERRORCHECKLOGFILE, errno);
		fclose(f);
		[self setTooltipIOErrorOK];
		return;
	}	
	
	long fileSize;
	size_t result;
	
	fseek(f, 0, SEEK_END);
	fileSize = ftell(f);
	NSInteger oldFileSize = [[NSUserDefaults standardUserDefaults] integerForKey:kIOErrorCheckLastCheckFilesizeKey];

	if (fileSize == 0)
	{
		asl_NSLog_debug(@"IOERRORCHECK logfile empty, stop");
		fclose(f);
				[self setTooltipIOErrorOK];
		return;
	}
	if (fileSize == oldFileSize)
	{
		asl_NSLog_debug(@"IOERRORCHECK file didn't grow, stop");
		fclose(f);
				[self setTooltipIOErrorOK];
		return;
	}
	if (fileSize < oldFileSize)
	{
		asl_NSLog_debug(@"IOERRORCHECK file smaller (rotated), reading everything");
		oldFileSize = 0;
	}
	
	fseek(f, oldFileSize, SEEK_SET);
	long bytesToRead = fileSize - oldFileSize;


	asl_NSLog_debug(@"IOERRORCHECK going to read %li bytes (old filesize %li, new filesize %li)", bytesToRead, (long)oldFileSize, fileSize);
	
	void *logData = malloc(bytesToRead);
	if (!logData)
	{
		asl_NSLog(ASL_LEVEL_WARNING, @"Warning: could not allocate memory for checking the system logfile %@ for for I/O-Errors. Errno: %i", IOERRORCHECKLOGFILE, errno);
		fclose(f);
				[self setTooltipIOErrorOK];
		return;
	}	
	
	result = fread(logData, bytesToRead, 1, f);
	fclose(f);
	
	[[NSUserDefaults standardUserDefaults] setInteger:fileSize forKey:kIOErrorCheckLastCheckFilesizeKey]; 

	if (result != 1)
	{
		asl_NSLog(ASL_LEVEL_WARNING, @"Warning: skipping I/O-Error check: actual read from %@ for I/O-Error check failed %i %i %i %i!", IOERRORCHECKLOGFILE, ferror(f), oldFileSize, fileSize, bytesToRead);
				[self setTooltipIOErrorOK];
        free(logData);
		return;
	}	
		
	
	
	if (bytesToRead > 1048576)
	{
		asl_NSLog(ASL_LEVEL_WARNING, @"Warning: skipping I/O-Error check: system logfile (%@) grew by more than 1MB in 10 minutes, something is spamming your logfile!", IOERRORCHECKLOGFILE);
				[self setTooltipIOErrorOK];
		return;
	}
	
	
	NSString *logString = [[NSString alloc] initWithBytes:logData length:bytesToRead encoding:NSUTF8StringEncoding];
    free(logData);
	NSRange range = [logString rangeOfString:@"I/O error"];
	if (range.location == NSNotFound)
	{
		[logString release];
#ifdef DEBUG
		asl_NSLog_debug(@"I/O-Error checking took %f ", [[NSDate date] timeIntervalSinceDate:pre]);
#endif
				[self setTooltipIOErrorOK];
		return;
	}

	NSCharacterSet *lineSeparatingSet = [NSCharacterSet characterSetWithCharactersInString:@"\n\r"];
	NSArray *logLines = [logString componentsSeparatedByCharactersInSet:lineSeparatingSet];
	NSMutableDictionary *warnedDrives = [NSMutableDictionary dictionary];
	[logString release];

	for (NSString *line in logLines)
	{
		if ([line length] < 10)
			continue;

		range = [line rangeOfString:@"I/O error"];
		if (range.location == NSNotFound)
			continue;

		range = [line rangeOfString:@"kernel" options:NSCaseInsensitiveSearch];
		if (range.location == NSNotFound)
			continue;


		
		NSArray *components = [line componentsSeparatedByString:@"disk"];
		if ([components count] < 2)
			continue;
		NSString *driveNumHelper = [components objectAtIndex:1];
		uint8_t i;

		for (i = 0; i < [driveNumHelper length]; i++)
		{
			unichar c = [driveNumHelper characterAtIndex:i];
			if (c < '0' || c > '9')
				break;
		}

		uint8_t driveNum = [[driveNumHelper substringToIndex:i] integerValue];

		for (Drive *dr in drives)
		{
			if ([[dr bsdnum] unsignedIntValue] == driveNum && ([warnedDrives objectForKey:[dr bsdnum]] == nil))
			{
				[NSApp activateIgnoringOtherApps:YES];
				[warnedDrives setObject:@"YES" forKey:[dr bsdnum]];
				NSString *warning = [NSString stringWithFormat:NSLocalizedString(@"SMARTReporter has detected an I/O Error on the drive named %@! This is not a S.M.A.R.T. error, but repeated errors still can indicate a failing drive. You can turn off this warning in the preferences. Full msg:\n\n%@", nil), [dr name], line];
				
				if (NSRunAlertPanel(@"SMARTReporter", warning, NSLocalizedString(@"OK! Open Console.app!", nil), NSLocalizedString(@"Cancel", nil), nil) == NSOKButton)
					[[NSWorkspace sharedWorkspace] openFile:IOERRORCHECKLOGFILE withApplication:@"Console.app"];
			}
		}
	}
	
	if ([warnedDrives count])
	{
		[delegate setIoErrorCheckStatusText:[NSString stringWithFormat:NSLocalizedString(@"I/O Error check (%@): FAILING - found I/O Errors on %i drive(s)", nil), [[NSDate date] descriptionWithCalendarFormat:@"%H:%M" timeZone:nil locale:nil], [warnedDrives count]]];
			[delegate updateTooltip];
	}
	else
		[self setTooltipIOErrorOK];

	
#ifdef DEBUG
	asl_NSLog_debug(@"I/O-Error checking took %f ", [[NSDate date] timeIntervalSinceDate:pre]);
#endif
}

- (void)raidErrorCheck:(NSTimer*)theTimer
{
	//NSDate *pre = [NSDate date];
	int raidSets = 0;
	int offlineSets = 0;
	int degradedSets = 0;
	
	NSTask *task = [[NSTask alloc] init];
	NSPipe *taskPipe = [NSPipe pipe];
	NSFileHandle *fileHandle = [taskPipe fileHandleForReading];
	
	[task setCurrentDirectoryPath:@"/usr/sbin/"];
	[task setLaunchPath:@"/usr/sbin/diskutil"];
	[task setStandardOutput:taskPipe];
	[task setArguments:[NSArray arrayWithObjects:@"listRAID", nil]];
	
	[task launch];
	[task waitUntilExit];
	
	NSData *data = [fileHandle readDataToEndOfFile];
	NSString *string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	NSArray *array = [string componentsSeparatedByString:@"\n"];
	
	
#ifdef DEBUG
	asl_NSLog_debug(@"RAID check diskutil got %@ ", [array description]);
#endif	
	
	BOOL checkOnlyDegradation = [[NSUserDefaults standardUserDefaults] boolForKey:kRAIDStatusKey];
	BOOL failure = FALSE;
	for (NSString *line in array)
	{
		if ([line hasPrefix:@"Status:"])
		{
			raidSets++;
			
			BOOL isDegraded = ([line rangeOfString:@"Degraded"].location != NSNotFound);
			BOOL isOffline = ([line rangeOfString:@"Offline"].location != NSNotFound);
			
			offlineSets += isOffline;
			degradedSets += isDegraded;			
			
			if (checkOnlyDegradation && isDegraded) 
				failure = TRUE;
			else if (!checkOnlyDegradation && ([line rangeOfString:@"Online"].location == NSNotFound))
				failure = TRUE;
		}	
	}
	
	if (failure)
	{
		if ([[NSUserDefaults standardUserDefaults] boolForKey:kRAIDNotPopupKey])
		{
			[NSApp activateIgnoringOtherApps:YES];

			NSRunAlertPanel(@"SMARTReporter", [NSString stringWithFormat:NSLocalizedString(@"SMARTReporter has detected a problem with an attached RAID! Full msg:\n\n%@", nil), string], NSLocalizedString(@"OK", nil), nil, nil);
		}
		if ([[NSUserDefaults standardUserDefaults] boolForKey:kRAIDNotEmailKey])
		{
			smtpResult result;
			
			if ([userDefaults boolForKey:kEmail_settingsKey])
			{
				NSString						*pass = @"";
				UInt32 passwordLength = 0;
				void *password = NULL;
				OSStatus status = SecKeychainFindInternetPassword(
																  NULL,																	// SecKeychainRef keychain,
																  (UInt32)[[userDefaults stringForKey:@"smtp_server"] length],			// UInt32 serverNameLength,
																  [[userDefaults stringForKey:@"smtp_server"] UTF8String],				// const char *serverName,
																  0,																	// UInt32 securityDomainLength,
																  NULL,																	// const char *securityDomain,
																  (UInt32)[[userDefaults stringForKey:@"auth_user"] length],			// UInt32 accountNameLength,
																  [[userDefaults stringForKey:@"auth_user"] UTF8String],				// const char *accountName,
																  0,																	// UInt32 pathLength,
																  "",																	// const char *path,
																  [userDefaults integerForKey:kSmtp_portKey],                           // UInt16 port,
																  kSecProtocolTypeSMTP,													// SecProtocolType protocol,
																  kSecAuthenticationTypeDefault,										// SecAuthType authType,
																  &passwordLength,                 // UInt32 *passwordLength,
																  &password,                    // void **passwordData,
																  NULL                            // SecKeychainItemRef *itemRef
																  );
				
				if (status || !passwordLength)
					asl_NSLog(ASL_LEVEL_CRIT, @"Critical: SMARTReporter could not obtain the e-mail password from the keychain and therefore won't be able to send an e-mail for the RAID error notification. Please make sure the keychain is unlocked and you give SMARTReporter permission to obtain the password.");
				else
					pass = [[[NSString alloc] initWithBytes:(const void *)password length:passwordLength encoding:NSUTF8StringEncoding] autorelease];
				
				result = [JMEmailSender	sendMailWithMailCore: [NSString stringWithFormat:NSLocalizedString(@"SMARTReporter has detected a problem with an attached RAID! Full msg:\n\n%@", nil), string]
													 subject: @"SMARTReporter RAID Problem Notification"
													  server: [userDefaults stringForKey:@"smtp_server"]
														port: [userDefaults integerForKey:kSmtp_portKey]
														from: [userDefaults stringForKey:@"email_source"]
														  to: [userDefaults stringForKey:@"emailaddress"]
														auth:[[NSUserDefaults standardUserDefaults] boolForKey:kUse_authenticationKey]
														 tls:[[NSUserDefaults standardUserDefaults] boolForKey:kUse_encryptionKey]
													username:[[NSUserDefaults standardUserDefaults] stringForKey:@"auth_user"]
													password:pass];
			}
			else
				result = [JMEmailSender	sendMailWithScriptingBridge: [NSString stringWithFormat:NSLocalizedString(@"SMARTReporter has detected a problem with an attached RAID! Full msg:\n\n%@", nil), string]
															subject: @"SMARTReporter RAID Problem Notification"
															timeout: 80
																 to: [userDefaults stringForKey:@"emailaddress"]];
			
			if (result != kSuccess)
			{
				asl_NSLog(ASL_LEVEL_ERR, @"Error: delivering an E-mail warning about the RAID status failed!");
			}
		}
		if ([[NSUserDefaults standardUserDefaults] boolForKey:kRAIDNotGrowlKey])
		{
//			if( [GrowlApplicationBridge isGrowlInstalled])
//			{
				if (![GrowlApplicationBridge isGrowlRunning])
				{
					NSString *userPath = [@"~/Library/PreferencePanes/Growl.prefPane/Contents/Resources/GrowlHelperApp.app" stringByExpandingTildeInPath];
					NSString *systemPath = @"/Library/PreferencePanes/Growl.prefPane/Contents/Resources/GrowlHelperApp.app";
					NSURL *url = nil;
					if ([[NSFileManager defaultManager] fileExistsAtPath:userPath])
						url	= [NSURL fileURLWithPath:userPath];
					else if ([[NSFileManager defaultManager] fileExistsAtPath:systemPath])
						url	= [NSURL fileURLWithPath:systemPath];
					
					if (!url)
						asl_NSLog(ASL_LEVEL_ERR, @"Error: RAID error and Growl failure notification is switched on, but Growl is not runnning and although it is supposedly installed we can't find it to start it ourselves.");
					else
					{
						LSLaunchURLSpec launchSpec;
						launchSpec.appURL = (CFURLRef)url;
						launchSpec.itemURLs = NULL;
						launchSpec.passThruParams = NULL;
						launchSpec.asyncRefCon = NULL;
						launchSpec.launchFlags = kLSLaunchDefaults | kLSLaunchDontAddToRecents | kLSLaunchDontSwitch;
						
						
						OSErr err = LSOpenFromURLSpec(&launchSpec, NULL);
						if (err != noErr)
							asl_NSLog(ASL_LEVEL_ERR, @"Error: RAID error and Growl failure notification is switched on, but Growl is not runnning and we can't start it ourselves.");
					}
					
				}
				
				[GrowlApplicationBridge notifyWithTitle:@"SMARTReporter"
											description:[NSString stringWithFormat:NSLocalizedString(@"SMARTReporter has detected a problem with an attached RAID! Full msg:\n\n%@", nil), string]
									   notificationName:@"SMARTReporter RAID Problem Notification"
											   iconData:nil
											   priority:2
											   isSticky:YES
										   clickContext:[NSDate date]];
//			}
//			else
//				asl_NSLog(ASL_LEVEL_ERR, @"Error: RAID error and Growl failure notification is switched on, but Growl is not installed now!");			
		}
	}

		
	
	//NSDate *post = [NSDate date];
	
	//NSLog(@"RAID error checking took %f ", [post timeIntervalSinceDate:pre]);
	[task release];
	[string release];
	
	if (!raidSets)
		[delegate setRaidCheckStatusText:[NSString stringWithFormat:NSLocalizedString(@"R.A.I.D. check (%@): no RAID sets found", nil), [[NSDate date] descriptionWithCalendarFormat:@"%H:%M" timeZone:nil locale:nil]]];
	else
	{
		if (!degradedSets && !offlineSets)
			[delegate setRaidCheckStatusText:[NSString stringWithFormat:NSLocalizedString(@"R.A.I.D. check (%@): all %i RAID sets ONLINE", nil), [[NSDate date] descriptionWithCalendarFormat:@"%H:%M" timeZone:nil locale:nil], raidSets]];
		else if (degradedSets && !offlineSets)
			[delegate setRaidCheckStatusText:[NSString stringWithFormat:NSLocalizedString(@"R.A.I.D. check (%@): %i of %i RAID sets DEGRADED", nil), [[NSDate date] descriptionWithCalendarFormat:@"%H:%M" timeZone:nil locale:nil], degradedSets, raidSets]];
		else if (!degradedSets && offlineSets)
			[delegate setRaidCheckStatusText:[NSString stringWithFormat:NSLocalizedString(@"R.A.I.D. check (%@): %i of %i RAID sets OFFLINE", nil), [[NSDate date] descriptionWithCalendarFormat:@"%H:%M" timeZone:nil locale:nil], offlineSets, raidSets]];
		else if (degradedSets && offlineSets)
			[delegate setRaidCheckStatusText:[NSString stringWithFormat:NSLocalizedString(@"R.A.I.D. check (%@): %i RAID sets OFFLINE and %i RAID sets DEGRADED", nil), [[NSDate date] descriptionWithCalendarFormat:@"%H:%M" timeZone:nil locale:nil], offlineSets, degradedSets]];
	}

	[delegate updateTooltip];
}
@end
