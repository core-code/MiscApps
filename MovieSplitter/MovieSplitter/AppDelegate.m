//
//  AppDelegate.m
//  MovieSplitter
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
    @"cuts".defaultString = @"one split point per line.\nuse ss or mm:ss or hh:mm:ss";
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

	for (NSString *cut in @"cuts".defaultString.lines)
    {
        if (cut.length)
        {
            let comps = [cut split:@":"];
                
            for (NSString *comp in comps)
            {
                if (!comp.isIntegerNumberOnly || comps.count > 3)
                {
                    alert_apptitled(@"you've specified an invalid split point'", @"D'oh", nil, nil);
                    return;
                }
            }
        }
    }
    
    let splits = (NSMutableArray <NSNumber *> *)makeMutableArray();
    [splits addObject:@(0)];
    for (NSString *cut in @"cuts".defaultString.lines)
    {
        if (cut.length)
        {
            let comps = [cut split:@":"];
            NSNumber *num;
            
            if (comps.count == 1)
                num = @([comps[0] intValue]);
            else if (comps.count == 2)
                num = @([comps[0] intValue]  * 60 + [comps[1] intValue]);
            else if (comps.count == 3)
                num = @([comps[0] intValue]  * 3600 + [comps[1] intValue] * 60 + [comps[1] intValue]);
            

           if (num.intValue <= splits.lastObject.intValue)
           {
               alert_apptitled(@"split points must be ascending", @"D'oh", nil, nil);
               return;
           }
            [splits addObject:num];
        }
    }
    [splits addObject:@(durationSecs)];


	NSSavePanel *panel = [NSSavePanel savePanel];

	[panel setExtensionHidden:NO];
	[panel setAllowedFileTypes:@[movie.pathExtension]];
	[panel setDirectoryURL:cc.deskURL];
	[panel setNameFieldStringValue:[[[movie URLByDeletingPathExtension] lastPathComponent] stringByAppendingString:@"-cut"]];

	[panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result)
	 {
        if (result == NSModalResponseOK)
		 {
			 NSPanel *progressPanel = [[NSPanel alloc]
							   initWithContentRect:NSMakeRect(0, 0, 120, 40)
                                       styleMask:NSWindowStyleMaskTitled
							   backing:NSBackingStoreBuffered
							   defer:YES];

             NSString *outPath = panel.URL.path;
             NSString *outPathWOExt = outPath.stringByDeletingPathExtension;
             NSString *outPathExt = outPath.pathExtension;

             [self.window beginSheet:progressPanel completionHandler:^(NSModalResponse returnCode) {}];

			 NSProgressIndicator *ind = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(10, 10, 100, 20)];
			 [ind setIndeterminate:YES];
			 [ind startAnimation:self];
			 [[progressPanel contentView] addSubview:ind];
			 dispatch_async_back(^
			 {
                 
                 for (int i = 0; i < splits.count - 1; i++)
                 {
                     
                     NSNumber *start = splits[i];
                     NSNumber *stop = splits[i+1];
                     NSNumber *duration = @(stop.intValue - start.intValue);

                     NSString *res = @[[[NSBundle mainBundle] pathForResource:@"ffmpeg" ofType:nil],
                                   @"-i",
                                   movie.path,
                                   @"-ss",
                                   start.stringValue,
                                   @"-map", @"0",
                                   @"-vcodec", @"copy",
                                   @"-acodec", @"copy",
                                   @"-scodec", @"copy",
                                   @"-y",
                                   @"-t",
                                   duration.stringValue,
                                   makeString(@"%@-%i.%@",outPathWOExt,i+1,outPathExt)].runAsTask;
                     cc_log(@"%@", res);


                     if (i == splits.count - 2)
                     {
                         dispatch_async_main(^
                         {
                            [self.window endSheet:progressPanel];
                            [progressPanel orderOut:self];


                             alert_apptitled(@"success", @"OK", nil, nil);

                         });
                     }
                 }
				 
			});
		 }
	 }];


}

@end

int main(int argc, const char * argv[])
{
	return NSApplicationMain(argc, argv);
}
