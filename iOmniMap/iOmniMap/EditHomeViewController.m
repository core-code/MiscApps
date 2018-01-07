//
//  EditHomeViewController.m
//  iOmniMap
//
//  Created by CoreCode on 23.12.11.
/*	Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

#import "EditHomeViewController.h"
#import "EditMatchViewController.h"
#import "EditVerifyViewController.h"

@interface EditHomeViewController ()

@property (weak, nonatomic) IBOutlet UIButton *matchFirstButton;
@property (weak, nonatomic) IBOutlet UIButton *matchSecondButton;
@property (weak, nonatomic) IBOutlet UIButton *verifyButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@end



@implementation EditHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title = makeString(@"Edit %@", _omniMapName);
    
    NSDictionary *map;
    for (NSDictionary *m in @"OmniMaps".defaultArray)
        if ([m[@"name"] isEqualToString:_omniMapName])
            map = m.mutableObject;
    
    {
        NSString *omniPointString = map[@"firstPointOmni"];
        NSNumber *lo = map[@"firstPointLongitude"];
        NSNumber *la = map[@"firstPointLatitude"];
        
        if (omniPointString && lo && la)
        {
            [_matchFirstButton setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
            _matchSecondButton.enabled = YES;
        }
        else
        {
        }
    }
    {
        NSString *omniPointString = map[@"secondPointOmni"];
        NSNumber *lo = map[@"secondPointLongitude"];
        NSNumber *la = map[@"secondPointLatitude"];
        
        if (omniPointString && lo && la)
        {
            [_matchSecondButton setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
            _verifyButton.enabled = YES;
            _saveButton.enabled = YES;
        }
        else
        {
        }
    }
    
//    [matchFirstButton setNeedsDisplay];
//        [matchSecondButton setNeedsDisplay];
//        [verifyButton setNeedsDisplay];
//        [saveButton setNeedsDisplay];


   self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"3rd" style:UIBarButtonItemStylePlain target:self action:@selector(matchThird)];
}

- (void)matchThird
{
	[self performSegueWithIdentifier:@"pushMatch" sender:self.navigationItem.rightBarButtonItem];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	NSArray *buttons = @[_matchFirstButton, _matchSecondButton, self.navigationItem.rightBarButtonItem];
    if ([buttons indexOfObject:sender] != NSNotFound)
    {
        EditMatchViewController *vc = [segue destinationViewController];
        vc.omniMapName = _omniMapName;
        vc.index = [buttons indexOfObject:sender];
    }
    else if (sender == _verifyButton)
    {
        EditVerifyViewController *vc = [segue destinationViewController];
        vc.omniMapName = _omniMapName;
    }
}

- (IBAction)saveAction:(id)sender
{
	self.tabBarController.selectedIndex = 2;
}
@end
