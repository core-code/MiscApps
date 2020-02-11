//
//  AppDelegate.m
//  VideoBreakout
//
//  Created by CoreCode on 30.03.15.
/*    Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/


#import "AppDelegate.h"
#import "JMVisibilityManager.h"
#import "JMLoginItemManager.h"
#import "JMAppMovedHandler.h"




@interface AppDelegate ()

@property (strong, nonatomic) IBOutlet NSWindow *mainWindow;
@property (strong, nonatomic) IBOutlet NSWindow *documentationWindow;
@property (strong, nonatomic) IBOutlet NSWindow *promotionWindow;
@property (strong, nonatomic) IBOutlet NSView *statusView;
@property (strong, nonatomic) IBOutlet NSView *settingsView;
@property (weak, nonatomic) IBOutlet NSToolbar *toolbar;
@property (strong, nonatomic) NSView *documentationView;
@property (strong, nonatomic) NSString *version;
@property (strong, nonatomic) NSString *build;


@property (weak, nonatomic) IBOutlet NSImageView *vlcStatusIcon;
@property (weak, nonatomic) IBOutlet NSImageView *safariStatusIcon;
@property (weak, nonatomic) IBOutlet NSImageView *summaryStatusIcon;
@property (weak, nonatomic) IBOutlet NSTextField *vlcUpperText;
@property (weak, nonatomic) IBOutlet NSTextField *vlcLowerText;
@property (weak, nonatomic) IBOutlet NSTextField *safariUpperText;
@property (weak, nonatomic) IBOutlet NSTextField *safariLowerText;
@property (weak, nonatomic) IBOutlet NSTextField *summaryUpperText;
@property (weak, nonatomic) IBOutlet NSTextField *summaryLowerText;
@property (weak, nonatomic) IBOutlet NSTextField *summaryLabel;

@property (assign, nonatomic) NSEventModifierFlags modifierFlagsAtLaunch;

@property (strong, nonatomic) NSValue *globalObservationToken;
@property (strong, nonatomic) NSValue *localObservationToken;

@end


CONST_KEY(ChosenVLCLocation)
CONST_KEY(SendFailedVideoURLsHome)

CC_ENUM(char, MultipleVideoSettingType)
{
	MultipleVideoSettingAsk = 0,
	MultipleVideoSettingFirst = 1
};
CONST_KEY_ENUM(MultipleVideos, MultipleVideoSettingType)
CC_ENUM(char, QuicktimePlayerSettingType)
{
	QuicktimePlayerSettingNever = 0,
	QuicktimePlayerSettingHold = 1,
	QuicktimePlayerSettingAlways = 2
};
CONST_KEY_ENUM(QuicktimePlayer, QuicktimePlayerSettingType)
CC_ENUM(int, KeySettingType)
{
	KeySettingShift = 0,
	KeySettingAlt = 1,
	KeySettingCommand = 2
};
CONST_KEY_ENUM(QuicktimePlayerKey, KeySettingType)
CC_ENUM(char, DownloadingVideosSettingType)
{
	DownloadingVideosSettingNever = 0,
	DownloadingVideosSettingHold = 1,
	DownloadingVideosSettingAlways = 2
};
CONST_KEY_ENUM(DownloadingVideos, DownloadingVideosSettingType)

CONST_KEY_ENUM(DownloadingVideosKey, KeySettingType)


@implementation AppDelegate


+ (void)initialize
{
	NSMutableDictionary *defaultValues = makeMutableDictionary();

	defaultValues[kUpdatecheckMenuindexKey] = @(0);
	defaultValues[kMultipleVideosKey] = @(MultipleVideoSettingAsk);
	defaultValues[kQuicktimePlayerKey] = @(QuicktimePlayerSettingHold);
	defaultValues[kQuicktimePlayerKeyKey] = @(KeySettingShift);
	defaultValues[kDownloadingVideosKey] = @(DownloadingVideosSettingHold);
	defaultValues[kDownloadingVideosKeyKey] = @(KeySettingAlt);

	defaultValues[kSendFailedVideoURLsHomeKey] = @(1);

	[NSUserDefaults.standardUserDefaults registerDefaults:defaultValues];
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
	LOGFUNC

	cc = [CoreLib new];


	[[NSAppleEventManager sharedAppleEventManager] setEventHandler:self
													   andSelector:@selector(handleURLEvent:withReplyEvent:)
													 forEventClass:kInternetEventClass
														andEventID:kAEGetURL];


//	[self handleURLEvent:nil withReplyEvent:nil];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    LOGFUNC

	self.build = makeString(@"%@ %i", @"Build:".localized, cc.appBuildNumber);
	self.version = makeString(@"%@ %@", @"Version:".localized, cc.appVersionString);


	[self checkAndReportCrashesContaining:@[@"[Value", @"AppDele", @"[NSException", @"uncaught exception"].id
									   to:@"crashreports@corecode.io"];



	[JMAppMovedHandler startMoveObservation];

	[self openMainWindow:@"".id];



	[self updateStatus];
}


- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    LOGFUNC


    [self openMainWindow:self];


    return FALSE;
}

#pragma mark - IBAction

- (IBAction)openMainWindow:(id)sender
{
	LOGFUNCPARAM(sender)

	[self openWindow:&_mainWindow nibName:@"MainWindow"];
	if (!self.documentationWindow)
	{
		[[NSBundle mainBundle] loadNibNamed:@"DocumentationWindow" owner:self topLevelObjects:NULL];
		self.documentationView = self.documentationWindow.contentView;


		if (sender)
			[self toolbarClicked:@(0)];
	}
}

- (IBAction)openPromotionWindow:(id)sender
{
	LOGFUNCPARAM(sender)

	[self openWindow:&_promotionWindow nibName:@"PromotionWindow"];
}

- (IBAction)openDocumentationWindow:(id)sender
{
	LOGFUNCPARAM(sender)

	[self openMainWindow:nil];
	[self toolbarClicked:@(3)];


	// make sure we select the right tab in the documentation as given in the tag of the sender
	if (sender && [sender respondsToSelector:@selector(tag)] && [sender tag] >= 0)
	{
		 NSTabView *documentationTabView = [_documentationWindow.contentView viewWithClass:NSTabView.class].id;
		 [documentationTabView selectTabViewItemAtIndex:[sender tag]];
	}
}

- (IBAction)openPreferencesWindow:(id)sender
{
	LOGFUNCPARAM(sender)

	[self openMainWindow:nil];
	[self toolbarClicked:@(1)];
}

- (IBAction)toolbarClicked:(id)sender
{
	LOGFUNCPARAM(sender)
    
    NSArray *views = @[_statusView, _settingsView, @"", OBJECT_OR(_documentationWindow.contentView, @"")];
	NSUInteger index = [sender isKindOfClass:[NSNumber class]] ? [sender unsignedIntegerValue] : [[_toolbar items] indexOfObject:sender];
	NSView *newView = views[index];

	_mainWindow.contentView = newView;

	_toolbar.selectedItemIdentifier = [_toolbar.items[index] itemIdentifier];
}

#pragma mark NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification
{
	LOGFUNCPARAM(notification)

	if (notification.object == self.mainWindow)
	{
		self.mainWindow = nil;
        self.documentationWindow = nil;
		self.documentationView = nil;
		self.statusView = nil;
	}
    else if (notification.object == self.promotionWindow)
        self.promotionWindow = nil;
}

#pragma mark private 

- (void)handleURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
	self.modifierFlagsAtLaunch = NSEvent.modifierFlags;

	NSString *url = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
	if (![url hasPrefix:@"videobreakout://"])
	{
		alert(@"Error", @"fatal error please reinstall videobreakout", @"ok", nil, nil);
		exit(1);
	}
	url = [url replaced:@"videobreakout://" with:@""];
	NSData *data = [[NSData alloc] initWithBase64EncodedString:url options:(NSDataBase64DecodingOptions)0];
	NSDictionary *dict = data.JSONDictionary;


	LOG(dict)


	NSString *paste = [NSPasteboard.generalPasteboard stringForType:NSStringPboardType];
	NSString *pageURL = dict[@"pageURL"];


	NSMutableArray <NSString *>*videoURLs = [(NSArray *)dict[@"videoURLs"] mutableObject];
	NSMutableArray <NSString *>*videoLinks = [(NSArray *)dict[@"videoLinks"] mutableObject];




	[videoLinks map:^id(NSString *input) { return [input hasPrefix:@"//"] ? [@"http:" stringByAppendingString:input] : input; }];
	[videoLinks filter:^int(NSString *input) { return [input isKindOfClass:NSString.class] && [input hasPrefix:@"http"]; }];
	[videoURLs map:^id(NSString *input) { return [input hasPrefix:@"//"] ? [@"http:" stringByAppendingString:input] : input; }];
	[videoURLs map:^id(NSString *input) { return [input replaced:@"/vimeo.com/" with:@"/player.vimeo.com/video/"]; }];
	[videoURLs map:^id(NSString *input) { return [input replaced:@"/player.vimeo.com/video/video/" with:@"/player.vimeo.com/video/"]; }];
	[videoURLs filter:^int(NSString *input) { return [input contains:@"youtube.com"] || [input contains:@"youtu.be"] || [input contains:@"player.vimeo.com"]; }];

	BOOL needToQuit = TRUE;
	if (videoLinks.count + videoURLs.count == 0)
	{
		if (paste && [paste isKindOfClass:NSString.class] &&
			[paste.lowercaseString hasPrefix:@"http"] &&
			([paste.lowercaseString contains:@"youtu"]||[paste.lowercaseString contains:@"vimeo"]))
		{
			[self launchPlayerWithURLString:paste];
		}
		else
		{
			NSUInteger res = (NSUInteger) kSendFailedVideoURLsHomeKey.defaultInt;
			alert_checkbox(@"Failure", makeString(@"VideoBreakout could not find a video on the site: %@", pageURL), @[@"D'Oh"], @"Send failed URL to our diagnosis team?", &res);
			kSendFailedVideoURLsHomeKey.defaultInt =  (NSInteger)res;

			if (kSendFailedVideoURLsHomeKey.defaultInt)
			{
				needToQuit = FALSE;

				[[NSURL URLWithHost:@"www.corecode.io" path:@"/cgi-bin/videobreakout/videobreakout.cgi" query:makeString(@"url=%@", pageURL)] performPOST:^(NSData *d)
                {
						[NSApp terminate:nil];
				}];
			}
		}
	}
	else if (videoLinks.count + videoURLs.count == 1)
	{
		[self launchPlayerWithURLString:videoLinks.count ? videoLinks[0] : videoURLs[0]];
	}
	else if (videoLinks.count + videoURLs.count > 1)
	{
		NSArray <NSString *>*allVideos = [videoLinks arrayByAddingObjectsFromArray:videoURLs];

		if (kMultipleVideosKey.defaultInt == MultipleVideoSettingAsk)
		{
			NSUInteger videoChoice;

			NSInteger alertResult = alert_selection_matrix(@"VideoBreakout: Select Video to play", allVideos, @[@"Open", @"Cancel"], &videoChoice);

			if (alertResult == NSAlertFirstButtonReturn)
				[self launchPlayerWithURLString:allVideos[videoChoice]];
		}
		else
		{
			[self launchPlayerWithURLString:allVideos[0]];
		}
	}
	else
		assert(0);


	if (needToQuit)
	{
        [NSApp terminate:nil];
	}


	//	NSString *videoSRC = videoLinks.count ? videoLinks[0] : nil;
	// <iframe class="media-youtube-player" width="610" height="350" title="THIS IS EVO..." src="//www.youtube.com/embed/HK-FGIh7XDE?wmode=opaque" frameborder="0" allowfullscreen="">Video of THIS IS EVO...</iframe>
	// <iframe width="505" height="315" src="https://www.youtube.com/embed/43FZqZEUKK4" frameborder="0" allowfullscreen=""></iframe>


	// TODO: pause/close video, test when safari is in fullscreen
	// http://www.windowscentral.com/microsoft-also-working-towards-swift-compiler-ios-developers-come-windows-10 // difficult cause player is actually in iframe which is not part of documentElement .. .same as COREBREACH site


}

- (void)launchPlayerWithURLString:(NSString *)urlString
{
	BOOL launched = FALSE;

    NSEventModifierFlags flagTable[] = {NSEventModifierFlagShift, NSEventModifierFlagOption, NSEventModifierFlagCommand};

//	if ((kDownloadingVideosKey.defaultInt == DownloadingVideosSettingAlways) || ((kDownloadingVideosKey.defaultInt == DownloadingVideosSettingHold) && (_modifierFlagsAtLaunch & flagTable[kDownloadingVideosKeyKey.defaultInt])))
//	{
//		// TODO: download
//	}
//	else
		if (((kQuicktimePlayerKey.defaultInt == QuicktimePlayerSettingAlways) || ((kQuicktimePlayerKey.defaultInt == QuicktimePlayerSettingHold) && (_modifierFlagsAtLaunch & flagTable[kQuicktimePlayerKeyKey.defaultInt]))) &&
			 ([urlString hasSuffix:@".mov"] || [urlString hasSuffix:@".mp4"] || [urlString hasSuffix:@".m4v"]))
	{
		NSDictionary			*errorDict;
		NSAppleEventDescriptor 	*returnDescriptor;
		NSAppleScript *scriptObject = [[NSAppleScript alloc] initWithSource:makeString(@"tell Application \"QuickTime Player\"\n\topen URL \"%@\"\n\tactivate\nend tell", urlString)];
		returnDescriptor = [scriptObject executeAndReturnError: &errorDict];

		if ([returnDescriptor descriptorType] && !errorDict)
			launched = TRUE;
	}

	if (!launched)
    {
        NSRunningApplication *vlc = [NSWorkspace.sharedWorkspace launchApplicationAtURL:[self vlcLocation].fileURL
                                                                                options:(NSWorkspaceLaunchOptions)NSWorkspaceLaunchNewInstance
                                                                          configuration:@{NSWorkspaceLaunchConfigurationArguments : @[urlString]}
                                                                                  error:NULL];

        [vlc activateWithOptions:(NSApplicationActivationOptions)(NSApplicationActivateAllWindows|NSApplicationActivateIgnoringOtherApps)];
    }
}

- (void)updateStatus
{
	NSString *vlc = [self vlcLocation];
	if (vlc)
	{
		self.vlcStatusIcon.image = @"ok".namedImage;
		self.vlcUpperText.stringValue = @"A recent version of VLC was found at:";
		self.vlcLowerText.stringValue = vlc;
		self.vlcLowerText.allowsEditingTextAttributes = NO;
		self.vlcLowerText.selectable = NO;
	}
	else
	{
		self.vlcStatusIcon.image = @"warning".namedImage;
		self.vlcUpperText.stringValue = @"No recent version of VLC was found on your Mac";


		self.vlcLowerText.allowsEditingTextAttributes = YES;
		self.vlcLowerText.selectable = YES;


		NSMutableAttributedString *downloadString = [[NSMutableAttributedString alloc] initWithString:@"Download VLC at: "];
		[downloadString appendAttributedString:[@"https://www.videolan.org/vlc/" attributedStringWithHyperlink:@"https://www.videolan.org/vlc/".URL]];
		self.vlcLowerText.attributedStringValue = downloadString;
	}


	NSString *ext = [self extensionLocation];
	if (ext)
	{
		if ([ext.stringByExpandingTildeInPath.fileURL.contents.SHA1 isEqualToString:@"VideoBreakout.safariextz".resourceURL.contents.SHA1]) // we should really compare only versions not whole file contents
		{
			self.safariStatusIcon.image = @"ok".namedImage;
			self.safariUpperText.stringValue = @"The Safari Extension 'VideoBreakout' is installed at:";
			self.safariLowerText.stringValue = ext;

			[@"/Library/Safari/Extensions/" stopObserving:self.globalObservationToken];
            [@"~/Library/Safari/Extensions/".stringByExpandingTildeInPath stopObserving:self.localObservationToken];
		}
		else
		{
			self.safariStatusIcon.image = @"warning".namedImage;
			self.safariUpperText.stringValue = @"The'VideoBreakout' Safari Extension is outdated";
			self.safariLowerText.stringValue = @"Click the 'Install' button and follow the instructions";
		}
	}
	else
	{
		self.safariStatusIcon.image = @"warning".namedImage;
		self.safariUpperText.stringValue = @"The'VideoBreakout' Safari Extension is not installed";
		self.safariLowerText.stringValue = @"Click the 'Install' button and follow the instructions";
	}



	if (ext && vlc)
	{
		self.summaryStatusIcon.image = @"ok".namedImage;
		self.summaryUpperText.stringValue = @"'VideoBreakout' is fully operational.";
		self.summaryLabel.stringValue = @"Usage:";
		self.summaryLowerText.stringValue = @"You can now Quit 'VideoBreakout'.\n\nIf you want to view a web-video outside your browser, just click the\n'VideoBreakout' button in your Safari toolbar and the video will be opened in VLC.";
	}
	else if (ext && !vlc)
	{
		self.summaryStatusIcon.image = @"warning".namedImage;
		self.summaryUpperText.stringValue = @"'VideoBreakout' is NOT operational. You need to:\n• Install the VLC video player";
		self.summaryLabel.stringValue = @"Help:";
		self.summaryLowerText.stringValue = @"To install VLC click on the link to the VLC download page above, install it\nand then click the 'Rescan' button.";
	}
	else if (!ext && vlc)
	{
		self.summaryStatusIcon.image = @"warning".namedImage;
		self.summaryUpperText.stringValue = @"'VideoBreakout' is NOT operational. You need to:\n• Install the 'VideoBreakout' Safari Extension";
		self.summaryLabel.stringValue = @"Help:";
		self.summaryLowerText.stringValue = @"To install the 'VideoBreakout' Safari Extension click on the 'Install' button above\nand tell Safari to 'Trust' the extension.";
	}
	else
	{
		self.summaryStatusIcon.image = @"warning".namedImage;
		self.summaryUpperText.stringValue = @"'VideoBreakout' is NOT operational. You need to:\n• Install the VLC video player and\n• Install the 'VideoBreakout' Safari Extension";
		self.summaryLabel.stringValue = @"Help:";
		self.summaryLowerText.stringValue = @"To install VLC click on the link to the VLC download page above, install it\nand then click the 'Rescan' button.\nTo install the 'VideoBreakout' Safari Extension click on the 'Install' button above\nand tell Safari to 'Trust' the extension.";
	}
}

- (BOOL)isVLCRecentEnough:(NSString *)loc
{
	NSBundle *b = [NSBundle bundleWithPath:loc];
	if (![[b objectForInfoDictionaryKey:@"CFBundleIdentifier"] isEqualToString:@"org.videolan.vlc"])
		return NO;


	NSString *v = [b objectForInfoDictionaryKey:@"CFBundleVersion"];
	NSArray <NSString *>*c = [v split:@"."];
	if (c.count == 3 && ((c[0].intValue > 2) || ((c[0].intValue == 2) && c[1].intValue >= 2)))
		return YES;
	else
		return NO;

}

- (NSString *)vlcLocation
{
	if (kChosenVLCLocationKey.defaultString && [self isVLCRecentEnough:kChosenVLCLocationKey.defaultString])
		return kChosenVLCLocationKey.defaultString;

	NSString *vlc;
	NSMutableArray <NSString *>*locations = @[@"/Applications"].mutableObject;
	if (@"~/Applications".expanded.fileExists)
		[locations addObject:@"~/Applications".expanded];
	for (NSString *dir in locations.copy)
		[locations addObjectsFromArray:[dir.directoryContentsAbsolute filtered:^BOOL(NSString *input) { return ![input hasSuffix:@".app"] && input.fileURL.fileIsDirectory;}]];
	for (NSString *dir in locations.copy)
	{
		if ([dir stringByAppendingPathComponent:@"/VLC.app/Contents/MacOS/VLC"].fileExists)
		{
			NSString *loc = [dir stringByAppendingPathComponent:@"/VLC.app"];
			if ([self isVLCRecentEnough:loc])
				vlc = loc;
		}
	}
	return vlc;
}



- (NSString *)extensionLocation
{
	for (NSString *loc in @[@"/Library/Safari/Extensions/VideoBreakout.safariextz",
							@"~/Library/Safari/Extensions/VideoBreakout.safariextz",
							@"/Library/Safari/Extensions/VideoBreakout-1.safariextz",
							@"~/Library/Safari/Extensions/VideoBreakout-1.safariextz",
							@"/Library/Safari/Extensions/VideoBreakout-2.safariextz",
							@"~/Library/Safari/Extensions/VideoBreakout-2.safariextz",
							@"/Library/Safari/Extensions/VideoBreakout-3.safariextz",
							@"~/Library/Safari/Extensions/VideoBreakout-3.safariextz",
							@"/Library/Safari/Extensions/VideoBreakout-4.safariextz",
							@"~/Library/Safari/Extensions/VideoBreakout-4.safariextz",
							@"/Library/Safari/Extensions/VideoBreakout-5.safariextz",
							@"~/Library/Safari/Extensions/VideoBreakout-5.safariextz",
							@"/Library/Safari/Extensions/VideoBreakout-6.safariextz",
							@"~/Library/Safari/Extensions/VideoBreakout-6.safariextz",
							@"/Library/Safari/Extensions/VideoBreakout-7.safariextz",
							@"~/Library/Safari/Extensions/VideoBreakout-8.safariextz",
							@"/Library/Safari/Extensions/VideoBreakout-8.safariextz",
							@"~/Library/Safari/Extensions/VideoBreakout-8.safariextz",
							@"/Library/Safari/Extensions/VideoBreakout-9.safariextz",
							@"~/Library/Safari/Extensions/VideoBreakout-9.safariextz"])
		if (loc.expanded.fileExists)
			return loc;

	return nil;
}



- (IBAction)rescanVLC:(id)sender
{
	[self updateStatus];
}

- (IBAction)selectVLC:(id)sender
{
	NSOpenPanel *panel = [NSOpenPanel openPanel];

	[panel setCanChooseDirectories:NO];
	[panel setCanChooseFiles:YES];
	[panel setAllowedFileTypes:@[@"app"]];

	[panel beginSheetModalForWindow:_mainWindow
				  completionHandler:^(NSInteger result)
	 {
        if (result == NSModalResponseOK)
		 {
			if ([self isVLCRecentEnough:panel.URL.path])
			{
				kChosenVLCLocationKey.defaultString = panel.URL.path;
				[self updateStatus];
			}
			else
				alert(@"Invalid VLC", @"You either didn't select VLC, or not a recent enough version (> 2.2).", @"D'Oh", nil, nil);
		 }
	 }];
}

- (IBAction)installExtension:(id)sender
{
	while ([self extensionLocation])	// remove old
	{
		[fileManager removeItemAtPath:[self extensionLocation].expanded
								error:NULL];
	}
	
    self.globalObservationToken = [@"/Library/Safari/Extensions/" startObserving:^(id input){ [self updateStatus]; } withFileLevelEvents:NO];
	self.localObservationToken = [@"~/Library/Safari/Extensions/".stringByExpandingTildeInPath startObserving:^(id input){ [self updateStatus]; } withFileLevelEvents:NO];

    NSError *err;
    NSString *tmpFolder = makeTempDirectory();
    NSURL *finalPath = @[tmpFolder, @"VideoBreakout.safariextz"].path.fileURL;

    [fileManager copyItemAtURL:@"VideoBreakout.safariextz".resourceURL
                         toURL:finalPath
                         error:&err];

    [finalPath open];
}

- (IBAction)checkForUpdatesAction:(id)sender
{
    if (alert(@"Update Check Unavailable", @"Sorry the update-check as been removed.\nPlease use our 'MacUpdater' to keep this and all your other apps up-to-date automatically.", @"Open MacUpdater Homepage", @"Cancel", nil) == NSAlertFirstButtonReturn)
         [@"https://www.corecode.io/macupdater/".URL open];
}

@end




int main(int argc, const char *argv[])
{
	@autoreleasepool
	{
		return NSApplicationMain(argc, (const char **)argv);
	}
}


#if !defined(APPSTORE_VALIDATERECEIPT) && !defined(TRYOUT) && !defined(DEBUG)
#warning Time-Limited Release-Beta build
#elif !defined(APPSTORE_VALIDATERECEIPT) && !defined(TRYOUT) && defined(DEBUG)
#warning Time-Limited Debug-Beta build
#elif !defined(APPSTORE_VALIDATERECEIPT) && defined(TRYOUT) && !defined(DEBUG)
#warning Tryout build
#elif !defined(APPSTORE_VALIDATERECEIPT) && defined(TRYOUT) && defined(DEBUG)
#error invalid_config
#elif defined(APPSTORE_VALIDATERECEIPT) && !defined(TRYOUT) && !defined(DEBUG)
#warning MacAppStore build
#elif defined(APPSTORE_VALIDATERECEIPT) && !defined(TRYOUT) && defined(DEBUG)
#error invalid_config
#elif defined(APPSTORE_VALIDATERECEIPT) && defined(TRYOUT) && !defined(DEBUG)
#error invalid_config
#elif defined(APPSTORE_VALIDATERECEIPT) && defined(TRYOUT) && defined(DEBUG)
#error invalid_config
#endif



