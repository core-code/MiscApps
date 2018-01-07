//
//  FingerMazeViewController.h
//  FingerMaze
//
//  Created by CoreCode on 01.04.10.
/*	Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

#import <UIKit/UIKit.h>
#import "GradientButton.h"
#import "PurchaseController.h"

@interface FingerMazeViewController : UIViewController {
	IBOutlet UILabel *timeLabel, *levelsetLabel, *levelnumLabel, *scoreLabel;
	IBOutlet UIPickerView *pickerView;
	IBOutlet UIView *mainMenuView, *gameView;
    UISwitch *textureBackgroundsSwitch;
    UISwitch *colorBackgroundsSwitch;
	PurchaseController *pc;
}

- (IBAction)playAction:(id)sender;
- (IBAction)resetAction:(id)sender;
- (IBAction)cutpathAction:(id)sender;
- (IBAction)mainmenuAction:(id)sender;

@property (strong, nonatomic) IBOutlet GradientButton *playButton;
@property (strong, nonatomic) IBOutlet UITableView *achievementsTable;
@property (strong, nonatomic) IBOutlet UITableView *optionsTable;

@end
