//
//  OptionsViewController.m
//  iOmniMap
//
//  Created by CoreCode on 20.12.12.
/*	Copyright © 2017 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

#import "OptionsViewController.h"


@interface OptionsViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *mapTypeSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *trackingModeSegmentedControl;
@property (weak, nonatomic) IBOutlet UISlider *opacitySlider;

@end



@implementation OptionsViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

    _mapTypeSegmentedControl.selectedSegmentIndex = _mapType;
	_trackingModeSegmentedControl.selectedSegmentIndex = _trackingMode;
	_opacitySlider.value = _opacity;
}

- (IBAction)dismissOptions:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)mapTypeChanged:(UISegmentedControl *)sender
{
	_mapTypeChangedBlock(sender.selectedSegmentIndex);
}

- (IBAction)trackingModeChanged:(UISegmentedControl *)sender
{
	_trackingModeChangedBlock(sender.selectedSegmentIndex);
}

- (IBAction)opacityChanged:(UISlider *)sender
{
	_opacityChangedBlock(sender.value);
}

@end
