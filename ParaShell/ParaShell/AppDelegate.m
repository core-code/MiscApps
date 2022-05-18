//
//  AppDelegate.m
//  ParaShell
//
//  Created by CoreCode on 30.03.15.
//  Copyright © 2020 CoreCode Limited. All rights reserved.
//

#undef PADDLE
#undef USE_SPARKLE

#import "AppDelegate.h"
#import "JMAppMovedHandler.h"


@interface AppDelegate ()

@property (strong, nonatomic) IBOutlet NSWindow *mainWindow;
@property (strong, nonatomic) IBOutlet NSWindow *documentationWindow;
@property (strong, nonatomic) IBOutlet NSWindow *promotionWindow;

@property (strong, nonatomic) NSString *version;
@property (strong, nonatomic) NSString *build;

@property (unsafe_unretained, nonatomic) IBOutlet NSTextView *textView;
@property (unsafe_unretained, nonatomic) IBOutlet NSTableView *sourceTable;

@property (strong, atomic) IBOutlet NSString *output;
@property (strong, atomic) NSMutableDictionary <NSString *, NSMutableDictionary *>*jobs;

@end


static NSString *kRVNBundleID = @"com.corecode.ParaShell";
static NSString *kRVNBundleVersion = @"1.0.0";


@implementation AppDelegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return self.jobs.count ? 1 + (int)self.jobs.count : 1;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    if (!self.jobs.count && rowIndex == 0)
        return @"INPUT";
    else if (self.jobs.count && rowIndex == 0)
        return @"FINISHED OUTPUT";
    else
    {
        let sortedJobKeys = [self sortedJobKeys];
        let job = self.jobs[sortedJobKeys[rowIndex-1]];
        
        if ([job[@"status"] intValue] == 0)
            return makeString(@"⚪ Task TODO: %@", job[@"cmd"]);
        if ([job[@"status"] intValue] == 1)
            return makeString(@"🟢 Task LIVE: %@", job[@"cmd"]);
        if ([job[@"status"] intValue] == 2)
            return makeString(@"⚫ Task DONE: %@", job[@"cmd"]);
        
        return @"";
    }
}

- (NSArray <NSString *> *)sortedJobKeys
{
    let sortedKeys = [self.jobs keysSortedByValueUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary * obj2)
    {
        int status1;
        int status2;
        
        
        @synchronized (self)
        {
            status1 = [obj1[@"status"] intValue];
            status2 = [obj2[@"status"] intValue];
        }
        
        if (status1 != status2)
        {
            NSNumber *modStatus1 = @(status1 == 0 ? 1.5 : status1);
            NSNumber *modStatus2 = @(status2 == 0 ? 1.5 : status2);
            return [modStatus1 compare:modStatus2];
        }
        else
        {
            NSString *cmd1;
            NSString *cmd2;
            @synchronized (self)
            {
                cmd1 = ((NSString *)obj1[@"cmd"]);
                cmd2 = ((NSString *)obj2[@"cmd"]);
            }
            
            return [cmd1 compare:cmd2];
        }
    }];
    
    return sortedKeys;
}

- (IBAction)run:(NSButton *)sender
{
    LOGFUNC

    self.output = @"";
    [fileManager changeCurrentDirectoryPath:@"~".stringByExpandingTildeInPath];

    if ([sender.title isEqualToString:@"Quit"]) [NSApp terminate:nil];
    sender.title = @"Quit";
    let inputText = self.textView.string;
    let separators = [NSCharacterSet characterSetWithCharactersInString:@";\n"];
    let inputArray = [inputText componentsSeparatedByCharactersInSet:separators];
    
    
    self.jobs = makeMutableDictionary();
    for (NSString *input in inputArray)
#warning todo better uniqufy here as it won't work later anyway
        if (input.trimmedOfWhitespaceAndNewlines.length)
            self.jobs[input] = @{@"status" : @(0), @"output" : makeMutableString(), @"cmd" : input}.mutableObject;
    
    dispatch_async_back(^
    {
        [self.jobs enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(NSString *command, NSMutableDictionary *value, BOOL * _Nonnull stop)
        {
            @synchronized (self)
            {
                value[@"status"] = @(1);
                dispatch_async_main(^{[self.sourceTable reloadData];});
            }

            var cmdOutput = [@[@"/bin/zsh", @"-l", @"-i", @"-c", command] runAsTaskWithProgressBlock:^(NSString *newString)
            {
                @synchronized (self)
                {
                    NSMutableString *o = value[@"output"];
                    if (o.length)
                        [o appendString:newString];
                }
            }];
            
            cmdOutput = [cmdOutput.lines filtered:^BOOL(NSString *input) { return ![input contains:@"error finding potential wrapper bundle for node"]; }]. joinedWithNewlines;
            
            @synchronized (self)
            {
                value[@"status"] = @(2);
                value[@"output"] = cmdOutput;
                self.output = makeString(@"%@\nOUTPUT FOR CMD: %@\n\n%@\n\n________________________", self.output, command, cmdOutput);
                
                int todo = [self.jobs.allKeys reduce:^int(NSString *i) { return [self.jobs[i][@"status"] intValue] == 0; }];
                int cwip = [self.jobs.allKeys reduce:^int(NSString *i) { return [self.jobs[i][@"status"] intValue] == 1; }];
                int done = = [self.jobs.allKeys reduce:^int(NSString *i) { return [self.jobs[i][@"status"] intValue] == 2; }];
                
                self.mainWindow.title = makeString(@"ParaShell [%i|%i|%i]", done, cwip, todo);
            }
            dispatch_async_main(^{[self.sourceTable reloadData];});
        }];
    });
    dispatch_async_main(^{[self.sourceTable reloadData];});
}

- (void)updateTextView
{
    LOGFUNCPARAM(@(self.sourceTable.selectedRow))

    if (self.sourceTable.selectedRow < 1)
    {
        if (self.jobs.count)
        {
            int todo;
            int cwip;
            //int done;
            
            @synchronized (self)
            {
                todo = [self.jobs.allKeys reduce:^int(NSString *i) { return [self.jobs[i][@"status"] intValue] == 0; }];
                cwip = [self.jobs.allKeys reduce:^int(NSString *i) { return [self.jobs[i][@"status"] intValue] == 1; }];
            //  done = = [self.jobs.allKeys reduce:^int(NSString *i) { return [self.jobs[i][@"status"] intValue] == 2; }];
            }
            
            let status = (todo + cwip) > 0 ? makeString(@"IN-PROGRESS: %i results outstanding", todo + cwip) : @"ALL-DONE-AND-FINITO";
        
            self.textView.string = makeString(@"%@\n\n%@", self.output, status);
        }
    }
    else
    {
        let sortedJobKeys = [self sortedJobKeys];
        let job = self.jobs[sortedJobKeys[self.sourceTable.selectedRow-1]];
        let newText = (NSString *)job[@"output"];
        
        self.textView.string = newText;
    }
}

- (void)updateTextTimer
{
    dispatch_async_main(^{[self updateTextView]; });
    dispatch_after_back(1, ^{[self updateTextTimer]; });
}

- (void)tableViewSelectionDidChange:(NSNotification *)not
{
    LOGFUNC
    [self updateTextView];
}

#pragma mark - NSApplication notification - template code

+ (void)initialize
{
	NSMutableDictionary *defaultValues = makeMutableDictionary();
    
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
    
	[self openMainWindow:self];
    
    dispatch_after_back(1, ^{[self updateTextTimer]; });
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    LOGFUNC

    [self openMainWindow:self];

    return FALSE;
}

#pragma mark - IBAction - template code

- (IBAction)openMainWindow:(id)sender
{
	LOGFUNCPARAM(sender)
	[self openWindow:&_mainWindow nibName:@"MainWindow"];
}

- (IBAction)openPromotionWindow:(id)sender
{
	LOGFUNCPARAM(sender)

	[self openWindow:&_promotionWindow nibName:@"PromotionWindow"];
}

- (IBAction)openDocumentationWindow:(NSMenuItem *)sender
{
	LOGFUNCPARAM(sender)

	[self openWindow:&_documentationWindow nibName:@"DocumentationWindow"];

	// make sure we select the right tab in the documentation as given in the tag of the sender
	if (sender && [sender respondsToSelector:@selector(tag)] && [sender tag] >= 0)
	{
		 NSTabView *documentationTabView = [_documentationWindow.contentView viewWithClass:NSTabView.class].id;
		 [documentationTabView selectTabViewItemAtIndex:[sender tag]];
	}
}

#pragma mark NSWindowDelegate - template code

- (void)windowWillClose:(NSNotification *)notification
{
	LOGFUNCPARAM(notification)

	if (notification.object == self.mainWindow)
		self.mainWindow = nil;
    else if (notification.object == self.documentationWindow)
        self.documentationWindow = nil;
    else if (notification.object == self.promotionWindow)
        self.promotionWindow = nil;
}
@end


int main(int argc, const char *argv[])
{
	@autoreleasepool
	{
		return NSApplicationMain(argc, (const char **)argv);
	}
}
