//
//  AppDelegate.m
//  MacEVO
//
//  Created by CoreCode on 30.03.15.
//  Copyright (c) 2015 CoreCode. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (strong, nonatomic) IBOutlet NSTableView *tableView;
@property (strong, nonatomic) IBOutlet NSWindow *mainWindow;
@property (strong, nonatomic) NSString *version;
@property (strong, nonatomic) NSString *build;
@property (strong, nonatomic) NSArray *allarticles;
@property (strong, nonatomic) NSArray *articles;
@property (strong, nonatomic) NSMutableDictionary *imagecache;

@end


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
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    LOGFUNC;

    [self openMainWindow:nil];

    return FALSE;
}

#pragma mark - IBAction

- (IBAction)openMainWindow:(id)sender
{
	LOGFUNCPARAM(sender);

	[self openWindow:&_mainWindow nibName:@"MainWindow"];
}

#pragma mark NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification
{
	LOGFUNCPARAM(notification);

	if (notification.object == self.mainWindow)
		self.mainWindow = nil;
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
		return NSApplicationMain(argc, (const char **)argv);
	}
}