//
//  AppDelegate.m
//  MovieCutter
//
//  Created by CoreCode on 14.01.14.
/*	Copyright (c) 2014 CoreCode
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import "AppDelegate.h"

int durationSecs;

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	cc = [CoreLib new];

	@"sourceMovie".defaultObject = nil;
	@"cutStart".defaultInt = 120;
	@"cutDuration".defaultInt = 10;
	@"fileDescription".defaultString = @"";
}

- (IBAction)fileChosen:(id)sender
{
	NSURL *movie = [NSKeyedUnarchiver unarchiveObjectWithData:@"sourceMovie".defaultObject];
	NSString *res = @[[[NSBundle mainBundle] pathForResource:@"ffmpeg" ofType:nil],
					  @"-i",
					  movie.path,
					].runAsTask;
	
	NSString *duration = [[[res split:@"Duration: "][1] split:@","][0] split:@"."][0];

	durationSecs = [[duration split:@":"][0] intValue] * 3600 +
					[[duration split:@":"][1] intValue] * 60 +
					[[duration split:@":"][2] intValue];
	unsigned long long size = movie.fileSize;

	NSString *desc = makeString(@"Duration: %@  (%i seconds)\nFilesize: %lluMB", duration, durationSecs, (size / (1024 * 1024)));

	@"fileDescription".defaultString = desc;

}

- (IBAction)cutMovie:(id)sender
{
	[self.window endEditingFor:nil];

	if (! @"sourceMovie".defaultObject )
	{
		alert_apptitled(@"you need to select a movie", @"OK", nil, nil);
		return;
	}

	NSURL *movie = [NSKeyedUnarchiver unarchiveObjectWithData:@"sourceMovie".defaultObject];
	if (!movie.fileExists)
	{
		alert_apptitled(@"you need to select a movie", @"OK", nil, nil);
		return;
	}

	if (@"cutStart".defaultInt + @"cutDuration".defaultInt > durationSecs)
	{
		alert_apptitled(makeString(@"the movie only has %i seconds", durationSecs), @"OK", nil, nil);
		return;
	}



	NSSavePanel *panel = [NSSavePanel savePanel];

	[panel setExtensionHidden:NO];
	[panel setAllowedFileTypes:@[movie.pathExtension]];
	[panel setDirectoryURL:cc.deskURL];
	[panel setNameFieldStringValue:[[[movie URLByDeletingPathExtension] lastPathComponent] stringByAppendingString:@"-cut"]];

	[panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result)
	 {
		 if (result == NSFileHandlingPanelOKButton)
		 {
			 NSPanel *progressPanel = [[NSPanel alloc]
							   initWithContentRect:NSMakeRect(0, 0, 120, 40)
							   styleMask:NSTitledWindowMask
							   backing:NSBackingStoreBuffered
							   defer:YES];

			 [NSApp beginSheet:progressPanel
				modalForWindow:self.window
				 modalDelegate:nil
				didEndSelector:nil
				   contextInfo:NULL];

			 NSProgressIndicator *ind = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(10, 10, 100, 20)];
			 [ind setIndeterminate:YES];
			 [ind startAnimation:self];
			 [[progressPanel contentView] addSubview:ind];
			 dispatch_async_back(^
			 {

				 NSString *res = @[[[NSBundle mainBundle] pathForResource:@"ffmpeg" ofType:nil],
							   @"-i",
							   movie.path,
							   @"-ss",
							   @"cutStart".defaultString,
							   @"-vcodec", @"copy",
							   @"-acodec", @"copy",
							   @"-scodec", @"copy",
							   @"-y",
							   @"-t",
							   @"cutDuration".defaultString,
							   panel.URL.path].runAsTask;
				 LOG(res);


				 dispatch_async_main(^
				 {
					[NSApp endSheet:progressPanel];
					[progressPanel orderOut:self];


					 alert_apptitled(@"success", @"OK", nil, nil);

				 });
			});
		 }
	 }];


}

@end

int main(int argc, const char * argv[])
{
	return NSApplicationMain(argc, argv);
}
