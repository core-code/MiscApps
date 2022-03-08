//
//  SleepLog.m
//  SleepLog
//
//  Created by CoreCode on 05/11/2017.
//  Copyright © 2020 CoreCode Limited. All rights reserved.
//

#import "SleepLog.h"
#import "CoreLib.h"


@interface SleepLog ()

@end



@implementation SleepLog

- (instancetype)init
{
    if ((self = [super init]))
    {
        let nc = NSWorkspace.sharedWorkspace.notificationCenter;
        [nc addObserver:self selector:@selector(receiveNotification:) name:NSWorkspaceWillSleepNotification object:NULL];
        [nc addObserver:self selector:@selector(receiveWakeNotification:) name:NSWorkspaceDidWakeNotification object:NULL];
//        [nc addObserver:self selector:@selector(receiveNotification:) name:NSWorkspaceScreensDidSleepNotification object:NULL];
//        [nc addObserver:self selector:@selector(receiveWakeNotification:) name:NSWorkspaceScreensDidWakeNotification object:NULL];
//        [nc addObserver:self selector:@selector(receiveNotification:) name:NSWorkspaceWillPowerOffNotification object:NULL];
//        [nc addObserver:self selector:@selector(receiveNotification:) name:NSWorkspaceSessionDidBecomeActiveNotification object:NULL];
//        [nc addObserver:self selector:@selector(receiveNotification:) name:NSWorkspaceSessionDidResignActiveNotification object:NULL];
    }
    return self;
}


- (void)receiveNotification:(NSNotification *)not
{
    cc_log(@"%@", not.name);
}

- (void)receiveWakeNotification:(NSNotification *)not
{
   cc_log(@"%@", not.name);
    [[NSSound soundNamed:@"Sosumi"] play];
}
@end
