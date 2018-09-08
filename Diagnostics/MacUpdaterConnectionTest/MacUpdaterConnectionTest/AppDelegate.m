//
//  AppDelegate.m
//  MacUpdaterConnectionTest
//
//  Created by CoreCode on 08/09/2018.
//  Copyright © 2018 CoreCode Limited. All rights reserved.
//

#import "AppDelegate.h"
#import "CoreLib.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSImageView *CCIV;
@property (weak) IBOutlet NSImageView *MUIV;
@property (weak) IBOutlet NSImageView *GHIV;
@property (weak) IBOutlet NSTextField *CCL;
@property (weak) IBOutlet NSTextField *MUL;
@property (weak) IBOutlet NSTextField *GHL;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    
    BOOL connectionOK_GH = [@"https://raw.githubusercontent.com/core-code/MiscApps/master/Diagnostics/connectiontest.txt".URL.download.string contains:@"successful"];
    BOOL connectionOK_MU = [@"https://macupdater.net/macupdater/connectiontest.txt".URL.download.string contains:@"successful"];
    BOOL connectionOK_CC = [@"https://www.corecode.io/macupdater/connectiontest.txt".URL.download.string contains:@"successful"];

    
    if (connectionOK_MU)
    {
        self.MUIV.image = @"Success".namedImage;
        self.MUL.stringValue = @"The connection to 'www.macupdater.net' works fine ;)";
    }
    else
    {
        self.MUIV.image = @"Failure".namedImage;
        self.MUL.stringValue = @"The connection to 'www.macupdater.net' DOES NOT WORK";
    }
    
    if (connectionOK_CC)
    {
        self.CCIV.image = @"Success".namedImage;
        self.CCL.stringValue = @"The connection to 'www.corecode.io' works fine ;)";
    }
    else
    {
        self.CCIV.image = @"Failure".namedImage;
        self.CCL.stringValue = @"The connection to 'www.corecode.io' DOES NOT WORK";
    }
    
    if (connectionOK_GH)
    {
        self.GHIV.image = @"Success".namedImage;
        self.GHL.stringValue = @"The connection to 'raw.githubusercontent.com' works fine ;)";
    }
    else
    {
        self.GHIV.image = @"Failure".namedImage;
        self.GHL.stringValue = @"The connection to 'raw.githubusercontent.com' DOES NOT WORK";
    }
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)ccClicked:(id)sender
{
    [@"https://www.corecode.io/macupdater/connectiontest.html".URL open];
}
- (IBAction)muClicked:(id)sender
{
    [@"https://macupdater.net/macupdater/connectiontest.html".URL open];
}
- (IBAction)ghClicked:(id)sender
{
    [@"https://raw.githubusercontent.com/core-code/MiscApps/master/Diagnostics/connectiontest.txt".URL open];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}
@end
