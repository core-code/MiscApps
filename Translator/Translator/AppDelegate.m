//
//  AppDelegate.m
//  Translator
//
//  Created by corecodeon 20.01.14.
//  Copyright (c) 2014 corecode. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	cc = [CoreLib new];

	NSOpenPanel *panel = [NSOpenPanel openPanel];

	[panel runModal];

	NSURL *url = [panel URL];


	NSString *n = url.path.contents.string;
	NSString *sep = @".title\" = \"";
	NSDictionary *trans = [NSDictionary dictionaryWithContentsOfURL:@"MainMenuTranslations.plist".resourceURL];
	NSString *appname;
	input(@"enter app name", @[@"ok"], &appname);

	for (NSString *translationName in trans)
	{
		NSMutableString *file = [NSMutableString new];
		NSDictionary *translation = trans[translationName];

		for (NSString *line in n.lines)
		{
			if ([line contains:sep])
			{
				NSStringArray * comp = [line split:sep];
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
