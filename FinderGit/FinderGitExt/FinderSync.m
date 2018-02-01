//
//  FinderSync.m
//  VCSExt
//
//  Created by CoreCode on 18.05.15.
/*	Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
#import "FinderSync.h"

@interface FinderSync ()

@end

// this should fix the dropbox problem
//"pluginkit", "-e", "ignore", "-i", "com.getdropbox.dropbox.garcon"
//"pluginkit", "-e", "use", "-i", "com.corecode.VCS.VCSExt"
//"pluginkit", "-e", "use", "-i", "com.getdropbox.dropbox.garcon"


@implementation FinderSync

- (instancetype)init
{
    self = [super init];

    cc = [CoreLib new];

    cc_log(@"%s launched from %@ ; compiled at %s", __PRETTY_FUNCTION__, [[NSBundle mainBundle] bundlePath], __TIME__);

    LOG(@"bin/git".resourcePath);

    
    
    [FIFinderSyncController defaultController].directoryURLs = @[@"~/Documents/".expanded.fileURL].set;


    [[FIFinderSyncController defaultController] setBadgeImage:[NSImage imageNamed:@"green"] label:@"green" forBadgeIdentifier:@"green"];
    [[FIFinderSyncController defaultController] setBadgeImage:[NSImage imageNamed:@"yellow"] label:@"yellow" forBadgeIdentifier:@"yellow"];
    [[FIFinderSyncController defaultController] setBadgeImage:[NSImage imageNamed:@"grey"] label:@"grey" forBadgeIdentifier:@"grey"];
    [[FIFinderSyncController defaultController] setBadgeImage:[NSImage imageNamed:@"red"] label:@"red" forBadgeIdentifier:@"red"];


    
    return self;
}

#pragma mark - Primary Finder Sync protocol methods

- (void)beginObservingDirectoryAtURL:(NSURL *)url
{
    // The user is now seeing the container's contents.
    // If they see it in more than one view at a time, we're only told once.
    cc_log(@"beginObservingDirectoryAtURL:%@", url.filePathURL);
}


- (void)endObservingDirectoryAtURL:(NSURL *)url
{
    // The user is no longer seeing the container's contents.
    cc_log(@"endObservingDirectoryAtURL:%@", url.filePathURL);
}

- (void)requestBadgeIdentifierForURL:(NSURL *)url
{
    NSURL *origURL = url;
    cc_log(@"requestBadgeIdentifierForURL:%@", url.filePathURL);

    
    if (!url.filePathURL.fileIsDirectory)
        url = url.URLByDeletingLastPathComponent;

    NSURL *origURLDir = url;

    
    BOOL foundGit = 0;
    while (![url.path isEqualToString:@"/"])
    {
        NSURL *possibleGitDir = [url URLByAppendingPathComponent:@".git"];
//        LOG(url);


        if (possibleGitDir.fileExists)
        {
            assert(possibleGitDir.directoryContents.count);
            foundGit = YES;
            break;
        }
        
        url = url.URLByDeletingLastPathComponent;
    }

    if (foundGit)
    {
       NSTask *task = [NSTask new];
       NSPipe *taskPipe = [NSPipe pipe];
       NSFileHandle *file = [taskPipe fileHandleForReading];

       [task setLaunchPath:@"bin/git".resourcePath];
       [task setStandardOutput:taskPipe];
       [task setStandardError:taskPipe];
       [task setCurrentDirectoryPath:origURLDir.path];
       [task setArguments:@[@"status", origURL.path]];

       [task launch];


       NSData *data = [file readDataToEndOfFile];

       [task waitUntilExit];
       
       NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

        if (!origURL.filePathURL.fileIsDirectory)
        {
            if ([string contains:@"nothing to commit"])
            {
                [[FIFinderSyncController defaultController] setBadgeIdentifier:@"green" forURL:origURL];
            }
            else if ([string contains:@"Untracked files:"])
            {
                [[FIFinderSyncController defaultController] setBadgeIdentifier:@"grey" forURL:origURL];
            }
            else if ([string contains:@"modified:"])
            {
                [[FIFinderSyncController defaultController] setBadgeIdentifier:@"yellow" forURL:origURL];
            }
            else
            {
                [[FIFinderSyncController defaultController] setBadgeIdentifier:@"red" forURL:origURL];
            }
        }
        else
        {
            if ([string contains:@"modified:"])
            {
                [[FIFinderSyncController defaultController] setBadgeIdentifier:@"yellow" forURL:origURL];
            }
            else
                [[FIFinderSyncController defaultController] setBadgeIdentifier:@"green" forURL:origURL];
            
        }
    }
    else
    {
    
    }
}

#pragma mark - Menu and toolbar item support

- (NSString *)toolbarItemName
{
    return @"VCSExt";
}

- (NSString *)toolbarItemToolTip
{
    return @"VCSExt: Click the toolbar item for a menu.";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNameCaution];
}

- (NSMenu *)menuForMenuKind:(FIMenuKind)whichMenu
{
    // Produce a menu for the extension.
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@""];
    [menu addItemWithTitle:@"Push (Directory)" action:@selector(sampleAction:) keyEquivalent:@""];
    [menu addItemWithTitle:@"Pull(Directory)" action:@selector(sampleAction:) keyEquivalent:@""];
    [menu addItemWithTitle:@"Stash (Directory)" action:@selector(sampleAction:) keyEquivalent:@""];
    
    [menu addItemWithTitle:@"Commit (File)" action:@selector(sampleAction:) keyEquivalent:@""];
    [menu addItemWithTitle:@"Revert (File)" action:@selector(sampleAction:) keyEquivalent:@""];
    [menu addItemWithTitle:@"Log (File)" action:@selector(sampleAction:) keyEquivalent:@""];
    
    return menu;
}

- (IBAction)sampleAction:(id)sender
{
    NSURL* target = [[FIFinderSyncController defaultController] targetedURL];
    NSArray* items = [[FIFinderSyncController defaultController] selectedItemURLs];

    cc_log(@"sampleAction: menu item: %@, target = %@, items = ", [sender title], [target filePathURL]);
    [items enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop)
    {
        cc_log(@"    %@", [obj filePathURL]);
    }];
}
@end

//green
//•	' ' = unmodified
//•	I = ignored
//
//yellow
//•	M = modified
//•	A = added
//•	D = deleted
//
//red:
//• C conflict/unmerged
//
//grey
//•	? = untracked
