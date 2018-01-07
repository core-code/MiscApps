//
//  LoginItemManager.m
//
//  Created by CoreCode on Fri Jun 18 2004.
/*	Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "LoginItemManager.h"

BOOL IsLoginItem(void)
{
	UInt32 outSnapshotSeed;
	LSSharedFileListRef list = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);

	if (list)
	{
		NSArray *array = (NSArray *) LSSharedFileListCopySnapshot(list, &outSnapshotSeed);

		if (array)
		{
			NSString *bp = [[NSBundle mainBundle] bundlePath];

			for (id item in array)
			{
				NSURL *url = NULL;
				OSStatus status = LSSharedFileListItemResolve((LSSharedFileListItemRef)item, kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes, (CFURLRef *)&url, NULL);

				if (status == noErr)
				{
					asl_NSLog_debug(@"isLoginItem: current login item: %@", [url path]);

					if (NSOrderedSame == [[url path] compare:bp]) // the path is the same as ours => return true
					{
						asl_NSLog_debug(@"isLoginItem: FOUND US");
						CFRelease(url);
						CFRelease(array);
						CFRelease(list);
						return TRUE;
					}
					else if (NSOrderedSame == [[[url path] lastPathComponent] compare:[[[NSBundle mainBundle] bundlePath] lastPathComponent]]) // another entry of us, must be valid since on 10.5 invalid entries are erased automatically
					{
						asl_NSLog_debug(@"isLoginItem: found similar");
					}
				}


				if (url != NULL)
					CFRelease(url);
			}
			CFRelease(array);
		}
		else
			asl_NSLog(ASL_LEVEL_WARNING, @"Warning: _IsLoginItem : LSSharedFileListCopySnapshot delivered NULL list!");

		CFRelease(list);
	}
	else
		asl_NSLog(ASL_LEVEL_WARNING, @"Warning: _IsLoginItem : LSSharedFileListCreate delivered NULL list!");

	return FALSE;
}

void AddLoginItem(void)
{
	asl_NSLog_debug(@"addLoginItem: bundle path: %@", [[NSBundle mainBundle] bundlePath]);
	LSSharedFileListRef list = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);

	if (list)
	{
		LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(list, kLSSharedFileListItemLast, (CFStringRef)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"], NULL, (CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]], NULL, NULL);

		CFRelease(list);

		if (item)
			CFRelease(item);
		else
			asl_NSLog(ASL_LEVEL_WARNING, @"Warning: _AddLoginItem : LSSharedFileListInsertItemURL delivered NULL item!");
	}
	else
		asl_NSLog(ASL_LEVEL_WARNING, @"Warning: _AddLoginItem : LSSharedFileListCreate delivered NULL list!");
}

void RemoveLoginItem(void)
{
	UInt32 outSnapshotSeed;
	LSSharedFileListRef list = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);

	if (list)
	{
		NSArray *array = (NSArray *) LSSharedFileListCopySnapshot(list, &outSnapshotSeed);

		if (array)
		{
			NSString *bp = [[NSBundle mainBundle] bundlePath];

			for (id item in array)
			{
				NSURL *url;
				OSStatus status = LSSharedFileListItemResolve((LSSharedFileListItemRef)item, kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes, (CFURLRef *)&url, NULL);

				if (status == noErr)
				{
					if (NSOrderedSame == [[url path] compare:bp]) // the path is the same as ours => return true
					{
						asl_NSLog_debug(@"removeLoginItem: removing: %@", [url path]);

						LSSharedFileListItemRemove(list, (LSSharedFileListItemRef) item);
					}
					CFRelease(url);
				}
				else if (status != fnfErr)
					asl_NSLog(ASL_LEVEL_WARNING, @"Warning: removeLoginItem: LSSharedFileListItemResolve error %i", (int)status);
			}
			CFRelease(array);
		}
		else
			asl_NSLog(ASL_LEVEL_WARNING, @"Warning: _RemoveLoginItem : LSSharedFileListCopySnapshot delivered NULL list!");

		CFRelease(list);
	}
	else
		asl_NSLog(ASL_LEVEL_WARNING, @"Warning: _RemoveLoginItem : LSSharedFileListCreate delivered NULL list!");
}
