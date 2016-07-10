//
//  FingerFragViewController.h
//  FingerFrag
//
//  Created by CoreCode on 01.04.10.
/*	Copyright (c) 2016 CoreCode
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

#import <UIKit/UIKit.h>

@interface FingerFragViewController : UIViewController { }


- (IBAction)playAction:(id)sender;
- (void)imageViewDone:(id)sender;
- (IBAction)mainmenuAction:(id)sender;
- (void)goPlay;


@property (strong) IBOutlet UIView *gameView;
@property (strong) IBOutlet UIView *mainMenuView;
@property (strong) IBOutlet UITextField *count;
@property (strong) IBOutlet UITextField *time;
@property (strong) IBOutlet UITextField *scorex;
@property (strong) IBOutlet UITextField *scorey;
@property (strong) IBOutlet UITextField *delay;
@property (strong) IBOutlet UITextField *enemyx;
@property (strong) IBOutlet UITextField *enemyy;
@property (nonatomic) int gameMode;

@end
