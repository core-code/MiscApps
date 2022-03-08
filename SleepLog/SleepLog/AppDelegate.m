//
//  AppDelegate.m
//  SleepLog
//
//  Created by CoreCode on 30.03.15.
//  Copyright © 2020 CoreCode Limited. All rights reserved.
//

#undef PADDLE
#undef USE_SPARKLE

#define DISPLAY_INMENUBAR 1
#define LAUNCH_ATLOGIN 1
#define USE_TOOLBAR 1

#import "AppDelegate.h"
#import "SleepLog.h"

#ifdef DISPLAY_INMENUBAR
#import "JMVisibilityManager.h"
#endif
#ifdef LAUNCH_ATLOGIN
#import "JMLoginItemManager.h"
#endif
#import "JMAppMovedHandler.h"

@interface AppDelegate ()

@property (strong, nonatomic) IBOutlet NSWindow *mainWindow;
@property (strong, nonatomic) IBOutlet NSWindow *documentationWindow;
@property (strong, nonatomic) IBOutlet NSWindow *promotionWindow;
#ifdef DISPLAY_INMENUBAR
@property (strong, nonatomic) IBOutlet NSMenu *statusItemMenu;
#endif
@property (strong, nonatomic) IBOutlet NSMenu *updateCheckMenu;

#ifdef USE_TOOLBAR
@property (strong, nonatomic) IBOutlet NSView *settingsView;
@property (strong, nonatomic) NSView *documentationView;
@property (weak, nonatomic) IBOutlet NSToolbar *toolbar;
#endif

@property (strong, nonatomic) NSString *version;
@property (strong, nonatomic) NSString *build;
#ifdef DISPLAY_INMENUBAR
@property (strong, nonatomic) VisibilityManager *visibilityManager;
#endif
#ifdef LAUNCH_ATLOGIN
@property (strong, nonatomic) LoginItemManager *loginItemManager;
#endif

@property (strong, nonatomic) SleepLog *SleepLog;

@end

CONST_KEY(FirstStart)

static NSString *kRVNBundleID = @"com.corecode.SleepLog";
static NSString *kRVNBundleVersion = @"1.0.0";


@implementation AppDelegate


+ (void)initialize
{
	NSMutableDictionary *defaultValues = makeMutableDictionary();

#ifdef USE_SPARKLE
    defaultValues[kUpdatecheckMenuindexKey] = @2;
#endif
    
	[NSUserDefaults.standardUserDefaults registerDefaults:defaultValues];
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
    cc = [CoreLib new];

    LOGFUNC
    

}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    LOGFUNC
    
	self.build = makeString(@"%@ %i", @"Build:".localized, cc.appBuildNumber);
	self.version = makeString(@"%@ %@", @"Version:".localized, cc.appVersionString);


#ifdef DISPLAY_INMENUBAR
	[[NSBundle mainBundle] loadNibNamed:@"StatusMenu" owner:self topLevelObjects:NULL];
	self.visibilityManager = [VisibilityManager new];
	self.visibilityManager.statusItemMenu = self.statusItemMenu;
	self.visibilityManager.menubarIcon = NSImageNameAdvanced.namedImage;
    [notificationCenter addObserverForName:kVisibilitySettingDidChangeNotificationKey object:nil queue:nil usingBlock:^(NSNotification *notification)
    {
         dispatch_after_main(1.0, ^{ [self openMainWindow:self]; });
    }];
#else
    assert(!@"StatusMenu.xib".resourceURL);
#endif
#ifdef LAUNCH_ATLOGIN
	self.loginItemManager = [LoginItemManager new];
#endif
    
#ifndef DISPLAY_INMENUBAR
	[self openMainWindow:self];
#endif

	[self checkMASReceipt];
    
#if !defined(APPSTORE_VALIDATERECEIPT) && !defined(XCTEST) && defined(USE_SPARKLE)
    [self initUpdateCheck];
    [self selectCurrentUpdateIntervalMenuItem:self.updateCheckMenu];
#endif

	[self checkBetaExpiryForDate:__DATE__ days:30];

#ifndef SANDBOX
	[self checkAndReportCrashesContaining:@[@"[Value", @"AppDele", @"[NSException", @"uncaught exception"].id
									   to:@"crashreports@corecode.io"];
#endif
	[self welcomeOrExpireDemo:20
				  welcomeText:@"You've used up all 20 operations allowed in this TRYOUT version of [APPNAME]. If you like [APPNAME] please consider buying the full version."
                   expiryText:@"Welcome to the feature-limited TRYOUT version of [APPNAME]. This version can be used to perform [USAGES_MAX] operations, you have [USAGES_LEFT] operations left!"];

	[self increaseUsages:YES allowFeedbackNow:YES];

	[JMAppMovedHandler startMoveObservation];

	
#ifdef DISPLAY_INMENUBAR
	[NSApp disableRelaunchOnLogin]; // important so applicationShouldHandleReopen is not called when rebooting with 'reopen windows'
#endif
    
    self.SleepLog = [SleepLog new];
    
    if (!kFirstStartKey.defaultInt)
    {
        self.visibilityManager.visibilitySetting = kVisibleMenubar;
        self.visibilityManager.visibilityOption = kDynamicVisibilityAddDockIconWhenWindowOpen;

        kFirstStartKey.defaultInt = 1;
    }
    
}

- (void)increaseUsages:(BOOL)increaseNow allowFeedbackNow:(BOOL)allowNow
{
    LOGFUNC
    
    [self increaseUsagesBy:increaseNow ? 1 : 0
          allowRatingsWith:10
       requestFeedbackWith:20
              feedbackText:@"You've now used [APPNAME] to successfully perform [USAGES_ASKREVIEW] operations on your data."
          allowFeedbackNow:allowNow
          forceFeedbackNow:NO];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    LOGFUNC

#ifdef DISPLAY_INMENUBAR
	[self.visibilityManager handleAppReopen];
#endif
    [self openMainWindow:self];

	[self checkMASReceipt];

    return FALSE;
}

#pragma mark - IBAction

- (IBAction)openMainWindow:(id)sender
{
	LOGFUNCPARAM(sender)

    
#ifdef DISPLAY_INMENUBAR
    [self.visibilityManager handleWindowOpened]; // this needs to be called first
#endif

	[self openWindow:&_mainWindow nibName:@"MainWindow"];
#ifdef USE_TOOLBAR
	if (!self.documentationWindow)
	{
		[[NSBundle mainBundle] loadNibNamed:@"DocumentationWindow" owner:self topLevelObjects:NULL];
		self.documentationView = self.documentationWindow.contentView;


		if (sender)
			[self toolbarClicked:@(0).id];
	}
#endif
}

- (IBAction)openPromotionWindow:(id)sender
{
	LOGFUNCPARAM(sender)

	[self openWindow:&_promotionWindow nibName:@"PromotionWindow"];
}

- (IBAction)openDocumentationWindow:(NSMenuItem *)sender
{
	LOGFUNCPARAM(sender)

#ifdef USE_TOOLBAR
	[self openMainWindow:nil];
	[self toolbarClicked:@(2).id];
#else
	[self openWindow:&_documentationWindow nibName:@"DocumentationWindow"];
#endif

	// make sure we select the right tab in the documentation as given in the tag of the sender
	if (sender && [sender respondsToSelector:@selector(tag)] && [sender tag] >= 0)
	{
		 NSTabView *documentationTabView = [_documentationWindow.contentView viewWithClass:NSTabView.class].id;
		 [documentationTabView selectTabViewItemAtIndex:[sender tag]];
	}
}

- (IBAction)toolbarClicked:(NSToolbarItem *)sender
{
#ifdef USE_TOOLBAR
	LOGFUNCPARAM(sender)

    NSView *documentatonView = _documentationWindow.contentView;
	NSArray *views = @[_settingsView, @"", documentatonView];
	NSUInteger index = [sender isKindOfClass:NSNumber.class] ? ((NSNumber *)sender).unsignedIntegerValue : [_toolbar.items indexOfObject:sender];
	NSView *newView = views[index];

    _mainWindow.contentView = newView;

	_toolbar.selectedItemIdentifier = [_toolbar.items[index] itemIdentifier];
#endif
}

#ifdef DISPLAY_INMENUBAR
- (IBAction)terminate:(id)sender
{
	LOGFUNCPARAM(sender)

	BOOL shouldAdd = ((self.visibilityManager.visibilitySetting == kVisibleDock) || (self.visibilityManager.visibilitySetting == kVisibleDockAndMenubar));
	NSString *message = makeString(@"SleepLog can only ??? while it is running. %@Are you sure you want to quit SleepLog?", shouldAdd ?
								   @"To have SleepLog running all the time without wasting space in the Dock consider changing the preferences to display only in the Menubar. "
								   : @"");

	NSInteger result = alert(@"Quit SleepLog?",
							 message,
							 @"Quit SleepLog",
							 @"Continue running", nil);


	if (result == NSAlertFirstButtonReturn)
		[application terminate:self];
}
#endif

#pragma mark NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification
{
	LOGFUNCPARAM(notification)

	if (notification.object == self.mainWindow)
	{
		self.mainWindow = nil;
#ifdef USE_TOOLBAR
        self.documentationWindow = nil;
        
        self.documentationView = nil;
		self.settingsView = nil;
#endif

#ifdef DISPLAY_INMENUBAR

        // inform visibility manager
        [self.visibilityManager handleWindowClosed];
#endif
	}
#ifndef USE_TOOLBAR
    else if (notification.object == self.documentationWindow)
        self.documentationWindow = nil;
#endif
    else if (notification.object == self.promotionWindow)
        self.promotionWindow = nil;
}

@end



int main(int argc, const char *argv[])
{
	@autoreleasepool
	{
#ifdef APPSTORE_VALIDATERECEIPT
		return RVNValidateAndRunApplication(argc, argv);
#else
		return NSApplicationMain(argc, (const char **)argv);
#endif
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
