//
//  AppDelegate.h
//  MailboxAlert
//
//  Created by CoreCode on 06.01.13.
//  Copyright (c) 2013 CoreCode. All rights reserved.
//

CONST_KEY_DECLARATION(NotificationAlert)
CONST_KEY_DECLARATION(NotificationOnscreen)
CONST_KEY_DECLARATION(NotificationMenubar)


@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign, nonatomic) IBOutlet NSWindow *window;

+ (NSDictionary *)checkMailbox:(NSDictionary *)account;

@end

