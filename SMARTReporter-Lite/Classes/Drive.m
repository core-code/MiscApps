//
//  Drive.m
//  SMARTReporter
//
//  Created by CoreCode on Sat Feb 28 2004.
/*	Copyright (c) 2004 - 2012 CoreCode
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
// Some code here is derived from Apple Sample Code, but changes have been made

#import "Drive.h"
#import "DriveList.h"
#import "HostInformation.h"
#import <Growl/Growl.h>
//#define TEST_FAIL 1

static IOReturn PrintSMARTDataForBSDNode(const char *bsdNode, char *smart);

@implementation Drive

@synthesize name, smart, model, serial, size, bsdnum, timer, interval, status, watch, driveList;

- (void)getSMARTData
{
#ifdef TEST_FAIL
	static NSDate *stund;
	static uint16_t times = 0;

	if (times == 0)
		stund = [[NSDate alloc] initWithTimeIntervalSinceNow:50.0];
	times++;
#endif

	IOReturn	err;
	uint16_t	i = 0;
	NSString	*bsdName = [NSString stringWithFormat:@"disk%u", [bsdnum unsignedIntValue]];

	err = PrintSMARTDataForBSDNode ([bsdName UTF8String], &status);
	while ((err == kIOReturnNotResponding) && (i < 50))
	{
		usleep(100000);
		err = PrintSMARTDataForBSDNode ([bsdName UTF8String], &status);
		i++;
	}
	if ((status == kSmartVerified) && (err != 0))
		status = kSmartNoData;

#ifdef TEST_FAIL
	#warning ENABLED_FAIL
	if ([stund timeIntervalSinceDate:[NSDate date]] < 0)
	{
		status = kSmartFailing;
		asl_NSLog_debug(@"DEBUG_TEST_FAIL:");
	}
#endif

	if (status == kSmartNoData)
	{
		[self setSmart:NSLocalizedString(@"Unknown", nil)];
		if (watch == TRUE)
			asl_NSLog(ASL_LEVEL_WARNING, @"Drive: '%@' Status: SMARTUNKNOWN (%@)", [self description], NSLocalizedString(@"S.M.A.R.T. condition could not be verified", nil));
	}
	else if (status == kSmartFailing)
	{
		[self setSmart:NSLocalizedString(@"Failing!", nil)];
		if (watch == TRUE)
			asl_NSLog(ASL_LEVEL_EMERG, @"Drive: '%@' Status: SMARTFAILURE (%@)", [self description], NSLocalizedString(@"S.M.A.R.T. condition exceeded, DRIVE COULD FAIL SOON", nil));
	}
	else if (status == kSmartVerified)
	{
		[self setSmart:NSLocalizedString(@"Verified", nil)];
		if (watch == TRUE)
			asl_NSLog(ASL_LEVEL_INFO, @"Drive: '%@' Status: SMARTOK (%@)", [self description], NSLocalizedString(@"S.M.A.R.T. condition not exceeded, drive OK", nil));
	}
}

- (void)notifyIfDriveIsFailing
{
	if ((watch == TRUE) && (status == kSmartFailing))
	{
		
		if ([userDefaults boolForKey:kPopupKey])
		{
			[NSApp activateIgnoringOtherApps:YES];
			NSRunAlertPanel(@"SMARTReporter",
							[NSString stringWithFormat:NSLocalizedString(@"The S.M.A.R.T.-data for the drive %@ indicates an impending drive-failure!\n\nPlease follow the instructions in the 'What to do when SMARTReporter predicts a failure' section in SMARTReporter's FAQ as soon as possible.", nil), model],
							NSLocalizedString(@"OK", nil), nil, nil);
		}
		if ([userDefaults boolForKey:kExecuteKey])
			[[NSWorkspace sharedWorkspace] openFile:[userDefaults stringForKey:@"executepath"]];
		if ([userDefaults boolForKey:kEmailKey])
		{
			[driveList sendMail:self testMode:FALSE];
		}
		if ([userDefaults boolForKey:kGrowlKey])
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
						asl_NSLog(ASL_LEVEL_ERR, @"Error: drive is failing and Growl failure notification is switched on, but Growl is not runnning and although it is supposedly installed we can't find it to start it ourselves.");
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
							asl_NSLog(ASL_LEVEL_ERR, @"Error: drive is failing and d Growl failure notification is switched on, but Growl is not runnning and we can't start it ourselves.");
					}
					
				}
				
				[GrowlApplicationBridge notifyWithTitle:@"SMARTReporter"
											description:[NSString stringWithFormat:NSLocalizedString(@"The S.M.A.R.T.-data for the drive %@ indicates an impending drive-failure!\n\nPlease follow the instructions in the 'What to do when SMARTReporter predicts a failure' section in SMARTReporter's FAQ as soon as possible.", nil), model]
									   notificationName:@"SMARTReporter Drive Failure Notification"
											   iconData:nil
											   priority:2
											   isSticky:YES
										   clickContext:[NSDate date]];
//			}
//			else
//				asl_NSLog(ASL_LEVEL_ERR, @"Error: drive is failing and Growl failure notification is switched on, but Growl is not installed now!");
		}
	}
}

- (void)createTimer
{
	if (watch == TRUE)
		timer = [[NSTimer scheduledTimerWithTimeInterval:[interval doubleValue] * 60 target:self selector:@selector(timerTarget:) userInfo:NULL repeats:YES] retain];
}

- (void)updateTimer
{
	if (((long)[timer timeInterval] != (long) ([interval doubleValue] * 60)) || (watch == FALSE))
	{
		if (timer != nil)
		{
			[timer invalidate];
			[timer release];
			timer = nil;
		}
		[self createTimer];
	}
}

- (void)timerTarget:(NSTimer *)ourtimer
{
	if ([userDefaults boolForKey:kDontcheckwhenonbatteryKey] && [HostInformation hasBattery] && [HostInformation runsOnBattery])
		asl_NSLog_debug(@"Running on Battery, refraining from disk check");
	else
	{
		[self getSMARTData];
		[self notifyIfDriveIsFailing];
		[driveList setMenuIconIfFailing];
	}
}

- (id)init
{
	self = [super init];

	[self setInterval:[NSDecimalNumber decimalNumberWithString:@"60"]];
	[self setSmart:@""];
	[self setWatch:TRUE];

	timer = nil;
	model = nil;
	size = nil;
	serial = nil;
	bsdnum = nil;
	name = nil;

	status = kSmartNoData;

	return self;
}

- (void)dealloc
{
	if (timer != nil)
	{
		[timer invalidate];
		[timer release];
		timer = nil;
	}

	[model release];
	[size release];
	[smart release];
	[serial release];
	[name release];
	[bsdnum release];
	[interval release];


	model = nil;
	size = nil;
	smart = nil;
	serial = nil;
	bsdnum = nil;
	interval = nil;
	name = nil;

	[super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:model forKey:@"model"];
	[coder encodeObject:serial forKey:@"serial"];
	[coder encodeBool:watch forKey:@"watch"];
	[coder encodeObject:interval forKey:@"interval"];
	[coder encodeObject:name forKey:@"name"];
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [self init];

	[self setModel:[coder decodeObjectForKey:@"model"]];
	[self setSerial:[coder decodeObjectForKey:@"serial"]];
	[self setWatch:[coder decodeBoolForKey:@"watch"]];
	[self setInterval:[coder decodeObjectForKey:@"interval"]];
	[self setName:[coder decodeObjectForKey:@"name"]];

	return self;
}

- (NSColor *)smartColor
{
	if (status == kSmartNoData)
		return [NSColor blackColor];
	else if (status == kSmartFailing)
		return [[NSColor redColor] blendedColorWithFraction:0.5f ofColor:[NSColor blackColor]];
	else if (status == kSmartVerified)
		return [[NSColor greenColor] blendedColorWithFraction:0.5f ofColor:[NSColor blackColor]];
	else
		return NULL;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ (%@ | %@ | disk%@)", model, name, serial, [bsdnum stringValue]];
}
@end

//***************************************************************************
//	PrintSMARTData - Prints S.M.A.R.T data
//***************************************************************************
IOReturn PrintSMARTData (io_service_t service, char *smart)
{

	IOCFPlugInInterface	**		cfPlugInInterface 	= NULL;
	IOATASMARTInterface	**		smartInterface		= NULL;
	HRESULT						herr				= S_OK;
	IOReturn					err					= kIOReturnSuccess;
	SInt32						score				= 0;
	Boolean						conditionExceeded	= false;

	err = IOCreatePlugInInterfaceForService ( 	service,
												kIOATASMARTUserClientTypeID,
												kIOCFPlugInInterfaceID,
												&cfPlugInInterface,
												&score);

	require ( ( err == kIOReturnSuccess), ErrorExit);

	herr = ( *cfPlugInInterface)->QueryInterface (
												   cfPlugInInterface,
												   CFUUIDGetUUIDBytes ( kIOATASMARTInterfaceID),
												   ( LPVOID) &smartInterface);

	require ( ( herr == S_OK), ReleasePlugIn);


	require ( ( smartInterface != NULL), ReleasePlugIn);

	err = ( *smartInterface)->SMARTEnableDisableOperations ( smartInterface, true);
	require ( ( err == kIOReturnSuccess), ReleaseInterface);

	err = ( *smartInterface)->SMARTEnableDisableAutosave ( smartInterface, true);
	require ( ( err == kIOReturnSuccess), ReleaseInterface);

	err = ( *smartInterface)->SMARTReturnStatus ( smartInterface, &conditionExceeded);
	require ( ( err == kIOReturnSuccess), ReleaseInterface);


	if ( conditionExceeded)
	{
		*smart = 1; // FAIL
	}
	else
	{
		*smart = 2; // OK
	}


ReleaseInterface:
		( *smartInterface)->Release ( smartInterface);
	smartInterface = NULL;


ReleasePlugIn:
		IODestroyPlugInInterface ( cfPlugInInterface);

ErrorExit:
		return err;
}



//***************************************************************************
//	PrintSMARTDataForBSDNode - Prints S.M.A.R.T data for a particular BSD Node
//***************************************************************************
static IOReturn PrintSMARTDataForBSDNode ( const char *bsdNode, char *smart)
{
	IOReturn		error	= kIOReturnError;
	io_object_t		object	= MACH_PORT_NULL;
	io_object_t		parent	= MACH_PORT_NULL;
	bool			found	= false;
	char *			bsdName = NULL;
	char 			deviceName[15];

	sprintf ( deviceName, "%s", bsdNode);

	if ( !strncmp ( deviceName, "/dev/r", 6))
	{
		// Strip off the /dev/r from /dev/rdiskX
		bsdName = &deviceName[6];
	}

	else if ( !strncmp ( deviceName, "/dev/", 5))
	{
		// Strip off the /dev/r from /dev/rdiskX
		bsdName = &deviceName[5];
	}
	else
	{
		bsdName = deviceName;
	}

	require ( ( strncmp ( bsdName, "disk", 4) == 0), ErrorExit);

	object = IOServiceGetMatchingService ( 	kIOMasterPortDefault, IOBSDNameMatching ( kIOMasterPortDefault, 0, bsdName));

	require ( ( object != MACH_PORT_NULL), ErrorExit);

	parent = object;
	while ((IOObjectConformsTo ( object, kIOBlockStorageDeviceClass) == false))
	{
		error = IORegistryEntryGetParentEntry ( object, kIOServicePlane, &parent);
		require ( ( error == kIOReturnSuccess), ReleaseObject);
		require ( ( parent != MACH_PORT_NULL), ReleaseObject);

		IOObjectRelease ( object);
		object = parent;
	}

	if (IOObjectConformsTo ( object, kIOBlockStorageDeviceClass))
	{
		error = PrintSMARTData ( object, smart);
		found = true;
	}


ReleaseObject:
		require ( ( object != MACH_PORT_NULL), ErrorExit);
	IOObjectRelease ( object);
	//object = MACH_PORT_NULL;


ErrorExit:
		if ( found == false)
		{
			error = kIOReturnNoResources;
		}

	return error;
}
