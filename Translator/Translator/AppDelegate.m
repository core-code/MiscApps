//
//  AppDelegate.m
//  Translator
//
//  Created by corecodeon 20.01.14.
/*	Copyright (c) 2014 CoreCode
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "AppDelegate.h"

@implementation AppDelegate
#warning todo doesn't seem to translate "show toolbar"
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	cc = [CoreLib new];

	NSOpenPanel *panel = [NSOpenPanel openPanel];

	[panel runModal];

	NSURL *url = [panel URL];

	NSString *path = url.path;
	NSData *contents = path.contents;
	NSString *n = contents.string;
	NSString *sep = @".title\" = \"";
	NSDictionary *trans = [NSDictionary dictionaryWithContentsOfURL:@"MainMenuTranslations.plist".resourceURL];
	NSString *appname;
	alert_input(@"enter app name", @[@"ok"], &appname);

	for (NSString *translationName in trans)
	{
		NSMutableString *file = [NSMutableString new];
		NSDictionary *translation = trans[translationName];

		for (NSString *line in n.lines)
		{
			if ([line contains:sep])
			{
				NSArray <NSString *>* comp = [line split:sep];
				NSString *cont = [comp[1] substringToIndex:comp[1].length - 2];

				NSString *translat = translation[[cont replaced:appname with:@"APPLICATIONNAME"]];
				if (translat)
					[file appendString:[line replaced:cont with:[translat replaced:@"APPLICATIONNAME" with:appname]]];
				else
					[file appendString:line];


			}
			else
				[file appendString:line];

			[file appendString:@"\n"];

		}

		LOG(file);

		assert([fileManager createDirectoryAtURL:[[url URLByDeletingLastPathComponent] URLByAppendingPathComponent:translationName] withIntermediateDirectories:YES attributes:nil error:nil]);
		
		assert([file writeToURL:[[[url URLByDeletingLastPathComponent] URLByAppendingPathComponent:translationName] URLByAppendingPathComponent:@"MainMenu.strings"] atomically:NO encoding:NSUTF8StringEncoding error:nil]);

	}
}
@end

int main(int argc, const char * argv[])
{
	return NSApplicationMain(argc, argv);
}
