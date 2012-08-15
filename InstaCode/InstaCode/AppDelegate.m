//
//  AppDelegate.m
//  InstaCode
//
//  Created by Julian Mayer on 31.07.12.
//  Copyright (c) 2012 CoreCode. All rights reserved.
//

#import "AppDelegate.h"

@implementation NSString(bla)
- (NSUInteger)countOccurencesOfString:(NSString *)str
{
    return [[self componentsSeparatedByString:str] count] - 1;
}
@end

@implementation AppDelegate
@synthesize resultTabView;
@synthesize progressIndicator;
@synthesize compileButton;
@synthesize compileLabel;
@synthesize runLabel;
@synthesize codeTextView;
@synthesize compilationTextView;
@synthesize outputTextView;



#define kMainPreset @"#include <stdio.h>\n\nint main() \n{\n       printf(\"hello world\");\n}"
#define kFunctionPreset @"#include <stdio.h>\n#include <unistd.h>\n\nint function(void)\n{\n	return 1;\n}\n\nint main()\n{\n	printf(\"function() returned: %i\", function());\n}"
#define kObjCPreset @"#import <Foundation/Foundation.h>\n\nint main(int argc, const char * argv[]) {\n	@autoreleasepool {\n	    NSLog(@\"Hello, World!\");\n	}\n	return 0;\n}\n"
#define kCPPPreset @"#include <iostream>\n \nusing namespace std;\n \nint main()\n{\n	cout << \"Hello World!\";\n}"

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [[NSUserDefaults standardUserDefaults] setObject:[codeTextView string] forKey:@"code"];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	if (![[NSFileManager defaultManager] fileExistsAtPath:@"/usr/bin/clang++"])
	{
		NSRunAlertPanel(@"Error", @"You need to install Xcode and its Command-Line Development tools to use InstaCode", @"D'oh", nil, nil);
		exit(1);
	}
	
    NSString *saved = [[NSUserDefaults standardUserDefaults] stringForKey:@"code"];
    if (saved && [saved length])
        [codeTextView setString:saved];
    else
        [codeTextView setString:kMainPreset];
}

- (void)runProgram
{
    runStart = [NSDate date];
    [outputTextView setString:@""];

    compiledAppTask = [[NSTask alloc] init];
	NSPipe *taskPipe = [NSPipe pipe];

    [compiledAppTask setLaunchPath:@"/tmp/InstaCode.out"];
    [compiledAppTask setStandardOutput:taskPipe];
	[compiledAppTask setStandardError:taskPipe];
    
    fileHandle = [taskPipe fileHandleForReading];
    [fileHandle waitForDataInBackgroundAndNotify];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(programStopped) name:NSTaskDidTerminateNotification object:compiledAppTask];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getData:) name:NSFileHandleDataAvailableNotification object:fileHandle];
    
    
    [compiledAppTask launch];

    //    [task waitUntilExit];
    
    //    NSData *data = [fileHandle readDataToEndOfFile];
    //    NSString *string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
}

- (void)programStopped
{
    
    NSData *data = [fileHandle readDataToEndOfFile];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    [outputTextView setString:[[outputTextView string] stringByAppendingString:string]];
    
    [[NSFileManager defaultManager] removeItemAtPath:@"/tmp/InstaCode.out" error:NULL];
    [progressIndicator stopAnimation:self];
    [compileButton setTitle:@"Compile & Run"];
    [runLabel setStringValue:[NSString stringWithFormat:@"Run: done in %.2fs (ret %i)", [[NSDate date] timeIntervalSinceDate:runStart], [compiledAppTask terminationStatus]]];

}

- (void)getData:(NSNotification *)aNotification
{
    NSData *data = [fileHandle availableData];
    NSString *outputString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [outputTextView setString:[[outputTextView string] stringByAppendingString:outputString]];
    
    
    
    if (![[compileButton title] isEqualToString:@"Compile & Run"])
    {
        [runLabel setStringValue:[NSString stringWithFormat:@"Run: currently running (%.2fs)", [[NSDate date] timeIntervalSinceDate:runStart]]];
        
        [fileHandle waitForDataInBackgroundAndNotify];
    }
}

- (IBAction)compileAndRun:(id)sender
{
    if ([[compileButton title] isEqualToString:@"Compile & Run"])
    {
        [[codeTextView string] writeToFile:@"/tmp/InstaCode.mm" atomically:YES encoding:NSUTF8StringEncoding error:NULL];
        //   NSTask
        NSTask *task = [[NSTask alloc] init];
        NSPipe *taskPipe = [NSPipe pipe];
        NSFileHandle *file = [taskPipe fileHandleForReading];
        
        [task setLaunchPath:@"/usr/bin/clang++"];
        [task setStandardOutput:taskPipe];
        [task setStandardError:taskPipe];
        
        [task setArguments:@[@"-x", @"objective-c++", @"-stdlib=libc++", @"-framework", @"Foundation", @"-O3", @"-Wall",  @"-o", @"/tmp/InstaCode.out", @"/tmp/InstaCode.mm"]];
        
        [task launch];
        
        NSDate *pre = [NSDate date];
        [task waitUntilExit];
        NSDate *post = [NSDate date];
        float compileTime = [post timeIntervalSinceDate:pre];
        
        NSData *data = [file readDataToEndOfFile];
        NSString *string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        
        [compilationTextView setString:string];
        
        [[NSFileManager defaultManager] removeItemAtPath:@"/tmp/InstaCode.mm" error:NULL];
        
        if ([task terminationStatus]) // err
        {
            [resultTabView selectFirstTabViewItem:nil];
            
            [compileLabel setStringValue:[NSString stringWithFormat:@"Compile: failed in %.2fs (%liw|%lie)", compileTime, [string countOccurencesOfString:@"warning:"], [string countOccurencesOfString:@"error:"]]];
            [runLabel setStringValue:@""];
        }
        else
        {
            [compileLabel setStringValue:[NSString stringWithFormat:@"Compile: done in %.2fs (%liw)", compileTime, [string countOccurencesOfString:@"warning:"]]];
            [runLabel setStringValue:@"Run: currently running"];
            [progressIndicator startAnimation:self];
            [compileButton setTitle:@"Stop"];
            
            [resultTabView selectLastTabViewItem:nil];
            [self runProgram];
        }
    }
    else if ([[compileButton title] isEqualToString:@"Stop"])
    {        
        [compileButton setTitle:@"Compile & Run"];

        [compiledAppTask terminate];
    }
    else
        assert(0);
}

- (IBAction)choosePreset:(id)sender
{
    if ([[sender title] isEqualToString:@"Main"])
        [codeTextView setString:kMainPreset];
    else if ([[sender title] isEqualToString:@"Function"])
        [codeTextView setString:kFunctionPreset];
    else if ([[sender title] isEqualToString:@"Obj-C"])
        [codeTextView setString:kObjCPreset];
    else if ([[sender title] isEqualToString:@"C++"])
        [codeTextView setString:kCPPPreset];
}
@end