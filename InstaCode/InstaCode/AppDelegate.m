//
//  AppDelegate.m
//  InstaCode
//
//  Created by CoreCode on 31.07.12.
/*	Copyright © 2017 CoreCode Limited
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "AppDelegate.h"
#import "CoreLib.h"

CONST_KEY(Runs)
CONST_KEY(Project)
CONST_KEY(NextNag)
CONST_KEY(NagCount)
CONST_KEY(XCodeVersions)
CONST_KEY(XCode)

#import "MGSFragaria.h"
#import "MGSPreferencesController.h"

@implementation AppDelegate

+ (void)initialize
{
	[[NSUserDefaults standardUserDefaults] registerDefaults:@{kProjectKey : @"#include <stdio.h>\n\nint main() \n{\n       printf(\"hello world\");\n}",
												  kRunsKey : @(1), kNextNagKey : @(40), kNagCountKey : @(1)}];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	cc = [CoreLib new];
	
	self.presetsNames = [@[@"Preset:"] arrayByAddingObjectsFromArray:[@[cc.resDir, @"Presets"].path.dirContents mapped:^(id input){return [input replaced:@".txt" with:@""];}]];
	self.snippetNames = [@[@"Snippets:"] arrayByAddingObjectsFromArray:[@[cc.resDir, @"Snippets"].path.dirContents mapped:^(id input){return [input replaced:@".txt" with:@""];}]];

	[_compilationTextView setFont:[NSFont fontWithName:@"Menlo" size:12]];

	
	// create an syntax highlight instance
	fragaria = [[MGSFragaria alloc] init];
	[fragaria setObject:self forKey:MGSFODelegate];
	[fragaria setObject:@"Objective-C" forKey:MGSFOSyntaxDefinitionName];
	[fragaria embedInView:self.contentView];
	MGSFragariaPrefsAutocompleteSuggestAutomatically.defaultInt = YES;
	[fragaria setString:kProjectKey.defaultString];
	dirty = YES;
	[self textDidChange:nil];
	
	
	// check xcode versions
	NSArray *xcodeVersions = [[@"/Applications".dirContents filteredUsingPredicateString:@"self BEGINSWITH[cd] 'Xcode'"] filtered:^BOOL(NSString *s){return makeString(@"/Applications/%@/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/ToolchainInfo.plist", s).fileExists;}];
	if (xcodeVersions.empty)
	{
		NSRunAlertPanel(@"Error", @"You need to install Xcode to use InstaCode.\n\nIt is a free download on the Mac App Store.\n\nIf you already have it installed, make sure it is in your /Applications folder and its name still begins with 'Xcode'.", @"OK", nil, nil);
		[@"https://itunes.apple.com/en/app/xcode/id497799835?mt=12".URL open];
		exit(1);
	}
	if (!kXCodeKey.defaultString.length)
		kXCodeKey.defaultString = xcodeVersions[0];
	kXCodeVersionsKey.defaultObject = xcodeVersions;

	
	// first start
	if (kRunsKey.defaultInt == 1)
	{
		[self openURL:@{@"tag" : @(2)}];
		kRunsKey.defaultInt = 2;
	}
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	kProjectKey.defaultString = [fragaria string];
}

#pragma mark IBAction

- (IBAction)showPreferencesWindow:(id)sender
{    
    [[MGSPreferencesController sharedPrefsWindowController] showWindow:self];
}

- (IBAction)openURL:(id)sender
{
	int tag = [[sender valueForKey:@"tag"] intValue];
    
	if (tag == 1)
		[makeString(@"mailto:feedback@corecode.io?subject=%@ %@ Feedback", cc.appName, cc.appVersionString).escaped.URL open];
	else if (tag == 2)
		[@"Read Me.rtf".resourceURL open];
	else if (tag == 3)
		[makeString(@"https://www.corecode.io/%@/", cc.appName.lowercaseString).escaped.URL open];
}

- (IBAction)compileAndRun:(id)sender
{
    if ([[_compileButton title] isEqualToString:@"Compile & Run"])
    {
		kRunsKey.defaultInt = kRunsKey.defaultInt+1;

        [[fragaria string] writeToURL:[cc.suppURL add:@"InstaCode.mm"] atomically:YES encoding:NSUTF8StringEncoding error:NULL];

		NSArray *args = @[makeString(@"/Applications/%@/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang++", kXCodeKey.defaultString), @"-x", @"objective-c++", @"-stdlib=libc++", @"-isysroot", makeString(@"/Applications/%@/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.%i.sdk", kXCodeKey.defaultString, [self checkSDKVersion]), @"-framework", @"Foundation", @"-framework", @"AppKit", @"-framework", @"QuartzCore", @"-O3", @"-Wall", @"-o", [cc.suppURL add:@"InstaCode.out"].path, [cc.suppURL add:@"InstaCode.mm"].path];
	
        NSInteger terminationStatus;
        NSDate *pre = [NSDate date];
        NSString *string = [args runAsTaskWithTerminationStatus:&terminationStatus];
        float compileTime = [[NSDate date] timeIntervalSinceDate:pre];

        
        [_compilationTextView setString:string];
        
        [[NSFileManager defaultManager] removeItemAtURL:[cc.suppURL add:@"InstaCode.mm"] error:NULL];
        
        if (terminationStatus) // err
        {
            [_resultTabView selectFirstTabViewItem:nil];
            
            [_compileLabel setStringValue:makeString(@"Compile: failed in %.2fs (%liw|%lie)", compileTime, [string countOccurencesOfString:@"warning:"], [string countOccurencesOfString:@"error:"])];
            [_runLabel setStringValue:@""];
			
			for (NSString *line in string.lines)
			{
				if ([line contains:@"InstaCode"] && [line contains:@" error: "])
				{
					int row = [[line split:@":"][1] intValue];
					int col = [[line split:@":"][2] intValue];
					
					int range = 0, i = 0;
					for (NSString *l in [fragaria string].lines)
					{
						i++;
						if (i == row)
						{
							[[fragaria textView] setSelectedRange:NSMakeRange(range+col-1, 1)];
							[[fragaria textView] scrollRangeToVisible:NSMakeRange(range+col-1, 1)];
							break;
						}
						range += [l length]+1;
					}
					break;
				}
			}
        }
        else
        {
            [_compileLabel setStringValue:[NSString stringWithFormat:@"Compile: done in %.2fs (%li warnings)", compileTime, [string countOccurencesOfString:@"warning:"]]];
            [_runLabel setStringValue:@"Run: currently running"];
            [_progressIndicator startAnimation:self];
            [_compileButton setTitle:@"Stop"];
            
            [_resultTabView selectLastTabViewItem:nil];
            [self runProgram];
        }
    }
    else if ([[_compileButton title] isEqualToString:@"Stop"])
    {
        [_compileButton setTitle:@"Compile & Run"];

        [compiledAppTask terminate];
    }
    else
        assert(0);
}

- (IBAction)chooseGoto:(id)sender
{
	NSRange r = NSRangeFromString(_gotoRanges[[sender indexOfSelectedItem]-1]);
	[[fragaria textView] setSelectedRange:r];
	[[fragaria textView] scrollRangeToVisible:r];

}

- (IBAction)chooseSnippet:(id)sender
{
	int level = 0;
	NSArray *ranges = [[fragaria textView] selectedRanges];
	if ([ranges count])
	{
		NSInteger insertionPoint = [[ranges objectAtIndex:0] rangeValue].location;
		for (NSInteger i = MIN(insertionPoint, [[fragaria string] length]-1); i >= 0; i--)
		{
			char c = [[fragaria string] characterAtIndex:i];
			if (c == '{') level++;
			if (c == '}') level--;
		}
	}
	
	NSString *path = [[cc.resDir stringByAppendingPathComponent:@"Snippets"] stringByAppendingPathComponent:[[[sender selectedItem] title] stringByAppendingString:@".txt"]];
	NSString *str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];

	
	[[fragaria textView] insertText:[[str.lines mapped:^id(NSString *s){ for (int i = 0; i < level; i++) s = [@"\t" stringByAppendingString:s]; return s;}] joined:@"\n"]];
}

- (IBAction)choosePreset:(id)sender
{
	if (!dirty || (dirty && alert(@"InstaCode", @"Choosing a new preset will erase your current project.", @"Continue", @"Cancel", nil) == NSAlertFirstButtonReturn))
	{
		NSURL *path = [[cc.resURL add:@"Presets"] add:[[[sender selectedItem] title] stringByAppendingString:@".txt"]];
		NSString *str = [NSString stringWithContentsOfURL:path encoding:NSUTF8StringEncoding error:NULL];
		[fragaria setString:str];
		[self textDidChange:nil];
		dirty = FALSE;
	}
}

#pragma mark NSTextDelegate

- (void)textDidChange:(NSNotification *)notification
{
	dirty = TRUE;
	
	NSMutableArray *tmp = @[@"Goto:"].mutableObject;
	NSMutableArray *tmpRanges = [NSMutableArray new];

	int level = 0;

	for (NSString *line in [fragaria string].lines)
	{
		if (level == 0)
		{
			if ([line hasPrefix:@"-"] || [line hasPrefix:@"+"] || [[[line split:@"{"][0] trimmedOfWhitespace] hasSuffix:@")"])
			{
				[tmp addObject:[line split:@"{"][0]];

				[tmpRanges addObject:NSStringFromRange([[fragaria string] rangeOfString:line])];
			}
		}
		
		for (int i = 0; i < [line length]; i++)
		{
			char c = [line characterAtIndex:i];
			if (c == '{') level++;
			if (c == '}') level--;
		}
	}
	
	self.gotoRanges = tmpRanges.immutableObject;
	self.gotoNames = tmp.immutableObject;
}

- (BOOL)textShouldBeginEditing:(NSText *)aTextObject
{
	return YES;
}

- (BOOL)textShouldEndEditing:(NSText *)aTextObject
{
	return YES;
}

#pragma mark Private

- (void)runProgram
{
    runStart = [NSDate date];
    [_outputTextView setString:@""];
	
    compiledAppTask = [[NSTask alloc] init];
	NSPipe *taskPipe = [NSPipe pipe];
	
    [compiledAppTask setLaunchPath:[cc.suppURL add:@"InstaCode.out"].path];
    [compiledAppTask setStandardOutput:taskPipe];
	[compiledAppTask setStandardError:taskPipe];
    
    fileHandle = [taskPipe fileHandleForReading];
    [fileHandle waitForDataInBackgroundAndNotify];
	
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(programStopped) name:NSTaskDidTerminateNotification object:compiledAppTask];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getData:) name:NSFileHandleDataAvailableNotification object:fileHandle];
    
    
    [compiledAppTask launch];
}

- (void)programStopped
{
    NSData *data = [fileHandle readDataToEndOfFile];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    [_outputTextView setString:[[_outputTextView string] stringByAppendingString:string]];
    
    [[NSFileManager defaultManager] removeItemAtURL:[cc.suppURL add:@"InstaCode.out"] error:NULL];
    [_progressIndicator stopAnimation:self];
    [_compileButton setTitle:@"Compile & Run"];
    [_runLabel setStringValue:[NSString stringWithFormat:@"Run: done in %.2fs (return %i)", [[NSDate date] timeIntervalSinceDate:runStart], [compiledAppTask terminationStatus]]];
}

- (void)getData:(NSNotification *)aNotification
{
    NSData *data = [fileHandle availableData];
    NSString *outputString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [_outputTextView setString:[[_outputTextView string] stringByAppendingString:outputString]];
    
    
    if (![[_compileButton title] isEqualToString:@"Compile & Run"])
    {
        [_runLabel setStringValue:[NSString stringWithFormat:@"Run: currently running (%.2fs)", [[NSDate date] timeIntervalSinceDate:runStart]]];
        
        [fileHandle waitForDataInBackgroundAndNotify];
    }
}

- (int)checkSDKVersion
{
    int sdkVer;
    for (sdkVer = 20; sdkVer >= 0; sdkVer--) // we are save until Mac OS X 10.20 ;->
        if (makeString(@"/Applications/%@/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.%i.sdk", kXCodeKey.defaultString, sdkVer).fileExists)
            break;
    
    if (!sdkVer)
    {
        NSRunAlertPanel(@"Error", @"Fatal Error", @"D'oh", nil, nil);
        exit(1);
    }
	
	return sdkVer;
}
@end

int main(int argc, char *argv[])
{
    return NSApplicationMain(argc, (const char **)argv);
}
