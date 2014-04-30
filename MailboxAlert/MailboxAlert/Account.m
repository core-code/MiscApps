//
//  Account.m
//  MailboxAlert
//
//  Created by CoreCode on 07.01.13.
//  Copyright (c) 2013 CoreCode. All rights reserved.
//

#import "Account.h"
#import "AppDelegate.h"
#import "SSKeychain.h"

@interface Account ()

@property (assign, nonatomic) int msgCount;
@property (assign, nonatomic) float msgSize;
@property (assign, nonatomic) BOOL failing;
@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) NSString *settings;
@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSURL *iconURL;
@property (strong, nonatomic) NSTimer *timer;

@end



@implementation Account

- (void)updateSettings
{
	NSString *quotastr;
	if (self.customquota && self.serverquota)
		quotastr = makeString(@"Quota: %i MB (Serverquota: %i MB)", self.customquota, self.serverquota);
	else if (self.customquota && !self.serverquota)
		quotastr = makeString(@"Quota: %i MB", self.customquota);
	else if (!self.customquota && self.serverquota)
		quotastr = makeString(@"Serverquota: %i MB", self.serverquota);


	self.settings = makeString(@"%@ Threshold: %i%% (%i MB)  Checkinterval: %i hours",
							   quotastr,
							   self.percent,
							   (int)( OBJECT_OR(self.customquota, self.serverquota) * ((float)self.percent / 100.0)),
							   self.interval);

	[notificationCenter postNotificationName:@"accountUpdate" object:nil];
//	NSLog(@"post accountUpdate update");
}

- (void)stopTimer
{
	[self.timer invalidate];
	self.timer = nil;
}

- (void)scheduleTests
{
	self.description = makeString(@"%@ | %@", self.username, self.server);

	[self updateSettings];
	
	self.status = @"Currently checking account…";
	self.iconURL = nil;

	[self stopTimer];
	[self timerTarget];

	int interval = self.interval * 60 * 60;

	self.timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(timerTarget) userInfo:nil repeats:YES];
}

- (void)timerTarget
{
	dispatch_async_back(^
	{
		NSDictionary *mb = [AppDelegate checkMailbox:@{@"username" : self.username, @"password" : self.password, @"server" : self.server}];
		self.failing = NO;

		if ([mb[@"status"] hasPrefix:@"ERR"])
		{
			self.iconURL = @"waring.png".resourceURL;

			if ([mb[@"status"] hasPrefix:@"ERRSERVER"])
				self.status = @"Server invalid or offline…";


			if ([mb[@"status"] hasPrefix:@"ERRCREDENTIALS"])
				self.status = @"Username or password invalid…";
		}
		else
		{
			if ([mb objectForKey:@"quota"] && [mb[@"quota"] intValue])
				self.serverquota = [mb[@"quota"] intValue];

			
			float quota = OBJECT_OR(self.customquota, self.serverquota);
			self.msgCount = [mb[@"count"] intValue];
			self.msgSize = [mb[@"size"] floatValue];

			NSString *time = [NSDateFormatter localizedStringFromDate:[NSDate date]
															dateStyle:NSDateFormatterNoStyle
															timeStyle:NSDateFormatterMediumStyle];
			
			if (self.msgSize > quota * ((float)self.percent / 100.0))
			{
				self.iconURL = @"error.png".resourceURL;

				self.status = makeString(@"%.1f MB (%.1f %%) used with %i messages - WARNING (%@)", self.msgSize, (self.msgSize * 100) / quota, self.msgCount, time);

				dispatch_async_main(^
				{
					[self triggerNotification];
				});
				self.failing = YES;
			}
			else
			{
				self.iconURL = @"ok.png".resourceURL;
				self.status = makeString(@"%.1f MB (%.1f %%) used with %i messages - OK (%@)", self.msgSize, (self.msgSize * 100) / quota, self.msgCount, time);
			}
		}

		
		[self updateSettings];
	});
}

- (void)triggerNotification
{
	NSString *infoString = makeString(@"The mailbox '%@' with the user-account '%@' is filled above the specified threshold (threshold: %i %@ | %i MB  actual: %.1f %@ | %.1f MB). Be sure to erase some mails as soon as possible to avoid not being able to receive mails anymore.", _server, _username, self.percent, @"%%",
									  (int)( OBJECT_OR(self.customquota, self.serverquota) * ((float)self.percent / 100.0)), (self.msgSize * 100) / OBJECT_OR(self.customquota, self.serverquota), @"%%", self.msgSize
									  );
	
	if (kNotificationOnscreenKey.defaultInt)
	{
		NSUserNotification *notification = [[NSUserNotification alloc] init];

		notification.title = @"MailboxAlert Warning";
		notification.informativeText = infoString;
		notification.hasActionButton = NO;
		notification.soundName = NSUserNotificationDefaultSoundName;

		[[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
	}

	if (kNotificationAlertKey.defaultInt)
		NSRunAlertPanel(@"MailboxAlert Warning", infoString, @"OK", nil, nil);
}

- (void)dealloc
{
    // TODO: this seems never to be called
}

- (id)initWithCoder:(NSCoder *)coder
{
	if ((self = [super init]))
	{
		NSError *error;

		_server = [coder decodeObjectForKey:@"server"];
		_username = [coder decodeObjectForKey:@"username"];
//		_password = [coder decodeObjectForKey:@"password"];

		_password = [SSKeychain passwordForService:makeString(@"mailbox://%@", self.server) account:self.username error:&error];
		if (!_password || error)
		{
			NSRunAlertPanel(@"MailboxAlert Problem", @"MailboxAlert could not retrieve your mailbox password from the system keychain. Please make sure you've allowed MailboxAlert to access the keychain and try again.", @"OK", nil, nil);
			exit(1);
		}

		_interval = [coder decodeIntForKey:@"interval"];
		_percent = [coder decodeIntForKey:@"percent"];
		_customquota = [coder decodeIntForKey:@"customquota"];
		_serverquota = [coder decodeIntForKey:@"serverquota"];
		
		[self scheduleTests];
	}

	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	// TODO: avoid 2 accounts with same server and username
	NSError *error;

    [coder encodeObject:_server forKey:@"server"];
    [coder encodeObject:_username forKey:@"username"];
//  [coder encodeObject:_password forKey:@"password"];

	if ((![[SSKeychain passwordForService:makeString(@"mailbox://%@", self.server) account:self.username] isEqualToString:_password]) &&	// not already stored
		(![SSKeychain setPassword:_password forService:makeString(@"mailbox://%@", self.server) account:self.username error:&error]))		// couldn't store it
	{
		NSRunAlertPanel(@"MailboxAlert Problem", @"MailboxAlert could not store your mailbox password securely in the system keychain. Please make sure you've allowed MailboxAlert to access the keychain and try again.", @"OK", nil, nil);
		exit(1);
	}
	
	[coder encodeInt:_interval forKey:@"interval"];
    [coder encodeInt:_percent forKey:@"percent"];
    [coder encodeInt:_customquota forKey:@"customquota"];
    [coder encodeInt:_serverquota forKey:@"serverquota"];
}
@end
