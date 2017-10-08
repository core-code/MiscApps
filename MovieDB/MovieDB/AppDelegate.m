//
//  AppDelegate.h.m
//  MovieDB
//
//  Created by CoreCode on 07.11.05.
/*	Copyright © 2017 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import "AppDelegate.h"
#import "JMCrashReporter.h"
#import <Sparkle/Sparkle.h>

NSDocumentController *sharedDocumentController;


@interface AppDelegate ()

    @property (weak, nonatomic) IBOutlet NSWindow *imdbAgreementWindow;
    @property (strong, nonatomic) IBOutlet NSWindow *preferencesWindow;
    @property (strong, nonatomic) IBOutlet NSMenu *pluginMenu;

@end



@implementation AppDelegate

+ (void)initialize
{
	TimeValueTransformer *timetransformer = [[TimeValueTransformer alloc] init];
	SizeValueTransformer *sizetransformer = [[SizeValueTransformer alloc] init];
	LanguageValueTransformer *languagetransformer = [[LanguageValueTransformer alloc] init];
	RatingValueTransformer *ratingtransformer = [[RatingValueTransformer alloc] init];
	TitleLinkValueTransformer *titlelinktransformer = [[TitleLinkValueTransformer alloc] init];
	PeopleLinkValueTransformer *peoplelinktransformer = [[PeopleLinkValueTransformer alloc] init];
	CastLinkValueTransformer *castlinktransformer = [[CastLinkValueTransformer alloc] init];
	ImageDataValueTransformer *imagedatatransformer = [[ImageDataValueTransformer alloc] init];
	AudioCodecValueTransformer *audiocodectransformer = [[AudioCodecValueTransformer alloc] init];

	[NSValueTransformer setValueTransformer:castlinktransformer forName:@"CastLinkValueTransformer"];
	[NSValueTransformer setValueTransformer:peoplelinktransformer forName:@"PeopleLinkValueTransformer"];
	[NSValueTransformer setValueTransformer:titlelinktransformer forName:@"TitleLinkValueTransformer"];
	[NSValueTransformer setValueTransformer:ratingtransformer forName:@"RatingValueTransformer"];
	[NSValueTransformer setValueTransformer:languagetransformer forName:@"LanguageValueTransformer"];
	[NSValueTransformer setValueTransformer:timetransformer forName:@"TimeValueTransformer"];
	[NSValueTransformer setValueTransformer:sizetransformer forName:@"SizeValueTransformer"];
	[NSValueTransformer setValueTransformer:imagedatatransformer forName:@"ImageDataValueTransformer"];
	[NSValueTransformer setValueTransformer:audiocodectransformer forName:@"AudioCodecValueTransformer"];


	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];

	defaultValues[kAgreedToIMDBConditionsKey] = @1;
	defaultValues[kUpdatecheckMenuindexKey] = @2;

	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}

- (instancetype)init
{
	self = [super init];

	if (self != nil)
	{
        cc = [CoreLib new];

		sharedDocumentController = [NSDocumentController sharedDocumentController];
	}
	return self;
}

- (void)awakeFromNib
{
    LOG(NSBundle.mainBundle.builtInPlugInsPath);

	if ([[NSUserDefaults standardUserDefaults] integerForKey:kAgreedToIMDBConditionsKey])
	{
		[NSApp activateIgnoringOtherApps:YES];

		[NSApp runModalForWindow:_imdbAgreementWindow];

		[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:kAgreedToIMDBConditionsKey];
	}




	CheckAndReportCrashes(@"crashreports@corecode.io", @[@"ValueTransformer", @"[Movie", @"[IMDB", @"[Info", @"[SU", @"[NSException", @"uncaught exception"]);



	for (NSString *bundlePath in NSBundle.mainBundle.builtInPlugInsPath.directoryContents)
	{
		NSMenuItem *mi = [[NSMenuItem alloc] init];
		NSString *title = bundlePath.lastPathComponent.stringByDeletingPathExtension;
		mi.title = title;
		mi.target = self;
		mi.action = @selector(pluginAction:);
		[_pluginMenu addItem:mi];

	}
}

- (IBAction)urlAction:(id)sender
{
    [cc openURL:[sender tag]];
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
	return NO;
}

- (IBAction)checkForUpdatesAction:(id)sender
{
}
- (IBAction)updatecheckAction:(id)sender
{
}

#pragma mark *** SUUpdater delegate-methods ***

- (BOOL)updaterShouldPromptForPermissionToCheckForUpdates:(SUUpdater *)bundle
{
    return NO;
}

#pragma mark *** JMApp methods ***

- (void)setUpdateCheck:(NSInteger)intervalIndex
{
}

#pragma mark *** IBAction action-methods ***

- (IBAction)pluginAction:(id)sender
{
	[sharedDocumentController.currentDocument pluginAction:[sender title]];
}

- (IBAction)lookupAction:(id)sender
{
	[sharedDocumentController.currentDocument lookupAction:sender];
}

- (IBAction)refreshAction:(id)sender
{
	[sharedDocumentController.currentDocument refreshAction:sender];
}

- (IBAction)refreshAllAction:(id)sender
{
	[sharedDocumentController.currentDocument refreshAllAction:sender];
}


- (IBAction)preferencesAction:(id)sender
{
	[NSApp activateIgnoringOtherApps:YES];
	[_preferencesWindow makeKeyAndOrderFront:self];
}

- (IBAction)acceptIMDBAction:(id)sender
{
	[NSApp stopModal];
	[_imdbAgreementWindow close];
}

- (IBAction)declineIMDBAction:(id)sender
{
	[NSApp terminate:self];
}

@end
