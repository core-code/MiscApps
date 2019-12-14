//
//  AppDelegate.m
//  SubtitleExtractor
//
//  Created by CoreCode on 14.01.14.
/*	Copyright © 2018 CoreCode Limited
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

    @"subtitleTracks".defaultObject = @[];
	@"fileDescription".defaultString = @"";
}

- (IBAction)fileChosen:(id)sender
{
	NSURL *movie = [NSKeyedUnarchiver unarchiveObjectWithData:@"sourceMovie".defaultObject];
	NSString *res = @[[[NSBundle mainBundle] pathForResource:@"ffmpeg" ofType:nil],
					  @"-i",
					  movie.path,
					].runAsTask;

    NSArray *subtitleTracks = [res.lines filtered:^BOOL(NSString *input) { return [input contains:@"Subtitle"]; }];
    

    @"subtitleTracks".defaultArray = subtitleTracks;
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




	NSSavePanel *panel = [NSSavePanel savePanel];

	[panel setExtensionHidden:NO];
	[panel setAllowedFileTypes:@[@"srt"]];
	[panel setDirectoryURL:cc.deskURL];
	[panel setNameFieldStringValue:@"subtitle.srt"];

	[panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result)
	 {
        if (result == NSModalResponseOK)
		 {
			 NSPanel *progressPanel = [[NSPanel alloc]
							   initWithContentRect:NSMakeRect(0, 0, 120, 40)
                                       styleMask:NSWindowStyleMaskTitled
                                       backing:NSBackingStoreBuffered
                                       defer:YES];

             [self.window beginSheet:progressPanel completionHandler:^(NSModalResponse returnCode) {}];

			 NSProgressIndicator *ind = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(10, 10, 100, 20)];
			 [ind setIndeterminate:YES];
			 [ind startAnimation:self];
			 [[progressPanel contentView] addSubview:ind];
             NSString *outputPath = panel.URL.path;
             NSInteger selectedSubtitle = @"selectedSubtitle".defaultInt;
			 dispatch_async_back(^
			 {
				 NSString *res = @[[[NSBundle mainBundle] pathForResource:@"ffmpeg" ofType:nil],
                               @"-txt_format",
                               @"text",
                               @"-i",
							   movie.path,
                                   @"-map",
                                   makeString(@"0:s:%li", (long)selectedSubtitle),
							   outputPath].runAsTask;
				 cc_log(@"%@", res);


				 dispatch_async_main(^
				 {
					[self.window endSheet:progressPanel];					
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
