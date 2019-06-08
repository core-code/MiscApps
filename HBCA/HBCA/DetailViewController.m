//
//  DetailViewController.m
//  HBCA
//
//  Created by CoreCode on 07.11.12.
/*	Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

#import "DetailViewController.h"


@interface DetailViewController ()

@end


@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    let caskPath = @[cc.docDir, @"homebrew-cask-master", @"Casks", makeString(@"%@.rb", self.caskName)].path;
    self.textView.text = caskPath.contents.string;
    
    dispatch_async_back(^
    {
        let url = makeString(@"https://raw.githubusercontent.com/Homebrew/homebrew-cask/master/Casks/%@.rb", self.caskName);
        let caskContents = url.download.string;
        
        if ([caskContents contains:@"cask"] && [caskContents contains:@"end"])
            dispatch_async_main(^{
                self.textView.text = caskContents;
            });
    });

    
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editCask:)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)editCask:(id)sender
{
    let url = makeString(@"https://github.com/Homebrew/homebrew-cask/edit/master/Casks/%@.rb", self.caskName);
    
     [[UIApplication sharedApplication] openURL:url.URL options:@{} completionHandler:^(BOOL success) { }];
}
@end
