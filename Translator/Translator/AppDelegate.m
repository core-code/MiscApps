//
//  AppDelegate.m
//  Translator
//
//  Created by CoreCode on 20.01.14.
/*	Copyright © 2018 CoreCode Limited
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	cc = [CoreLib new];

	NSOpenPanel *panel = [NSOpenPanel openPanel];

    panel.title = @"Please choose MainMenu.strings";
	[panel runModal];

	NSURL *url = [panel URL];

	NSString *path = url.path;
    
    if (![path hasSuffix:@".strings"])
    {
        alert_apptitled(@"Not a strings file", @"D'oh", nil, nil);
        exit(1);
    }
	NSData *contents = path.contents;
	NSString *n = contents.string;
	NSString *sep = @".title\" = \"";
	NSDictionary *allTranslations = [NSDictionary dictionaryWithContentsOfURL:@"MainMenuTranslations.plist".resourceURL];
	NSString *appname;
	alert_input(@"enter app name", @[@"ok"], &appname);

	for (NSString *languageName in allTranslations)
	{
		NSMutableString *file = [NSMutableString new];

		NSDictionary *translationsInLanguage = allTranslations[languageName];
        int translated = 0, untranslated = 0;
        
		for (NSString *line in n.lines)
		{
			if ([line contains:sep])
			{
				NSArray <NSString *>* comp = [line split:sep];
				NSString *cont = [comp[1] substringToIndex:comp[1].length - 2];


				NSDictionary <NSString *, NSNumber *> *translationsForString  = translationsInLanguage[[cont replaced:appname with:@"<APPNAME>"]];

				if (translationsForString && ![cont isEqualToString:appname])
                {
                    NSString *bestTranslation;
                    int bestTranslationScore = 0;

                    for (NSString *translation in translationsForString)
                    {
                        int score = [translationsForString[translation] intValue];
                        if (score > bestTranslationScore)
                        {
                            bestTranslationScore = score;
                            bestTranslation = translation;
                        }
                    }
                    assert(bestTranslation);
                    if (bestTranslationScore < 20)
                        cc_log(@"Warning: [%@] translating string with low score: %@ =[%i]> %@", languageName, line, bestTranslationScore, bestTranslation);
                    for (NSString *translation in translationsForString)
                        if ([translationsForString[translation] intValue] == bestTranslationScore && ![translation isEqualToString:bestTranslation])
                            cc_log(@"Warning: [%@] translating string although alternative translation with same score exists %@ =[%i]> %@ ? %@", languageName, line, bestTranslationScore, bestTranslation, translation);

                    translated ++;
                    
                    [file appendString:[line replaced:cont with:[bestTranslation replaced:@"<APPNAME>" with:appname]]];
                    cc_log(@"Notice: [%@] translating line %@ with %@", languageName, line, bestTranslation);
                }
				else
                {
                    untranslated ++;
                    
                    [file appendString:line];
                    //cc_log(@"Info: [%@] got no translation for line %@", languageName, line);
                }
			}
			else
            {
                //cc_log(@"Warning: ignoring line for lack of .title %@", line);

                [file appendString:line];
            }

			[file appendString:@"\n"];

		}

        cc_log(@"\n\n\n");
        cc_log(@"Info: [%@] translated %i lines untranslated %i lines", languageName, translated, untranslated);
        cc_log(@"\n\n\n");

		assert([fileManager createDirectoryAtURL:[[url URLByDeletingLastPathComponent] URLByAppendingPathComponent:languageName] withIntermediateDirectories:YES attributes:nil error:nil]);
		
		assert([file writeToURL:[[[url URLByDeletingLastPathComponent] URLByAppendingPathComponent:languageName] URLByAppendingPathComponent:@"MainMenu.strings"] atomically:NO encoding:NSUTF8StringEncoding error:nil]);
	}


    alert_apptitled(makeString(@"Success: all translation files have been written to: %@", url.URLByDeletingLastPathComponent.path), @"OK", nil, nil);
    [NSApp terminate:@"bla"];
}
@end

int main(int argc, const char * argv[])
{
	return NSApplicationMain(argc, argv);
}
