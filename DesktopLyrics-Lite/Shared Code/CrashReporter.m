//
//  CrashReporter.m
//
//  Created by CoreCode on 12.03.07.
/*	Copyright (c) 2007 - 2012 CoreCode
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "CrashReporter.h"
#import "HostInformation.h"

// dependencies:
//	user default key "nevercheckcrashes"
//	user default key "lastcrashdate"

// parameters:
//	email:	email to report crashes to
//	neccessaryStrings:	a array of strings one of which must be contained for the report to be accepted
void CheckAndReportCrashes(NSString *email, NSArray *neccessaryStrings)
{
	if ([[NSUserDefaults standardUserDefaults] integerForKey:kNeverCheckCrashesKey] == 0)
	{
		NSString *name = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
		NSString *path = nil;
		NSString *dpath = [@"~/Library/Logs/CrashReporter/" stringByExpandingTildeInPath];
		NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dpath error:NULL];
		NSDate *newestcrashdate = [NSDate dateWithString:@"2007-03-12 00:00:00 +0000"];
		NSString *newestcrashfile = nil;
		NSString *fname;

		for (fname in contents)
		{
			if ([fname hasPrefix:name])
			{
				NSDate *date = [[[NSFileManager defaultManager] attributesOfItemAtPath:[dpath stringByAppendingPathComponent:fname] error:NULL] objectForKey:@"NSFileModificationDate"];

				if ([date compare:newestcrashdate] == NSOrderedDescending)
				{
					newestcrashdate = date;
					newestcrashfile = fname;
				}
			}
		}

		if (newestcrashfile)
			path = [dpath stringByAppendingPathComponent:newestcrashfile];

		if (path)
		{
			if ([(NSDate *)[[[NSFileManager defaultManager] attributesOfItemAtPath:path error:NULL] objectForKey:@"NSFileModificationDate"] compare:[[NSUserDefaults standardUserDefaults] objectForKey:kLastCrashDateKey]] == NSOrderedDescending)
			{
				NSString *crashlogsource = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:path] encoding:NSUTF8StringEncoding];
				NSString *crashlog = [[[[crashlogsource componentsSeparatedByString:@"**********"] lastObject] componentsSeparatedByString:@"Binary Images:"] objectAtIndex:0];

				NSString *machinetype = [HostInformation machineType];
				BOOL foundNeccessaryString = FALSE;

				[crashlogsource release];


				for (NSString *ns in neccessaryStrings)
					if ([crashlog rangeOfString:ns].location != NSNotFound)
						foundNeccessaryString = TRUE;

				if (!foundNeccessaryString)
					return;

				[NSApp activateIgnoringOtherApps:YES];
				NSInteger code = NSRunAlertPanel(name,
												 [NSString stringWithFormat:NSLocalizedString(@"It seems like %@ has crashed recently. Please consider sending the crash-log to help fix this problem. Also make sure you are using the latest version by using the built-in update mechanism since most reported crashes are already fixed in the latest version.", nil), name],
												 NSLocalizedString(@"Send", nil), NSLocalizedString(@"Never", nil), NSLocalizedString(@"Cancel", nil));

				[[NSUserDefaults standardUserDefaults] setObject:[NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24 * 3] forKey:kLastCrashDateKey]; // bug the user every 3 days at most

				if (code == NSAlertDefaultReturn)
				{
					NSMutableString *inputManagers = [NSMutableString string];
					NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSAllDomainsMask, YES);
					for (NSString *libPath in paths)
					{
						NSArray *inputManagerArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[libPath stringByAppendingPathComponent:@"/InputManagers/"] error:NULL];
						for (NSString *inputManager in inputManagerArray)
							if (![inputManager isEqualToString:@".DS_Store"])
								[inputManagers appendFormat:@" %@ ", inputManager];
					}


					NSString *mailtoLink = [NSString stringWithFormat:@"mailto:%@?subject=%@ Crashreport&body=Unfortunately %@ has crashed!\n\n--%@--\n\n\nMachine Type: %@\nInput Managers: %@\n\nCrash Log (%@):\n\n**********\n%@\nUser Defaults:\n\n**********\n%@", email, name, name, NSLocalizedString(@"Please fill in additional details here", nil), machinetype, inputManagers, [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"], crashlog, [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] description]];
					CFStringRef urlstring = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)mailtoLink, NULL, NULL, kCFStringEncodingUTF8);
					NSURL *url = [NSURL URLWithString:(NSString *)urlstring];

					CFRelease(urlstring);
					if (![[NSWorkspace sharedWorkspace] openURL:url])
						asl_NSLog(ASL_LEVEL_WARNING, @"Warning: %@ was unable to open the URL.", name);
				}
				else if (code == NSAlertAlternateReturn)
					[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:kNeverCheckCrashesKey];

				if (![[NSUserDefaultsController sharedUserDefaultsController] commitEditing])
					asl_NSLog(ASL_LEVEL_WARNING, @"Warning: shared user defaults controller could not commit editing");
			}
		}
	}
}
