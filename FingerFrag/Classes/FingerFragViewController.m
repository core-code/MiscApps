//
//  FingerFragViewController.m
//  FingerFrag
//
//  Created by CoreCode on 01.04.10.
/*	Copyright (c) 2016 CoreCode
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

#import "FingerFragViewController.h"
#import "ImageViewController.h"


@implementation FingerFragViewController


- (void)viewDidLoad
{
	[super viewDidLoad];

	_gameView.hidden = YES;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainmenuAction:) name:@"mainmenu" object:nil];
}

- (void)goPlay
{
	_mainMenuView.hidden = YES;
	_gameView.hidden = NO;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"gamestarts" object:self];
}

- (void)viewWillAppear:(BOOL)animated
{

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}


- (IBAction)mainmenuAction:(id)sender
{
	_gameView.hidden = YES;
	_mainMenuView.hidden = FALSE;

}

- (BOOL)canBecomeFirstResponder
{
	return YES;
}

- (IBAction)playAction:(id)sender
{
	_gameMode = [sender tag];
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"IntroShown"])
	{
		[self goPlay];
	}
	else
	{
		ImageViewController *introController = [[ImageViewController alloc] initWithNibName:@"IntroView" bundle:nil];
		introController.delegate = self;
		introController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
		introController.modalPresentationStyle = UIModalPresentationFormSheet;
		[self presentModalViewController:introController animated:YES];
	}
}

- (void)imageViewDone:(id)sender
{
	[self dismissModalViewControllerAnimated:NO];

	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"IntroShown"];
	[[NSUserDefaults standardUserDefaults] synchronize];

	[self goPlay];
}
@end
