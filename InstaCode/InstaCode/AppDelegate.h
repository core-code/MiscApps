//
//  AppDelegate.h
//  InstaCode
//
//  Created by Julian Mayer on 31.07.12.
//  Copyright (c) 2012 CoreCode. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    NSFileHandle *fileHandle;
    NSTask *compiledAppTask;
    NSDate *runStart;
}
@property (assign) IBOutlet NSWindow *window;
@property (unsafe_unretained) IBOutlet NSTextView *codeTextView;
@property (unsafe_unretained) IBOutlet NSTextView *compilationTextView;
@property (unsafe_unretained) IBOutlet NSTextView *outputTextView;
@property (unsafe_unretained) IBOutlet NSTabView *resultTabView;
@property (unsafe_unretained) IBOutlet NSProgressIndicator *progressIndicator;
@property (unsafe_unretained) IBOutlet NSButton *compileButton;
@property (unsafe_unretained) IBOutlet NSTextField *compileLabel;
@property (unsafe_unretained) IBOutlet NSTextField *runLabel;

- (IBAction)compileAndRun:(id)sender;
- (IBAction)choosePreset:(id)sender;
@end
