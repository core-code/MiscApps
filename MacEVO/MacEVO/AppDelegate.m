//
//  AppDelegate.m
//  MacEVO
//
//  Created by CoreCode on 30.03.15.
//  Copyright (c) 2015 CoreCode. All rights reserved.
//

#import "AppDelegate.h"
#import "JMReceiptValidation.h"

@interface AppDelegate ()

@property (strong, nonatomic) IBOutlet NSTableView *tableView;
@property (strong, nonatomic) IBOutlet NSWindow *mainWindow;
@property (strong, nonatomic) IBOutlet NSWindow *documentationWindow;
@property (strong, nonatomic) IBOutlet NSWindow *promotionWindow;
@property (strong, nonatomic) NSString *version;
@property (strong, nonatomic) NSString *build;
@property (strong, nonatomic) NSArray *allarticles;
@property (strong, nonatomic) NSArray *articles;
@property (strong, nonatomic) NSMutableDictionary *imagecache;

@end


NSString *kRVNBundleID = @"com.corecode.MacEVO";
NSString *kRVNBundleVersion = @"1.0.0";


@implementation AppDelegate


+ (void)initialize
{
	NSMutableDictionary *defaultValues = makeMutableDictionary();


	[NSUserDefaults.standardUserDefaults registerDefaults:defaultValues];
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
	LOGFUNC;

	cc = [CoreLib new];

    self.allarticles = @"http://api.app.evo.co.uk/evo_db.json?device=mobile&resolution=2x".download.JSONDictionary[@"articles"];
    self.articles = self.allarticles;

    self.imagecache = [NSMutableDictionary new];
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	LOGFUNC;

	self.build = makeString(@"%@ %i", @"Build:".localized, cc.appBuildNumber);
	self.version = makeString(@"%@ %@", @"Version:".localized, cc.appVersionString);



	[self openMainWindow:self];


	[self checkMASReceipt];

	[self checkBetaExpiryForDate:__DATE__ days:30];

#ifndef SANDBOX
	[self checkAndReportCrashesContaining:@[@"[Value", @"AppDele", @"[NSException", @"uncaught exception"].id
									   to:@"crashreports@corecode.at"];
#endif

	[self welcomeOrExpireDemo:20
				  welcomeText:@"You've used up all 20 operations allowed in this TRYOUT version of MacEVO. If you like MacEVO please consider buying the full version."
				   expiryText:@"Welcome to the feature-limited TRYOUT version of MacEVO. This version can be used to perform 20 operations, you have %li operations left!"];

	[self increaseUsages];

	[self checkAppMovements];
}

- (void)increaseUsages
{
	LOGFUNC;

	[self increaseUsages:20
		   requestReview:40
			feedbackText:@"You've used MacEVO to successfully perform 20 operations, it would be great if you could rate the app on the MacAppStore or on MacUpdate! This message will not appear again for this version."];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    LOGFUNC;

    [self openMainWindow:nil];

	[self checkMASReceipt];

    return FALSE;
}

#pragma mark - IBAction

- (IBAction)openMainWindow:(id)sender
{
	LOGFUNCPARAM(sender);

	[self openWindow:&_mainWindow nibName:@"MainWindow"];
}

- (IBAction)openPromotionWindow:(id)sender
{
	LOGFUNCPARAM(sender);

	[self openWindow:&_promotionWindow nibName:@"PromotionWindow"];
}

- (IBAction)openDocumentationWindow:(id)sender
{
	LOGFUNCPARAM(sender);

	[self openWindow:&_documentationWindow nibName:@"DocumentationWindow"];


	// make sure we select the right tab in the documentation as given in the tag of the sender
	if (sender && [sender respondsToSelector:@selector(tag)] && [sender tag] >= 0)
	{
		 NSTabView *documentationTabView = [_documentationWindow.contentView viewWithClass:NSTabView.class].id;
		 [documentationTabView selectTabViewItemAtIndex:[sender tag]];
	}
}

#pragma mark NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification
{
	LOGFUNCPARAM(notification);

	if (notification.object == self.mainWindow)
		self.mainWindow = nil;
    else if (notification.object == self.documentationWindow)
        self.documentationWindow = nil;
    else if (notification.object == self.promotionWindow)
        self.promotionWindow = nil;
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return (NSInteger)self.articles.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSUInteger ind = [tableView.tableColumns indexOfObject:tableColumn];
    NSDictionary *article = self.articles[(uint32_t)row];

    if (ind == 0)
    {
        NSString *urlstr = ((NSString *)article[@"thumbnail_url"]);
        NSImage *image = self.imagecache[urlstr];

        if (image)
            return image;
        else
        {
			self.imagecache[urlstr] = @"placeholder".namedImage;

            dispatch_async_back(^
            {
				[urlstr.URL performGET:^(NSData *data)
				{
					NSImage *newimage = [[NSImage alloc] initWithData:data];

					dispatch_async_main(^
					{
						self.imagecache[urlstr] = newimage;

						[tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:(NSUInteger)row]
											 columnIndexes:[NSIndexSet indexSetWithIndex:0]];
					});
				}];
            });

            return @"placeholder".namedImage;
        }

    }
    else if (ind == 1)
        return makeString(@"%@: %@\n\n%@", article[@"label"], article[@"title"], NON_NIL_STR([article[@"makes"] joined:@" "]));
    else
        return article[@"summary"];

}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    NSTableView *tv = aNotification.object;
    uint32_t row = (uint32_t)tv.selectedRow;
    NSDictionary *article = self.articles[row];

    NSString *url = article[@"html_url"];

    if ([url hasPrefix:@"http"])
        [url.URL open];
    else
        [makeString(@"http://api.app.evo.co.uk/%@", url).URL open];
}

- (IBAction)searchField:(NSSearchField *)sender
{

    if (sender.stringValue.length)
    {
        NSMutableArray *tmp = makeMutableArray();

        for (NSDictionary *article in self.allarticles)
        {
            NSString *string = makeString(@"%@ %@ %@ %@", article[@"label"], article[@"title"], article[@"summary"], NON_NIL_STR([article[@"makes"] joined:@" "]));

            if ([string.lowercaseString contains:sender.stringValue.lowercaseString])
                [tmp addObject:article];
        }


        self.articles = tmp;
        }
    else
        self.articles = self.allarticles;

    [self.tableView reloadData];
    
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
