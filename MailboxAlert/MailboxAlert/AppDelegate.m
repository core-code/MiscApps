//
//  AppDelegate.m
//  MailboxAlert
//
//  Created by CoreCode on 06.01.13.
/*	Copyright (c) 2016 CoreCode
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

#import "AppDelegate.h"
#import "Account.h"
#import "JMLoginItemManager.h"
#import "JMHostInformation.h"
#import "JMVisibilityManager.h"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Woverriding-method-mismatch"
#import "Mail.h"
#pragma clang diagnostic pop



CONST_KEY_IMPLEMENTATION(NotificationAlert)
CONST_KEY_IMPLEMENTATION(NotificationOnscreen)
CONST_KEY_IMPLEMENTATION(NotificationMenubar)
CONST_KEY(AccountData)
CONST_KEY(WelcomeShown)


@interface AppDelegate ()

@property (unsafe_unretained, nonatomic) IBOutlet NSPanel *setupPanel1;
@property (unsafe_unretained, nonatomic) IBOutlet NSPanel *setupPanel2;
@property (weak, nonatomic) IBOutlet NSTableView *tableView;
@property (weak, nonatomic) IBOutlet NSMatrix *quotaMatrix;
@property (weak, nonatomic) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak, nonatomic) IBOutlet NSTextField *customquotaField;
@property (weak, nonatomic) IBOutlet NSTextField *usernameField;
@property (weak, nonatomic) IBOutlet NSTextField *serverField;
@property (weak, nonatomic) IBOutlet NSPopUpButton *importButton;
@property (weak, nonatomic) IBOutlet NSSecureTextField *passwordField;
@property (weak, nonatomic) IBOutlet NSTextField *thresholdField;
@property (weak, nonatomic) IBOutlet NSTextField *thresholdLabel;
@property (weak, nonatomic) IBOutlet NSTextField *serverquotaLabel;
@property (weak, nonatomic) IBOutlet NSTextField *intervalField;
@property (weak, nonatomic) IBOutlet NSToolbar *toolbar;
@property (weak, nonatomic) IBOutlet NSTabView *mainTabView;
@property (weak, nonatomic) IBOutlet NSView *settingsView;
@property (weak, nonatomic) IBOutlet NSView *aboutView;
@property (weak, nonatomic) IBOutlet NSMenu *statusItemMenu;
@property (weak, nonatomic) IBOutlet NSTabView *documentationTabView;
@property (weak, nonatomic) IBOutlet NSArrayController *arrayController;
@property (weak, nonatomic) IBOutlet NSTextField *summaryLabel;
@property (weak, nonatomic) IBOutlet NSView *blockView;
@property (strong, nonatomic) LoginItemManager *loginItemManager;
@property (strong, nonatomic) VisibilityManager *visibilityManager;
@property (strong, nonatomic) NSString *version;
@property (strong, nonatomic) NSString *build;
@property (strong, nonatomic) NSURL *faqURL;
@property (strong, nonatomic) NSURL *historyURL;
@property (strong, nonatomic) NSURL *readmeURL;
@property (strong, nonatomic) NSURL *aboutURL;
@property (strong, nonatomic) NSMutableDictionary *currentAccount;
@property (strong, nonatomic) NSMutableArray <NSDictionary *> *mailAccounts;
@property (strong, nonatomic) NSMutableArray <Account *> *accountArray;
@property (assign, nonatomic) BOOL isNotificationInstalled;

@end


@implementation AppDelegate

+ (void)initialize
{
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
    
	defaultValues[kNotificationOnscreenKey] = @(NSAppKitVersionNumber >= NSAppKitVersionNumber10_8);
	defaultValues[kNotificationMenubarKey] = @1;
	defaultValues[kNotificationAlertKey] = @1;
	defaultValues[kWelcomeShownKey] = @0;
	defaultValues[kAccountDataKey] = [NSKeyedArchiver archivedDataWithRootObject:@[]];

	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	cc = [CoreLib new];

	self.visibilityManager = [VisibilityManager new];
	self.visibilityManager.statusItemMenu = self.statusItemMenu;
	NSImage *image = [NSImage imageNamed:@"menuicon_ok"];
	[image setTemplate:YES];
	self.visibilityManager.menubarIcon = image;
	self.loginItemManager = [LoginItemManager new];

	NSArray <Account *>*accounts = [NSKeyedUnarchiver unarchiveObjectWithData:kAccountDataKey.defaultObject];
	self.accountArray = accounts.mutableObject;


	self.build = makeString(@"%@ %i", @"Build:".localized, cc.appBuildNumber);
	self.version = makeString(@"%@ %@", @"Version:".localized, cc.appVersionString);
	self.aboutURL = @"Credits.rtfd".resourceURL;
	self.historyURL = @"History.rtf".resourceURL;
	self.faqURL = @"FAQ.rtf".resourceURL;
	self.readmeURL = @"Read Me.rtf".resourceURL;
	self.isNotificationInstalled = (NSAppKitVersionNumber >= NSAppKitVersionNumber10_8);





	[notificationCenter addObserverForName:@"accountUpdate"
									object:nil
									 queue:[NSOperationQueue mainQueue]
								usingBlock:^(NSNotification *note)
	{
//		NSLog(@"got accountUpdate");
		NSUInteger problems = [self.accountArray filtered:^BOOL(Account *a) { return a.failing; }].count;
		
		(self.summaryLabel).stringValue = makeString(@"%li accounts, %li problems", self.accountArray.count, problems);

		NSImage *image = [NSImage imageNamed:(problems && kNotificationMenubarKey.defaultInt) ? @"menuicon_error" : @"menuicon_ok"];
		[image setTemplate:YES];
		self.visibilityManager.menubarIcon = image;

		self.visibilityManager.menuTooltip = makeString(@"MailboxAlert: %li accounts, %li problems (last check: %@)", self.accountArray.count, problems, [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterMediumStyle]);

		while (!((NSMenuItem *)[self.statusItemMenu itemAtIndex:2]).separatorItem)
			[self.statusItemMenu removeItemAtIndex:2];
		// TODO: bug this isn't updated when changing to menu display
		for (Account *a in accounts)
		{
			NSMenuItem *item = [NSMenuItem new];
			item.title = makeString(@"%@ %@", a.information, a.status);
			[item setEnabled:NO];
			[self.statusItemMenu insertItem:item atIndex:2];
		}
	}];
}

- (void)awakeFromNib
{
	[notificationCenter postNotificationName:@"accountUpdate" object:nil];
//	NSLog(@"post accountUpdate awake");

	if (!kWelcomeShownKey.defaultInt)
	{
		[self openMainWindow:nil];
		kWelcomeShownKey.defaultInt = 1;
	}

	_tableView.doubleAction = @selector(editAccount:);
	_tableView.target = self;
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
	[self.visibilityManager handleAppReopen];
	
	[self openMainWindow:nil];

	return FALSE;
}

- (IBAction)openMainWindow:(id)sender
{
	if (!_window)
    {
        [NSBundle loadNibNamed:@"MainWindow" owner:self];
        [self toolbarClicked:@(0)];
        _toolbar.selectedItemIdentifier = (_toolbar.items[0]).itemIdentifier;
    }

    [NSApp activateIgnoringOtherApps:YES];
	[_window makeKeyAndOrderFront:self];
}

- (IBAction)showHelp:(id)sender
{
	[self openMainWindow:self];
	
	[self toolbarClicked:@(1)];
	_toolbar.selectedItemIdentifier = (_toolbar.items[1]).itemIdentifier;

	[_documentationTabView selectTabViewItemAtIndex:1];
}

- (IBAction)toolbarClicked:(id)sender
{
    NSArray *views = @[_settingsView, _aboutView];
    NSInteger index = [sender isKindOfClass:[NSNumber class]] ? [sender intValue] : [sender tag];
    [_mainTabView tabViewItemAtIndex:index].view = views[(NSUInteger) index];
    [_mainTabView selectTabViewItemAtIndex:index];
}

- (void)startAccountEditing
{
	[NSApp beginSheet:self.setupPanel1
	   modalForWindow:self.window
		modalDelegate:nil
	   didEndSelector:nil
		  contextInfo:NULL];

	self.passwordField.stringValue = NON_NIL_STR(self.currentAccount[@"password"]);
	self.usernameField.stringValue = NON_NIL_STR(self.currentAccount[@"username"]);
	self.serverField.stringValue = NON_NIL_STR(self.currentAccount[@"server"]);

	self.mailAccounts = [NSMutableArray array];
	while (self.importButton.numberOfItems > 1)
		[self.importButton removeItemAtIndex:1];

	[self.importButton itemAtIndex:0].title = @"Import Account (please wait)";

    dispatch_async_back(^
	{
		MailApplication *mail = [SBApplication applicationWithBundleIdentifier:@"com.apple.Mail"];
		for (MailAccount *account in mail.imapAccounts)
		{
			if (account.userName && account.serverName && account.name)
				dispatch_async_main(^
				{
					[self.mailAccounts addObject:@{@"username" : account.userName,
												   @"server" : account.serverName,
												   @"accountname" : account.name}];

					[self.importButton addItemWithTitle:account.name];
				});
		}
		dispatch_async_main(^
		{
			[self.importButton itemAtIndex:0].title = @"Import Account";
		});
	});
}

- (IBAction)importAccount:(NSPopUpButton *)sender
{
	NSDictionary *accountInfo = self.mailAccounts[sender.indexOfSelectedItem-1];
	
	self.serverField.stringValue = @"";
	self.usernameField.stringValue = NON_NIL_STR(accountInfo[@"username"]);
	self.serverField.stringValue = NON_NIL_STR(accountInfo[@"server"]);
}

- (IBAction)addAccount:(id)sender
{
	self.currentAccount = [NSMutableDictionary new];

	[self startAccountEditing];
}

- (IBAction)deleteAccount:(id)sender
{
	Account *account = (self.arrayController).selectedObjects[0];
	[account stopTimer];

	[self.arrayController remove:sender];

	[self saveAccounts];
}

- (IBAction)editAccount:(id)sender
{
	Account *account = (self.arrayController).selectedObjects[0]; //selection];
	
	self.currentAccount = [NSMutableDictionary new];

	self.currentAccount[@"account"] = account;
	self.currentAccount[@"password"] = account.password;
	self.currentAccount[@"username"] = account.username;
	self.currentAccount[@"server"] = account.server;
	if (account.customquota)
		self.currentAccount[@"customquota"] = @(account.customquota).stringValue;
	self.currentAccount[@"interval"] = @(account.interval).stringValue;
	self.currentAccount[@"threshold"] = @(account.percent).stringValue;

	[self startAccountEditing];
}

- (IBAction)cancelAccount:(id)sender
{
	[NSApp endSheet:self.setupPanel1];
	[self.setupPanel1 orderOut:self];

	[NSApp endSheet:self.setupPanel2];
	[self.setupPanel2 orderOut:self];
}

- (IBAction)updateThresholdField:(id)sender
{
	float threshold = (self.thresholdField).stringValue.floatValue / 100.0;
	
	if (self.quotaMatrix.selectedRow == 0)
		self.thresholdLabel.stringValue = makeString(@"(%i MB)", (int)(threshold * [self.currentAccount[@"quota"] floatValue]));
	else
		self.thresholdLabel.stringValue = makeString(@"(%i MB)", (int)(threshold * self.customquotaField.stringValue.floatValue));
}

- (IBAction)continueAccount:(NSButton *)sender
{
	if ((self.serverField).stringValue.length &&
		(self.usernameField).stringValue.length &&
		(self.passwordField).stringValue.length)
	{
		self.blockView.hidden = NO;
		self.progressIndicator.hidden = NO;
		[self.progressIndicator startAnimation:self];
		sender.enabled = NO;
		
		dispatch_async_back(^
		{
			self.currentAccount[@"password"] = (self.passwordField).stringValue;
			self.currentAccount[@"username"] = (self.usernameField).stringValue;
			self.currentAccount[@"server"] = (self.serverField).stringValue;

			NSDictionary *mb = [AppDelegate checkMailbox:self.currentAccount];

			dispatch_async_main(^
			{
				self.blockView.hidden = YES;
				self.progressIndicator.hidden = YES;
				[self.progressIndicator stopAnimation:self];
				sender.enabled = YES;

				if ([mb[@"status"] hasPrefix:@"ERR"])
				{
					if ([mb[@"status"] hasPrefix:@"ERRSERVER"])
						NSRunAlertPanel(cc.appName, @"The server you've entered doesn't seem to be a valid IMAP server or maybe it is offline at the moment.", @"OK", nil, nil);

					if ([mb[@"status"] hasPrefix:@"ERRCREDENTIALS"])
						NSRunAlertPanel(cc.appName, @"The username and password combination was not accepted by the server.", @"OK", nil, nil);
				}
				else
				{
					[NSApp endSheet:self.setupPanel1];
					[self.setupPanel1 orderOut:self];

					[self.currentAccount addEntriesFromDictionary:mb];

					if (mb[@"quota"] && [mb[@"quota"] intValue])
					{
						[self.quotaMatrix selectCellAtRow:0 column:0];
						(self.serverquotaLabel).stringValue = makeString(@"(%i MB)", [mb[@"quota"] intValue]);
						self.quotaMatrix.enabled = YES;
					}
					else
					{
						self.serverquotaLabel.stringValue = @"(unavailable)";
						[self.quotaMatrix selectCellAtRow:1 column:0];
						self.quotaMatrix.enabled = NO;
					}


					
					[self.customquotaField setStringValue:OBJECT_OR(self.currentAccount[@"customquota"], @"100")];
					[self.intervalField setStringValue:OBJECT_OR(self.currentAccount[@"interval"], @"4")];
					[self.thresholdField setStringValue:OBJECT_OR(self.currentAccount[@"threshold"], @"90")];

					[self updateThresholdField:nil];
					
					[NSApp beginSheet:self.setupPanel2
					   modalForWindow:self.window
						modalDelegate:nil
					   didEndSelector:nil
						  contextInfo:NULL];
				}
			});
		});
	}
	else
	{
		NSRunAlertPanel(cc.appName, @"You must enter a server and username and password to continue.", @"OK", nil, nil);
	}
}

- (void)saveAccounts
{
    kAccountDataKey.defaultObject = [NSKeyedArchiver archivedDataWithRootObject:self.accountArray];
	[userDefaults synchronize];
	[notificationCenter postNotificationName:@"accountUpdate" object:nil];
//	NSLog(@"post accountUpdate save");
}

- (IBAction)finishAccount:(id)sender
{
	[NSApp endSheet:self.setupPanel2];
	[self.setupPanel2 orderOut:self];


	Account *oldAccount = self.currentAccount[@"account"];
	Account *newAccount = OBJECT_OR(oldAccount, [Account new]);

	newAccount.server = NON_NIL_STR(self.currentAccount[@"server"]);
	newAccount.username = NON_NIL_STR(self.currentAccount[@"username"]);
	newAccount.password = NON_NIL_STR(self.currentAccount[@"password"]);
	newAccount.interval = (self.intervalField).stringValue.intValue;
	newAccount.percent = (self.thresholdField).stringValue.intValue;
	if ((self.quotaMatrix).selectedRow == 0)
		newAccount.customquota = 0;
	else
		newAccount.customquota = (self.customquotaField).stringValue.intValue;

	[newAccount scheduleTests];

	if (!oldAccount)
	{
		[self willChangeValueForKey:@"accountArray"];
		[self.accountArray addObject:newAccount];
		[self didChangeValueForKey:@"accountArray"];
	}
	
	[self saveAccounts];
}

- (IBAction)openURL:(id)sender
{
	int tag = [[sender valueForKey:@"tag"] intValue];
	NSString *urlString = @"";

	if (tag == 1)
		urlString = makeString(@"mailto:feedback@corecode.io?subject=%@ %@ Support Request (License code: %@)&body=Insert Support Request Here\n\n\n\nP.S: Hardware: %@ Software: %@ %@: %i%@", cc.appName, cc.appVersionString, cc.appChecksumSHA, [JMHostInformation machineType], [NSProcessInfo processInfo].operatingSystemVersionString, cc.appName, cc.appBuildNumber, ((cc.appCrashLogs).count ? makeString(@" Problems: %li", (cc.appCrashLogs).count) : @""));
	else if (tag == 2)
		urlString = makeString(@"mailto:feedback@corecode.io?subject=%@ Beta Versions&body=Hello\nI would like to test upcoming beta versions of %@.\nBye\n", cc.appName, cc.appName);
	else if (tag == 3)
		urlString = makeString(@"https://www.corecode.io/%@/", (cc.appName).lowercaseString);
	else if (tag == 4)
		urlString = @"https://itunes.apple.com/us/app/mailboxalert/id595630519?mt=12";

    if (![[NSWorkspace sharedWorkspace] openURL:urlString.escaped.URL])
        asl_NSLog(ASL_LEVEL_WARNING, @"Warning: [[NSWorkspace sharedWorkspace] openURL:url] failed");
}

+ (NSDictionary *)checkMailbox:(NSDictionary *)account
{
	//	SumCalc 3080 1004.000000
	//	SumSum 9379 1476.000000
	//	Quota 1480.996094 10333.430664

	NSMutableDictionary *out = [NSMutableDictionary new];
	NSString *res = [@[@"/usr/bin/python", @"imap.py".resourcePath, account[@"server"], account[@"username"], account[@"password"]] runAsTask];

//	LOG(res);
	
	if ([res hasPrefix:@"ERR"])
		out[@"status"] = res;
	else
	{
		out[@"status"] = @"OK";


		int maxCount = 0;
		float maxSize = 0;

		for (NSString *line in res.lines)
		{
			if ([line hasPrefix:@"Sum"])
			{
				int count = ([line split:@" "][1]).intValue;
				float size = ([line split:@" "][2]).floatValue;

				maxSize = MAX(size, maxSize);
				maxCount = MAX(count, maxCount);
			}
			if ([line hasPrefix:@"Quota"])
			{
				float size = ([line split:@" "][1]).floatValue;
				float quota = ([line split:@" "][2]).floatValue;

				maxSize = MAX(size, maxSize);
				out[@"quota"] = @(quota);
			}
		}
		out[@"count"] = @(maxCount);
		out[@"size"] = @(maxSize);
	}
	return out;
}

- (IBAction)changeAppVisibility:(id)sender
{
	dispatch_after_main(1.0, ^
	{
		[self openMainWindow:nil];
	});
}
@end

int main(int argc, const char *argv[])
{
    return NSApplicationMain(argc, (const char **)argv);
}