//
//  AppDelegate.h
//  VersionsManagerDiagnosisTool
//
//  Created by Julian Mayer on 09.01.13.
//  Copyright (c) 2013 CoreCode. All rights reserved.
//


@interface AppDelegate : NSObject <NSApplicationDelegate>
{
	NSString *tmpPath;
	NSURL *tmpURL;

}

@property (assign) IBOutlet NSWindow *window;
@property (unsafe_unretained) IBOutlet NSView *box2;
@property (unsafe_unretained) IBOutlet NSView *box1;
@property (unsafe_unretained) IBOutlet NSProgressIndicator *progress;

@end
