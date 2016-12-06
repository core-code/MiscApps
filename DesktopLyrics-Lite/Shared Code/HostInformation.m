//
//  HostInformation.m
//
//  Created by CoreCode on 16.01.05.
/*	Copyright (c) 2016 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
// Some code here is derived from Apple Sample Code, but changes have been made

#import "HostInformation.h"

#include <sys/socket.h>
#include <ifaddrs.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <net/if.h>
#include <SystemConfiguration/SystemConfiguration.h>

extern CFStringRef IOPSGetProvidingPowerSourceType(CFTypeRef ps_blob);
extern CFBooleanRef IOPSPowerSourceSupported(CFTypeRef ps_blob, CFStringRef ps_type);
#define kIOPMBatteryPowerKey "Battery Power"
static kern_return_t FindEthernetInterfaces(io_iterator_t *matchingServices);
static kern_return_t GetMACAddress(io_iterator_t intfIterator, UInt8 *MACAddress);


@implementation HostInformation

+ (NSString *)macAddress
{
	NSString *result = @"";
	kern_return_t kernResult = KERN_SUCCESS;

	io_iterator_t intfIterator;
	UInt8 MACAddress[kIOEthernetAddressSize];

	kernResult = FindEthernetInterfaces(&intfIterator);

	if (KERN_SUCCESS != kernResult)
		asl_NSLog(ASL_LEVEL_ERR, @"Error:	FindEthernetInterfaces returned 0x%08x\n", kernResult);
	else
	{
		kernResult = GetMACAddress(intfIterator, MACAddress);

		if (KERN_SUCCESS != kernResult)
			asl_NSLog(ASL_LEVEL_ERR, @"Error:	GetMACAddress returned 0x%08x\n", kernResult);
		else
		{
			uint8_t i;

			for (i = 0; i < kIOEthernetAddressSize; i++)
			{
				if (![result isEqualToString:@""])
					result = [result stringByAppendingString:@":"];

				if (MACAddress[i] <= 15)
					result = [result stringByAppendingString:@"0"];

				result = [result stringByAppendingFormat:@"%x", MACAddress[i]];
			}
		}
	}

	(void) IOObjectRelease(intfIterator);

	return result;
}

+ (NSString *)ipAddress:(bool)ipv6
{
//	NSArray *a = [[NSHost currentHost] addresses]; // [NSHost currentHost]  broken
//	NSMutableArray *b = [NSMutableArray arrayWithCapacity:[a count]];
//	unsigned char i;
//	unsigned char longestitem = 0, longest = 0;
//
//	for (i = 0; i < [a count]; i++)
//	{
//		if ([[a objectAtIndex:i] rangeOfString:ipv6 ? @":" : @"."].location != NSNotFound)
//			[b addObject:[a objectAtIndex:i]];
//	}
//
//
//	if ([b count] <= 1)
//		return [b objectAtIndex:0];
//
//	[b removeObjectIdenticalTo:ipv6 ? @"::1" : @"127.0.0.1"];
//
//	if ([b count] <= 1)
//		return [b objectAtIndex:0];
//
//
//	for (i = 0; i < [b count]; i++)
//	{
//		if ([(NSString *)[b objectAtIndex:i] length] > longest)
//		{
//			longest = [(NSString *)[b objectAtIndex:i] length];
//			longestitem = i;
//		}
//	}
//
//
//	return [b objectAtIndex:longestitem];
	struct ifaddrs *myaddrs, *ifa;
	struct sockaddr_in *s4;
	struct sockaddr_in6 *s6;
	int status;
	/* buf must be big enough for an IPv6 address (e.g. 3ffe:2fa0:1010:ca22:020a:95ff:fe8a:1cf8) */
	char buf[64];

	status = getifaddrs(&myaddrs);
	if (status != 0)
	{
		perror("getifaddrs");
		exit(1);
	}

	for (ifa = myaddrs; ifa != NULL; ifa = ifa->ifa_next)
	{
		if (ifa->ifa_addr == NULL) continue;
		if ((ifa->ifa_flags & IFF_UP) == 0) continue;

		if ((ifa->ifa_addr->sa_family == AF_INET) && !ipv6)
		{
			s4 = (struct sockaddr_in *)(ifa->ifa_addr);
			if (inet_ntop(ifa->ifa_addr->sa_family, (void *)&(s4->sin_addr), buf, sizeof(buf)) == NULL)
			{
				//printf("%s: inet_ntop failed!\n", ifa->ifa_name);
			}
			else
			{
				//printf("%s: %s\n", ifa->ifa_name, buf);

				if (![[NSString stringWithUTF8String:ifa->ifa_name] hasPrefix:@"lo"])
				{
					freeifaddrs(myaddrs);
					NSString *ip = [NSString stringWithUTF8String:buf];
					if (ip)
						return ip;
				}
			}
		}
		else if ((ifa->ifa_addr->sa_family == AF_INET6) && ipv6)
		{
			s6 = (struct sockaddr_in6 *)(ifa->ifa_addr);
			if (inet_ntop(ifa->ifa_addr->sa_family, (void *)&(s6->sin6_addr), buf, sizeof(buf)) == NULL)
			{
				//printf("%s: inet_ntop failed!\n", ifa->ifa_name);
			}
			else
			{
				//printf("%s: %s\n", ifa->ifa_name, buf);

				if (![[NSString stringWithUTF8String:ifa->ifa_name] hasPrefix:@"lo"])
				{
					freeifaddrs(myaddrs);
					NSString *ip = [NSString stringWithUTF8String:buf];
					if (ip)
						return ip;
				}
			}
		}
	}

	freeifaddrs(myaddrs);

	return ipv6 ? @"::1" : @"127.0.0.1";
}

+ (NSString *)ipName
{
	//return [[NSHost currentHost] name]; // [NSHost currentHost]  broken

	SCDynamicStoreRef dynRef = SCDynamicStoreCreate(kCFAllocatorSystemDefault, (CFStringRef)@"SMARTReporter", NULL, NULL);
    NSString *hostname = [(NSString *)SCDynamicStoreCopyLocalHostName(dynRef) autorelease];
    CFRelease(dynRef);

    if (hostname)
		return [hostname stringByAppendingString:@".local"];
	else
		return @"";
}

+ (NSString *)machineType
{
	char modelBuffer[256];
	size_t sz = sizeof(modelBuffer);
	if (0 == sysctlbyname("hw.model", modelBuffer, &sz, NULL, 0))
	{
		modelBuffer[sizeof(modelBuffer) - 1] = 0;
		return [NSString stringWithUTF8String:modelBuffer];
	}
	else
	{
		return @"";
	}
}

+ (NSString *)nameForDevice:(NSInteger)deviceNumber
{
	NSMutableString *name = [NSMutableString stringWithCapacity:12];
	OSErr			result = noErr;
	ItemCount			volumeIndex;


	// Iterate across all mounted volumes using FSGetVolumeInfo. This will return nsvErr
	// (no such volume) when volumeIndex becomes greater than the number of mounted volumes.
	for (volumeIndex = 1; result == noErr || result != nsvErr; volumeIndex++)
	{
		FSVolumeRefNum	actualVolume;
		HFSUniStr255	volumeName;
		FSVolumeInfo	volumeInfo;

		bzero((void *) &volumeInfo, sizeof(volumeInfo));

		// We're mostly interested in the volume reference number (actualVolume)
		result = FSGetVolumeInfo(kFSInvalidVolumeRefNum,
								 volumeIndex,
								 &actualVolume,
								 kFSVolInfoFSInfo,
								 &volumeInfo,
								 &volumeName,
								 NULL);

		if (result == noErr)
		{
			GetVolParmsInfoBuffer volumeParms;

			result = FSGetVolumeParms (actualVolume, &volumeParms, sizeof(volumeParms));

			if (result != noErr)
				asl_NSLog(ASL_LEVEL_ERR, @"Error:	FSGetVolumeParms returned %d\n", result);
			else
			{
				if ((char *)volumeParms.vMDeviceID != NULL)
				{
					NSString *bsdName = [NSString stringWithUTF8String:(char *)volumeParms.vMDeviceID];

					if ([bsdName hasPrefix:@"disk"])
					{
						NSString *shortBSDName = [bsdName substringFromIndex:4];

						NSArray *components = [shortBSDName componentsSeparatedByString:@"s"];

						if (([components count] > 1) && (!([shortBSDName isEqualToString:[components objectAtIndex:0]])))
						{
							if ([[components objectAtIndex:0] integerValue] == deviceNumber)
							{
								if (![name isEqualToString:@""])
									[name appendString:@", "];

								[name appendString:[NSString stringWithCharacters:volumeName.unicode length:volumeName.length]];
							}
						}
					}
				}
				else
					asl_NSLog(ASL_LEVEL_ERR, @"Error:	volumeParms.vMDeviceID == NULL\n");
			}
		}
	}

	return [NSString stringWithString:name];
}

+ (NSString *)bsdPathForVolume:(NSString *)volume	// TODO: merge with above
{
	OSErr			result = noErr;
	ItemCount			volumeIndex;

	// Iterate across all mounted volumes using FSGetVolumeInfo. This will return nsvErr
	// (no such volume) when volumeIndex becomes greater than the number of mounted volumes.
	for (volumeIndex = 1; result == noErr || result != nsvErr; volumeIndex++)
	{
		FSVolumeRefNum	actualVolume;
		HFSUniStr255	volumeName;
		FSVolumeInfo	volumeInfo;

		bzero((void *) &volumeInfo, sizeof(volumeInfo));

		// We're mostly interested in the volume reference number (actualVolume)
		result = FSGetVolumeInfo(kFSInvalidVolumeRefNum,
								 volumeIndex,
								 &actualVolume,
								 kFSVolInfoFSInfo,
								 &volumeInfo,
								 &volumeName,
								 NULL);

		if (result == noErr)
		{
			GetVolParmsInfoBuffer volumeParms;
			result = FSGetVolumeParms (actualVolume, &volumeParms, sizeof(volumeParms));


			if (result != noErr)
				asl_NSLog(ASL_LEVEL_ERR, @"Error:	FSGetVolumeParms returned %d\n", result);
			else
			{
				if ((char *)volumeParms.vMDeviceID != NULL)
				{
					// This code is just to convert the volume name from a HFSUniCharStr to
					// a plain C string so we can print it with printf. It'd be preferable to
					// use CoreFoundation to work with the volume name in its Unicode form.
					CFStringRef	volNameAsCFString;

					volNameAsCFString = CFStringCreateWithCharacters(kCFAllocatorDefault,
																	 volumeName.unicode,
																	 volumeName.length);

					[(NSString *)volNameAsCFString autorelease];

					if ([volume isEqualToString:(NSString *)volNameAsCFString])
						return [NSString stringWithFormat:@"/dev/rdisk%@", [[[[NSString stringWithUTF8String:(char *)volumeParms.vMDeviceID] substringFromIndex:4] componentsSeparatedByString:@"s"] objectAtIndex:0]];
				}
				else
					asl_NSLog(ASL_LEVEL_ERR, @"Error:	volumeParms.vMDeviceID == NULL\n");
			}
		}
	}

	return nil;
}

+ (BOOL)runsOnBattery
{
	CFTypeRef		ps_info = IOPSCopyPowerSourcesInfo();
	CFStringRef		ps_name = NULL;
	BOOL			ret;

	if (!ps_info)
		return FALSE;

	ps_name = (CFStringRef)IOPSGetProvidingPowerSourceType(ps_info);

	ret = CFEqual(CFSTR(kIOPMBatteryPowerKey), ps_name);

	CFRelease(ps_info);

	return ret;
}

+ (BOOL)hasBattery
{
	static BOOL		checked = FALSE, result;
	CFTypeRef		ps_info = IOPSCopyPowerSourcesInfo();

	if (checked == FALSE)
	{
		checked = TRUE;

		if (kCFBooleanTrue == IOPSPowerSourceSupported(ps_info, CFSTR(kIOPMBatteryPowerKey)))
			result = TRUE;
		else
			result = FALSE;
	}

	CFRelease(ps_info);

	return result;
}
@end


// Returns an iterator containing the primary (built-in) Ethernet interface. The caller is responsible for
// releasing the iterator after the caller is done with it.
static kern_return_t FindEthernetInterfaces(io_iterator_t *matchingServices)
{
	kern_return_t kernResult;
	mach_port_t masterPort;
	CFMutableDictionaryRef matchingDict;
	CFMutableDictionaryRef propertyMatchDict;

	// Retrieve the Mach port used to initiate communication with I/O Kit
	kernResult = IOMasterPort(MACH_PORT_NULL, &masterPort);
	if (KERN_SUCCESS != kernResult)
	{
		asl_NSLog(ASL_LEVEL_ERR, @"Error:	IOMasterPort returned %d\n", kernResult);
		return kernResult;
	}

	// Ethernet interfaces are instances of class kIOEthernetInterfaceClass.
	// IOServiceMatching is a convenience function to create a dictionary with the key kIOProviderClassKey and
	// the specified value.
	matchingDict = IOServiceMatching(kIOEthernetInterfaceClass);

	// Note that another option here would be:
	// matchingDict = IOBSDMatching("en0");

	if (NULL == matchingDict)
		asl_NSLog(ASL_LEVEL_ERR, @"Error:	IOServiceMatching returned a NULL dictionary.\n");
	else
	{
		// Each IONetworkInterface object has a Boolean property with the key kIOPrimaryInterface. Only the
		// primary (built-in) interface has this property set to TRUE.

		// IOServiceGetMatchingServices uses the default matching criteria defined by IOService. This considers
		// only the following properties plus any family-specific matching in this order of precedence
		// (see IOService::passiveMatch):
		//
		// kIOProviderClassKey (IOServiceMatching)
		// kIONameMatchKey (IOServiceNameMatching)
		// kIOPropertyMatchKey
		// kIOPathMatchKey
		// kIOMatchedServiceCountKey
		// family-specific matching
		// kIOBSDNameKey (IOBSDNameMatching)
		// kIOLocationMatchKey

		// The IONetworkingFamily does not define any family-specific matching. This means that in
		// order to have IOServiceGetMatchingServices consider the kIOPrimaryInterface property, we must
		// add that property to a separate dictionary and then add that to our matching dictionary
		// specifying kIOPropertyMatchKey.

		propertyMatchDict = CFDictionaryCreateMutable(kCFAllocatorDefault, 0,
		                                              &kCFTypeDictionaryKeyCallBacks,
		                                              &kCFTypeDictionaryValueCallBacks);

		if (NULL == propertyMatchDict)
			asl_NSLog(ASL_LEVEL_ERR, @"Error:	CFDictionaryCreateMutable returned a NULL dictionary.\n");
		else
		{
			// Set the value in the dictionary of the property with the given key, or add the key
			// to the dictionary if it doesn't exist. This call retains the value object passed in.
			CFDictionarySetValue(propertyMatchDict, CFSTR(kIOPrimaryInterface), kCFBooleanTrue);

			// Now add the dictionary containing the matching value for kIOPrimaryInterface to our main
			// matching dictionary. This call will retain propertyMatchDict, so we can release our reference
			// on propertyMatchDict after adding it to matchingDict.
			CFDictionarySetValue(matchingDict, CFSTR(kIOPropertyMatchKey), propertyMatchDict);
			CFRelease(propertyMatchDict);
		}
	}

	// IOServiceGetMatchingServices retains the returned iterator, so release the iterator when we're done with it.
	// IOServiceGetMatchingServices also consumes a reference on the matching dictionary so we don't need to release
	// the dictionary explicitly.
	kernResult = IOServiceGetMatchingServices(masterPort, matchingDict, matchingServices);

	if (KERN_SUCCESS != kernResult)
		asl_NSLog(ASL_LEVEL_ERR, @"Error:	IOServiceGetMatchingServices returned %d\n", kernResult);

	return kernResult;
}

// Given an iterator across a set of Ethernet interfaces, return the MAC address of the last one.
// If no interfaces are found the MAC address is set to an empty string.
// In this sample the iterator should contain just the primary interface.
static kern_return_t GetMACAddress(io_iterator_t intfIterator, UInt8 *MACAddress)
{
	io_object_t intfService;
	io_object_t controllerService;
	kern_return_t kernResult = KERN_FAILURE;

	// Initialize the returned address
	bzero(MACAddress, kIOEthernetAddressSize);

	// IOIteratorNext retains the returned object, so release it when we're done with it.
	while ((intfService = IOIteratorNext(intfIterator)))
	{
		CFTypeRef MACAddressAsCFData;

		// IONetworkControllers can't be found directly by the IOServiceGetMatchingServices call,
		// since they are hardware nubs and do not participate in driver matching. In other words,
		// registerService() is never called on them. So we've found the IONetworkInterface and will
		// get its parent controller by asking for it specifically.

		// IORegistryEntryGetParentEntry retains the returned object, so release it when we're done with it.
		kernResult = IORegistryEntryGetParentEntry(intfService,
		                                           kIOServicePlane,
		                                           &controllerService);

		if (KERN_SUCCESS != kernResult)
			asl_NSLog(ASL_LEVEL_ERR, @"Error:	IORegistryEntryGetParentEntry returned 0x%08x\n", kernResult);
		else
		{
			// Retrieve the MAC address property from the I/O Registry in the form of a CFData
			MACAddressAsCFData = IORegistryEntryCreateCFProperty(controllerService,
			                                                     CFSTR(kIOMACAddress),
			                                                     kCFAllocatorDefault,
			                                                     0);
			if (MACAddressAsCFData)
			{
				// CFShow(MACAddressAsCFData); for display purposes only; output goes to stderr

				// Get the raw bytes of the MAC address from the CFData
				CFDataGetBytes(MACAddressAsCFData, CFRangeMake(0, kIOEthernetAddressSize), MACAddress);
				CFRelease(MACAddressAsCFData);
			}

			// Done with the parent Ethernet controller object so we release it.
			(void) IOObjectRelease(controllerService);
		}

		// Done with the Ethernet interface object so we release it.
		(void) IOObjectRelease(intfService);
	}

	return kernResult;
}
