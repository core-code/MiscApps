//
//  CoreLib.m
//  CoreLib
//
//  Created by CoreCode on 17.12.12.
/*	Copyright © 2018 CoreCode Limited
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "CoreLibOld.h"
#ifndef CORELIB
#error you need to include CoreLib.h in your PCH file
#endif
#ifdef USE_SECURITY
#include <CommonCrypto/CommonDigest.h>
#endif

#if __has_feature(modules)
@import Darwin.POSIX.unistd;
@import Darwin.POSIX.sys.types;
@import Darwin.POSIX.pwd;
#include <assert.h>
#else
#include <unistd.h>
#include <sys/types.h>
#include <pwd.h>
#include <assert.h>
#endif



NSString *_machineType(void);

CoreLib *cc;
NSUserDefaults *userDefaults;
NSFileManager *fileManager;
NSNotificationCenter *notificationCenter;
NSBundle *bundle;
#if defined(TARGET_OS_MAC) && TARGET_OS_MAC && !TARGET_OS_IPHONE
NSFontManager *fontManager;
NSDistributedNotificationCenter *distributedNotificationCenter;
NSApplication *application;
NSWorkspace *workspace;
NSProcessInfo *processInfo;
#endif


#if defined(TARGET_OS_MAC) && TARGET_OS_MAC && !TARGET_OS_IPHONE
__attribute__((noreturn)) void exceptionHandler(NSException *exception)
{
	alert_feedback_fatal(exception.name, makeString(@" %@ %@ %@ %@", exception.description, exception.reason, exception.userInfo.description, exception.callStackSymbols));
}
#endif

@implementation CoreLib

@dynamic appCrashLogs, appBundleIdentifier, appBuildNumber, appVersionString, appName, resDir, docDir, suppDir, resURL, docURL, suppURL, deskDir, deskURL, prefsPath, prefsURL, homeURLInsideSandbox, homeURLOutsideSandbox
#ifdef USE_SECURITY
, appChecksumSHA;
#else
;
#endif

+ (void)initialize
{
	
}

- (instancetype)init
{
	assert(!cc);

	if ((self = [super init]))
    {
        cc = self;


        userDefaults = [NSUserDefaults standardUserDefaults];
        fileManager = [NSFileManager defaultManager];
        notificationCenter = [NSNotificationCenter defaultCenter];
        bundle = [NSBundle mainBundle];
    #if defined(TARGET_OS_MAC) && TARGET_OS_MAC && !TARGET_OS_IPHONE
        fontManager = [NSFontManager sharedFontManager];
        distributedNotificationCenter = [NSDistributedNotificationCenter defaultCenter];
        workspace = [NSWorkspace sharedWorkspace];
        application = [NSApplication sharedApplication];
        processInfo = [NSProcessInfo processInfo];
    #endif

        if (!self.suppURL.fileExists)
		{
			if ([fileManager respondsToSelector:@selector(createDirectoryAtURL:withIntermediateDirectories:attributes:error:)])
				[fileManager createDirectoryAtURL:self.suppURL
					  withIntermediateDirectories:YES attributes:nil error:NULL];
			else
			{
				NSString *p = self.suppURL.path;
				[fileManager createDirectoryAtPath:p
					   withIntermediateDirectories:YES attributes:nil error:NULL];
			}
		}

    #ifdef DEBUG
		#ifndef XCTEST
            BOOL isSandbox = [@"~/Library/".expanded contains:@"/Library/Containers/"];

            #ifdef SANDBOX
                assert(isSandbox);
            #else
                assert(!isSandbox);
            #endif
		#endif

        #ifdef NDEBUG
            LOG(@"Warning: you are running in DEBUG mode but have disabled assertions (NDEBUG)");
        #endif

        #if !defined(XCTEST) || !XCTEST
            NSString *bundleID = [bundle objectForInfoDictionaryKey:@"CFBundleIdentifier"];
            if (![[self appBundleIdentifier] isEqualToString:bundleID])
                exit(666);
        #endif

        if ([[bundle objectForInfoDictionaryKey:@"LSUIElement"] boolValue] &&
            ![[bundle objectForInfoDictionaryKey:@"NSPrincipalClass"] isEqualToString:@"JMDocklessApplication"])
            cc_log_debug(@"Warning: app can hide dock symbol but has no fixed principal class");


        if (![[[bundle objectForInfoDictionaryKey:@"MacupdateProductPage"] lowercaseString] contains:self.appName.lowercaseString])
            cc_log_debug(@"Warning: info.plist key MacupdateProductPage not properly set");

        if ([[[bundle objectForInfoDictionaryKey:@"MacupdateProductPage"] lowercaseString] contains:@"/find/"])
            cc_log_debug(@"Warning: info.plist key MacupdateProductPage should be updated to proper product page");

        if (![[[bundle objectForInfoDictionaryKey:@"StoreProductPage"] lowercaseString] contains:self.appName.lowercaseString])
            cc_log_debug(@"Warning: info.plist key StoreProductPage not properly set (%@ NOT CONTAINS %@", [[bundle objectForInfoDictionaryKey:@"StoreProductPage"] lowercaseString], self.appName.lowercaseString);

        if (![(NSString *)[bundle objectForInfoDictionaryKey:@"LSApplicationCategoryType"] length])
            LOG(@"Warning: LSApplicationCategoryType not properly set");
        
        
        
        if (NSClassFromString(@"JMRatingWindowController") &&
            NSProcessInfo.processInfo.environment[@"XCInjectBundleInto"] != nil)
        {
            assert(@"icon-appstore.png".resourceURL);
            assert(@"icon-macupdate.png".resourceURL);
            assert(@"JMRatingWindow.nib".resourceURL);
        }
        #ifdef USE_SPARKLE
            assert(@"dsa_pub.pem".resourceURL);
        #endif
    #else
        #ifndef NDEBUG
            cc_log_error(@"Warning: you are not running in DEBUG mode but have not disabled assertions (NDEBUG)");
        #endif
    #endif

        
    #if defined(TARGET_OS_MAC) && TARGET_OS_MAC && !TARGET_OS_IPHONE
    #ifndef DONT_CRASH_ON_EXCEPTIONS
        NSSetUncaughtExceptionHandler(&exceptionHandler);
    #endif

        
        NSString *frameworkPath = bundle.privateFrameworksPath;
        for (NSString *framework in frameworkPath.dirContents)
        {
            NSString *smylinkToBinaryPath = makeString(@"%@/%@/%@", frameworkPath, framework, framework.stringByDeletingPathExtension);

            if (!smylinkToBinaryPath.fileIsAlias)
            {
#ifdef DEBUG
                if ([framework hasPrefix:@"libclang"]) continue;
#endif
                alert_apptitled(@"This application is damaged. Either your download was damaged or you used a faulty program to extract the ZIP archive. Please re-download and make sure to use the ZIP decompression built into Mac OS X.", @"OK", nil, nil);
                exit(0);
            }
#ifdef DEBUG
            NSString *versionsPath = makeString(@"%@/%@/Versions", frameworkPath, framework);
            for (NSString *versionsEntry in versionsPath.dirContents)
            {
                if ((![versionsEntry isEqualToString:@"A"]) && (![versionsEntry isEqualToString:@"Current"]))
                {
                    cc_log_error(@"The frameworks are damaged probably by lowercasing. Either your download was damaged or you used a faulty program to extract the ZIP archive. Please re-download and make sure to use the ZIP decompression built into Mac OS X.");
                    exit(0);
                }
            }
            NSString *versionAPath = makeString(@"%@/%@/Versions/A", frameworkPath, framework);
            for (NSString *entry in versionAPath.dirContents)
            {
                if (([entry isEqualToString:@"headers"]) && (![entry isEqualToString:@"resources"]))
                {
                    cc_log_error(@"The frameworks are damaged probably by lowercasing. Either your download was damaged or you used a faulty program to extract the ZIP archive. Please re-download and make sure to use the ZIP decompression built into Mac OS X.");
                    exit(0);
                }
            }
#endif
        }
    #endif
    }

    assert(cc);


	return self;
}

- (NSString *)prefsPath
{
	return makeString(@"~/Library/Preferences/%@.plist", self.appBundleIdentifier).expanded;
}

- (NSURL *)prefsURL
{
	return self.prefsPath.fileURL;
}

- (NSArray *)appCrashLogs // doesn't do anything in sandbox!
{
	NSArray <NSString *> *logs1 = @"~/Library/Logs/DiagnosticReports/".expanded.dirContents;
	NSArray <NSString *> *logs2 = @"/Library/Logs/DiagnosticReports/".expanded.dirContents;
	NSArray <NSString *> *logs = [logs1 arrayByAddingObjectsFromArray:logs2];
	
	return [logs filteredUsingPredicateString:@"self BEGINSWITH[cd] %@", self.appName];
}

- (NSString *)appBundleIdentifier
{
	return NSBundle.mainBundle.bundleIdentifier;
}

- (NSString *)appVersionString
{
	return [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

- (NSString *)appName
{
#if defined(XCTEST) && XCTEST
	return @"TEST";
#else
	return [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleName"];
#endif
}

- (int)appBuildNumber
{
	return [[NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleVersion"] intValue];
}

- (NSString *)resDir
{
	return NSBundle.mainBundle.resourcePath;
}

- (NSURL *)resURL
{
	return NSBundle.mainBundle.resourceURL;
}

- (NSString *)docDir
{
	return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
}

- (NSString *)deskDir
{
	return NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES)[0];
}

- (NSURL *)homeURLInsideSandbox
{
	return NSHomeDirectory().fileURL;
}

- (NSURL *)homeURLOutsideSandbox
{
    struct passwd *pw = getpwuid(getuid());
    assert(pw);
    NSString *realHomePath = @(pw->pw_dir);
    NSURL *realHomeURL = [NSURL fileURLWithPath:realHomePath];

    return realHomeURL;
}


- (NSURL *)docURL
{
	return [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
}

- (NSURL *)deskURL
{
	return [NSFileManager.defaultManager URLsForDirectory:NSDesktopDirectory inDomains:NSUserDomainMask][0];
}

- (NSString *)suppDir
{
	return [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:self.appName];
}

- ( NSURL * __nonnull)suppURL
{
	NSURL *dir = [NSFileManager.defaultManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask][0];

	assert(dir && self.appName);

	return [dir add:self.appName];
}

- (NSString *)appChecksumSHA
{
#ifdef USE_SECURITY
    NSURL *u = [[NSBundle mainBundle] executableURL];
	NSData *d = [NSData dataWithContentsOfURL:u];
	unsigned char result[CC_SHA1_DIGEST_LENGTH];
	CC_SHA1([d bytes], (CC_LONG)[d length], result);
	NSMutableString *ms = [NSMutableString string];
	
	for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
	{
		[ms appendFormat: @"%02x", (int)(result [i])];
	}
	
#if ! __has_feature(objc_arc)
	return [[ms copy] autorelease];
#else
	return [ms copy];
#endif
#else
	return @"Unvailable";
#endif
}

- (void)sendSupportRequestMail:(NSString *)text
{
    NSString *urlString = @"";

    
#if defined(TARGET_OS_MAC) && TARGET_OS_MAC && !TARGET_OS_IPHONE
    BOOL optionDown = ([NSEvent modifierFlags] & NSEventModifierFlagOption) != 0;
#endif
    
    NSString *encodedPrefs = @"";
    
#if defined(TARGET_OS_MAC) && TARGET_OS_MAC && !TARGET_OS_IPHONE
#if (__MAC_OS_X_VERSION_MIN_REQUIRED < 1090)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#pragma clang diagnostic ignored "-Wpartial-availability"
#endif
    if (optionDown && [NSData instancesRespondToSelector:@selector(base64EncodedStringWithOptions:)])
        encodedPrefs = [self.prefsURL.contents base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0];
#if (__MAC_OS_X_VERSION_MIN_REQUIRED < 1090)
#pragma clang diagnostic pop
#endif
#endif
    
    
    NSString *recipient = OBJECT_OR([bundle objectForInfoDictionaryKey:@"FeedbackEmail"], kFeedbackEmail);
    
    NSString *subject = makeString(@"%@ v%@ (%i) Support Request (License code: %@)",
                                   cc.appName,
                                   cc.appVersionString,
                                   cc.appBuildNumber,
                                   cc.appChecksumSHA);
    
    NSString *content =  makeString(@"%@\n\n\n\nP.S: Hardware: %@ Software: %@%@\n%@",
                                    text,
                                    _machineType(),
                                    [[NSProcessInfo processInfo] operatingSystemVersionString],
                                    ([cc.appCrashLogs count] ? makeString(@" Problems: %li", (unsigned long)[cc.appCrashLogs count]) : @""),
                                    encodedPrefs);
    
    
    urlString = makeString(@"mailto:%@?subject=%@&body=%@", recipient, subject, content);
    
    [urlString.escaped.URL open];
}

- (void)openURL:(openChoice)choice
{
	if (choice == openSupportRequestMail)
	{
        [self sendSupportRequestMail:@"<Insert Support Request Here>"];
        return;
	}
    
	
    NSString *urlString = @"";

    if (choice == openBetaSignupMail)
		urlString = makeString(@"s%@?subject=%@ Beta Versions&body=Hello\nI would like to test upcoming beta versions of %@.\nBye\n",
							   [bundle objectForInfoDictionaryKey:@"FeedbackEmail"], cc.appName, cc.appName);
	else if (choice == openHomepageWebsite)
		urlString = OBJECT_OR([bundle objectForInfoDictionaryKey:@"VendorProductPage"],
							  makeString(@"%@%@/", kVendorHomepage, [cc.appName.lowercaseString.words[0] split:@"-"][0]));
	else if (choice == openAppStoreWebsite)
		urlString = [bundle objectForInfoDictionaryKey:@"StoreProductPage"];
	else if (choice == openAppStoreApp)
    {
        urlString = [[bundle objectForInfoDictionaryKey:@"StoreProductPage"] replaced:@"https" with:@"macappstore"];
        urlString = [urlString stringByAppendingString:@"&at=1000lwks"];
    }
	else if (choice == openMacupdateWebsite)
    	urlString = [bundle objectForInfoDictionaryKey:@"MacupdateProductPage"];

	[urlString.escaped.URL open];
}

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat-nonliteral"


NSString *makeDescription(id sender, NSArray *args)
{
	NSMutableString *tmp = [NSMutableString new];

	for (NSString *arg in args)
	{
		NSString *d = [[sender valueForKey:arg] description];

		[tmp appendFormat:@"\n%@: %@", arg, d];
	}

#if ! __has_feature(objc_arc)
	[tmp autorelease];
#endif

	return tmp.immutableObject;
}

NSString *makeString(NSString *format, ...)
{
	va_list args;
	va_start(args, format);
	NSString *str = [[NSString alloc] initWithFormat:format arguments:args];
	va_end(args);
	
#if ! __has_feature(objc_arc)
	[str autorelease];
#endif
	
	return str;
}

#if defined(TARGET_OS_MAC) && TARGET_OS_MAC && !TARGET_OS_IPHONE

void alert_feedback(NSString *usermsg, NSString *details, BOOL fatal)
{
    cc_log_error(@"alert_feedback %@ %@", usermsg, details);

	dispatch_block_t block = ^
	{
        static const int maxLen = 400;

        NSString *encodedPrefs = @"";
        
#if defined(TARGET_OS_MAC) && TARGET_OS_MAC && !TARGET_OS_IPHONE
#if (__MAC_OS_X_VERSION_MIN_REQUIRED < 1090)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#pragma clang diagnostic ignored "-Wpartial-availability"
#endif
		if ([NSData instancesRespondToSelector:@selector(base64EncodedStringWithOptions:)])
			encodedPrefs = [cc.prefsURL.contents base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0];
#if (__MAC_OS_X_VERSION_MIN_REQUIRED < 1090)
#pragma clang diagnostic pop
#endif
#endif

		NSString *visibleDetails = details;
		if (visibleDetails.length > maxLen)
			visibleDetails = makeString(@"%@  …\n(Remaining message omitted)", [visibleDetails clamp:maxLen]);
		NSString *message = makeString(@"%@\n\n You can contact our support with detailed information so that we can fix this problem.\n\nInformation: %@", usermsg, visibleDetails);
		NSString *mailtoLink = @"";
		@try
		{
			mailtoLink = makeString(@"mailto:%@?subject=%@ v%@ (%i) Problem Report (License code: %@)&body=Hello\nA %@ error in %@ occured (%@).\n\nBye\n\nP.S. Details: %@\n\n\nP.P.S: Hardware: %@ Software: %@ Admin: %i%@\n\nPreferences: %@\n",
												kFeedbackEmail,
												cc.appName,
												cc.appVersionString,
												cc.appBuildNumber,
												cc.appChecksumSHA,
												fatal ? @"fatal" : @"",
												cc.appName,
												usermsg,
												details,
												_machineType(),
												[[NSProcessInfo processInfo] operatingSystemVersionString],
												44,
												([cc.appCrashLogs count] ? makeString(@" Problems: %li", [cc.appCrashLogs count]) : @""),
												encodedPrefs);

		}
		@catch (NSException *)
		{
		}


		{
			if (alert(fatal ? @"Fatal Error" : @"Error",
					  message,
					  @"Send to support", fatal ? @"Quit" : @"Continue", nil) == NSAlertFirstButtonReturn)
			{
				[mailtoLink.escaped.URL open];
			}
		}

		if (fatal)
			exit(1);
    };







	dispatch_sync_main(block);
}

void alert_feedback_fatal(NSString *usermsg, NSString *details)
{
	alert_feedback(usermsg, details, YES);
	exit(1);
}

void alert_feedback_nonfatal(NSString *usermsg, NSString *details)
{
	alert_feedback(usermsg, details, NO);
}


NSInteger _alert_input(NSString *prompt, NSArray *buttons, NSString **result, BOOL useSecurePrompt)
{
    assert(buttons);
    assert(result);
    assert([NSThread currentThread] == [NSThread mainThread]);

    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = prompt;
    
    if (buttons.count > 0)
        [alert addButtonWithTitle:buttons[0]];
    if (buttons.count > 1)
        [alert addButtonWithTitle:buttons[1]];
    if (buttons.count > 2)
        [alert addButtonWithTitle:buttons[2]];
    
	NSTextField *input;
	if (useSecurePrompt)
		input = [[NSSecureTextField alloc] initWithFrame:NSMakeRect(0, 0, 310, 24)];
	else
		input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 310, 24)];

#if ! __has_feature(objc_arc)
	[input autorelease];
#endif
	[alert setAccessoryView:input];
	NSInteger selectedButton = [alert runModal];

	[input validateEditing];
	*result = [input stringValue];
    
#if ! __has_feature(objc_arc)
    [alert release];
#endif
    
	return selectedButton;
}

NSInteger alert_checkbox(NSString *prompt, NSArray <NSString *>*buttons, NSString *checkboxTitle, NSUInteger *checkboxStatus)
{
	assert(buttons);
	assert(checkboxStatus);
	assert([NSThread currentThread] == [NSThread mainThread]);

	NSAlert *alert = [[NSAlert alloc] init];
	alert.messageText = prompt;

	if (buttons.count > 0)
		[alert addButtonWithTitle:buttons[0]];
	if (buttons.count > 1)
		[alert addButtonWithTitle:buttons[1]];
	if (buttons.count > 2)
		[alert addButtonWithTitle:buttons[2]];

	NSButton *input = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 310, 24)];
	[input setButtonType:NSSwitchButton];
	[input setState:(NSInteger )*checkboxStatus];
	[input setTitle:checkboxTitle];

	[alert setAccessoryView:input];
	NSInteger selectedButton = [alert runModal];

	*checkboxStatus = (NSUInteger)[input state];

#if ! __has_feature(objc_arc)
	[input release];
	[alert release];
#endif

	return selectedButton;
}

NSInteger alert_colorwell(NSString *prompt, NSArray <NSString *>*buttons, NSColor **selectedColor)
{
    assert(buttons);
    assert(selectedColor);
    assert([NSThread currentThread] == [NSThread mainThread]);

    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = prompt;

    if (buttons.count > 0)
        [alert addButtonWithTitle:buttons[0]];
    if (buttons.count > 1)
        [alert addButtonWithTitle:buttons[1]];
    if (buttons.count > 2)
        [alert addButtonWithTitle:buttons[2]];

    NSColorWell *input = [[NSColorWell alloc] initWithFrame:NSMakeRect(0, 0, 310, 24)];
    [input setColor:*selectedColor];

    [alert setAccessoryView:input];
    NSInteger selectedButton = [alert runModal];

    *selectedColor = [input color];

#if ! __has_feature(objc_arc)
    [input release];
    [alert release];
#endif
    
    return selectedButton;
}

NSInteger alert_inputtext(NSString *prompt, NSArray *buttons, NSString **result)
{
	assert(buttons);
	assert(result);
	assert([NSThread currentThread] == [NSThread mainThread]);

	NSAlert *alert = [[NSAlert alloc] init];
	alert.messageText = prompt;

	if (buttons.count > 0)
		[alert addButtonWithTitle:buttons[0]];
	if (buttons.count > 1)
		[alert addButtonWithTitle:buttons[1]];
	if (buttons.count > 2)
		[alert addButtonWithTitle:buttons[2]];

	NSTextView *input = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, 310, 200)];

#if ! __has_feature(objc_arc)
	[input autorelease];
#endif
	[alert setAccessoryView:input];
	NSInteger selectedButton = [alert runModal];

	*result = [input string];

#if ! __has_feature(objc_arc)
	[alert release];
#endif

	return selectedButton;
}

NSInteger alert_selection_popup(NSString *prompt, NSArray<NSString *> *choices, NSArray<NSString *> *buttons, NSUInteger *result)
{
	assert(buttons);
	assert(choices);
	assert(result);
	assert([NSThread currentThread] == [NSThread mainThread]);

	NSAlert *alert = [[NSAlert alloc] init];
	alert.messageText = prompt;

	if (buttons.count > 0)
		[alert addButtonWithTitle:buttons[0]];
	if (buttons.count > 1)
		[alert addButtonWithTitle:buttons[1]];
	if (buttons.count > 2)
		[alert addButtonWithTitle:buttons[2]];

	NSPopUpButton *input = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(0, 0, 310, 24)];
	for (NSString *str in choices)
		[input addItemWithTitle:str];
#if ! __has_feature(objc_arc)
	[input autorelease];
#endif
	[alert setAccessoryView:input];
	NSInteger selectedButton = [alert runModal];

	[input validateEditing];
	*result = (NSUInteger)[input indexOfSelectedItem];

#if ! __has_feature(objc_arc)
	[alert release];
#endif

	return selectedButton;
}

NSInteger alert_selection_matrix(NSString *prompt, NSArray<NSString *> *choices, NSArray<NSString *> *buttons, NSUInteger *result)
{
	assert(buttons);
	assert(result);
	assert([NSThread currentThread] == [NSThread mainThread]);

	NSAlert *alert = [[NSAlert alloc] init];
	alert.messageText = prompt;

	if (buttons.count > 0)
		[alert addButtonWithTitle:buttons[0]];
	if (buttons.count > 1)
		[alert addButtonWithTitle:buttons[1]];
	if (buttons.count > 2)
		[alert addButtonWithTitle:buttons[2]];

	NSButtonCell *thepushbutton = [[NSButtonCell alloc] init];
	[thepushbutton setButtonType:NSRadioButton];

	NSMatrix *thepushbuttons = [[NSMatrix alloc] initWithFrame:NSMakeRect(0,0,269,17 * choices.count)
                                                          mode:NSRadioModeMatrix
                                                     prototype:thepushbutton
                                                  numberOfRows:(int)choices.count
                                               numberOfColumns:1];

	for (NSUInteger i = 0; i < choices.count; i++)
	{
		[thepushbuttons selectCellAtRow:(int)i column:0];

        NSString *title = choices[i];
        if (title.length > 150)
            title = makeString(@"%@ […] %@", [title substringToIndex:70], [title substringFromIndex:title.length-70]);

		[[thepushbuttons selectedCell] setTitle:title];
	}
	[thepushbuttons selectCellAtRow:0 column:0];

	[thepushbuttons sizeToFit];

	[alert setAccessoryView:thepushbuttons];
	[[alert window] makeFirstResponder:thepushbuttons];

	NSInteger selectedButton = [alert runModal];
//U	[[alert window] setInitialFirstResponder: thepushbuttons];

	*result = (NSUInteger)[thepushbuttons selectedRow];

#if ! __has_feature(objc_arc)
	[thepushbuttons release];
	[thepushbutton release];
	[alert release];
#endif

	return selectedButton;
}

NSInteger alert_input(NSString *prompt, NSArray *buttons, NSString **result)
{
	return _alert_input(prompt, buttons, result, NO);
}

NSInteger alert_inputsecure(NSString *prompt, NSArray *buttons, NSString **result)
{
	return _alert_input(prompt, buttons, result, YES);
}

__attribute__((annotate("returns_localized_nsstring"))) static inline NSString *LocalizationNotNeeded(NSString *s) { return s; }
NSInteger alert(NSString *title, NSString *message, NSString *defaultButton, NSString *alternateButton, NSString *otherButton)
{
	assert([NSThread currentThread] == [NSThread mainThread]);
    
	[NSApp activateIgnoringOtherApps:YES];

    
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = title;
    alert.informativeText = LocalizationNotNeeded(message);
    
    if (defaultButton)
        [alert addButtonWithTitle:LocalizationNotNeeded(defaultButton)];
    if (alternateButton)
        [alert addButtonWithTitle:alternateButton];
    if (otherButton)
        [alert addButtonWithTitle:otherButton];
    
    NSInteger result = [alert runModal];
    
#if ! __has_feature(objc_arc)
    [alert release];
#endif
    
    return result;
}

NSInteger alert_apptitled(NSString *message, NSString *defaultButton, NSString *alternateButton, NSString *otherButton)
{
	return alert(cc.appName, message, defaultButton, alternateButton, otherButton);
}

void alert_dontwarnagain_version(NSString *identifier, NSString *title, NSString *message, NSString *defaultButton, NSString *dontwarnButton)
{
    assert(defaultButton && dontwarnButton);
    
   	dispatch_block_t block = ^
	{
		NSString *defaultKey = makeString(@"_%@_%@_asked", identifier, cc.appVersionString);
		if (!defaultKey.defaultInt)
		{
            NSAlert *alert = [[NSAlert alloc] init];
            
            alert.messageText = title;
            alert.informativeText = message;
            [alert addButtonWithTitle:defaultButton];
            alert.showsSuppressionButton = YES;
            alert.suppressionButton.title = dontwarnButton;
            
            
			[NSApp activateIgnoringOtherApps:YES];
            [alert runModal];
            
            defaultKey.defaultInt = alert.suppressionButton.state;
            
            
#if ! __has_feature(objc_arc)
            [alert release];
#endif
		}
	};

    if ([NSThread currentThread] == [NSThread mainThread])
        block();
    else
        dispatch_async_main(block);
}
void alert_dontwarnagain_ever(NSString *identifier, NSString *title, NSString *message, NSString *defaultButton, NSString *dontwarnButton)
{
    dispatch_block_t block = ^
	{
		NSString *defaultKey = makeString(@"_%@_asked", identifier);
        
        if (!defaultKey.defaultInt)
        {
            NSAlert *alert = [[NSAlert alloc] init];
            
            alert.messageText = title;
            alert.informativeText = message;
            [alert addButtonWithTitle:defaultButton];
            alert.showsSuppressionButton = YES;
            alert.suppressionButton.title = dontwarnButton;
            
            
            [NSApp activateIgnoringOtherApps:YES];
            [alert runModal];
            
            defaultKey.defaultInt = alert.suppressionButton.state;
            
            
#if ! __has_feature(objc_arc)
            [alert release];
#endif
        }
	};

	if ([NSThread currentThread] == [NSThread mainThread])
		block();
	else
		dispatch_async_main(block);
}
#pragma clang diagnostic pop


NSColor *makeColor(CGFloat r, CGFloat g, CGFloat b, CGFloat a)
{
	return [NSColor colorWithCalibratedRed:(r) green:(g) blue:(b) alpha:(a)];
}
NSColor *makeColor255(CGFloat r, CGFloat g, CGFloat b, CGFloat a)
{
	return [NSColor colorWithCalibratedRed:(r) / 255.0 green:(g) / 255.0 blue:(b) / 255.0 alpha:(a) / 255.0];
}
#else
UIColor *makeColor(CGFloat r, CGFloat g, CGFloat b, CGFloat a)
{
	return [UIColor colorWithRed:(r) green:(g) blue:(b) alpha:(a)];
}
UIColor *makeColor255(CGFloat r, CGFloat g, CGFloat b, CGFloat a)
{
	return [UIColor colorWithRed:(r) / (CGFloat)255.0 green:(g) / (CGFloat)255.0 blue:(b) / (CGFloat)255.0 alpha:(a) / (CGFloat)255.0];
}
#endif

__inline__ CGFloat generateRandomFloatBetween(CGFloat a, CGFloat b)
{
	return a + (b - a) * (random() / (CGFloat) RAND_MAX);
}

__inline__ int generateRandomIntBetween(int a, int b)
{
	int range = b - a < 0 ? b - a - 1 : b - a + 1;
	long rand = random();
	int value = (int)(range * ((CGFloat)rand  / (CGFloat) RAND_MAX));
	return value == range ? a : a + value;
}


// logging support


#undef asl_log
#undef os_log
#if __has_feature(modules) && ((defined(__MAC_OS_X_VERSION_MAX_ALLOWED) && __MAC_OS_X_VERSION_MAX_ALLOWED >= 101200) || (defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= 100000)))
@import asl;
@import os.log;
#else
#include <asl.h>
#include <os/log.h>
#endif



static NSFileHandle *logfileHandle;
void cc_log_enablecapturetofile(NSURL *fileURL, unsigned long long filesizeLimit) // ASL broken on 10.12+ and especially logging to file not working anymore
{
    assert(!logfileHandle);

    if (!fileURL.fileExists)
        [NSData.data writeToURL:fileURL atomically:YES]; // create file with weird API
    else if (filesizeLimit) // truncate first
    {
        NSString *path = fileURL.path;

        unsigned long long filesize = [[[fileManager attributesOfItemAtPath:path error:NULL] objectForKey:@"NSFileSize"] unsignedLongLongValue];

        if (filesize > filesizeLimit)
        {
            NSFileHandle *fh = [NSFileHandle fileHandleForUpdatingURL:fileURL error:nil];

            [fh seekToFileOffset:(filesize - filesizeLimit)];

            NSData *data = [fh readDataToEndOfFile];

            [fh seekToFileOffset:0];
            [fh writeData:data];
            [fh truncateFileAtOffset:filesizeLimit];
            [fh synchronizeFile];
            [fh closeFile];
        }
    }

    // now open for appending
    logfileHandle = [NSFileHandle fileHandleForUpdatingURL:fileURL error:nil];

    if (!logfileHandle)
    {
        cc_log_error(@"could not open file %@ for log file usage", fileURL.path);
    }
#if  !__has_feature(objc_arc)
    [logfileHandle retain];
#endif
}

void _cc_log_tologfile(int level, NSString *string)
{
    if (logfileHandle)
    {
        static const char* levelNames[8] = {ASL_STRING_EMERG, ASL_STRING_ALERT, ASL_STRING_CRIT, ASL_STRING_ERR, ASL_STRING_WARNING, ASL_STRING_NOTICE, ASL_STRING_INFO, ASL_STRING_DEBUG};
        assert(level < 8);
        NSString *levelStr = @(levelNames[level]);
        NSString *dayString = [NSDate.date stringUsingFormat:@"MMM dd"];
        NSString *timeString = [NSDate.date stringUsingDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
        NSString *finalString = makeString(@"%@ %@  %@[%i] <%@>: %@\n",
                                           dayString,
                                           timeString,
                                           cc.appName,
                                           NSProcessInfo.processInfo.processIdentifier,
                                           levelStr,
                                           string);

        [logfileHandle seekToEndOfFile];

        NSData *data = [finalString dataUsingEncoding:NSUTF8StringEncoding];

        if (data)
            [logfileHandle writeData:data];
        else
            cc_log_error(@"could not open create data from string %@ for log", finalString);
    }
}

void _cc_log_toprefs(int level, NSString *string)
{
#ifndef DONTLOGTOUSERDEFAULTS
    static int lastPosition[8] = {0,0,0,0,0,0,0,0};
    assert(level < 8);
    NSString *key = makeString(@"corelib_asl_lev%i_pos%i", level, lastPosition[level]);
    key.defaultString = makeString(@"date: %@ message: %@", NSDate.date.description, string);
    lastPosition[level]++;
    if (lastPosition[level] > 9)
        lastPosition[level] = 0;
#endif
}


void cc_log_level(int level, NSString *format, ...)
{
    assert(level >= 0);
    assert(level < 8);
	va_list args;
	va_start(args, format);
	NSString *str = [[NSString alloc] initWithFormat:format arguments:args];
	va_end(args);

    _cc_log_tologfile(level, str);
    _cc_log_toprefs(level, str);

#if defined(TARGET_OS_MAC) && TARGET_OS_MAC && !TARGET_OS_IPHONE
    if (OS_IS_POST_10_11)
#else
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_9_x_Max)
#endif
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#pragma clang diagnostic ignored "-Wpartial-availability"
        const char *utf = str.UTF8String;

        if (level == ASL_LEVEL_DEBUG || level == ASL_LEVEL_INFO)
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_DEBUG, "%{public}s", utf);
        else if (level == ASL_LEVEL_NOTICE || level == ASL_LEVEL_WARNING)
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_DEFAULT, "%{public}s", utf);
        else if (level == ASL_LEVEL_ERR)
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "%{public}s", utf);
        else if (level == ASL_LEVEL_CRIT || level == ASL_LEVEL_ALERT || level == ASL_LEVEL_EMERG)
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_FAULT, "%{public}s", utf);
    }
    else
        asl_log(NULL, NULL, level, "%s", str.UTF8String);
#pragma clang diagnostic pop

#if ! __has_feature(objc_arc)
	[str release];
#endif
}

void log_to_prefs(NSString *str)
{
    static int lastPosition = 0;

    NSString *key = makeString(@"corelib_logtoprefs_pos%i", lastPosition);

    key.defaultString = makeString(@"date: %@ message: %@", NSDate.date.description, str);

    lastPosition++;

    if (lastPosition > 42)
        lastPosition = 0;
}

// gcd convenience
void dispatch_after_main(float seconds, dispatch_block_t block)
{
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), block);
}

void dispatch_after_back(float seconds, dispatch_block_t block)
{
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_global_queue(0, 0), block);
}

void dispatch_async_main(dispatch_block_t block)
{
	dispatch_async(dispatch_get_main_queue(), block);
}

void dispatch_async_back(dispatch_block_t block)
{
	dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
	dispatch_async(queue, block);
}

void dispatch_sync_main(dispatch_block_t block)
{
	if ([NSThread currentThread] == [NSThread mainThread])
		block();	// using with dispatch_sync would deadlock when on the main thread
	else
		dispatch_sync(dispatch_get_main_queue(), block);
}

void dispatch_sync_back(dispatch_block_t block)
{
	dispatch_sync(dispatch_get_global_queue(0, 0), block);
}
#if ((defined(MAC_OS_X_VERSION_MIN_REQUIRED) && MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_10) || (defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED >= 80000))
BOOL dispatch_sync_back_timeout(dispatch_block_t block, float timeoutSeconds) // returns 0 on succ
{
    dispatch_block_t newblock = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, block);
    dispatch_async(dispatch_get_global_queue(0, 0), newblock);
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeoutSeconds * NSEC_PER_SEC));
    return dispatch_block_wait(newblock, popTime) != 0;
}
#endif

static dispatch_semaphore_t ccAsyncToSyncSema;
static id ccAsyncToSyncResult;

void dispatch_async_to_sync_resulthandler(id res)
{
    assert(ccAsyncToSyncSema);
    assert(!ccAsyncToSyncResult);
    ccAsyncToSyncResult = res;
    dispatch_semaphore_signal(ccAsyncToSyncSema);
}

id dispatch_async_to_sync(BasicBlock block)
{
    assert(!ccAsyncToSyncResult);
    assert(!ccAsyncToSyncSema);
    ccAsyncToSyncSema = dispatch_semaphore_create(0);
    block();
    dispatch_semaphore_wait(ccAsyncToSyncSema, DISPATCH_TIME_FOREVER);
    assert(ccAsyncToSyncResult);
    ccAsyncToSyncSema = NULL;
    id copy = ccAsyncToSyncResult;
    ccAsyncToSyncResult = nil;
    return copy;
}

// private
#if __has_feature(modules)
@import Darwin.POSIX.sys.types;
@import Darwin.sys.sysctl;
@import Darwin.POSIX.pwd;
@import Darwin.POSIX.grp;
#else
#include <sys/types.h>
#include <sys/sysctl.h>
#include <pwd.h>
#include <grp.h>
#endif
NSString *_machineType()
{
	char modelBuffer[256];
	size_t sz = sizeof(modelBuffer);
	if (0 == sysctlbyname("hw.model", modelBuffer, &sz, NULL, 0))
	{
		modelBuffer[sizeof(modelBuffer) - 1] = 0;
		return @(modelBuffer);
	}
	else
	{
		return @"";
	}
}


#if __has_feature(modules)
#ifdef USE_SECURITY
#include <CommonCrypto/CommonDigest.h>
#endif
@import ObjectiveC.runtime;
#else
#ifdef USE_SECURITY
#include <CommonCrypto/CommonDigest.h>
#endif
#import <objc/runtime.h>
#endif


#ifdef USE_SNAPPY
#import <snappy/snappy-c.h>
#endif

#if __has_feature(modules)
@import Darwin.POSIX.sys.stat;
#else
#include <sys/stat.h>
#endif


CONST_KEY(CoreCodeAssociatedValue)



@implementation NSArray (CoreCode)

@dynamic mutableObject, empty, set, reverseArray, string, path, sorted, XMLData, flattenedArray, literalString;

#if (MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_7)
@dynamic orderedSet;
#endif

- (NSString *)literalString
{
    NSMutableString *tmp = [NSMutableString stringWithString:@"@["];

    for (id obj in self)
        [tmp appendFormat:@"%@, ", [obj literalString]];

    [tmp replaceCharactersInRange:NSMakeRange(tmp.length-2, 2)                // replace trailing ', '
                       withString:@"]"];                        // with terminating ']'

    return tmp;
}

- (NSArray *)sorted
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wselector"
    return [self sortedArrayUsingSelector:@selector(compare:)];
#pragma clang diagnostic pop
}


- (NSData *)XMLData
{
    NSError *err;
    NSData *data =  [NSPropertyListSerialization dataWithPropertyList:self
                                                               format:NSPropertyListXMLFormat_v1_0
                                                              options:(NSPropertyListWriteOptions)0
                                                                error:&err];

    if (!data || err)
    {
        cc_log_error(@"Error: XML write fails! input %@ data %@ err %@", self, data, err);
        return nil;
    }

    return data;
}

#

+ (void)_addArrayContents:(NSArray *)array toArray:(NSMutableArray *)newArray
{
    for (id object in array)
    {
        if ([object isKindOfClass:[NSArray class]])
            [NSArray _addArrayContents:object toArray:newArray];
        else
            [newArray addObject:object];
    }
}

- (NSArray *)flattenedArray
{
    NSMutableArray *tmp = [NSMutableArray array];

    [NSArray _addArrayContents:self toArray:tmp];

    return tmp.immutableObject;
}

- (NSString *)string
{
    NSString *ret = @"";

    for (NSString *str in self)
        ret = [ret stringByAppendingString:str];

    return ret;
}

- (NSString *)path
{
    NSString *ret = @"";

    for (NSString *str in self)
        ret = [ret stringByAppendingPathComponent:str];

    return ret;
}

- (BOOL)contains:(id)object
{
    return [self indexOfObject:object] != NSNotFound;
}

- (NSArray *)reverseArray
{
    return [[self reverseObjectEnumerator] allObjects];
}

#if (MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_7)
- (NSOrderedSet *)orderedSet
{
    return [NSOrderedSet orderedSetWithArray:self];
}
#endif

- (NSSet *)set
{
    return [NSSet setWithArray:self];
}

- (NSArray *)arrayByAddingNewObject:(id)anObject
{
    if ([self indexOfObject:anObject] == NSNotFound)
        return [self arrayByAddingObject:anObject];
    else
        return self;
}

- (NSArray *)arrayByRemovingObjectIdenticalTo:(id)anObject
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self];

    [array removeObjectIdenticalTo:anObject];

    return [NSArray arrayWithArray:array];
}

- (NSArray *)arrayByRemovingObjectsIdenticalTo:(NSArray *)objects
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self];

    for (id obj in objects)
        [array removeObjectIdenticalTo:obj];

    return [NSArray arrayWithArray:array];
}

- (NSArray *)arrayByRemovingObjectsAtIndexes:(NSIndexSet *)indexSet
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self];

    [array removeObjectsAtIndexes:indexSet];

    return [NSArray arrayWithArray:array];
}

- (NSArray *)arrayByRemovingObjectAtIndex:(NSUInteger)index
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self];

    [array removeObjectAtIndex:index];

    return [NSArray arrayWithArray:array];
}

- (NSArray *)arrayByReplacingObject:(id)anObject withObject:(id)newObject
{
    NSMutableArray *mut = self.mutableObject;

    mut[[mut indexOfObject:anObject]] = newObject;

    return mut.immutableObject;
}

- (id)safeObjectAtIndex:(NSUInteger)index
{
    if ([self count] > index)
        return self[index];
    else
        return nil;
}

- (BOOL)containsDictionaryWithKey:(NSString *)key equalTo:(NSString *)value
{
    for (NSDictionary *dict in self)
        if ([[dict valueForKey:key] isEqual:value])
            return TRUE;

    return FALSE;
}

- (NSArray *)sortedArrayByKey:(NSString *)key
{
    return [self sortedArrayByKey:key ascending:YES];
}

- (NSArray *)sortedArrayByKey:(NSString *)key ascending:(BOOL)ascending
{
    NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:key ascending:ascending];
#if ! __has_feature(objc_arc)
    [sd autorelease];
#endif
    return [self sortedArrayUsingDescriptors:@[sd]];
}

- (NSArray *)subarrayFromIndex:(NSUInteger)location
{
    return [self subarrayWithRange:NSMakeRange(location, self.count-location)];
}

- (NSArray *)subarrayToIndex:(NSUInteger)location
{
    return [self subarrayWithRange:NSMakeRange(0, self.count-location-1)];
}

- (NSMutableArray *)mutableObject
{
    return [NSMutableArray arrayWithArray:self];
}

- (BOOL)empty
{
    return [self count] == 0;
}

- (NSArray *)mapped:(ObjectInOutBlock)block
{
    NSMutableArray *resultArray = [NSMutableArray new];

    for (id object in self)
    {
        id result = block(object);
        if (result)
            [resultArray addObject:result];
    }
#if ! __has_feature(objc_arc)
    [resultArray autorelease];
#endif

    return [NSArray arrayWithArray:resultArray];
}

- (NSInteger)reduce:(ObjectInIntOutBlock)block
{
    NSInteger value = 0;

    for (id object in self)
        value += block(object);

    return value;
}

- (NSArray *)filtered:(BOOL (^)(id input))block
{
    NSMutableArray *resultArray = [NSMutableArray new];

    for (id object in self)
        if (block(object))
            [resultArray addObject:object];

#if ! __has_feature(objc_arc)
    [resultArray autorelease];
#endif

    return [NSArray arrayWithArray:resultArray];
}

- (void)apply:(ObjectInBlock)block                                // enumerateObjectsUsingBlock:
{
    for (id object in self)
        block(object);
}

// forwards for less typing
- (NSString *)joined:(NSString *)sep                            // componentsJoinedByString:
{
    return [self componentsJoinedByString:sep];
}

- (NSArray *)filteredUsingPredicateString:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    NSPredicate *pred = [NSPredicate predicateWithFormat:format arguments:args];
    va_end(args);

    return [self filteredArrayUsingPredicate:pred];
}


#if defined(TARGET_OS_MAC) && TARGET_OS_MAC && !TARGET_OS_IPHONE
- (NSString *)runAsTask
{
    return [self runAsTaskWithTerminationStatus:NULL];
}

- (NSString *)runAsTaskWithTerminationStatus:(NSInteger *)terminationStatus
{
    NSTask *task = [NSTask new];
    NSPipe *taskPipe = [NSPipe pipe];
    NSFileHandle *file = [taskPipe fileHandleForReading];

    [task setLaunchPath:self[0]];
    [task setStandardOutput:taskPipe];
    [task setStandardError:taskPipe];
    [task setArguments:[self subarrayWithRange:NSMakeRange(1, self.count-1)]];

    if ([task.arguments reduce:^int(NSString *input) { return (int)input.length; }] > 200000)
        cc_log_error(@"Error: task argument size approaching or above limit, spawn will fail");

    @try
    {
        [task launch];
    }
    @catch (NSException *)
    {
        return nil;
    }

    NSData *data = [file readDataToEndOfFile];

    [task waitUntilExit];

    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];


    if (terminationStatus)
        (*terminationStatus) = [task terminationStatus];

#if ! __has_feature(objc_arc)
    [task release];
    [string autorelease];
#endif

    return string;
}
#endif
@end


@implementation  NSMutableArray (CoreCode)

@dynamic immutableObject;

- (void)moveObjectAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    id object = self[fromIndex];
    [self removeObjectAtIndex:fromIndex];

    if (toIndex < self.count)
        [self insertObject:object atIndex:toIndex];
    else
        [self addObject:object];
}

- (void)removeObjectPassingTest:(ObjectInIntOutBlock)block
{
    NSUInteger idx = [self indexOfObjectPassingTest:^BOOL(id obj, NSUInteger i, BOOL *s)
                      {
                          int res = block(obj);
                          return (BOOL)res;
                      }];

    if (idx != NSNotFound)
        [self removeObjectAtIndex:idx];
}

- (NSArray *)immutableObject
{
    return [NSArray arrayWithArray:self];
}

- (void)addNewObject:(id)anObject
{
    if (anObject && [self indexOfObject:anObject] == NSNotFound)
        [self addObject:anObject];
}

- (void)addObjectSafely:(id)anObject
{
    if (anObject)
        [self addObject:anObject];
}

- (void)map:(ObjectInOutBlock)block
{
    for (NSUInteger i = 0; i < [self count]; i++)
    {
        id result = block(self[i]);

        self[i] = result;
    }
}

- (void)filter:(ObjectInIntOutBlock)block
{
    NSMutableIndexSet *indices = [NSMutableIndexSet new];

    for (NSUInteger i = 0; i < [self count]; i++)
    {
        int result = block(self[i]);
        if (!result)
            [indices addIndex:i];
    }


    [self removeObjectsAtIndexes:indices];

#if ! __has_feature(objc_arc)
    [indices release];
#endif
}

- (void)filterUsingPredicateString:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    NSPredicate *pred = [NSPredicate predicateWithFormat:format arguments:args];
    va_end(args);

    [self filterUsingPredicate:pred];
}

- (void)removeFirstObject
{
    [self removeObjectAtIndex:0];
}
@end



@implementation NSString (CoreCode)

@dynamic words, lines, trimmedOfWhitespace, trimmedOfWhitespaceAndNewlines, URL, fileURL, download, resourceURL, resourcePath, localized, defaultObject, defaultString, defaultInt, defaultFloat, defaultURL, dirContents, dirContentsRecursive, dirContentsAbsolute, dirContentsRecursiveAbsolute, fileExists, uniqueFile, expanded, defaultArray, defaultDict, isWriteablePath, fileSize, directorySize, contents, dataFromHexString, unescaped, escaped, namedImage,  isIntegerNumber, isIntegerNumberOnly, data, firstCharacter, lastCharacter, fullRange, stringByResolvingSymlinksInPathFixed, literalString, rot13;

#if defined(TARGET_OS_MAC) && TARGET_OS_MAC && !TARGET_OS_IPHONE
@dynamic fileIsAlias, fileAliasTarget, fileIsRestricted;
#endif

#ifdef USE_SECURITY
@dynamic SHA1;
#endif

- (NSString *)rot13
{
    const char *cstring = [self cStringUsingEncoding:NSASCIIStringEncoding];

    if (!cstring) return nil;

    char *newcstring = malloc(self.length+1);


    NSUInteger x;
    for(x = 0; x < self.length; x++)
    {
        unsigned int aCharacter = (unsigned int)cstring[x];

        if( 0x40 < aCharacter && aCharacter < 0x5B ) // A - Z
            newcstring[x] = (((aCharacter - 0x41) + 0x0D) % 0x1A) + 0x41;
        else if ( 0x60 < aCharacter && aCharacter < 0x7B ) // a-z
            newcstring[x] = (((aCharacter - 0x61) + 0x0D) % 0x1A) + 0x61;
        else  // Not an alpha character
            newcstring[x] = (char)aCharacter;
    }

    newcstring[x] = '\0';

    NSString *rotString = [NSString stringWithCString:newcstring encoding:NSASCIIStringEncoding];
    free(newcstring);
    return rotString;
}

#if defined(TARGET_OS_MAC) && TARGET_OS_MAC && !TARGET_OS_IPHONE
- (NSImage *)namedImage
{
    NSImage *image = [NSImage imageNamed:self];

    if (!image)
        cc_log_error(@"Error: there is no named image with name: %@", self);

    return image;
}
#else
- (UIImage *)namedImage
{
    UIImage *image = [UIImage imageNamed:self];

    if (!image)
        cc_log_error(@"Error: there is no named image with name: %@", self);

    return image;
}
#endif

#if defined(TARGET_OS_MAC) && TARGET_OS_MAC && !TARGET_OS_IPHONE

- (BOOL)fileIsRestricted
{
    struct stat info;
    lstat(self.UTF8String, &info);
    return (info.st_flags & SF_RESTRICTED) > 0;
}

- (BOOL)fileIsAlias
{
    NSURL *url = [NSURL fileURLWithPath:self];
    CFURLRef cfurl = (BRIDGE CFURLRef) url;
    CFBooleanRef aliasBool = kCFBooleanFalse;
    Boolean success = CFURLCopyResourcePropertyForKey(cfurl, kCFURLIsAliasFileKey, &aliasBool, NULL);
    Boolean alias = CFBooleanGetValue(aliasBool);

    return alias && success;
}

- (NSString *)stringByResolvingSymlinksInPathFixed
{
    NSString *ret = [self stringByResolvingSymlinksInPath];


    for (NSString *exception in @[@"/etc/", @"/tmp/", @"/var/"])
    {
        if ([ret hasPrefix:exception])
        {
            NSString *fixed = [@"/private" stringByAppendingPathComponent:ret];

            return fixed;
        }
    }

    return ret;
}



- (NSString *)fileAliasTarget
{
    CFErrorRef *err = NULL;
    CFDataRef bookmark = CFURLCreateBookmarkDataFromFile(NULL, (BRIDGE CFURLRef)self.fileURL, err);
    if (bookmark == nil)
        return nil;
    CFURLRef url = CFURLCreateByResolvingBookmarkData (NULL, bookmark, kCFBookmarkResolutionWithoutUIMask, NULL, NULL, NULL, err);
    __autoreleasing NSURL *nurl = [(BRIDGE NSURL *)url copy];
    CFRelease(bookmark);
    CFRelease(url);
#if  !__has_feature(objc_arc)
    [nurl autorelease];
#endif
    return [nurl path];

}

- (CGSize)sizeUsingFont:(NSFont *)font maxWidth:(CGFloat)maxWidth
{
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:self];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(maxWidth, DBL_MAX)];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    [textStorage beginEditing];
    [textStorage setAttributes:@{NSFontAttributeName: font} range:NSMakeRange(0, [self length])];
    [textStorage endEditing];

    (void) [layoutManager glyphRangeForTextContainer:textContainer];

    NSRect r = [layoutManager usedRectForTextContainer:textContainer];

#if  !__has_feature(objc_arc)
    [textStorage release];
    [layoutManager release];
    [textContainer release];
#endif
    return r.size;
}
#endif

- (NSString *)literalString
{
    return makeString(@"@\"%@\"", self);
}

- (NSRange)fullRange
{
    return NSMakeRange(0, self.length);
}

- (unichar)firstCharacter
{
    if (self.length)
        return [self characterAtIndex:0];
    return 0;
}

- (unichar)lastCharacter
{
    NSUInteger len = self.length;
    if (len)
        return [self characterAtIndex:len-1];
    return 0;
}


- (unsigned long long)fileSize
{
    NSDictionary *attr = [fileManager attributesOfItemAtPath:self error:NULL];
    if (!attr) return 0;
    return [attr[NSFileSize] unsignedLongLongValue];
}

- (unsigned long long)directorySize
{
    unsigned long long size = 0;
    for (NSString *file in self.dirContentsRecursiveAbsolute)
    {
        NSDictionary *attr = [fileManager attributesOfItemAtPath:file error:NULL];
        if (attr && !([attr[NSFileType] isEqualToString:NSFileTypeDirectory]))
            size += [attr[NSFileSize] unsignedLongLongValue];
    }
    return size;
}

- (BOOL)isIntegerNumber
{
    return [self rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location != NSNotFound;
}


- (BOOL)isIntegerNumberOnly
{
    return [self rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet].invertedSet].location == NSNotFound;
}

- (BOOL)isWriteablePath
{
    if (self.fileExists)
        return NO;

    if (![@"TEST" writeToFile:self atomically:YES encoding:NSUTF8StringEncoding error:NULL])
        return NO;

    [fileManager removeItemAtPath:self error:NULL];

    return YES;
}

- (BOOL)isValidEmails
{
    for (NSString *line in self.lines)
        if (!line.isValidEmail)
            return NO;

    return YES;
}

- (BOOL)isValidEmail
{
    if (self.length > 254)
        return NO;


    NSArray <NSString *> *portions = [self split:@"@"];

    if (portions.count != 2)
        return FALSE;

    NSString *local = portions[0];
    NSString *domain = portions[1];

    if (![domain contains:@"."])
        return FALSE;

    static NSCharacterSet *localValid = nil, *domainValid = nil;

    if (!localValid)
    {
        localValid = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!#$%&'*+-/=?^_`{|}~."];
        domainValid = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-."];

#if  !__has_feature(objc_arc)
        [localValid retain];
        [domainValid retain];
#endif
    }

    if ([local rangeOfCharacterFromSet:localValid.invertedSet options:(NSStringCompareOptions)0].location != NSNotFound)
        return NO;

    if ([domain rangeOfCharacterFromSet:domainValid.invertedSet options:(NSStringCompareOptions)0].location != NSNotFound)
        return NO;

    return YES;
}

- (NSArray <NSString *> *)dirContents
{
    return [fileManager contentsOfDirectoryAtPath:self error:NULL];
}

- (NSArray <NSString *> *)dirContentsRecursive
{
    return [fileManager subpathsOfDirectoryAtPath:self error:NULL];
}

- (NSArray <NSString *> *)dirContentsAbsolute
{
    NSArray <NSString *> *c = self.dirContents;
    return [c mapped:^NSString *(NSString *input) { return [self stringByAppendingPathComponent:input]; }];
}

- (NSArray <NSString *> *)dirContentsRecursiveAbsolute
{
    NSArray <NSString *> *c = self.dirContentsRecursive;
    return [c mapped:^NSString *(NSString *input) { return [self stringByAppendingPathComponent:input]; }];
}


- (NSString *)uniqueFile
{
    assert(fileManager);
    if (![fileManager fileExistsAtPath:self])
        return self;
    else
    {
        NSString *ext = self.pathExtension;
        NSString *namewithoutext = self.stringByDeletingPathExtension;
        int i = 0;

        while ([fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@-%i.%@", namewithoutext, i,ext]])
            i++;

        return [NSString stringWithFormat:@"%@-%i.%@", namewithoutext, i,ext];
    }
}

- (void)setContents:(NSData *)data
{
    NSError *err;

    if (![data writeToFile:self options:NSDataWritingAtomic error:&err])
        LOG(err);
}

- (NSData *)contents
{
#if  __has_feature(objc_arc)
    return [[NSData alloc] initWithContentsOfFile:self];
#else
    return [[[NSData alloc] initWithContentsOfFile:self] autorelease];
#endif
}

- (BOOL)fileExists
{
    assert(fileManager);
    return [fileManager fileExistsAtPath:self];
}

- (NSUInteger)countOccurencesOfString:(NSString *)str
{
    return [[self componentsSeparatedByString:str] count] - 1;
}

- (BOOL)contains:(NSString *)otherString
{
    return ([self rangeOfString:otherString].location != NSNotFound);
}

- (BOOL)contains:(NSString *)otherString insensitive:(BOOL)insensitive
{
    return ([self rangeOfString:otherString options:insensitive ? NSCaseInsensitiveSearch : 0].location != NSNotFound);
}

- (BOOL)containsAny:(NSArray <NSString *>*)otherStrings
{
    for (NSString *otherString in otherStrings)
        if ([self rangeOfString:otherString].location != NSNotFound)
            return YES;

    return NO;
}


- (BOOL)containsAll:(NSArray <NSString *>*)otherStrings
{
    for (NSString *otherString in otherStrings)
        if ([self rangeOfString:otherString].location == NSNotFound)
            return NO;

    return YES;
}

- (BOOL)equalsAny:(NSArray <NSString *>*)otherStrings
{
    for (NSString *otherString in otherStrings)
        if ([self isEqualToString:otherString])
            return YES;

    return NO;
}

- (NSString *)localized
{
    return NSLocalizedString(self, nil);
}

- (NSString *)resourcePath
{
    return [bundle pathForResource:self ofType:nil];
}

- (NSURL *)resourceURL
{
    return [bundle URLForResource:self withExtension:nil];
}

- (NSURL *)URL
{
    return [NSURL URLWithString:self];
}

- (NSURL *)fileURL
{
    return [NSURL fileURLWithPath:self];
}

- (NSString *)expanded
{
    return [self stringByExpandingTildeInPath];
}

- (NSArray <NSString *> *)words
{
    return [self componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSArray <NSString *> *)lines
{
    return [self componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
}


- (NSAttributedString *)hyperlinkWithURL:(NSURL *)url
{
    NSString *urlstring = url.absoluteString;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self];

    [attributedString beginEditing];
    [attributedString addAttribute:NSLinkAttributeName value:urlstring range:self.fullRange];
    [attributedString addAttribute:NSForegroundColorAttributeName value:makeColor(0, 0, 1, 1) range:self.fullRange];
    [attributedString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:self.fullRange];
    [attributedString endEditing];

#if ! __has_feature(objc_arc)
    [attributedString autorelease];
#endif
    return attributedString;
}

- (NSString *)trimmedOfWhitespace
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString *)trimmedOfWhitespaceAndNewlines
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)clamp:(NSUInteger)maximumLength
{
    return (([self length] <= maximumLength) ? self : [self substringToIndex:maximumLength]);
}


- (NSString *)stringByReplacingMultipleStrings:(NSDictionary <NSString *, NSString *>*)replacements
{
    NSString *ret = self;
    assert(![self contains:@"k9BBV15zFYi44YyB"]);

    for (NSString *key in replacements)
    {
        if ([[NSNull null] isEqual:key] || [[NSNull null] isEqual:replacements[key]])
            continue;
        ret = [ret stringByReplacingOccurrencesOfString:key
                                             withString:[key stringByAppendingString:@"k9BBV15zFYi44YyB"]];
    }

    BOOL replaced;
    do
    {
        replaced = FALSE;

        for (NSString *key in replacements)
        {
            id value = replacements[key];

            if ([[NSNull null] isEqual:key] || [[NSNull null] isEqual:value])
                continue;
            NSString *tmp = [ret stringByReplacingOccurrencesOfString:[key stringByAppendingString:@"k9BBV15zFYi44YyB"]
                                                           withString:value];

            if (![tmp isEqualToString:ret])
            {
                ret = tmp;
                replaced = YES;
            }
        }
    } while (replaced);

    return ret;
}

- (NSString *)capitalizedStringWithUppercaseWords:(NSArray <NSString *> *)uppercaseWords
{
    NSString *res = self.capitalizedString;

    for (NSString *word in uppercaseWords)
    {
        res = [res stringByReplacingOccurrencesOfString:makeString(@"(\\W)%@(\\W)", word.capitalizedString)
                                             withString:makeString(@"$1%@$2", word.uppercaseString)
                                                options:NSRegularExpressionSearch range: res.fullRange];
    }
    for (NSString *word in uppercaseWords)
    {
        res = [res stringByReplacingOccurrencesOfString:makeString(@"(\\W)%@(\\Z)", word.capitalizedString)
                                             withString:makeString(@"$1%@", word.uppercaseString)
                                                options:NSRegularExpressionSearch range:res.fullRange];
    }

    return res;
}

- (NSString *)titlecaseStringWithLowercaseWords:(NSArray <NSString *> *)lowercaseWords andUppercaseWords:(NSArray <NSString *> *)uppercaseWords
{
    NSString *res = [self capitalizedStringWithUppercaseWords:uppercaseWords];

    for (NSString *word in lowercaseWords)
    {
        res = [res stringByReplacingOccurrencesOfString:makeString(@"([^:,;,-]\\s)%@(\\s)", word.capitalizedString)
                                             withString:makeString(@"$1%@$2", word.lowercaseString)
                                                options:NSRegularExpressionSearch range: res.fullRange];

    }

    //    for (NSString *word in lowercaseWords)
    //    {
    //        res = [res stringByReplacingOccurrencesOfString:makeString(@"(\\s)%@(\\Z)", word.capitalizedString)
    //                                             withString:makeString(@"$1%@", word.lowercaseString)
    //                                                options:NSRegularExpressionSearch range: res.fullRange];
    //
    //    }

    return res;
}

- (NSString *)titlecaseString
{
    NSArray *words = @[@"a", @"an", @"the", @"and", @"but", @"for", @"nor", @"or", @"so", @"yet", @"at", @"by", @"for", @"in", @"of", @"off", @"on", @"out", @"to", @"up", @"via", @"to", @"c", @"ca", @"etc", @"e.g.", @"i.e.", @"vs.", @"vs", @"v", @"down", @"from", @"into", @"like", @"near", @"onto", @"over", @"than", @"with", @"upon"];

    return [self titlecaseStringWithLowercaseWords:words.id andUppercaseWords:nil];
}

- (NSString *)propercaseString
{
    if ([self length] == 0)
        return @"";
    else if ([self length] == 1)
        return [self uppercaseString];

    return makeString(@"%@%@",
                      [[self substringToIndex:1] uppercaseString],
                      [[self substringFromIndex:1] lowercaseString]);
}

- (NSData *)download
{
#ifdef DEBUG
    if ([NSThread currentThread] == [NSThread mainThread])
        LOG(@"Warning: performing blocking download on main thread");
#endif
    NSData *d = [[NSData alloc] initWithContentsOfURL:self.URL];
#if ! __has_feature(objc_arc)
    [d autorelease];
#endif
    return d;
}


#ifdef USE_SECURITY
- (NSString *)SHA1
{
    const char *cStr = self.UTF8String;
    if (!cStr) return nil;

    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(cStr, (CC_LONG)strlen(cStr), result);
    NSString *s = [NSString  stringWithFormat:
                   @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   result[0], result[1], result[2], result[3], result[4],
                   result[5], result[6], result[7],
                   result[8], result[9], result[10], result[11], result[12],
                   result[13], result[14], result[15],
                   result[16], result[17], result[18], result[19]
                   ];

    return s;
}
#endif

- (NSMutableString *)mutableObject
{
    return [NSMutableString stringWithString:self];
}

- (NSString *)language
{
    CFStringRef resultLanguage;

    resultLanguage = CFStringTokenizerCopyBestStringLanguage((CFStringRef)self, CFRangeMake(0, self.length > 500 ? 500 : (long)self.length));

    return CFBridgingRelease(resultLanguage);


    //   NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes:@[NSLinguisticTagSchemeLanguage] options:0];
    //   tagger.string = self;
    //
    //   NSString *resultLanguage = [tagger tagAtIndex:0 scheme:NSLinguisticTagSchemeLanguage tokenRange:NULL sentenceRange:NULL];
    //   return resultLanguage;




    //    __block NSString *resultLanguage;
    //    dispatch_queue_t queue;
    //    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    //    NSSpellChecker *spellChecker = NSSpellChecker.sharedSpellChecker;
    //    spellChecker.automaticallyIdentifiesLanguages = YES;
    //    [spellChecker requestCheckingOfString:self
    //                                    range:(NSRange){0, self}
    //                                    types:NSTextCheckingTypeOrthography
    //                                  options:nil
    //                   inSpellDocumentWithTag:0
    //                        completionHandler:^(NSInteger sequenceNumber, NSArray *results, NSOrthography *orthography, NSInteger wordCount)
    //     {
    //         resultLanguage = orthography.dominantLanguage;
    //         dispatch_semaphore_signal(sema);
    //     }];
    //
    //
    //    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    //    sema = NULL;
    //
    //    return resultLanguage;
}

- (NSString *)removed:(NSString *)stringToRemove
{
    return [self stringByReplacingOccurrencesOfString:stringToRemove withString:@""];
}

- (NSString *)replaced:(NSString *)str1 with:(NSString *)str2    // stringByReplacingOccurencesOfString:withString:
{
    return [self stringByReplacingOccurrencesOfString:str1 withString:str2];
}

- (NSArray <NSString *> *)split:(NSString *)sep                                // componentsSeparatedByString:
{
    return [self componentsSeparatedByString:sep];
}

- (NSArray *)defaultArray
{
    return [[NSUserDefaults standardUserDefaults] arrayForKey:self];
}

- (void)setDefaultArray:(NSArray *)newDefault
{
    [[NSUserDefaults standardUserDefaults] setObject:newDefault forKey:self];
}

- (NSDictionary *)defaultDict
{
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:self];
}

- (void)setDefaultDict:(NSDictionary *)newDefault
{
    [[NSUserDefaults standardUserDefaults] setObject:newDefault forKey:self];
}

- (id)defaultObject
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:self];
}

- (void)setDefaultObject:(id)newDefault
{
    [[NSUserDefaults standardUserDefaults] setObject:newDefault forKey:self];
}

- (NSString *)defaultString
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:self];
}

- (void)setDefaultString:(NSString *)newDefault
{
    [[NSUserDefaults standardUserDefaults] setObject:newDefault forKey:self];
}

- (NSURL *)defaultURL
{
    return [[NSUserDefaults standardUserDefaults] URLForKey:self];
}

- (void)setDefaultURL:(NSURL *)newDefault
{
    [[NSUserDefaults standardUserDefaults] setURL:newDefault forKey:self];
}

- (NSInteger)defaultInt
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:self];
}

- (void)setDefaultInt:(NSInteger)newDefault
{
    [[NSUserDefaults standardUserDefaults] setInteger:newDefault forKey:self];
}

- (float)defaultFloat
{
    return [[NSUserDefaults standardUserDefaults] floatForKey:self];
}

- (void)setDefaultFloat:(float)newDefault
{
    [[NSUserDefaults standardUserDefaults] setFloat:newDefault forKey:self];
}

- (NSString *)stringValue
{
    return self;
}

//- (NSNumber *)numberValue
//{
//    return @(self.doubleValue);
//}

- (NSArray <NSArray <NSString *> *> *)parsedDSVWithDelimiter:(NSString *)delimiter
{    // credits to Drew McCormack
    NSMutableArray *rows = [NSMutableArray array];

    NSMutableCharacterSet *whitespaceCharacterSet = [NSMutableCharacterSet whitespaceCharacterSet];
    NSMutableCharacterSet *newlineCharacterSetMutable = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
    [newlineCharacterSetMutable formIntersectionWithCharacterSet:[whitespaceCharacterSet invertedSet]];
    [whitespaceCharacterSet removeCharactersInString:delimiter];
    NSCharacterSet *newlineCharacterSet = [NSCharacterSet characterSetWithBitmapRepresentation:[newlineCharacterSetMutable bitmapRepresentation]];
    NSMutableCharacterSet *importantCharactersSetMutable = [NSMutableCharacterSet characterSetWithCharactersInString:[delimiter stringByAppendingString:@"\""]];
    [importantCharactersSetMutable formUnionWithCharacterSet:newlineCharacterSet];
    NSCharacterSet *importantCharactersSet = [NSCharacterSet characterSetWithBitmapRepresentation:[importantCharactersSetMutable bitmapRepresentation]];

    NSScanner *scanner = [NSScanner scannerWithString:self];
    [scanner setCharactersToBeSkipped:nil];

    while (![scanner isAtEnd])
    {
        BOOL insideQuotes = NO;
        BOOL finishedRow = NO;
        NSMutableArray *columns = [NSMutableArray arrayWithCapacity:30];
        NSMutableString *currentColumn = [NSMutableString string];

        while (!finishedRow)
        {
            NSString *tempString;
            if ([scanner scanUpToCharactersFromSet:importantCharactersSet intoString:&tempString])
            {
                [currentColumn appendString:tempString];
            }

            if ([scanner isAtEnd])
            {
                if (![currentColumn isEqualToString:@""])
                    [columns addObject:currentColumn];

                finishedRow = YES;
            }
            else if ([scanner scanCharactersFromSet:newlineCharacterSet intoString:&tempString])
            {
                if (insideQuotes)
                {
                    [currentColumn appendString:tempString];
                }
                else
                {
                    if (![currentColumn isEqualToString:@""])
                        [columns addObject:currentColumn];
                    finishedRow = YES;
                }
            }
            else if ([scanner scanString:@"\"" intoString:NULL])
            {
                if (insideQuotes && [scanner scanString:@"\"" intoString:NULL])
                {
                    [currentColumn appendString:@"\""];
                }
                else
                {
                    insideQuotes = !insideQuotes;
                }
            }
            else if ([scanner scanString:delimiter intoString:NULL])
            {
                if (insideQuotes)
                {
                    [currentColumn appendString:delimiter];
                }
                else
                {
                    [columns addObject:currentColumn];
                    currentColumn = [NSMutableString string];
                    [scanner scanCharactersFromSet:whitespaceCharacterSet intoString:NULL];
                }
            }
        }
        if ([columns count] > 0)
            [rows addObject:columns];
    }

    return rows;
}

- (NSData *)data
{
    return [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
}

- (NSData *)dataFromHexString
{
    const char *bytes = [self cStringUsingEncoding:NSUTF8StringEncoding];
    if (!bytes) return nil;
    NSUInteger length = strlen(bytes);
    unsigned char *r = (unsigned char *)malloc(length / 2 + 1);
    unsigned char *index = r;

    while ((*bytes) && (*(bytes +1)))
    {
        char encoder[3] = {'\0','\0','\0'};
        encoder[0] = *bytes;
        encoder[1] = *(bytes+1);
        *index = (unsigned char)strtol(encoder, NULL, 16);
        index++;
        bytes+=2;
    }
    *index = '\0';

    NSData *result = [NSData dataWithBytes:r length:length / 2];
    free(r);
    return result;
}

- (NSString *)unescaped
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#pragma clang diagnostic ignored "-Wpartial-availability"
#if defined(TARGET_OS_MAC) && TARGET_OS_MAC && !TARGET_OS_IPHONE
    if (OS_IS_POST_10_8)
#else
        if (1)
#endif
            return [self stringByRemovingPercentEncoding];
#if defined(TARGET_OS_MAC) && TARGET_OS_MAC && !TARGET_OS_IPHONE
        else
        {
#if  __has_feature(objc_arc)
            NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapes(NULL, (CFStringRef)self, CFSTR("")));
            return encodedString;
#else
            NSString *encodedString = (NSString *)CFURLCreateStringByReplacingPercentEscapes(NULL, (CFStringRef)self, CFSTR(""));
            return [encodedString autorelease];
#endif
        }
#endif
#pragma clang diagnostic pop
}

- (NSString *)escaped
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#pragma clang diagnostic ignored "-Wpartial-availability"
#if defined(TARGET_OS_MAC) && TARGET_OS_MAC && !TARGET_OS_IPHONE
    if (OS_IS_POST_10_8)
#else
        if (1)
#endif
            return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
#if defined(TARGET_OS_MAC) && TARGET_OS_MAC && !TARGET_OS_IPHONE
        else
        {

#if  __has_feature(objc_arc)
            NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, NULL, kCFStringEncodingUTF8));
            return encodedString;
#else
            NSString *encodedString = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, NULL, kCFStringEncodingUTF8);
            return [encodedString autorelease];
#endif
        }
#endif
#pragma clang diagnostic pop
}

//- (NSString *)encoded
//{
//#if  __has_feature(objc_arc)
//    #warning depre
//    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
//    return encodedString;
//#else
//    NSString *encodedString = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
//    return [encodedString autorelease];
//#endif
//}

- (NSString *)stringByTrimmingLeadingCharactersInSet:(NSCharacterSet *)characterSet
{
    NSRange rangeOfFirstWantedCharacter = [self rangeOfCharacterFromSet:[characterSet invertedSet]];
    if (rangeOfFirstWantedCharacter.location == NSNotFound)
        return @"";

    return [self substringFromIndex:rangeOfFirstWantedCharacter.location];
}

- (NSString *)stringByTrimmingTrailingCharactersInSet:(NSCharacterSet *)characterSet
{
    NSRange rangeOfLastWantedCharacter = [self rangeOfCharacterFromSet:[characterSet invertedSet]
                                                               options:NSBackwardsSearch];
    if (rangeOfLastWantedCharacter.location == NSNotFound)
        return @"";

    return [self substringToIndex:rangeOfLastWantedCharacter.location+1];
}

#if defined(TARGET_OS_MAC) && TARGET_OS_MAC && !TARGET_OS_IPHONE
void directoryObservingReleaseCallback(const void *info)
{
    CFBridgingRelease(info);
}

void directoryObservingEventCallback(ConstFSEventStreamRef streamRef, void *clientCallBackInfo, size_t numEvents, void *eventPaths, const FSEventStreamEventFlags eventFlags[], const FSEventStreamEventId eventIds[])
{
    //    NSMutableArray <NSDictionary *> *tmp = makeMutableArray();
    //    char **paths = eventPaths;
    //    for (NSUInteger i = 0; i < numEvents; i++)
    //    {
    //        char *eventPath = paths[i];
    //
    //        [tmp addObject:@{@"path" : @(eventPath),
    //                         @"flags" : @(eventFlags[i])}];
    //
    //    }
    //
    //    void (^block)(id input) = (__bridge void (^)())(clientCallBackInfo);
    //    block(tmp);

    void (^block)(void) = (__bridge void (^)(void))(clientCallBackInfo);
    block();
}

CONST_KEY(CCDirectoryObserving)
- (void)startObserving:(BasicBlock)block
{
#if ! __has_feature(objc_arc)
    void *ptr = (void *)[block retain];
#else
    void *ptr = (__bridge_retained void *)block;
#endif
    FSEventStreamContext context = {0, ptr, NULL, directoryObservingReleaseCallback, NULL};
    CFStringRef mypath = (BRIDGE CFStringRef)self.stringByExpandingTildeInPath;
    CFArrayRef pathsToWatch = CFArrayCreate(NULL, (const void **)&mypath, 1, NULL);
    FSEventStreamRef stream;
    CFAbsoluteTime latency = 2.0;


    assert(self.fileURL.fileIsDirectory);
    stream = FSEventStreamCreate(NULL, &directoryObservingEventCallback, &context, pathsToWatch, kFSEventStreamEventIdSinceNow, latency, 0);

    CFRelease(pathsToWatch);
    FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);

    FSEventStreamStart(stream);

    [self setAssociatedValue:[NSValue valueWithPointer:stream] forKey:kCCDirectoryObservingKey];
}

- (void)stopObserving
{
    NSValue *v = [self associatedValueForKey:kCCDirectoryObservingKey];
    if (v)
    {
        FSEventStreamRef stream = v.pointerValue;

        FSEventStreamStop(stream);
        FSEventStreamInvalidate(stream);
        FSEventStreamRelease(stream);
    }
    else
        cc_log_debug(@"Warning: stopped observing on location which was never observed %@", self);
}
#endif

//- (NSString *)arg:(id)arg, ...
//{
//    va_list args;
//    void *stackLocal = (__bridge void *)(arg);
//    struct __va_list_tag *stackLocal2 = stackLocal;
//    va_start(args, arg);
//
//    NSString *result = [[NSString alloc] initWithFormat:self arguments:stackLocal2];
//    va_end(args);
//
//#if ! __has_feature(objc_arc)
//    [d result];
//#endif
//    return result;
//}

@end


@implementation NSTask (CoreCode)

- (BOOL)waitUntilExitWithTimeout:(NSTimeInterval)timeout
{
    NSDate *killDate = [NSDate dateWithTimeIntervalSinceNow:timeout];
    BOOL killed = NO;
    
    while ([self isRunning])
    {
        if ([[NSDate date] laterDate:killDate] != killDate)
        {
            [self terminate];
            killed = YES;
        }
        [NSThread sleepForTimeInterval:0.1];
    }
    
    return killed;
}

@end



@implementation  NSMutableString (CoreCode)

@dynamic immutableObject;

- (NSString *)immutableObject
{
    return [NSString stringWithString:self];
}
@end



@implementation NSURL (CoreCode)

@dynamic dirContents, dirContentsRecursive, fileExists, uniqueFile, request, mutableRequest, fileSize, directorySize, isWriteablePath, download, contents, fileIsDirectory, fileOrDirectorySize; // , path
#if defined(TARGET_OS_MAC) && TARGET_OS_MAC && !TARGET_OS_IPHONE
@dynamic fileIsAlias, fileAliasTarget, fileIsRestricted;

- (BOOL)fileIsRestricted
{
    struct stat info;
    lstat(self.path.UTF8String, &info);
    return (info.st_flags & SF_RESTRICTED) > 0;
}

- (BOOL)fileIsAlias
{
    CFURLRef cfurl = (BRIDGE CFURLRef) self;
    CFBooleanRef aliasBool = kCFBooleanFalse;
    Boolean success = CFURLCopyResourcePropertyForKey(cfurl, kCFURLIsAliasFileKey, &aliasBool, NULL);
    Boolean alias = CFBooleanGetValue(aliasBool);

    return alias && success;
}

- (BOOL)fileIsDirectory
{
    NSNumber *value;
    [self getResourceValue:&value forKey:NSURLIsDirectoryKey error:NULL];
    return value.boolValue;
}

- (NSURL *)fileAliasTarget
{
    CFErrorRef *err = NULL;
    CFDataRef bookmark = CFURLCreateBookmarkDataFromFile(NULL, (BRIDGE CFURLRef)self, err);
    if (bookmark == nil)
        return nil;
    CFURLRef url = CFURLCreateByResolvingBookmarkData (NULL, bookmark, kCFBookmarkResolutionWithoutUIMask, NULL, NULL, NULL, err);
    __autoreleasing NSURL *nurl = [(BRIDGE NSURL *)url copy];
    CFRelease(bookmark);
    CFRelease(url);
#if  __has_feature(objc_arc)
    return nurl;
#else
    return [nurl autorelease];
#endif
}
#endif

- (NSURLRequest *)request
{
    return [NSURLRequest requestWithURL:self];
}

- (NSMutableURLRequest *)mutableRequest
{
    return [NSMutableURLRequest requestWithURL:self];
}

- (NSURL *)add:(NSString *)component
{
    return [self URLByAppendingPathComponent:component];
}

- (NSArray <NSURL *> *)dirContents
{
    if (![self isFileURL]) return nil;

    NSString *path = self.path;
    NSError *err;
    NSArray *c = [fileManager contentsOfDirectoryAtPath:path error:&err];

    return [c mapped:^id (NSString *input) { return [self URLByAppendingPathComponent:input]; }];
}

- (NSArray <NSURL *> *)dirContentsRecursive
{
    if (![self isFileURL]) return nil;

    NSString *path = self.path;
    NSError *err;
    NSArray *c = [fileManager subpathsOfDirectoryAtPath:path error:&err];
    if (!c || err)
    {
        if (!self.fileExists)
        {
            cc_log_debug(@"Warning: trying to get contents of non-existant dir %@", self);

            return nil;
        }
        else
            assert(0);
    }
    return [c mapped:^id (NSString *input) { return [self URLByAppendingPathComponent:input]; }];
}

- (NSURL *)uniqueFile
{
    if (![self isFileURL]) return nil;
    return [self path].uniqueFile.fileURL;
}

- (BOOL)fileExists
{
    NSString *path = self.path;
    return [self isFileURL] && [fileManager fileExistsAtPath:path];
}


- (unsigned long long)fileOrDirectorySize
{
    return (self.fileIsDirectory ? self.directorySize : self.fileSize);
}


- (unsigned long long)fileSize
{
    NSNumber *size;

    if ([self getResourceValue:&size forKey:NSURLFileSizeKey error:nil])
        return [size unsignedLongLongValue];
    else
        return 0;
}

- (unsigned long long)directorySize
{
    unsigned long long size = 0;
    for (NSURL *file in self.dirContentsRecursive)
    {
        NSString *filePath = file.path;
        NSDictionary *attr = [fileManager attributesOfItemAtPath:filePath error:NULL];
        if (attr && !([attr[NSFileType] isEqualToString:NSFileTypeDirectory]))
            size += [attr[NSFileSize] unsignedLongLongValue];
    }
    return size;
}

- (void)open
{
#if defined(TARGET_OS_MAC) && TARGET_OS_MAC && !TARGET_OS_IPHONE
    [[NSWorkspace sharedWorkspace] openURL:self];
#else
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#pragma clang diagnostic ignored "-Wpartial-availability"
    if ([[UIDevice currentDevice] systemVersion].floatValue >= 10.0f)
        [[UIApplication sharedApplication] openURL:self options:@{} completionHandler:NULL];
    else
        [[UIApplication sharedApplication] openURL:self];
#pragma clang diagnostic pop
#endif
}

- (BOOL)isWriteablePath
{
    if (self.fileExists)
        return NO;

    if (![@"TEST" writeToURL:self atomically:YES encoding:NSUTF8StringEncoding error:NULL])
        return NO;

    [fileManager removeItemAtURL:self error:NULL];

    return YES;
}


- (NSData *)download
{
#ifdef DEBUG
    if ([NSThread currentThread] == [NSThread mainThread] && !self.isFileURL)
        LOG(@"Warning: performing blocking download on main thread");
#endif

    NSData *d = [NSData dataWithContentsOfURL:self];

    return d;
}

- (void)setContents:(NSData *)data
{
    NSError *err;

    if (![data writeToURL:self options:NSDataWritingAtomic error:&err])
        LOG(err);
}

- (NSData *)contents
{
    return self.download;
}

#if (MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_9)
+ (NSURL *)URLWithHost:(NSString *)host path:(NSString *)path query:(NSString *)query
{
    return [NSURL URLWithHost:host path:path query:query user:nil password:nil fragment:nil scheme:@"https" port:nil];
}

+ (NSURL *)URLWithHost:(NSString *)host path:(NSString *)path query:(NSString *)query user:(NSString *)user password:(NSString *)password fragment:(NSString *)fragment scheme:(NSString *)scheme port:(NSNumber *)port
{
    assert([path hasPrefix:@"/"]);
    assert(![query contains:@"k9BBV15zFYi44YyB"]);
    query = [query replaced:@"+" with:@"k9BBV15zFYi44YyB"];
    NSURLComponents *urlComponents = [NSURLComponents new];
    urlComponents.scheme = scheme;
    urlComponents.host = host;
    urlComponents.path = path;
    urlComponents.query = query;
    urlComponents.user = user;
    urlComponents.password = password;
    urlComponents.fragment = fragment;
    urlComponents.port = port;
    urlComponents.percentEncodedQuery = [urlComponents.percentEncodedQuery replaced:@"k9BBV15zFYi44YyB" with:@"%2B"];

    NSURL *url = urlComponents.URL;

#if ! __has_feature(objc_arc)
    [urlComponents release];
#endif

    assert(url);


    return url;
}

- (NSData *)performBlockingPOST
{
    __block NSData *data;
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);

    [self performPOST:^(NSData *d)
     {
         data = d;
         dispatch_semaphore_signal(sem);
     }];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);

    return data;
}

- (NSData *)performBlockingGET
{
    __block NSData *data;
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);

    [self performGET:^(NSData *d)
     {
         data = d;
         dispatch_semaphore_signal(sem);
     }];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);

    return data;
}

- (void)performGET:(void (^)(NSData *data))completion
{
    NSURLSessionDataTask *dataTask = [NSURLSession.sharedSession dataTaskWithURL:self completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
                                      {
                                          completion(data);
                                      }];
    [dataTask resume];
}

- (void)performPOST:(void (^)(NSData *data))completion
{
    NSURL *newURL = [NSURL URLWithHost:self.host path:self.path query:nil user:self.user
                              password:self.password fragment:self.fragment scheme:self.scheme port:self.port]; // don't want the query in there
    NSMutableURLRequest *request = newURL.request.mutableCopy;

    request.HTTPBody = self.query.data;
    request.HTTPMethod = @"POST";
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

    NSURLSessionDataTask *dataTask = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
                                      {
                                          completion(data);
                                      }];
    [dataTask resume];
}
#endif
@end



@implementation NSData (CoreCode)

@dynamic string, hexString, mutableObject;
#ifdef USE_SECURITY
@dynamic SHA1, MD5, SHA256;
#endif


#ifdef USE_SECURITY
- (NSString *)SHA1
{
    const char *cStr = [self bytes];
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(cStr, (CC_LONG)[self length], result);
    NSString *s = [NSString  stringWithFormat:
                   @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   result[0], result[1], result[2], result[3], result[4],
                   result[5], result[6], result[7],
                   result[8], result[9], result[10], result[11], result[12],
                   result[13], result[14], result[15],
                   result[16], result[17], result[18], result[19]
                   ];

    return s;
}

- (NSString *)MD5
{
    const char *cStr = [self bytes];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)[self length], result);
    NSString *s = [NSString  stringWithFormat:
                   @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   result[0], result[1], result[2], result[3], result[4],
                   result[5], result[6], result[7],
                   result[8], result[9], result[10], result[11], result[12],
                   result[13], result[14], result[15]
                   ];

    return s;
}

- (NSString *)SHA256
{
    const char *cStr = [self bytes];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(cStr, (CC_LONG)[self length], result);
    NSString *s = [NSString  stringWithFormat:
                   @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   result[0], result[1], result[2], result[3], result[4],
                   result[5], result[6], result[7],
                   result[8], result[9], result[10], result[11], result[12],
                   result[13], result[14], result[15],
                   result[16], result[17], result[18], result[19],
                   result[20], result[21], result[22], result[23],
                   result[24], result[25], result[26], result[27],
                   result[28], result[29], result[30], result[31]
                   ];

    return s;
}
#endif

#ifdef USE_SNAPPY
@dynamic snappyCompressed, snappyDecompressed;

- (NSData *)snappyDecompressed
{
    size_t uncompressedSize = 0;

    if( snappy_uncompressed_length(self.bytes, self.length, &uncompressedSize) != SNAPPY_OK )
    {
        cc_log_error(@"Error: can't calculate the uncompressed length!\n");
        return nil;
    }

    assert(uncompressedSize);

    char *buf = (char *)malloc(uncompressedSize);
    assert(buf);


    int res = snappy_uncompress(self.bytes, self.length, buf, &uncompressedSize);
    if(res != SNAPPY_OK)
    {
        cc_log_error(@"Error: can't uncompress the file!\n");
        free(buf);
        return nil;
    }


    NSData *d = [NSData dataWithBytesNoCopy:buf length:uncompressedSize];
#if ! __has_feature(objc_arc)
    [d autorelease];
#endif
    return d;
}

- (NSData *)snappyCompressed
{
    size_t output_length = snappy_max_compressed_length(self.length);
    char *buf = (char*)malloc(output_length);
    assert(buf);

    int res = snappy_compress(self.bytes, self.length, buf, &output_length);
    if (res != SNAPPY_OK )
    {
        cc_log_error(@"Error: problem compressing the file\n");
        free(buf);
        return nil;
    }

    NSData *d = [NSData dataWithBytesNoCopy:buf length:output_length];
#if ! __has_feature(objc_arc)
    [d autorelease];
#endif
    return d;
}
#endif

- (NSString *)string
{
#if defined(TARGET_OS_MAC) && TARGET_OS_MAC && !TARGET_OS_IPHONE
    if (OS_IS_POST_10_9)
#else
        if ([[UIDevice currentDevice] systemVersion].floatValue >= 8.0f)
#endif
        {
            NSString *result;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#pragma clang diagnostic ignored "-Wpartial-availability"

            [NSString stringEncodingForData:self
                            encodingOptions:nil
                            convertedString:&result
                        usedLossyConversion:nil];
#pragma clang diagnostic pop

            if (result)
                return result;
        }

    for (NSNumber *num in @[@(NSUTF8StringEncoding), @(NSISOLatin1StringEncoding), @(NSASCIIStringEncoding), @(NSUTF16StringEncoding)])
    {
        NSString *s = [[NSString alloc] initWithData:self encoding:num.unsignedIntegerValue];

        if (!s)
            continue;
#if ! __has_feature(objc_arc)
        [s autorelease];
#endif
        return s;
    }

    cc_log_error(@"Error: could not create string from data %@", self);
    return nil;
}

- (NSString *)hexString
{
    const unsigned char *dataBuffer = (const unsigned char *)[self bytes];

    if (!dataBuffer)
        return [NSString string];

    NSUInteger          dataLength  = [self length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];

    for (NSUInteger i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];

    return [NSString stringWithString:hexString];
}

- (NSMutableData *)mutableObject
{
    return [NSMutableData dataWithData:self];
}

@end



@implementation NSDate (CoreCode)

+ (NSDate *)dateWithString:(NSString *)dateString format:(NSString *)dateFormat localeIdentifier:(NSString *)localeIdentifier
{
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:dateFormat];
    NSLocale *l = [[NSLocale alloc] initWithLocaleIdentifier:localeIdentifier];
    [df setLocale:l];
#if ! __has_feature(objc_arc)
    [l release];
    [df autorelease];
#endif
    return [df dateFromString:dateString];
}

+ (NSDate *)dateWithString:(NSString *)dateString format:(NSString *)dateFormat
{
    return [self dateWithString:dateString format:dateFormat localeIdentifier:@"en_US"];
}

+ (NSDate *)dateWithPreprocessorDate:(const char *)preprocessorDateString
{
    return [self dateWithString:@(preprocessorDateString) format:@"MMM d yyyy"];
}

- (NSString *)stringUsingFormat:(NSString *)dateFormat
{
    NSDateFormatter *df = [NSDateFormatter new];
    NSLocale *l = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [df setLocale:l];
    [df setDateFormat:dateFormat];
#if ! __has_feature(objc_arc)
    [l release];
    [df autorelease];
#endif
    return [df stringFromDate:self];
}

- (NSString *)stringUsingDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle
{
    NSDateFormatter *df = [NSDateFormatter new];

    [df setLocale:[NSLocale currentLocale]];
    [df setDateStyle:dateStyle];
    [df setTimeStyle:timeStyle];
#if ! __has_feature(objc_arc)
    [df autorelease];
#endif
    return [df stringFromDate:self];
}

@end


@implementation NSDateFormatter (CoreCode)

+ (NSString *)formattedTimeFromTimeInterval:(NSTimeInterval)timeInterval
{
    int minutes = (int)(timeInterval / 60);
    int seconds = (int)(timeInterval - (minutes * 60));


    if (minutes)
        return makeString(@"%im %is", minutes, seconds);
    else
        return makeString(@"%is", (int)timeInterval);
}

@end



@implementation NSDictionary (CoreCode)

@dynamic mutableObject, XMLData, literalString;

- (NSString *)literalString
{
    NSMutableString *tmp = [NSMutableString stringWithString:@"@{"];

    for (id key in self)
        [tmp appendFormat:@"%@ : %@, ", [key literalString], [self[key] literalString]];

    [tmp replaceCharactersInRange:NSMakeRange(tmp.length-2, 2)                // replace trailing ', '
                       withString:@"}"];                                    // with terminating '}'

    return tmp;
}


- (NSData *)XMLData
{
    NSError *err;
    NSData *data =  [NSPropertyListSerialization dataWithPropertyList:self
                                                               format:NSPropertyListXMLFormat_v1_0
                                                              options:(NSPropertyListWriteOptions)0
                                                                error:&err];

    if (!data || err)
    {
        cc_log_error(@"Error: XML write fails! input %@ data %@ err %@", self, data, err);
        return nil;
    }

    return data;
}

- (NSMutableDictionary *)mutableObject
{
    return [NSMutableDictionary dictionaryWithDictionary:self];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wselector"
    return [super methodSignatureForSelector:@selector(valueForKey:)];
#pragma clang diagnostic pop
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    NSString *propertyName = NSStringFromSelector(invocation.selector);
    [invocation setSelector:@selector(valueForKey:)];
    [invocation setArgument:&propertyName atIndex:2];
    [invocation invokeWithTarget:self];
}

- (NSDictionary *)dictionaryByAddingValue:(id)value forKey:(id)key
{
    NSMutableDictionary *mutable = self.mutableObject;

    mutable[key] = value;

    return mutable.immutableObject;
}

- (NSDictionary *)dictionaryByRemovingKey:(id)key
{
    NSMutableDictionary *mutable = self.mutableObject;

    [mutable removeObjectForKey:key];

    return mutable.immutableObject;
}

- (NSDictionary *)dictionaryByRemovingKeys:(NSArray <NSString *>*)keys
{
    NSMutableDictionary *mutable = self.mutableObject;

    for (NSString *key in keys)
        [mutable removeObjectForKey:key];

    return mutable.immutableObject;
}

@end


@implementation NSMutableDictionary (CoreCode)

@dynamic immutableObject;

- (NSDictionary *)immutableObject
{
    return [NSDictionary dictionaryWithDictionary:self];
}
@end




@implementation NSObject (CoreCode)

@dynamic associatedValue, id;


- (void)setAssociatedValue:(id)value forKey:(const NSString *)key
{
#if    TARGET_OS_IPHONE
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-objc-pointer-introspection"
    BOOL is64Bit = sizeof(void *) == 8;
    BOOL isTagged = ((uintptr_t)self & 0x1);
    assert(!(is64Bit && isTagged)); // associated values on tagged pointers broken on 64 bit iOS
#pragma clang diagnostic pop
#endif

    objc_setAssociatedObject(self, (BRIDGE const void *)(key), value, OBJC_ASSOCIATION_RETAIN);
}

- (id)associatedValueForKey:(const NSString *)key
{
    id value = objc_getAssociatedObject(self, (BRIDGE const void *)(key));

    return value;
}

- (void)setAssociatedValue:(id)value
{
    [self setAssociatedValue:value forKey:kCoreCodeAssociatedValueKey];
}

- (id)associatedValue
{
    return [self associatedValueForKey:kCoreCodeAssociatedValueKey];
}

+ (instancetype)newWith:(NSDictionary *)dict
{
    NSObject *obj = [self new];
    for (NSString *key in dict)
    {
        [obj setValue:dict[key] forKey:key];
    }

    return obj;
}

- (id)id
{
    return (id)self;
}
@end



@implementation NSTextField (NSTextField_AutoFontsize)

- (void)adjustFontSize
{
    double width = self.frame.size.width;
    NSFont *curr = self.font;
    int currentFontSize = (int)curr.pointSize;
    NSSize strSize;
    do
    {
        NSFont *font = [NSFont fontWithName:curr.fontName size:currentFontSize];
        NSDictionary *attrs = @{NSFontAttributeName : font};
        strSize = [self.stringValue sizeWithAttributes:attrs];

        currentFontSize --;

    } while (strSize.width > width);


    [self setFont:[NSFont fontWithName:curr.fontName size:currentFontSize+1]];
}
@end


static int bundleFileDescriptor;



void MoveCallbackFunction(ConstFSEventStreamRef streamRef,
                          void *clientCallBackInfo,
                          size_t numEvents,
                          void *eventPaths,
                          const FSEventStreamEventFlags eventFlags[],
                          const FSEventStreamEventId eventIds[])
{
    //char **paths = eventPaths;


    for (size_t i = 0; i < numEvents; i++)
    {
        if ( eventFlags[i] == kFSEventStreamEventFlagRootChanged)
        {
            //   printf("Change %llu in %s, flags %lu\n", eventIds[i], paths[i], eventFlags[i]);

            char *newPath = calloc(4096, sizeof(char));

            fcntl(bundleFileDescriptor, F_GETPATH, newPath);




            alert_apptitled([NSString stringWithFormat:NSLocalizedString(@"%@ has been moved, but applications should never be moved while they are running.", nil), cc.appName], [NSString stringWithFormat:NSLocalizedString(@"Restart %@", nil), cc.appName], nil, nil);


            //    printf("new path: %s\n", newPath);

            NSURL * url = @(newPath).fileURL;


            NSRunningApplication *newInstance = [workspace launchApplicationAtURL:url
                                                                          options:(NSWorkspaceLaunchOptions)(NSWorkspaceLaunchAsync | NSWorkspaceLaunchNewInstance)
                                                                    configuration:@{} error:NULL];

            free(newPath);

            if (newInstance)
                [NSApp terminate:nil];
            else
            {
                alert_apptitled([NSString stringWithFormat:NSLocalizedString(@"%@ could not restart itself. Please do so yourself.", nil), cc.appName], NSLocalizedString(@"Quit", nil), nil, nil);

                [NSApp terminate:nil];
            }
        }
    }
}

@implementation JMAppMovedHandler

+ (void)startMoveObservation
{
    CFStringRef mypath = (BRIDGE CFStringRef)[[NSBundle mainBundle] bundlePath];
    CFArrayRef pathsToWatch = CFArrayCreate(NULL, (const void **)&mypath, 1, NULL);
    void *callbackInfo = NULL;
    FSEventStreamRef stream;
    CFAbsoluteTime latency = 3.0;


    bundleFileDescriptor = open([[[NSBundle mainBundle] bundlePath] UTF8String], O_RDONLY, 0700);
    stream = FSEventStreamCreate(NULL,
                                 &MoveCallbackFunction,
                                 callbackInfo,
                                 pathsToWatch,
                                 kFSEventStreamEventIdSinceNow,
                                 latency,
                                 kFSEventStreamCreateFlagWatchRoot
                                 );
    CFRelease(pathsToWatch);
    FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);

    FSEventStreamStart(stream);
}
@end



@interface JMCorrectTimer ()

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) id target;
@property (strong, nonatomic) NSDate *date;
@property (copy, nonatomic) void (^timerBlock)(void);
@property (copy, nonatomic) void (^dropBlock)(void);

@end


@implementation JMCorrectTimer

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithFireDate:(NSDate *)d timerBlock:(void (^)(void))timerBlock dropBlock:(void (^)(void))dropBlock
{
    LOGFUNC;
    if ((self = [super init]))
    {
        self.timerBlock = timerBlock;
        self.dropBlock = dropBlock;
        self.date = d;

        [self scheduleTimer];

        [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                               selector:@selector(receiveSleepNote:)
                                                                   name:NSWorkspaceWillSleepNotification object:NULL];
        [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                               selector:@selector(receiveWakeNote:)
                                                                   name:NSWorkspaceDidWakeNotification object:NULL];
    }
    return self;
}

- (void)scheduleTimer
{
    LOGFUNCPARAM(makeString(@"timerDate: %@   now: %@", self.date, NSDate.date.description));

    NSTimer *t = [[NSTimer alloc] initWithFireDate:self.date
                                          interval:0
                                            target:self
                                          selector:@selector(timer:)
                                          userInfo:NULL repeats:NO];

    [[NSRunLoop currentRunLoop] addTimer:t forMode:NSDefaultRunLoopMode];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#pragma clang diagnostic ignored "-Wpartial-availability"
    if ([t respondsToSelector:@selector(setTolerance:)])
        t.tolerance = 0.1;
#pragma clang diagnostic pop

    self.timer = t;

#if ! __has_feature(objc_arc)
    [t release];
#endif
}

- (void)invalidate
{
    LOGFUNC;

    if (self.timer)
        [self.timer invalidate];
    self.timer = nil;
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
}

- (void)timer:(id)sender
{
    LOGFUNCPARAM(makeString(@"timerDate: %@   now: %@", self.timer.fireDate.description, NSDate.date.description));

#if ! __has_feature(objc_arc)
    [self retain];
#else
    __strong JMCorrectTimer *strongSelf = self;
#endif

    self.timerBlock();


    [self invalidate];
    self.timerBlock = nil;
    self.dropBlock = nil;

#if ! __has_feature(objc_arc)
    [self release];
#else
    strongSelf = nil;
#endif
}

- (void)receiveSleepNote:(id)sender
{
    LOGFUNC;

    if (self.timer)
    {
        [self.timer invalidate];
        self.timer = nil;
    }
    else
        cc_log_error(@"JMCorrectTimer: receiveSleepNote but no timer");
}

- (void)receiveWakeNote:(id)sender
{
    if (self.timer)
    {
        cc_log_error(@"JMCorrectTimer: receiveWakeNote but timer");
        [self.timer invalidate];
        self.timer = nil;
    }


    if ([[NSDate date] timeIntervalSinceDate:self.date] > 0.01)
    {
        LOGFUNCPARAM(makeString(@"dropping Timer as we have been sleeping, missed target by: %f", -[[NSDate date] timeIntervalSinceDate:self.date]));

        if (self.dropBlock)
        {
#if ! __has_feature(objc_arc)
            [self retain];
#else
            __strong JMCorrectTimer *strongSelf = self;
#endif
            self.dropBlock();

            self.timerBlock = nil;
            self.dropBlock = nil;


#if ! __has_feature(objc_arc)
            [self release];
#else
            strongSelf = nil;
#endif
        }
        else
            cc_log_error(@"JMCorrectTimer: error dropBlock was nil");
    }
    else
    {
        LOGFUNCPARAM(makeString(@"rescheduling timer, still time left to reschedule: %f", -[[NSDate date] timeIntervalSinceDate:self.date]));

        [self scheduleTimer];
    }
}

- (void)dealloc
{
    LOGFUNC;

    if (_timer)
    {
        cc_log_error(@"JMCorrectTimer: error dealloced while still in use");
    }


    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];

#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}
@end



@implementation JMDocklessApplication


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

- (void)sendEvent:(NSEvent *)event
{

    if ([event type] == NSEventTypeKeyDown)
    {
        if (([event modifierFlags] & NSEventModifierFlagDeviceIndependentFlagsMask) == NSEventModifierFlagCommand)
        {
            if ([[event charactersIgnoringModifiers] isEqualToString:@"x"])
            {
                if ([self sendAction:@selector(cut:) to:nil from:self])
                    return;
            }
            else if ([[event charactersIgnoringModifiers] isEqualToString:@"c"])
            {
                if ([self sendAction:@selector(copy:) to:nil from:self])
                    return;
            }
            else if ([[event charactersIgnoringModifiers] isEqualToString:@"v"])
            {
                if ([self sendAction:@selector(paste:) to:nil from:self])
                    return;
            }
            else if ([[event charactersIgnoringModifiers] isEqualToString:@"z"])
            {
                if ([self sendAction:@selector(undo:) to:nil from:self])
                    return;
            }
            else if ([[event charactersIgnoringModifiers] isEqualToString:@"a"])
            {
                if ([self sendAction:@selector(selectAll:) to:nil from:self])
                    return;
            }
        }
    }
    if (event.type == NSEventTypeMouseExited)
    {
        NSWindow *w = event.window;
        NSView *v = w.contentView;
     
        if (![[v className] isEqualToString:@"GrowlMistView"])
            [super sendEvent:event];
    }
    else
        [super sendEvent:event];
    
}

#pragma clang diagnostic pop

@end



#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-macros"
#define WIN32 0
#ifdef USE_MAILCORE
#import <MailCore/MailCore.h>
//#import <MailCore/CTCoreAddress.h>
//#import <MailCore/CTCoreMessage.h>
#endif
#ifdef USE_APPLEMAIL
#import "Mail.h"
#endif
#pragma clang diagnostic pop

@implementation JMEmailSender


#ifdef USE_APPLEMAIL
+ (smtpResult)sendMailWithScriptingBridge:(NSString *)content subject:(NSString *)subject to:(NSString *)recipients timeout:(uint16_t)secs attachment:(NSString *)attachmentFilePath
{
    cc_log_debug(@"sendMailWithScriptingBridge %@\n\n sub: %@\n rec: %@", content, subject, recipients);

    BOOL validAddressFound = FALSE;
    NSArray *recipientList = [recipients componentsSeparatedByString:@"\n"];
    NSString *recipient;

    if (recipients == nil)
        return kSMTPToNilFailure;

    @try
    {
        smtpResult res;
        /* create a Scripting Bridge object for talking to the Mail application */
        MailApplication *mail = [SBApplication applicationWithBundleIdentifier:@"com.apple.Mail"];

        [mail setTimeout:secs*60];

#if defined(TARGET_OS_MAC) && TARGET_OS_MAC && !TARGET_OS_IPHONE
#if (__MAC_OS_X_VERSION_MIN_REQUIRED < 1090)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#endif
        if ( [attachmentFilePath length] > 0 && [NSData instancesRespondToSelector:@selector(base64EncodedStringWithOptions:)])
            content = [content stringByAppendingFormat:@"\n\ninline-attachment-base64:\n%@", [attachmentFilePath.fileURL.contents base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0]];
#if (__MAC_OS_X_VERSION_MIN_REQUIRED < 1090)
#pragma clang diagnostic pop
#endif
#endif

        NSDictionary *messageProperties = [NSDictionary dictionaryWithObjectsAndKeys:subject, @"subject", content, @"content", nil];
        MailOutgoingMessage *emailMessage =    [[[mail classForScriptingClass:@"outgoing message"] alloc] initWithProperties:messageProperties];

        /* add the object to the mail app */
        [[mail outgoingMessages] addObject:emailMessage];

        /* set the sender, show the message */
        //emailMessage.visible = YES;

        /* create a new recipient and add it to the recipients list */
        for (recipient in recipientList) // the recipient string can be a newline seperated list of recipients
        {
            if (recipient.isValidEmail)
            {
                cc_log_debug(@"sendMail: messageframework - sending to: %@", recipient);

                validAddressFound = TRUE;
                NSDictionary *recipientProperties = [NSDictionary dictionaryWithObjectsAndKeys:recipient, @"address", nil];
                MailToRecipient *theRecipient =    [[[mail classForScriptingClass:@"to recipient"] alloc] initWithProperties:recipientProperties];
                [emailMessage.toRecipients addObject:theRecipient];
#if ! __has_feature(objc_arc)
                [theRecipient release];
#endif
            }
            else
            {
                cc_log_debug(@"sendMail: %@ is not valid email!", recipient);
            }
        }

        cc_log_debug(@"going to send");
        if (validAddressFound != TRUE)
            return kSMTPToNilFailure;





        if ( [attachmentFilePath length] > 0 && ![NSData instancesRespondToSelector:@selector(base64EncodedStringWithOptions:)])
        {
            MailAttachment *theAttachment;

            if (OS_IS_POST_10_6)
                theAttachment = [[[mail classForScriptingClass:@"attachment"] alloc] initWithProperties:
                                 [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSURL URLWithString:attachmentFilePath], @"fileName",
                                  nil]];
            else
                theAttachment = [[[mail classForScriptingClass:@"attachment"] alloc] initWithProperties:
                                 [NSDictionary dictionaryWithObjectsAndKeys:
                                  [[NSURL URLWithString:attachmentFilePath] path], @"fileName",
                                  nil]];


            [[emailMessage.content attachments] addObject: theAttachment];

#if ! __has_feature(objc_arc)
            [theAttachment release];
#endif
        }
        if ( [mail lastError] != nil )
            return kSMTPScriptingBridgeFailure;

        if ([emailMessage send])
            res = kSMTPSuccess;
        else
            res = kSMTPScriptingBridgeFailure;
        cc_log_debug(@"sent!");
#if ! __has_feature(objc_arc)
        [emailMessage release];
#endif
        return res;
    }
    @catch (NSException *e)
    {
        cc_log_error(@"sendMailWithScriptingBridge, exception %@", [e description]);

        return kSMTPScriptingBridgeFailure;
    }

    return kSMTPScriptingBridgeFailure;  // just to silence the compiler
}
#endif

#ifdef USE_MAILCORE
+ (smtpResult)sendMailWithMailCore:(NSString *)mail subject:(NSString *)subject timeout:(uint16_t)secs server:(NSString *)server port:(uint16_t)port from:(NSString *)sender to:(NSString *)recipients auth:(BOOL)auth tls:(BOOL)tls username:(NSString *)username password:(NSString *)password
{
    cc_log_debug(@"sendMailWithMailCore %@\n\n sub: %@\n sender: %@\nrec: %@", mail, subject, sender, recipients);

    BOOL validAddressFound = FALSE;
    NSArray *recipientList = [recipients componentsSeparatedByString:@"\n"];
    NSMutableSet *set = [NSMutableSet setWithCapacity:[recipientList count]];
    NSString *recipient;

    @try
    {
        struct timeval delay = {  secs, 0 };
        mailstream_network_delay = delay;


        if (recipients == nil)
            return kSMTPToNilFailure;
        if (sender == nil || [sender length] == 0 || !sender.isValidEmail)
            return kSMTPFromNilFailure;

        /* create a new recipient and add it to the recipients list */
        for (recipient in recipientList) // the recipient string can be a newline seperated list of recipients
        {
            if (recipient.isValidEmail)
            {
                cc_log_debug(@"sendMail: mailcore - sending to: %@", recipient);

                validAddressFound = TRUE;
                [set addObject:[CTCoreAddress addressWithName:@"" email:recipient]];
            }
            else
            {
                cc_log_debug(@"sendMail: %@ is not valid email!", recipient);
            }
        }

        if (!validAddressFound)
            return kSMTPToNilFailure;

        CTCoreMessage *msg = [[CTCoreMessage alloc] init];

        [msg setTo:set];
        [msg setFrom:[NSSet setWithObject:[CTCoreAddress addressWithName:@"" email:sender]]];
        [msg setBody:mail];
        [msg setSubject:subject];

        [CTSMTPConnection sendMessage:msg server:server username:username  password:password  port:port useTLS:tls useAuth:auth];

        [msg release];

        return kSMTPSuccess;
    }
    @catch (NSException *e)
    {
        cc_log_error(@"e-mail delivery failed with unknown problem, exception %@", [e description]);

        return kSMTPMailCoreFailure;
    }

    return kSMTPMailCoreFailure; // just to silence the compiler
}
#endif


@end




#if __has_feature(modules)
@import Darwin.sys.sysctl;
@import Darwin.POSIX.sys.socket;
@import Darwin.POSIX.netinet.in;
@import Darwin.POSIX.arpa.inet;
#if defined(MAC_OS_X_VERSION_10_13) && \
defined(__MAC_OS_X_VERSION_MAX_ALLOWED) && \
__MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_13
@import Darwin.POSIX.ifaddrs;
#else
#include <ifaddrs.h>
#endif
@import Darwin.POSIX.net;
@import Darwin.C.stdio;
@import Darwin.POSIX.unistd;
@import Darwin.POSIX.sys.types;
@import Darwin.POSIX.strings;
@import Darwin.sys.param;
@import Darwin.sys.mount;
#ifdef USE_IOKIT
@import IOKit.ps;
@import IOKit.network;
@import IOKit.storage;
@import IOKit.storage.ata;
#endif
#ifdef USE_IOKIT
@import SystemConfiguration;
#endif
#else
#include <sys/sysctl.h>
#include <sys/socket.h>
#include <ifaddrs.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <net/if.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <strings.h>
#include <sys/param.h>
#include <sys/mount.h>
#ifdef USE_IOKIT
#include <IOKit/ps/IOPSKeys.h>
#include <IOKit/ps/IOPowerSources.h>
#include <IOKit/network/IOEthernetInterface.h>
#include <IOKit/network/IONetworkInterface.h>
#include <IOKit/network/IOEthernetController.h>
#include <IOKit/storage/IOMedia.h>
#include <IOKit/storage/ata/IOATAStorageDefines.h>
#include <IOKit/storage/ata/ATASMARTLib.h>
#include <IOKit/storage/IOBlockStorageDevice.h>
#include <IOKit/storage/IOStorageDeviceCharacteristics.h>
#endif
#ifdef USE_IOKIT
#include <SystemConfiguration/SystemConfiguration.h>
#endif
#endif


#ifdef USE_DISKARBITRATION
#ifdef FORCE_LOG
#define LOGMOUNTEDHARDDISK cc_log_debug
#else
#define LOGMOUNTEDHARDDISK(x, ...)
#endif
#endif

#ifdef USE_IOKIT
static kern_return_t FindEthernetInterfaces(io_iterator_t *matchingServices);
static kern_return_t GetMACAddress(io_iterator_t intfIterator, UInt8 *MACAddress);
#endif





@implementation JMHostInformation

#if MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_7
+ (NSString *)bsdPathForVolume:(NSString *)volume
{
    OSStatus            result = noErr;
    ItemCount            volumeIndex;

    // Iterate across all mounted volumes using FSGetVolumeInfo. This will return nsvErr
    // (no such volume) when volumeIndex becomes greater than the number of mounted volumes.
    for (volumeIndex = 1; result == noErr || result != nsvErr; volumeIndex++)
    {
        FSVolumeRefNum    actualVolume;
        HFSUniStr255    volumeName;
        FSVolumeInfo    volumeInfo;

        bzero((void *) &volumeInfo, sizeof(volumeInfo));

        // We're mostly interested in the volume reference number (actualVolume)
        result = FSGetVolumeInfo(kFSInvalidVolumeRefNum,
                                 volumeIndex,
                                 &actualVolume,
                                 kFSVolInfoFSInfo,
                                 &volumeInfo,
                                 &volumeName,
                                 NULL);

        if (result == noErr)
        {
            GetVolParmsInfoBuffer volumeParms;
            result = FSGetVolumeParms (actualVolume, &volumeParms, sizeof(volumeParms));


            if (result != noErr)
                cc_log_error(@"Error:    FSGetVolumeParms returned %d", result);
            else
            {
                if ((char *)volumeParms.vMDeviceID != NULL)
                {
                    // This code is just to convert the volume name from a HFSUniCharStr to
                    // a plain C string so we can print it with printf. It'd be preferable to
                    // use CoreFoundation to work with the volume name in its Unicode form.
                    CFStringRef volNameAsCFString = CFStringCreateWithCharacters(kCFAllocatorDefault, volumeName.unicode, volumeName.length);
                    if (volNameAsCFString)
                    {
                        if ([volume isEqualToString:(BRIDGE NSString *)volNameAsCFString])
                        {
                            CFRelease(volNameAsCFString);
                            return [NSString stringWithFormat:@"/dev/rdisk%@", [[[[NSString stringWithUTF8String:(char *)volumeParms.vMDeviceID] substringFromIndex:4] componentsSeparatedByString:@"s"] objectAtIndex:0]];
                        }
                        else
                            CFRelease(volNameAsCFString);

                    }
                    else
                        cc_log_error(@"Error: volNameAsCFString == NULL, %i", __LINE__);
                }
                else
                    cc_log_error(@"Error: bsdPathForVolume volumeParms.vMDeviceID == NULL, %i", __LINE__);
            }
        }
    }

    return nil;
}

+ (NSString *)volumeNamesForDevice:(NSInteger)deviceNumber
{
    NSMutableString *name = [NSMutableString stringWithCapacity:12];
    OSStatus            result = noErr;
    ItemCount            volumeIndex;


    // Iterate across all mounted volumes using FSGetVolumeInfo. This will return nsvErr
    // (no such volume) when volumeIndex becomes greater than the number of mounted volumes.
    for (volumeIndex = 1; result == noErr || result != nsvErr; volumeIndex++)
    {
        FSVolumeRefNum    actualVolume;
        HFSUniStr255    volumeName;
        FSVolumeInfo    volumeInfo;

        bzero((void *) &volumeInfo, sizeof(volumeInfo));

        // We're mostly interested in the volume reference number (actualVolume)
        result = FSGetVolumeInfo(kFSInvalidVolumeRefNum,
                                 volumeIndex,
                                 &actualVolume,
                                 kFSVolInfoFSInfo,
                                 &volumeInfo,
                                 &volumeName,
                                 NULL);

        if (result == noErr)
        {
            GetVolParmsInfoBuffer volumeParms;

            result = FSGetVolumeParms (actualVolume, &volumeParms, sizeof(volumeParms));

            if (result != noErr)
                cc_log_error(@"Error:    FSGetVolumeParms returned %d", result);
            else
            {
                if ((char *)volumeParms.vMDeviceID != NULL)
                {
                    NSString *bsdName = [NSString stringWithUTF8String:(char *)volumeParms.vMDeviceID];

                    if ([bsdName hasPrefix:@"disk"])
                    {
                        NSString *shortBSDName = [bsdName substringFromIndex:4];

                        NSArray *components = [shortBSDName componentsSeparatedByString:@"s"];

                        if (([components count] > 1) && (!([shortBSDName isEqualToString:[components objectAtIndex:0]])))
                        {
                            if ([[components objectAtIndex:0] integerValue] == deviceNumber)
                            {
                                if (![name isEqualToString:@""])
                                    [name appendString:@", "];

                                [name appendString:[NSString stringWithCharacters:volumeName.unicode length:volumeName.length]];
                            }
                        }
                    }
                }
                else
                    cc_log_error(@"Error: volumeNamesForDevice    volumeParms.vMDeviceID == NULL, %i", __LINE__);
            }
        }
    }

    return [NSString stringWithString:name];
}
#endif

+ (NSURL *)growlInstallURL
{
    NSString *appPath = @"/Applications/Growl.app";
    NSString *userPath = [@"~/Library/PreferencePanes/Growl.prefPane/Contents/Resources/GrowlHelperApp.app" stringByExpandingTildeInPath];
    NSString *systemPath = @"/Library/PreferencePanes/Growl.prefPane/Contents/Resources/GrowlHelperApp.app";
    NSURL *url = nil;

    if ([[NSFileManager defaultManager] fileExistsAtPath:appPath])
        url    = [NSURL fileURLWithPath:appPath];
    else if ([[NSFileManager defaultManager] fileExistsAtPath:userPath])
        url    = [NSURL fileURLWithPath:userPath];
    else if ([[NSFileManager defaultManager] fileExistsAtPath:systemPath])
        url    = [NSURL fileURLWithPath:systemPath];

    return url;
}

#ifdef USE_IOKIT
+ (NSString *)macAddress
{
    NSString *result = @"";
    kern_return_t kernResult = KERN_SUCCESS;

    io_iterator_t intfIterator = 0;
    UInt8 MACAddress[kIOEthernetAddressSize];

    kernResult = FindEthernetInterfaces(&intfIterator);

    if (KERN_SUCCESS != kernResult)
        cc_log_error(@"Error:    FindEthernetInterfaces returned 0x%08x", kernResult);
    else
    {
        kernResult = GetMACAddress(intfIterator, MACAddress);

        if (KERN_SUCCESS != kernResult)
            cc_log_error(@"Error:    GetMACAddress returned 0x%08x", kernResult);
        else
        {
            uint8_t i;

            for (i = 0; i < kIOEthernetAddressSize; i++)
            {
                if (![result isEqualToString:@""])
                    result = [result stringByAppendingString:@":"];

                if (MACAddress[i] <= 15)
                    result = [result stringByAppendingString:@"0"];

                result = [result stringByAppendingFormat:@"%x", MACAddress[i]];
            }
        }
    }

    if (intfIterator)
        IOObjectRelease(intfIterator);

    return result;
}
#endif


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wcast-align"

+ (NSString *)ipAddress:(bool)ipv6
{
    //    NSArray *a = [[NSHost currentHost] addresses]; // [NSHost currentHost]  broken
    //    NSMutableArray *b = [NSMutableArray arrayWithCapacity:[a count]];
    //    unsigned char i;
    //    unsigned char longestitem = 0, longest = 0;
    //
    //    for (i = 0; i < [a count]; i++)
    //    {
    //        if ([[a objectAtIndex:i] rangeOfString:ipv6 ? @":" : @"."].location != NSNotFound)
    //            [b addObject:[a objectAtIndex:i]];
    //    }
    //
    //
    //    if ([b count] <= 1)
    //        return [b objectAtIndex:0];
    //
    //    [b removeObjectIdenticalTo:ipv6 ? @"::1" : @"127.0.0.1"];
    //
    //    if ([b count] <= 1)
    //        return [b objectAtIndex:0];
    //
    //
    //    for (i = 0; i < [b count]; i++)
    //    {
    //        if ([(NSString *)[b objectAtIndex:i] length] > longest)
    //        {
    //            longest = [(NSString *)[b objectAtIndex:i] length];
    //            longestitem = i;
    //        }
    //    }
    //
    //
    //    return [b objectAtIndex:longestitem];
    struct ifaddrs *myaddrs, *ifa;
    struct sockaddr_in *s4;
    struct sockaddr_in6 *s6;
    int status;
    /* buf must be big enough for an IPv6 address (e.g. 3ffe:2fa0:1010:ca22:020a:95ff:fe8a:1cf8) */
    char buf[64];

    status = getifaddrs(&myaddrs);
    if (status != 0)
    {
        perror("getifaddrs");
        exit(1);
    }

    for (ifa = myaddrs; ifa != NULL; ifa = ifa->ifa_next)
    {
        if (ifa->ifa_addr == NULL) continue;
        if ((ifa->ifa_flags & IFF_UP) == 0) continue;

        if ((ifa->ifa_addr->sa_family == AF_INET) && !ipv6)
        {
            s4 = (struct sockaddr_in *)(ifa->ifa_addr);
            if (inet_ntop(ifa->ifa_addr->sa_family, (void *)&(s4->sin_addr), buf, sizeof(buf)) == NULL)
            {
                //printf("%s: inet_ntop failed!\n", ifa->ifa_name);
            }
            else
            {
                //printf("%s: %s\n", ifa->ifa_name, buf);

                if (![[NSString stringWithUTF8String:ifa->ifa_name] hasPrefix:@"lo"])
                {
                    freeifaddrs(myaddrs);
                    NSString *ip = [NSString stringWithUTF8String:buf];
                    if (ip)
                        return ip;
                }
            }
        }
        else if ((ifa->ifa_addr->sa_family == AF_INET6) && ipv6)
        {
            s6 = (struct sockaddr_in6 *)(ifa->ifa_addr);
            if (inet_ntop(ifa->ifa_addr->sa_family, (void *)&(s6->sin6_addr), buf, sizeof(buf)) == NULL)
            {
                //printf("%s: inet_ntop failed!\n", ifa->ifa_name);
            }
            else
            {
                //printf("%s: %s\n", ifa->ifa_name, buf);

                if (![[NSString stringWithUTF8String:ifa->ifa_name] hasPrefix:@"lo"])
                {
                    freeifaddrs(myaddrs);
                    NSString *ip = [NSString stringWithUTF8String:buf];
                    if (ip)
                        return ip;
                }
            }
        }
    }

    freeifaddrs(myaddrs);

    return ipv6 ? @"::1" : @"127.0.0.1";
}
#pragma clang diagnostic pop

#ifdef USE_SYSTEMCONFIGURATION
+ (BOOL)isOnline
{
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;

    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    BOOL connected = SCNetworkReachabilityGetFlags(reachability, &flags);
    BOOL isConnected = connected && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
    CFRelease(reachability);
    return isConnected;
}

+ (NSString *)ipName
{
    //return [[NSHost currentHost] name]; // [NSHost currentHost]  broken

    SCDynamicStoreRef dynRef = SCDynamicStoreCreate(kCFAllocatorSystemDefault,
                                                    (BRIDGE CFStringRef)cc.appName,
                                                    NULL, NULL);

    if (dynRef)
    {
        CFStringRef hostnameCF = SCDynamicStoreCopyLocalHostName(dynRef);
        CFRelease(dynRef);

        if (!hostnameCF)
        {
            cc_log_error(@"Error: SCDynamicStoreCopyLocalHostName == NULL, %i", __LINE__);
            return @"";
        }
        NSString *hostname = [NSString stringWithFormat:@"%@.local", (BRIDGE NSString *)hostnameCF];
        CFRelease(hostnameCF);

        return hostname;
    }
    else
    {
        cc_log_error(@"Error: SCDynamicStoreCreate == NULL, %i", __LINE__);
        return @"";
    }
}
#endif

NSString *_machineType(void);
+ (NSString *)machineType
{
    return _machineType();
}

+ (NSInteger)bootDiskBSDNum
{
    static NSInteger num = -100;

    if (num == -100)
    {
        struct statfs buffer;
        statfs("/", &buffer);
        NSString *bootDiskString = [NSString stringWithUTF8String:buffer.f_mntfromname];
        if (![bootDiskString hasPrefix:@"/dev/disk"])
            return -1;
        NSString *bsdNumStr = [[[bootDiskString substringFromIndex:9] componentsSeparatedByString:@"s"] objectAtIndex:0];
        num = [bsdNumStr integerValue];
    }

    return num;
}

+ (void)_addDiskToList:(NSMutableArray *)array number:(NSNumber *)num name:(NSString *)name detail:(NSString *)detail
{
    BOOL found = FALSE;

    for (NSMutableDictionary *disk in array)
    {
        if ([[disk objectForKey:kDiskNumberKey] isEqualToNumber:num])
        {
            NSString *currentName = [disk objectForKey:kDiskNameKey];
            [disk setObject:[name stringByAppendingFormat:@", %@", currentName] forKey:kDiskNameKey];

            //cc_log_debug(@"_addDiskToList replace name unique %@\n", [disk description]);

            found = TRUE;
        }
    }

    if (!found)
    {
        NSMutableDictionary *diskDict = [NSMutableDictionary dictionary];

        [diskDict setObject:num forKey:kDiskNumberKey];
        [diskDict setObject:((detail) ? makeString(@"%@ (%@)", name, detail) : name) forKey:kDiskNameKey];

        //cc_log_debug(@"_addDiskToList add unique %@\n", [diskDict description]);

        [array addObject:diskDict];
    }
}

#ifdef USE_IOKIT
#ifdef USE_DISKARBITRATION

+ (NSString *)_serialNumberForIOKitObject:(io_object_t)ggparent
{
    NSString *serial = nil;

    CFTypeRef s = IORegistryEntrySearchCFProperty(ggparent, kIOServicePlane, CFSTR("Serial Number"), kCFAllocatorDefault, kIORegistryIterateRecursively | kIORegistryIterateParents);
    if (s)
    {
        cc_log_debug(@"Serial Number: %@", (BRIDGE NSString *) s);
        serial = [(BRIDGE NSString *)s copy];
        CFRelease(s);
    }
    else
    {
        s = IORegistryEntrySearchCFProperty(ggparent, kIOServicePlane, CFSTR("device serial"), kCFAllocatorDefault, kIORegistryIterateRecursively | kIORegistryIterateParents);
        if (s)
        {
            cc_log_debug(@"Serial Number: %@", (BRIDGE NSString *) s);
            serial = [(BRIDGE NSString *)s copy];
            CFRelease(s);
        }
        else
        {
            s = IORegistryEntrySearchCFProperty(ggparent, kIOServicePlane, CFSTR("USB Serial Number"), kCFAllocatorDefault, kIORegistryIterateRecursively | kIORegistryIterateParents);
            if (s)
            {
                cc_log_debug(@"USB Serial Number: %@", (BRIDGE NSString *) s);
                serial = [(BRIDGE NSString *)s copy];

                CFRelease(s);
            }
            //                                                                                            else
            //                                                                                                cc_log_error(@"Error: couldn't get serial number");
        }
    }

    NSString *info = serial ? [serial stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] : @"NOSERIAL";

#if ! __has_feature(objc_arc)
    [serial release];
#endif

    return info;
}


+ (void)_findZFSBacking:(BOOL *)foundBacking_p volumeName:(NSString *)volumeName nonRemovableVolumes:(NSMutableArray *)nonRemovableVolumes bsdNum:(NSInteger)bsdNum
{
    kern_return_t                kernResult;
    CFMutableDictionaryRef        matchingDict;
    io_iterator_t                iter;

    LOGMOUNTEDHARDDISK(@"mountedHarddisks ZFS");

    matchingDict = IOServiceMatching(kIOMediaClass);
    if (matchingDict != NULL)
    {
        kernResult = IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDict, &iter);

        if ((KERN_SUCCESS == kernResult) && (iter != 0))
        {
            io_object_t object;

            while ((object = IOIteratorNext(iter)))
            {

                CFTypeRef    bsdVolume = NULL;

                bsdVolume = IORegistryEntryCreateCFProperty(object, CFSTR("BSD Name"), kCFAllocatorDefault, 0);
                if (bsdVolume)
                {

                    if ([(BRIDGE NSString *)bsdVolume isEqualToString:[NSString stringWithFormat:@"disk%li", bsdNum]])
                    {
                        LOGMOUNTEDHARDDISK(@"mountedHarddisks ZFS found match");

                        io_iterator_t           parents = MACH_PORT_NULL;
                        kern_return_t res = IORegistryEntryGetParentIterator (object, kIOServicePlane, &parents);

                        if ((KERN_SUCCESS == res) && (parents != 0))
                        {
                            io_object_t parent;

                            while ((parent = IOIteratorNext(parents)))
                            {
                                io_iterator_t gparents = MACH_PORT_NULL;

                                kern_return_t res2 = IORegistryEntryGetParentIterator (parent, kIOServicePlane, &gparents);

                                if ((KERN_SUCCESS == res2) && (gparents != 0))
                                {
                                    io_object_t gparent;

                                    while ((gparent = IOIteratorNext(gparents)))
                                    {

                                        CFTypeRef data = IORegistryEntrySearchCFProperty(gparent, kIOServicePlane, CFSTR("BSD Name"), kCFAllocatorDefault, kIORegistryIterateRecursively | kIORegistryIterateParents);
                                        if (data)
                                        {
                                            LOGMOUNTEDHARDDISK(@"mountedHarddisks ZFS found match %@", (BRIDGE NSString *)data);


                                            NSMutableDictionary *diskDict2 = [NSMutableDictionary dictionary];


                                            if ([(BRIDGE NSString *)data hasPrefix:@"disk"] && ([(BRIDGE NSString *)data length] >= 5))
                                            {
                                                NSInteger num = [[(BRIDGE NSString *)data substringFromIndex:4] integerValue];
                                                [diskDict2 setObject:[NSNumber numberWithInteger:num] forKey:kDiskNumberKey];
                                            }
                                            else
                                                cc_log_error(@"Error: bsd name doesn't look good %@", (BRIDGE NSString *) data);

                                            CFRelease(data);



                                            if ([diskDict2 objectForKey:kDiskNumberKey])
                                            {
                                                NSString *serial = [self _serialNumberForIOKitObject:gparent];

                                                [self _addDiskToList:nonRemovableVolumes
                                                              number:[diskDict2 objectForKey:kDiskNumberKey]
                                                                name:volumeName
                                                              detail:serial];

                                                LOGMOUNTEDHARDDISK(@"mountedHarddisks found zfs backing %@", [diskDict2 description]);

                                                *foundBacking_p = true;
                                                //    NSLog(@"disk Dict %@", diskDict2);

                                            }
                                        }
                                        else
                                            cc_log_error(@"Error: couldn't get bsd name");

                                        IOObjectRelease(gparent);
                                    }

                                    IOObjectRelease(gparents);
                                }

                                IOObjectRelease(parent);
                            }

                            IOObjectRelease(parents);
                        }

                    }
                    CFRelease(bsdVolume);
                }
                IOObjectRelease(object);

            }
            IOObjectRelease(iter);
        }
    }
}

+ (BOOL)_findRAIDBacking:(NSString *)bsdName props:(NSDictionary *)props volumeName:(NSString *)volumeName nonRemovableVolumes:(NSMutableArray *)nonRemovableVolumes
{
    BOOL foundBacking = false;
    LOGMOUNTEDHARDDISK(@"mountedHarddisks found props %@", bsdName);

    CFUUIDRef DAMediaUUID = (BRIDGE CFUUIDRef)[props objectForKey:@"DAMediaUUID"];
    if (DAMediaUUID)
    {
        CFStringRef uuidCF = CFUUIDCreateString(kCFAllocatorDefault, DAMediaUUID);
        NSString *uuid = (BRIDGE NSString *)uuidCF;



        LOGMOUNTEDHARDDISK(@"mountedHarddisks found UUID %@ %@", bsdName, uuid);


        kern_return_t                kernResult;
        CFMutableDictionaryRef        matchingDict;
        io_iterator_t                iter;


        matchingDict = IOServiceMatching(kIOMediaClass);
        if (matchingDict != NULL)
        {
            kernResult = IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDict, &iter);

            if ((KERN_SUCCESS == kernResult) && (iter != 0))
            {
                io_object_t object;

                while ((object = IOIteratorNext(iter)))
                {
                    CFTypeRef    ourUUID = IORegistryEntryCreateCFProperty(object, CFSTR(kIOMediaUUIDKey), kCFAllocatorDefault, 0);
                    if (ourUUID)
                    {
                        if ([(BRIDGE NSString *)ourUUID isEqualToString:uuid])
                        {
                            LOGMOUNTEDHARDDISK(@"mountedHarddisks found matching UUID %@", bsdName);


                            CFTypeRef    d = NULL;
                            d = IORegistryEntryCreateCFProperty(object, CFSTR("SoftRAID Provider Array"), kCFAllocatorDefault, 0);
                            if (d)
                            {
                                LOGMOUNTEDHARDDISK(@"mountedHarddisks SOFTRAID");

                                for (NSString *name in (BRIDGE NSArray *)d)
                                {
                                    if ([name hasPrefix:@"disk"] && ([name length] >= 5))
                                    {
                                        NSString *numStr = [(NSString *)name substringFromIndex:4];
                                        NSInteger num;
                                        if ([numStr contains:@"s"])
                                            num = [[[numStr componentsSeparatedByString:@"s"] objectAtIndex:0] integerValue];
                                        else
                                            num = [numStr integerValue];

                                        [self _addDiskToList:nonRemovableVolumes
                                                      number:@(num)
                                                        name:volumeName
                                                      detail:name];

                                        LOGMOUNTEDHARDDISK(@"mountedHarddisks found1\n");

                                        foundBacking = true;
                                    }
                                    else
                                        cc_log_error(@"Error: 1bsd name doesn't look good %@", (NSString *) name);

                                }
                                CFRelease(d);
                            }
                            else
                            {
                                io_iterator_t           parents = MACH_PORT_NULL;
                                kern_return_t res = IORegistryEntryGetParentIterator (object, kIOServicePlane, &parents);

                                if ((KERN_SUCCESS == res) && (parents != 0))
                                {
                                    io_object_t parent;

                                    while ((parent = IOIteratorNext(parents)))
                                    {
                                        io_iterator_t gparents = MACH_PORT_NULL;

                                        kern_return_t res2 = IORegistryEntryGetParentIterator (parent, kIOServicePlane, &gparents);

                                        if ((KERN_SUCCESS == res2) && (gparents != 0))
                                        {
                                            io_object_t gparent;

                                            while ((gparent = IOIteratorNext(gparents)))
                                            {
                                                io_iterator_t ggparents = MACH_PORT_NULL;

                                                kern_return_t res3 = IORegistryEntryGetParentIterator (gparent, kIOServicePlane, &ggparents);

                                                if ((KERN_SUCCESS == res3) && (ggparents != 0))
                                                {
                                                    io_object_t ggparent;

                                                    while ((ggparent = IOIteratorNext(ggparents)))
                                                    {

                                                        CFTypeRef    data = NULL;
                                                        NSMutableDictionary *diskDict2 = [NSMutableDictionary dictionary];


                                                        data = IORegistryEntrySearchCFProperty(ggparent, kIOServicePlane, CFSTR("BSD Name"), kCFAllocatorDefault, kIORegistryIterateRecursively | kIORegistryIterateParents);
                                                        if (data)
                                                        {
                                                            if ([(BRIDGE NSString *)data hasPrefix:@"disk"] && ([(BRIDGE NSString *)data length] >= 5))
                                                            {
                                                                NSInteger num = [[(BRIDGE NSString *)data substringFromIndex:4] integerValue];
                                                                [diskDict2 setObject:[NSNumber numberWithInteger:num] forKey:kDiskNumberKey];
                                                            }
                                                            else
                                                                cc_log_error(@"Error: bsd name doesn't look good %@", (BRIDGE NSString *) data);

                                                            CFRelease(data);



                                                            if ([diskDict2 objectForKey:kDiskNumberKey])
                                                            {
                                                                NSString *serial = [self _serialNumberForIOKitObject:ggparent];

                                                                [self _addDiskToList:nonRemovableVolumes
                                                                              number:[diskDict2 objectForKey:kDiskNumberKey]
                                                                                name:volumeName
                                                                              detail:serial];

                                                                LOGMOUNTEDHARDDISK(@"mountedHarddisks found %@", [diskDict2 description]);

                                                                foundBacking = true;
                                                                //    NSLog(@"disk Dict %@", diskDict2);
                                                            }

                                                        }
                                                        else
                                                        {
                                                            LOGMOUNTEDHARDDISK(@"Error: couldn't get bsd name");
                                                        }



                                                        IOObjectRelease(ggparent);
                                                    }
                                                }
                                                IOObjectRelease(gparent);
                                            }
                                            IOObjectRelease(gparents);
                                        }
                                        IOObjectRelease(parent);
                                    }
                                }
                                IOObjectRelease(parents);
                            }
                        }
                        CFRelease(ourUUID);
                    }
                    IOObjectRelease(object);
                }
                IOObjectRelease(iter);
            }
        }

        CFRelease(uuidCF);
    }
    return foundBacking;
}


+ (NSMutableArray *)mountedHarddisks:(BOOL)includeRAIDBackingDevices
{
    OSStatus           result = noErr;
    ItemCount       volumeIndex;
    NSMutableArray    *volumeNamesToIgnore = [NSMutableArray array];
    NSMutableArray    *volumePathsToIgnore = [NSMutableArray array];
    NSMutableArray  *nonRemovableVolumes = [NSMutableArray array];

    for (NSString *name in [[NSWorkspace sharedWorkspace] mountedRemovableMedia])
    {
        if ([name hasPrefix:@"/Volumes/"])
            [volumeNamesToIgnore addObject:[name substringFromIndex:[@"/Volumes/" length]]];
        else
            [volumeNamesToIgnore addObject:name];

        [volumePathsToIgnore addObject:name];
    }

    for (NSString *path in [[NSWorkspace sharedWorkspace] mountedLocalVolumePaths])
    {
        NSString *description, *type;
        BOOL removable = NO, writable, unmountable;

        [[NSWorkspace sharedWorkspace] getFileSystemInfoForPath:path
                                                    isRemovable:&removable
                                                     isWritable:&writable
                                                  isUnmountable:&unmountable
                                                    description:&description
                                                           type:&type];

        if (removable)
            [volumePathsToIgnore addObject:path];
    }


    DASessionRef session = NULL;
    if (includeRAIDBackingDevices)
    {
        session = DASessionCreate(kCFAllocatorDefault);
        assert(session);
        if (!session)
        {
            cc_log_error(@"Error:    DASessionCreate returned NULL");
            return nil;
        }
    }

    LOGMOUNTEDHARDDISK(@"mountedHarddisks removableVolumeNames %@", ([volumeNamesToIgnore description]));





    // Iterate across all mounted volumes using FSGetVolumeInfo. This will return nsvErr
    // (no such volume) when volumeIndex becomes greater than the number of mounted volumes.
    for (volumeIndex = 1; result == noErr || result != nsvErr; volumeIndex++)
    {
        FSVolumeRefNum    actualVolume;
        HFSUniStr255    volumeName;
        FSVolumeInfo    volumeInfo;
        FSRef            volumeFSRef;

        bzero((void *) &volumeInfo, sizeof(volumeInfo));

        // We're mostly interested in the volume reference number (actualVolume)
        result = FSGetVolumeInfo(kFSInvalidVolumeRefNum,
                                 volumeIndex,
                                 &actualVolume,
                                 kFSVolInfoFSInfo,
                                 &volumeInfo,
                                 &volumeName,
                                 &volumeFSRef);

        if (result == noErr)
        {
            GetVolParmsInfoBuffer volumeParms;
            result = FSGetVolumeParms (actualVolume, &volumeParms, sizeof(volumeParms));

            CFStringRef    volNameAsCFString = CFStringCreateWithCharacters(kCFAllocatorDefault,
                                                                            volumeName.unicode,
                                                                            volumeName.length);

            if (result != noErr)
                cc_log_error(@"Error:    FSGetVolumeParms returned %d", result);
            else
            {
                if (!volNameAsCFString)
                    cc_log_error(@"Error: volNameAsCFString == NULL");
                else if ([((BRIDGE NSString *)volNameAsCFString) contains:@"@snap-"])
                {
                    cc_log_debug(@"ignoring local snapshot %@", ((BRIDGE NSString *)volNameAsCFString));
                    CFRelease(volNameAsCFString);
                    volNameAsCFString = NULL;
                }
                else
                {
                    LOGMOUNTEDHARDDISK(@"mountedHarddisks found IOKit name %@", (BRIDGE NSString *)volNameAsCFString);

                    if ((char *)volumeParms.vMDeviceID != NULL)
                    {
                        CFURLRef mountURLCF = CFURLCreateFromFSRef(NULL, &volumeFSRef);

                        if (mountURLCF)
                        {
                            NSURL *mountURL = (BRIDGE NSURL *)mountURLCF;
                            if ([mountURL.path isEqualToString:@"/private/var/vm"]) // ignore HighSierra 'VM' partition
                            {
                                CFRelease(mountURLCF);
                                continue;
                            }

                            // This code is just to convert the volume name from a HFSUniCharStr to
                            // a plain C string so we can print it with printf. It'd be preferable to
                            // use CoreFoundation to work with the volume name in its Unicode form.


                            //NSLog((NSString *)volNameAsCFString);

                            if ([volumeNamesToIgnore indexOfObject:(BRIDGE NSString *)volNameAsCFString] == NSNotFound &&
                                [volumePathsToIgnore indexOfObject:[mountURL path]] == NSNotFound) // not removable
                            {

                                NSString *bsdName = [NSString stringWithUTF8String:(char *)volumeParms.vMDeviceID];

                                LOGMOUNTEDHARDDISK(@"mountedHarddisks has BSD name %@", bsdName);

                                if ([bsdName hasPrefix:@"disk"])
                                {
                                    NSString *bsdNumStr = [[[bsdName substringFromIndex:4] componentsSeparatedByString:@"s"] objectAtIndex:0];
                                    NSInteger bsdNum = [bsdNumStr integerValue];
                                    BOOL found = FALSE;

                                    for (NSMutableDictionary *disk in nonRemovableVolumes)  // check if we already added the disk because of another partition
                                    {
                                        if ([[disk objectForKey:kDiskNumberKey] integerValue] == bsdNum)
                                        {
                                            NSString *currentName = [disk objectForKey:kDiskNameKey];
                                            [disk setObject:[currentName stringByAppendingFormat:@", %@", (BRIDGE NSString *)volNameAsCFString] forKey:kDiskNameKey];
                                            found = TRUE;
                                        }
                                    }

                                    if (!found) // new disk
                                    {
                                        BOOL foundBacking = false;


                                        if (includeRAIDBackingDevices)
                                        {
                                            NSString *bsdname = [NSString stringWithFormat:@"/dev/disk%li", bsdNum];

                                            DADiskRef disk = DADiskCreateFromBSDName(kCFAllocatorDefault, session, [bsdname UTF8String]);

                                            if (disk)
                                            {
                                                CFDictionaryRef propsCF = DADiskCopyDescription(disk);

                                                if (propsCF)
                                                {
                                                    NSDictionary *props = (BRIDGE NSDictionary *)propsCF;


                                                    CFRelease(disk);
                                                    disk = NULL;

                                                    LOGMOUNTEDHARDDISK(@"mountedHarddisks checking for raid backing %@", bsdName);

                                                    if ([[props objectForKey:@"DAVolumeKind"] isEqualToString:@"zfs"])
                                                    {
                                                        [self _findZFSBacking:&foundBacking
                                                                   volumeName:(BRIDGE NSString *)volNameAsCFString
                                                          nonRemovableVolumes:nonRemovableVolumes
                                                                       bsdNum:bsdNum];
                                                    }
                                                    else if (([props objectForKey:@"DAMediaLeaf"] && [[props objectForKey:@"DAMediaLeaf"] intValue]) ||
                                                             ([[props objectForKey:@"DAMediaName"] isEqualToString:@"AppleAPFSMedia"]))
                                                    {
                                                        foundBacking = [self _findRAIDBacking:bsdName
                                                                                        props:props
                                                                                   volumeName:(BRIDGE NSString *)volNameAsCFString
                                                                          nonRemovableVolumes:nonRemovableVolumes];
                                                    }
                                                    
                                                    CFRelease(propsCF);
                                                    propsCF = NULL;
                                                    props = nil;
                                                }
                                                else
                                                    cc_log_error(@"Error: DADiskCopyDescription == NULL");
                                            }
                                            else
                                                cc_log_error(@"Error: DADiskCreateFromBSDName == NULL");
                                        }

                                        if (!foundBacking)
                                        {
                                            [self _addDiskToList:nonRemovableVolumes
                                                          number:[NSNumber numberWithInteger:bsdNum]
                                                            name:(BRIDGE NSString *)volNameAsCFString
                                                          detail:nil];


                                            LOGMOUNTEDHARDDISK(@"mountedHarddisks is new disk without backing %@", bsdName);
                                        }
                                        else
                                            LOGMOUNTEDHARDDISK(@"mountedHarddisks ignoring volume with raid/zfs backing %@", bsdName);
                                    }
                                }
                            }

                            CFRelease(mountURLCF);
                            mountURLCF = NULL;
                        }
                        else
                            cc_log_error(@"Error: mountURLCF == NULL");
                    }
                    else
                    {
                        cc_log_debug(@"mountedHarddisks volumeParms.vMDeviceID == NULL");
                    }

                    CFRelease(volNameAsCFString);
                    volNameAsCFString = NULL;
                }
            }
        }
    }

    if (includeRAIDBackingDevices)
        CFRelease(session);


    if ([nonRemovableVolumes count] >= 2) // move boot volume to first spot
    {
        NSInteger bootDisk = [self bootDiskBSDNum];

        for (NSUInteger i = 1; i < [nonRemovableVolumes count]; i++)
        {
            NSDictionary *disk = [nonRemovableVolumes objectAtIndex:i];

            if ([[disk objectForKey:kDiskNumberKey] integerValue] == bootDisk)
            {
                [nonRemovableVolumes exchangeObjectAtIndex:0 withObjectAtIndex:i];

                break;
            }
        }
    }

    return nonRemovableVolumes;
}

+ (NSArray *)allHarddisks
{
    DASessionRef session = DASessionCreate(kCFAllocatorDefault);

    int subsequentNil = 0;
    NSMutableArray *disks = [NSMutableArray array];
    for (int i = 0; i < 64 && subsequentNil < 5; i++)
    {
        NSString *bsdname = [NSString stringWithFormat:@"/dev/disk%i", i];
        const char *bsdnameC = bsdname.UTF8String;

        DADiskRef disk = DADiskCreateFromBSDName(kCFAllocatorDefault, session, bsdnameC);
        CFDictionaryRef propsCF = DADiskCopyDescription(disk);
        NSDictionary *props = (__bridge NSDictionary *)propsCF;

        if (!props)
            subsequentNil ++;
        else
        {
            subsequentNil = 0;
            NSString *name = props[@"DAVolumeName"];
            [disks addObject:@{kDiskNameKey :name ? name :  bsdname, kDiskNumberKey : @(i)}];

            CFRelease(propsCF);
        }


        CFRelease(disk);
        disk = NULL;

    }
    CFRelease(session);
    return disks.immutableObject;
}
#endif



#ifdef USE_IOKIT
+ (BOOL)runsOnBattery
{
    CFTypeRef        blob = IOPSCopyPowerSourcesInfo();
    if (!blob)        return FALSE;
    CFArrayRef        array = IOPSCopyPowerSourcesList(blob);
    BOOL            ret = FALSE;

    if (array)
    {
        for (int i = 0 ; i < CFArrayGetCount(array); i++)
        {
            CFDictionaryRef    dict = IOPSGetPowerSourceDescription(blob, CFArrayGetValueAtIndex(array, i));
            CFStringRef        str = (CFStringRef)CFDictionaryGetValue(dict, CFSTR(kIOPSPowerSourceStateKey));

            if (CFEqual(str, CFSTR(kIOPSBatteryPowerValue)))
                ret = TRUE;
        }
        CFRelease(array);
    }
    CFRelease(blob);

    return ret;
}


#endif
#endif
@end

// Returns an iterator containing the primary (built-in) Ethernet interface. The caller is responsible for
// releasing the iterator after the caller is done with it.
static kern_return_t FindEthernetInterfaces(io_iterator_t *matchingServices)
{
    kern_return_t kernResult;
    mach_port_t masterPort;
    CFMutableDictionaryRef matchingDict;
    CFMutableDictionaryRef propertyMatchDict;

    // Retrieve the Mach port used to initiate communication with I/O Kit
    kernResult = IOMasterPort(MACH_PORT_NULL, &masterPort);
    if (KERN_SUCCESS != kernResult)
    {
        cc_log_error(@"Error:    IOMasterPort returned %d", kernResult);
        return kernResult;
    }

    // Ethernet interfaces are instances of class kIOEthernetInterfaceClass.
    // IOServiceMatching is a convenience function to create a dictionary with the key kIOProviderClassKey and
    // the specified value.
    matchingDict = IOServiceMatching(kIOEthernetInterfaceClass);

    // Note that another option here would be:
    // matchingDict = IOBSDMatching("en0");

    if (NULL == matchingDict)
        cc_log_error(@"Error:    IOServiceMatching returned a NULL dictionary.");
    else
    {
        // Each IONetworkInterface object has a Boolean property with the key kIOPrimaryInterface. Only the
        // primary (built-in) interface has this property set to TRUE.

        // IOServiceGetMatchingServices uses the default matching criteria defined by IOService. This considers
        // only the following properties plus any family-specific matching in this order of precedence
        // (see IOService::passiveMatch):
        //
        // kIOProviderClassKey (IOServiceMatching)
        // kIONameMatchKey (IOServiceNameMatching)
        // kIOPropertyMatchKey
        // kIOPathMatchKey
        // kIOMatchedServiceCountKey
        // family-specific matching
        // kIOBSDNameKey (IOBSDNameMatching)
        // kIOLocationMatchKey

        // The IONetworkingFamily does not define any family-specific matching. This means that in
        // order to have IOServiceGetMatchingServices consider the kIOPrimaryInterface property, we must
        // add that property to a separate dictionary and then add that to our matching dictionary
        // specifying kIOPropertyMatchKey.

        propertyMatchDict = CFDictionaryCreateMutable(kCFAllocatorDefault, 0,
                                                      &kCFTypeDictionaryKeyCallBacks,
                                                      &kCFTypeDictionaryValueCallBacks);

        if (NULL == propertyMatchDict)
            cc_log_error(@"Error:    CFDictionaryCreateMutable returned a NULL dictionary.");
        else
        {
            // Set the value in the dictionary of the property with the given key, or add the key
            // to the dictionary if it doesn't exist. This call retains the value object passed in.
            CFDictionarySetValue(propertyMatchDict, CFSTR(kIOPrimaryInterface), kCFBooleanTrue);

            // Now add the dictionary containing the matching value for kIOPrimaryInterface to our main
            // matching dictionary. This call will retain propertyMatchDict, so we can release our reference
            // on propertyMatchDict after adding it to matchingDict.
            CFDictionarySetValue(matchingDict, CFSTR(kIOPropertyMatchKey), propertyMatchDict);
            CFRelease(propertyMatchDict);
        }
    }

    // IOServiceGetMatchingServices retains the returned iterator, so release the iterator when we're done with it.
    // IOServiceGetMatchingServices also consumes a reference on the matching dictionary so we don't need to release
    // the dictionary explicitly.
    kernResult = IOServiceGetMatchingServices(masterPort, matchingDict, matchingServices);

    if (KERN_SUCCESS != kernResult)
        cc_log_error(@"Error:    IOServiceGetMatchingServices returned %d", kernResult);

    return kernResult;
}

// Given an iterator across a set of Ethernet interfaces, return the MAC address of the last one.
// If no interfaces are found the MAC address is set to an empty string.
// In this sample the iterator should contain just the primary interface.

static kern_return_t GetMACAddress(io_iterator_t intfIterator, UInt8 *MACAddress)
{
    io_object_t intfService;
    io_object_t controllerService;
    kern_return_t kernResult = KERN_FAILURE;

    // Initialize the returned address
    bzero(MACAddress, kIOEthernetAddressSize);

    // IOIteratorNext retains the returned object, so release it when we're done with it.
    while ((intfService = IOIteratorNext(intfIterator)))
    {
        CFTypeRef MACAddressAsCFData;

        // IONetworkControllers can't be found directly by the IOServiceGetMatchingServices call,
        // since they are hardware nubs and do not participate in driver matching. In other words,
        // registerService() is never called on them. So we've found the IONetworkInterface and will
        // get its parent controller by asking for it specifically.

        // IORegistryEntryGetParentEntry retains the returned object, so release it when we're done with it.
        kernResult = IORegistryEntryGetParentEntry(intfService,
                                                   kIOServicePlane,
                                                   &controllerService);

        if (KERN_SUCCESS != kernResult)
            cc_log_error(@"Error:    IORegistryEntryGetParentEntry returned 0x%08x", kernResult);
        else
        {
            // Retrieve the MAC address property from the I/O Registry in the form of a CFData
            MACAddressAsCFData = IORegistryEntryCreateCFProperty(controllerService,
                                                                 CFSTR(kIOMACAddress),
                                                                 kCFAllocatorDefault,
                                                                 0);
            if (MACAddressAsCFData)
            {
                // CFShow(MACAddressAsCFData); for display purposes only; output goes to stderr

                // Get the raw bytes of the MAC address from the CFData
                CFDataGetBytes(MACAddressAsCFData, CFRangeMake(0, kIOEthernetAddressSize), MACAddress);
                CFRelease(MACAddressAsCFData);
            }

            // Done with the parent Ethernet controller object so we release it.
            (void) IOObjectRelease(controllerService);
        }

        // Done with the Ethernet interface object so we release it.
        (void) IOObjectRelease(intfService);
    }

    return kernResult;
}





#if ! __has_feature(objc_arc)
#define BRIDGE
#else
#define BRIDGE __bridge
#endif

BOOL IsLoginItem(void)
{
    UInt32 outSnapshotSeed;
    LSSharedFileListRef list = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);

    if (list)
    {
        NSArray *array = (BRIDGE NSArray *) LSSharedFileListCopySnapshot(list, &outSnapshotSeed);

        if (array)
        {
            NSString *bp = [[NSBundle mainBundle] bundlePath];

            for (id item in array)
            {
#if MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_10
                CFURLRef url = NULL;
                OSStatus status = LSSharedFileListItemResolve((BRIDGE LSSharedFileListItemRef)item, kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes, &url, NULL);
                if (status == noErr && url)
#else
                    CFErrorRef err = NULL;
                CFURLRef url = LSSharedFileListItemCopyResolvedURL((BRIDGE LSSharedFileListItemRef)item, kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes, &err);
                if (!err && url)
#endif
                {

                    //cc_log_debug(@"isLoginItem: current login item: %@", [url path]);

                    if (NSOrderedSame == [[(BRIDGE NSURL *)url path] compare:bp]) // the path is the same as ours => return true
                    {
                        //cc_log_debug(@"isLoginItem: FOUND US");
                        CFRelease((url));
                        CFRelease((BRIDGE CFTypeRef)(array));
                        CFRelease(list);
                        return TRUE;
                    }
                    else if (NSOrderedSame == [[[(BRIDGE NSURL *)url path] lastPathComponent] compare:[[[NSBundle mainBundle] bundlePath] lastPathComponent]]) // another entry of us, must be valid since on 10.5 invalid entries are erased automatically
                    {
                        //cc_log_debug(@"isLoginItem: found similar");
                    }
                }


                if (url != NULL)
                    CFRelease(url);
            }
            CFRelease((BRIDGE CFTypeRef)(array));
        }
        else
            cc_log_error(@"Warning: _IsLoginItem : LSSharedFileListCopySnapshot delivered NULL list!");

        CFRelease(list);
    }
    else
        cc_log_error(@"Warning: _IsLoginItem : LSSharedFileListCreate delivered NULL list!");

    return FALSE;
}

void AddLoginItem(void)
{
    //cc_log_debug(@"addLoginItem: bundle path: %@", [[NSBundle mainBundle] bundlePath]);
    LSSharedFileListRef list = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);

    if (list)
    {
        LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(list, kLSSharedFileListItemLast, (BRIDGE CFStringRef)cc.appName, NULL, (BRIDGE CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]], NULL, NULL);

        CFRelease(list);

        if (item)
            CFRelease(item);
        else
            cc_log_error(@"Warning: _AddLoginItem : LSSharedFileListInsertItemURL delivered NULL item!");
    }
    else
        cc_log_error(@"Warning: _AddLoginItem : LSSharedFileListCreate delivered NULL list!");
}

void RemoveLoginItem(void)
{
    UInt32 outSnapshotSeed;
    LSSharedFileListRef list = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);

    if (list)
    {
        NSArray *array = (BRIDGE NSArray *) LSSharedFileListCopySnapshot(list, &outSnapshotSeed);

        if (array)
        {
            NSString *bp = [[NSBundle mainBundle] bundlePath];

            for (id item in array)
            {
#if MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_10
                CFURLRef url = NULL;
                OSStatus status = LSSharedFileListItemResolve((BRIDGE LSSharedFileListItemRef)item, kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes, &url, NULL);
                if (status == noErr && url)
#else
                    CFErrorRef err = NULL;
                CFURLRef url = LSSharedFileListItemCopyResolvedURL((BRIDGE LSSharedFileListItemRef)item, kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes, &err);
                if (!err && url)
#endif
                {
                    if (NSOrderedSame == [[(BRIDGE NSURL *)url path] compare:bp]) // the path is the same as ours => return true
                    {
                        cc_log_debug(@"removeLoginItem: removing: %@", [(BRIDGE NSURL *)url path]);

                        LSSharedFileListItemRemove(list, (BRIDGE LSSharedFileListItemRef) item);
                    }
                    CFRelease(url);
                }
#if MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_10
                else if (status != fnfErr)
                    cc_log_error(@"Warning: removeLoginItem: LSSharedFileListItemResolve error %i", (int)status);
#else
                else
                    cc_log_error(@"Warning: removeLoginItem: LSSharedFileListItemResolve error %@ url %@", [((BRIDGE NSError *)err) description], [((BRIDGE NSURL *)url) description]);
#endif
            }
            CFRelease((BRIDGE CFTypeRef)(array));
        }
        else
            cc_log_error(@"Warning: _RemoveLoginItem : LSSharedFileListCopySnapshot delivered NULL list!");

        CFRelease(list);
    }
    else
        cc_log_error(@"Warning: _RemoveLoginItem : LSSharedFileListCreate delivered NULL list!");
}


