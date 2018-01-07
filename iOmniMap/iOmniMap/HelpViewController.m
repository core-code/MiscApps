//
//  HelpViewController.m
//  iOmniMap
//
//  Created by CoreCode on 25.12.11.
/*	Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

#import "HelpViewController.h"
#import "JMWebViewController.h"


@interface HelpViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *videoView;

@end



@implementation HelpViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidLoad
{
	// TODO: replace link with built in resource or on-demand appstore resource
	NSURL *url = @"https://www.corecode.io/ios/iomnimap/explanation_video_ipad.mp4".URL;
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    [_videoView loadRequest:request];

	[super viewDidLoad];
}

- (IBAction)openURL:(id)sender
{
	NSString *urlString = @"";

	if ([sender tag] == 1)
		urlString = makeString(@"mailto:feedback@corecode.io?subject=%@ %@ Support Request&body=Insert Support Request Here", cc.appName, cc.appVersionString);
	else if ([sender tag] == 3)
		urlString = makeString(@"https://www.corecode.io/%@/", [cc.appName lowercaseString]);


    [urlString.escaped.URL open];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   JMWebViewController *vc = [segue destinationViewController];
	
	if ([sender tag] == 4)
	{
		// TODO: replace link with built in resource or on-demand appstore resource
		vc.url = @"https://www.corecode.io/ios/iomnimap/explanation_video_iphone.mp4".URL;		
		vc.navigationTitle = @"Video";
	}
	else
	{
		vc.url = @"manual.html".resourceURL;
		vc.navigationTitle = @"Manual";
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[self.navigationController setNavigationBarHidden:YES animated:animated];

    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[self.navigationController setNavigationBarHidden:NO animated:animated];

    [super viewWillDisappear:animated];
}
@end
