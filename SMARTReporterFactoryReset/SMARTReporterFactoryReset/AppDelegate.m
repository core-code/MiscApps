//
//  AppDelegate.m
//  SMARTReporterFactoryReset
//
//  Created by CoreCode on 13/03/2017.
//  Copyright © 2018 CoreCode Limited. All rights reserved.
//

#import "AppDelegate.h"
#import "CoreLib.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *label1;
@property (weak) IBOutlet NSTextField *label2;
@property (weak) IBOutlet NSTextField *label3;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    cc = [CoreLib new];
    [self updateStatus];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    [fileManager removeItemAtPath:@"~/Library/Preferences/com.corecode.SMARTReporterFactoryReset.plist".stringByExpandingTildeInPath error:NULL];
}

- (void)updateStatus
{
    if (@"/Library/Preferences/com.corecode.SMARTReporter.plist".fileExists || @"/Library/Preferences/com.corecode.SMARTReporter-DEMO.plist".fileExists)
        self.label1.stringValue = @"Global Preferences File: PRESENT ON DISK";
    else
        self.label1.stringValue = @"Global Preferences File: NOT PRESENT ON DISK";


    if (@"~/Library/Preferences/com.corecode.SMARTReporter.plist".stringByExpandingTildeInPath.fileExists || @"~/Library/Preferences/com.corecode.SMARTReporter-DEMO.plist".stringByExpandingTildeInPath.fileExists)
        self.label2.stringValue = @"Local Preferences File: PRESENT ON DISK";
    else
        self.label2.stringValue = @"Local Preferences File: NOT PRESENT ON DISK";


    if (@"~/Library/Application Support/SMARTReporter/".stringByExpandingTildeInPath.fileExists || @"~/Library/Application Support-DEMO/SMARTReporter/".stringByExpandingTildeInPath.fileExists)
        self.label3.stringValue = @"Application Support Folder: PRESENT ON DISK";
    else
        self.label3.stringValue = @"Application Support Folder: NOT PRESENT ON DISK";
}

- (IBAction)removeAll:(id)sender
{
    [@[@"/usr/bin/killall", @"SMARTReporter"] runAsTask];


    if (@"/Library/Preferences/com.corecode.SMARTReporter.plist".fileExists)
    {
        NSError *error;
        BOOL result;

        result = [fileManager removeItemAtPath:@"/Library/Preferences/com.corecode.SMARTReporter.plist"
                                         error:&error];

        if (!result || error)
            alert_apptitled(makeString(@"Error: could not remove global preferences file (reason %@", error.description),
                            @"D'Oh", nil, nil);
    }
    if (@"/Library/Preferences/com.corecode.SMARTReporter-DEMO.plist".fileExists)
    {
        NSError *error;
        BOOL result;
        
        result = [fileManager removeItemAtPath:@"/Library/Preferences/com.corecode.SMARTReporter-DEMO.plist"
                                         error:&error];
        
        if (!result || error)
            alert_apptitled(makeString(@"Error: could not remove global demo preferences file (reason %@", error.description),
                            @"D'Oh", nil, nil);
    }
    if (@"~/Library/Preferences/com.corecode.SMARTReporter.plist".stringByExpandingTildeInPath.fileExists)
    {
        NSError *error;
        BOOL result;

        result = [fileManager removeItemAtPath:@"~/Library/Preferences/com.corecode.SMARTReporter.plist".stringByExpandingTildeInPath
                                         error:&error];

        if (!result || error)
            alert_apptitled(makeString(@"Error: could not remove local preferences file (reason %@", error.description),
                            @"D'Oh", nil, nil);
    }
    if (@"~/Library/Preferences/com.corecode.SMARTReporter-DEMO.plist".stringByExpandingTildeInPath.fileExists)
    {
        NSError *error;
        BOOL result;
        
        result = [fileManager removeItemAtPath:@"~/Library/Preferences/com.corecode.SMARTReporter-DEMO.plist".stringByExpandingTildeInPath
                                         error:&error];
        
        if (!result || error)
            alert_apptitled(makeString(@"Error: could not remove local demo preferences file (reason %@", error.description),
                            @"D'Oh", nil, nil);
    }
    if (@"~/Library/Application Support/SMARTReporter/".stringByExpandingTildeInPath.fileExists)
    {
        NSError *error;
        BOOL result;

        result = [fileManager removeItemAtPath:@"~/Library/Application Support/SMARTReporter/".stringByExpandingTildeInPath
                                         error:&error];

        if (!result || error)
            alert_apptitled(makeString(@"Error: could not remove application support directory (reason %@", error.description),
                            @"D'Oh", nil, nil);
    }
    if (@"~/Library/Application Support/SMARTReporter-DEMO/".stringByExpandingTildeInPath.fileExists)
    {
        NSError *error;
        BOOL result;
        
        result = [fileManager removeItemAtPath:@"~/Library/Application Support/SMARTReporter/".stringByExpandingTildeInPath
                                         error:&error];
        
        if (!result || error)
            alert_apptitled(makeString(@"Error: could not remove demo application support directory (reason %@", error.description),
                            @"D'Oh", nil, nil);
    }

    [@[@"/usr/bin/killall", @"-SIGTERM", @"cfprefsd"] runAsTask];

    [self updateStatus];
    [userDefaults synchronize];
}

@end


int main(int argc, const char * argv[])
{
    return NSApplicationMain(argc, argv);
}
