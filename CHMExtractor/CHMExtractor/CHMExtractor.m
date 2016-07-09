//
//  CHMExtractor.m
//  CHMExtractor
//
//  Created by CoreCode on Fri Oct 24 2003.
/*	Copyright (c) 2003 CoreCode
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
/*
 *	TODO 1.0b:
 *		testing
 *		ui(menu items, cancel button, etc)
 *		doku
 *	TODO 1.0:
 *		convert .hhk, .hhp, .hhc (MS-ITS: in pathes?, other objects?)
 *		error checking (tool outout?) + handling
 *		proper highlighting
 *	TODO 1.x:
 *		performance
 *		integrate tool
 *		preferences: remove orig, location: same, ask, use (+ folder in use??), quit after use
 *
*/

#import "CHMExtractor.h"
#include <sys/types.h>
#include <sys/stat.h>

@implementation CHMExtractor

- (id)init
{
	if (self = [super init])
	{
		task = nil;
		status = nil;
		files = [[NSMutableArray alloc] initWithCapacity:5];

		[[NSFileManager defaultManager] removeFileAtPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/temp/"] handler: nil];

		//[self convertHHC];
	}
	return self;
}

- (void)convertHHC:(NSString *)file
{
	NSMutableString *hhc = [NSMutableString stringWithContentsOfFile:[[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/temp/"] stringByAppendingString:file]];
	NSRange range, name, local, global;
	int tmp;
	
	NS_DURING
		range.location = 0;
		range.length = [hhc length];
		global.location = 0;
		do
		{
			int length = [hhc length];
			
			global.length = length - global.location;
			range = [hhc rangeOfString:@"text/sitemap" options:0 range:global];
			if (range.location != NSNotFound)
			{
#define ADVANCE range.location = range.location + range.length; range.length = length - range.location;
				
				ADVANCE
				local.location = range.location; local.length = range.length;
				range = [hhc rangeOfString:@"name=\"Name\"" options:NSCaseInsensitiveSearch range:range];
				if (range.location == NSNotFound)
					global.location = range.location;
				else
				{
					ADVANCE
					range = [hhc rangeOfString:@"value=\"" options:NSCaseInsensitiveSearch range:range];
					ADVANCE
						name.location = range.location;
					range = [hhc rangeOfString:@"\"" options:0 range:range];
					name.length = range.location - name.location;
					range = [hhc rangeOfString:@"name=\"Local\"" options:NSCaseInsensitiveSearch range:local];
					if (range.location == NSNotFound)
						global.location = range.location;
					else
					{
						ADVANCE
						range = [hhc rangeOfString:@"value=\"" options:NSCaseInsensitiveSearch range:range];
						ADVANCE
							local.location = range.location;
						range = [hhc rangeOfString:@"\"" options:0 range:range];
						local.length = range.location - local.location;
						range.location = 0;
						range.length = name.location;
						range = [hhc rangeOfString:@"<OBJECT" options:NSCaseInsensitiveSearch | NSBackwardsSearch range:range];
						tmp = range.location;
						ADVANCE
							range = [hhc rangeOfString:@"</OBJECT>" options:NSCaseInsensitiveSearch range:range];
						range.length = (range.location + range.length) - tmp;
						range.location = tmp;
						
						[hhc replaceCharactersInRange:range withString:[NSString stringWithFormat:@"<a href=\"%@\">%@</a>", [hhc substringWithRange:local], [hhc substringWithRange:name]]];
					}
				}
			}
		} while (range.location != NSNotFound);
		//NSLog(hhc);
		[hhc writeToFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/temp/toc.html"] atomically:YES];
	NS_HANDLER
		NSLog(file);
	NS_ENDHANDLER
}

- (void)start
{
	//NSLog(@"****************************\nSTART\n****************************\n");
	task = [[TaskWrapper alloc] initWithController:self arguments:[NSArray arrayWithObjects:[[NSBundle mainBundle] pathForResource:@"chmdump" ofType:nil], [files objectAtIndex:0], @"temp", nil]];
	if (!status)
		status = [[StatusPanelController alloc] init];
	[status showWindow:self];
	[task startProcess];
}

#pragma mark *** TaskWrapperController protocol-methods ***

- (void)appendOutput:(NSString *)output
{
	//NSLog(output);
}

- (void)processStarted
{
	//NSLog(@"****************************\nprocessStarted\n****************************\n");
}

- (void)processFinished
{
	NSDirectoryEnumerator *direnum = [[NSFileManager defaultManager] enumeratorAtPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/temp/"]];
	NSString *pname;
	//NSLog(@"****************************\nprocessFinished\n****************************\n");

	while ((pname = [direnum nextObject]))
	{
		if ([[pname pathExtension] isEqualToString:@"hhc"])
		{
			[self convertHHC:pname];
			break;
		}
	}

	remove([[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/temp/#IDXHDR"] fileSystemRepresentation]);
	remove([[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/temp/#ITBITS"] fileSystemRepresentation]);
	remove([[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/temp/#IVB"] fileSystemRepresentation]);
	remove([[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/temp/#STRINGS"] fileSystemRepresentation]);
	remove([[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/temp/#SYSTEM"] fileSystemRepresentation]);
	remove([[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/temp/#TOCIDX"] fileSystemRepresentation]);
	remove([[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/temp/#TOPICS"] fileSystemRepresentation]);
	remove([[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/temp/#URLSTR"] fileSystemRepresentation]);
	remove([[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/temp/#URLTBL"] fileSystemRepresentation]);
	remove([[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/temp/#WINDOWS"] fileSystemRepresentation]);
	remove([[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/temp/$FIftiMain"] fileSystemRepresentation]);
	remove([[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/temp/$OBJINST"] fileSystemRepresentation]);
	remove([[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/temp/$WWAssociativeLinks/BTree"] fileSystemRepresentation]);
	remove([[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/temp/$WWAssociativeLinks/Data"] fileSystemRepresentation]);
	remove([[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/temp/$WWAssociativeLinks/Map"] fileSystemRepresentation]);
	remove([[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/temp/$WWAssociativeLinks/Property"] fileSystemRepresentation]);
	remove([[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/temp/$WWAssociativeLinks/"] fileSystemRepresentation]);
	remove([[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/temp/$WWKeywordLinks/BTree"] fileSystemRepresentation]);
	remove([[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/temp/$WWKeywordLinks/Data"] fileSystemRepresentation]);
	remove([[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/temp/$WWKeywordLinks/Map"] fileSystemRepresentation]);
	remove([[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/temp/$WWKeywordLinks/Property"] fileSystemRepresentation]);
	remove([[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/temp/$WWKeywordLinks/"] fileSystemRepresentation]);

	mkdir([[[files objectAtIndex:0] stringByDeletingPathExtension] fileSystemRepresentation], S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);

	rename([[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/temp/"] fileSystemRepresentation], [[[[files objectAtIndex:0] stringByDeletingPathExtension] stringByAppendingPathComponent:@"html"] fileSystemRepresentation]);


	if (([FileUtilities makeRelativeAlias:[[[files objectAtIndex:0] stringByDeletingPathExtension] stringByAppendingPathComponent:@"TableOfContents.html"]
                                   toFile:[[[[files objectAtIndex:0] stringByDeletingPathExtension] stringByAppendingPathComponent:@"html"] stringByAppendingPathComponent:@"toc.html"]]) != noErr)
		NSLog(@"making alias failed");

	[task autorelease];

	[files removeObjectAtIndex:0];
	[status setRemainingItems:[files count]];
	if ([files count] > 0)
		[self start];
	else
		[status close];
}

#pragma mark *** NSApplication delegate-methods ***

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)file
{
	[files addObject:file];
	if ([files count] == 1)
		[self start];
	
	[status setRemainingItems:[files count]];
	return YES;
}
@end

int main(int argc, const char *argv[])
{
	return NSApplicationMain(argc, argv);
}