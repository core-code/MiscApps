//
//  Updater.m
//  Updater
//
//  Created by CoreCode on 29.12.08.
/*	Copyright © 2018 CoreCode Limited
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "Updater.h"

@implementation Updater

- (void)awakeFromNib
{
	NSFileManager *fm = [NSFileManager defaultManager];
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	NSString *name = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];	
	
	[panel setAllowsMultipleSelection:NO];

	if (NSRunInformationalAlertPanel(name, @"%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CHOOSER_MSG"], @"Proceed", @"Cancel", nil) != NSCancelButton)
	{
		if ([panel runModalForDirectory:@"/Applications" file:nil types:[NSArray arrayWithObjects:@"app", nil]] == NSOKButton)
		{
			NSString *appPath = [[[panel filenames] objectAtIndex:0] stringByAppendingString:@"/"];
			NSString *updatePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/Update/"];
			NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:updatePath];
			NSString *file;
			
			if (![[appPath lastPathComponent] isEqualToString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"APP_NAME"]])
			{
				NSRunCriticalAlertPanel(name, @"%@", [NSString stringWithFormat:@"You must choose: %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"APP_NAME"]], @"I'll try again", nil, nil);			
				exit(1);
			}
				
			while ((file = [dirEnum nextObject]))
			{				
				NSString *srcFullPath = [updatePath stringByAppendingString:file];
				NSString *dstFullPath = [appPath stringByAppendingString:file];
				BOOL destExists = [fm fileExistsAtPath:dstFullPath];
				BOOL srcIsDir;
				
				[fm fileExistsAtPath:srcFullPath isDirectory:&srcIsDir];
				
				if (srcIsDir)
				{
					if (!destExists)
						if (![fm createDirectoryAtPath:dstFullPath attributes:nil])
							NSRunCriticalAlertPanel(name, @"Directory creation failed", @"Oh NO!", nil, nil);
				}
				else
				{					
					if (destExists)
						if (![fm removeFileAtPath:dstFullPath handler:nil])
							NSRunCriticalAlertPanel(name, @"File removal failed", @"Oh NO!", nil, nil);
					
					if (![fm copyPath:srcFullPath toPath:dstFullPath handler:nil])
						NSRunCriticalAlertPanel(name, @"File copy failed", @"Oh NO!", nil, nil);
				}
				
			}
		}
	}
	
	[NSApp terminate:self];
}
@end

int main(int argc, char *argv[])
{
	return NSApplicationMain(argc, (const char **) argv);
}
