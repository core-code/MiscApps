//
//  AppDelegate.m
//  TableEdit-Lite
//
//  Created by CoreCode on 05.06.14.
/*    Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/


#import "AppDelegate.h"
#import "Document.h"
#import "JMAppMovedHandler.h"
#import "JMHostInformation.h"



CONST_KEY(UsagesThisVersion)


@interface AppDelegate ()

@property (strong, nonatomic) IBOutlet NSWindow *welcomeWindow;
//@property (strong, nonatomic) IBOutlet NSWindow *documentationWindow;
@property (strong, nonatomic) IBOutlet NSWindow *promotionWindow;
@property (strong, nonatomic) IBOutlet NSMenu *updateCheckMenu;
@property (weak, nonatomic) CoreLib *cl;
@property (strong, nonatomic) NSString *version;
@property (strong, nonatomic) NSString *build;
@property (strong, nonatomic) NSArray *recentDocuments;
@property (assign, nonatomic) BOOL isMAS;
@property (readonly, nonatomic) BOOL isRateable;


@end


@implementation AppDelegate

@dynamic isRateable;


+ (void)initialize
{
	[NSUserDefaults.standardUserDefaults registerDefaults:
		@{
#ifdef USE_SPARKLE
			kUpdatecheckMenuindexKey : @2,
#endif
            kShowWelcomeWindowKey : @1,
			kPaddingColumnsKey : @2,
			kPaddingRowsKey : @2,
			kCloseColorPanelKey : @1,
			kAutocreateBorderKey : @1,
			kOddRowColorKey :  [NSArchiver archivedDataWithRootObject:makeColor(0.92f, 0.96f, 0.98f, 1.0f)],
			kEvenRowColorKey : [NSArchiver archivedDataWithRootObject:makeColor(1.0f, 1.0f, 1.0f, 1.0f)],
			kRowColorsEnabledKey : @NO,
            kPrintSettingsHorizontalPaginationKey : @(NSFitPagination),
            kPrintSettingsVerticalPaginationKey : @(NSAutoPagination),
            kPrintSettingsHorizontallyCenteredKey : @YES,
            kPrintSettingsVerticallyCenteredKey : @NO,
            kPrintSettingsTopMarginKey : @(90),
            kPrintSettingsBottomMarginKey : @(90),
            kPrintSettingsLeftMarginKey : @(72),
            kPrintSettingsRightMarginKey : @(72)}
     ];
}

	
- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
	LOGFUNC;
	cc = CoreLib.new;

#ifndef USE_SPARKLE
	self.isMAS = YES;
#endif
}

//- (void)application:(NSApplication *)sender openFiles:(NSArray<NSString *> *)filenames
//{
//	return;
//}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	LOGFUNC;
	self.cl = cc;
    @"NSInitialToolTipDelay".defaultInt = 300;

#if !defined(APPSTORE_VALIDATERECEIPT) && !defined(XCTEST) && defined(USE_SPARKLE)
	[self initUpdateCheck];
    [self selectCurrentUpdateIntervalMenuItem:self.updateCheckMenu];
#endif

	self.build = makeString(@"%@ %i", @"Build:".localized, cc.appBuildNumber);
	self.version = makeString(@"%@ %@", @"Version:".localized, cc.appVersionString);

	application.helpMenu = NSMenu.new;

	srandom((int)time(0));

    
	[self checkMASReceipt];

	[self checkBetaExpiryForDate:__DATE__ days:20];


    [JMAppMovedHandler startMoveObservation];

    
    NSUserNotificationCenter.defaultUserNotificationCenter.delegate = self;
}


- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}



- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
	//LOGFUNCPARAM(sender);
	
#ifdef XCTEST
    return NO;
#else
	if (kShowWelcomeWindowKey.defaultInt)
    {
        [self openWelcome:self];
        return NO;
    }
    else
        return YES;
#endif
}

#pragma mark - responder actions

- (IBAction)import:(id)sender
{
	LOGFUNC;
	[Document showImportPanel:self forWindow:nil];
}

#pragma mark - IBAction

- (IBAction)openWelcome:(id)sender
{
	LOGFUNC;
	NSMutableArray *tmp = @[].mutableObject;
	for (NSURL *url in NSDocumentController.sharedDocumentController.recentDocumentURLs)
	{
        NSString *path = [url.path.stringByDeletingPathExtension replaced:cc.homeURLOutsideSandbox.path with:@"~"];

        if ([path contains:@"com~apple~CloudDocs"])
            path = @[@"iCloudDrive", [path split:@"com~apple~CloudDocs"][1]].string;

        [tmp addObject:@{@"name" : url.lastPathComponent.stringByDeletingPathExtension,
                         @"path" : path}];
	}
	self.recentDocuments = tmp.immutableObject;

	if (!self.welcomeWindow)
	{
		[NSBundle.mainBundle loadNibNamed:@"WelcomeWindow" owner:self topLevelObjects:NULL];

		if (self.recentDocuments.count == 0)
		{
			CGRect f = self.welcomeWindow.frame;
			f.size.width -= 260;
			f.origin.x += 260/2;
			[self.welcomeWindow setFrame:f display:YES];
		}
	}
	
	[NSApp activateIgnoringOtherApps:YES];
	[self.welcomeWindow makeKeyAndOrderFront:self];
}


- (IBAction)openPromotion:(id)sender
{
	LOGFUNC;
	[self openWindow:&_promotionWindow nibName:@"PromotionWindow"];
}

- (IBAction)closeWelcome:(id)sender
{
	LOGFUNC;
	[self.welcomeWindow performBorderlessClose:sender];
}

- (IBAction)openDocumentation:(id)sender
{
	LOGFUNC;
	[self openWindow:&_documentationWindow nibName:@"DocumentationWindow"];
}


#pragma mark NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification
{
    LOGFUNC;
	if (notification.object == self.documentationWindow)
		self.documentationWindow = nil;
	else if (notification.object == self.welcomeWindow)
		self.welcomeWindow = nil;
	else if (notification.object == self.promotionWindow)
		self.promotionWindow = nil;
}


#pragma mark NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)not
{
    LOGFUNC;
	NSArray *urls = NSDocumentController.sharedDocumentController.recentDocumentURLs;
	NSInteger row = [not.object selectedRow];

	[NSDocumentController.sharedDocumentController openDocumentWithContentsOfURL:urls[row] display:YES completionHandler:^(id d, BOOL ao, id e) { }];

	[self.welcomeWindow performBorderlessClose:nil];
}

@end

#if !defined(APPSTORE_VALIDATERECEIPT) && !defined(TRYOUT) && !defined(PADDLE) && !defined(DEBUG)
#warning Release build
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
#ifdef FAILCOMPILATION
#error invalid_config
#endif

CONST_KEY_IMPLEMENTATION(ShowWelcomeWindow)
CONST_KEY_IMPLEMENTATION(RowColorsEnabled)
CONST_KEY_IMPLEMENTATION(OddRowColor)
CONST_KEY_IMPLEMENTATION(EvenRowColor)
CONST_KEY_IMPLEMENTATION(ClosePopovers)
CONST_KEY_IMPLEMENTATION(CloseColorPanel)
CONST_KEY_IMPLEMENTATION(AutocreateBorder)
CONST_KEY_IMPLEMENTATION(PaddingRows)
CONST_KEY_IMPLEMENTATION(PaddingColumns)
CONST_KEY_IMPLEMENTATION(ImportAction)
CONST_KEY_IMPLEMENTATION(ImportDelimiter)
CONST_KEY_IMPLEMENTATION(ImportEncoding)
CONST_KEY_IMPLEMENTATION(ShowReferenceNotification)
CONST_KEY_IMPLEMENTATION(GenerateAbsoluteReferences)
CONST_KEY_ENUM_IMPLEMENTATION(NumberFormat, numberInputFormat)
