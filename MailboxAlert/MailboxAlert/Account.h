//
//  Account.h
//  MailboxAlert
//
//  Created by CoreCode on 07.01.13.
//  Copyright (c) 2013 CoreCode. All rights reserved.
//

@interface Account : NSObject

@property (readonly, strong, nonatomic) NSString *information;
@property (readonly, strong, nonatomic) NSString *settings;
@property (readonly, strong, nonatomic) NSString *status;
@property (readonly, strong, nonatomic) NSURL *iconURL;
@property (readonly, nonatomic) BOOL failing;

@property (copy, nonatomic) NSString *server;
@property (copy, nonatomic) NSString *username;
@property (copy, nonatomic) NSString *password;
@property (assign, nonatomic) int interval;
@property (assign, nonatomic) int percent;
@property (assign, nonatomic) int customquota;
@property (assign, nonatomic) int serverquota;

- (void)scheduleTests;
- (void)stopTimer;

@end
