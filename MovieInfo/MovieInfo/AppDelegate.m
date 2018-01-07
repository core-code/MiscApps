//
//  AppDelegate.m
//  MovieInfo
//
//  Created by CoreCode on 14.01.14.
/*	Copyright © 2018 CoreCode Limited
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import "AppDelegate.h"


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	cc = [CoreLib new];

	@"sourceMovie".defaultObject = nil;
    @"fileDescription".defaultString = @"";
}

- (IBAction)fileChosen:(id)sender
{

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

    NSString *res = @[[[NSBundle mainBundle] pathForResource:@"ffmpeg" ofType:nil],
                      @"-i",
                      movie.path,
                      ].runAsTask;
    
    if([res contains:@"Input #0"])
    {
        res = [res split:@"Input #0"][1];
        res = [@"Input #0" stringByAppendingString:res];
    }
    res = [res replaced:@"At least one output file must be specified" with:@""];
    
    @"fileDescription".defaultString = res;
}

@end

int main(int argc, const char * argv[])
{
	return NSApplicationMain(argc, argv);
}
