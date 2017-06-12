//
//  FinderSync.m
//  VCSExt
//
//  Created by CoreCode on 18.05.15.
//  Copyright © 2017 CoreCode Limited. All rights reserved.
//

#import "FinderSync.h"

@interface FinderSync ()

@property NSURL *myFolderURL;

@end



@implementation FinderSync

- (instancetype)init
{
    self = [super init];

    cc = [CoreLib new];

    cc_log_debug(@"%s launched from %@ ; compiled at %s", __PRETTY_FUNCTION__, [[NSBundle mainBundle] bundlePath], __TIME__);


    // Set up the directory we are syncing.
    self.myFolderURL = [NSURL fileURLWithPath:@"/Applications"];
    [FIFinderSyncController defaultController].directoryURLs = [NSSet setWithObject:self.myFolderURL];

    // Set up images for our badge identifiers. For demonstration purposes, this uses off-the-shelf images.
    [[FIFinderSyncController defaultController] setBadgeImage:[NSImage imageNamed:@"green"] label:@"green" forBadgeIdentifier:@"green"];
    [[FIFinderSyncController defaultController] setBadgeImage:[NSImage imageNamed:@"yellow"] label:@"yellow" forBadgeIdentifier:@"yellow"];
    [[FIFinderSyncController defaultController] setBadgeImage:[NSImage imageNamed:@"red"] label:@"red" forBadgeIdentifier:@"red"];

    
    return self;
}

#pragma mark - Primary Finder Sync protocol methods

- (void)beginObservingDirectoryAtURL:(NSURL *)url
{
    cc_log_debug(@"beginObservingDirectoryAtURL:%@", url.filePathURL);  // The user is now seeing the container's contents. - If they see it in more than one view at a time, we're only told once.
}


- (void)endObservingDirectoryAtURL:(NSURL *)url
{
    cc_log_debug(@"endObservingDirectoryAtURL:%@", url.filePathURL);    // The user is no longer seeing the container's contents.
}

- (NSString *)hashNameForApp:(NSURL *)url
{
    NSString *infoPlistPath = [url.path stringByAppendingPathComponent:@"Contents/Info.plist"];
    NSData *infoData = infoPlistPath.contents;
    NSString *infoSHA = infoData.SHA1;
    @try
    {
        NSDictionary* plist = [NSPropertyListSerialization propertyListWithData:infoData options:NSPropertyListImmutable format:nil error:NULL];
        NSString *binaryName = plist[@"CFBundleExecutable"];
        NSString *binaryPath = [url.path stringByAppendingPathComponent:@"Contents/MacOS/"];
        binaryPath = [url.path stringByAppendingPathComponent:binaryName];
        unsigned long long binaryFileSize = binaryName.fileSize;

        NSString *hash = makeString(@"%@%@%@", url.path, infoSHA, @(binaryFileSize));
        
        return hash;
    }
    @catch (NSException *exception)
    {
    }

    return nil;
}

- (NSString *)signingOfApp:(NSURL *)url
{
    NSTask *task = [NSTask new];
    NSPipe *taskPipe = [NSPipe pipe];
    NSFileHandle *file = [taskPipe fileHandleForReading];
    [task setLaunchPath:@"/usr/bin/codesign"];
    [task setStandardOutput:taskPipe];
    [task setStandardError:taskPipe];
    [task setCurrentDirectoryPath:url.URLByDeletingLastPathComponent.path];
    [task setArguments:@[@"--verify", @"-v", url.path]];
    [task launch];
    NSData *data = [file readDataToEndOfFile];
    [task waitUntilExit];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSString *)entitlementsOfApp:(NSURL *)url
{
    NSTask *task = [NSTask new];
    NSPipe *taskPipe = [NSPipe pipe];
    NSFileHandle *file = [taskPipe fileHandleForReading];
    [task setLaunchPath:@"/usr/bin/codesign"];
    [task setStandardOutput:taskPipe];
    [task setStandardError:taskPipe];
    [task setCurrentDirectoryPath:url.URLByDeletingLastPathComponent.path];
    [task setArguments:@[@"-d", @"--entitlements", @":-", url.path]];
    [task launch];
    NSData *data = [file readDataToEndOfFile];
    [task waitUntilExit];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (void)requestBadgeIdentifierForURL:(NSURL *)url
{
    cc_log_debug(@"requestBadgeIdentifierForURL:%@", url.filePathURL);


    if ([url.path hasSuffix:@".app"])
    {
        NSString *hashName = [self hashNameForApp:url];
        NSInteger cachedValue = hashName ? hashName.defaultInt : 0;


        if (!cachedValue)   // don't know yet, update
        {
            hashName.defaultInt = 1; // not even signed

            NSString *signing = [self signingOfApp:url];

            if ([signing contains:@"satisfies its Designated Requirement"])
            {
                NSString *entitlements = [self entitlementsOfApp:url];

                hashName.defaultInt = 2; // not sandboxed

                if ([entitlements contains:@"<?xml"])
                {
                    NSString *plistString = [@"<?xml" stringByAppendingString:[entitlements split:@"<?xml"][1]];
                    NSData* plistData = [plistString dataUsingEncoding:NSUTF8StringEncoding];
                    NSError *error;
                    NSDictionary* plist = [NSPropertyListSerialization propertyListWithData:plistData options:NSPropertyListImmutable format:nil error:&error];


                    NSNumber *bla = plist[@"com.apple.security.app-sandbox"];
                    if (plist && !error)
                    {
    //                    [[FIFinderSyncController defaultController] openURL:origURL completionHandler:^(BOOL success)
    //                     {
    //
    //                     }];

                        if (bla.boolValue)
                        {
                            [[FIFinderSyncController defaultController] setBadgeIdentifier:@"green" forURL:url];
                            hashName.defaultInt = 3; // sandboxed
                        }
                        else
                            [[FIFinderSyncController defaultController] setBadgeIdentifier:@"yellow" forURL:url];
                    }
                    else
                        [[FIFinderSyncController defaultController] setBadgeIdentifier:@"yellow" forURL:url];
                }
                else
                    [[FIFinderSyncController defaultController] setBadgeIdentifier:@"yellow" forURL:url];
            }
            else
                [[FIFinderSyncController defaultController] setBadgeIdentifier:@"red" forURL:url];
        }
        else if (cachedValue == 1) // not even signed
            [[FIFinderSyncController defaultController] setBadgeIdentifier:@"red" forURL:url];
        else if (cachedValue == 2) //  not sandboxed
            [[FIFinderSyncController defaultController] setBadgeIdentifier:@"yellow" forURL:url];
       else if (cachedValue == 3) //  sandboxed
            [[FIFinderSyncController defaultController] setBadgeIdentifier:@"green" forURL:url];
    }
}
@end
