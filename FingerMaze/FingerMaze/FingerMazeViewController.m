//
//  FingerMazeViewController.m
//  FingerMaze
//
//  Created by CoreCode on 01.04.10.
/*	Copyright © 2017 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

#import "FingerMazeViewController.h"
#import "JMWebViewController.h"
#import "Maze.h"
#import "Preferences.h"
#import "JMAlertController.h"


extern Maze *maze;
extern Preferences *prefs;
extern NSArray *levelsNames;
extern NSArray *levelsCounts;

@implementation FingerMazeViewController
@synthesize playButton;
@synthesize achievementsTable;
@synthesize optionsTable;

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	//	[self.view setFrame:CGRectMake(0, 0 , 768 , 1024)];
	//	[barView setFrame:CGRectMake(724, 0 , 44 , 1024)];
	
	//	bannerView.requiredContentSizeIdentifiers = [NSSet setWithObjects: ADBannerContentSizeIdentifier480x32, nil];
	//	bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifier480x32;
	
	NSMutableArray *colors = [NSMutableArray arrayWithCapacity:3];
	UIColor *color = [UIColor colorWithRed:0.764 green:0.764 blue:0.764 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
	color = [UIColor colorWithRed:0.895 green:0.895 blue:0.895 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
	color = [UIColor colorWithRed:0.896 green:0.856 blue:0.855 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
	playButton.normalGradientColors = colors;
	[playButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	playButton.titleLabel.font = [UIFont boldSystemFontOfSize:30];
	

    [playButton layer].shadowColor = [UIColor orangeColor].CGColor;
    [playButton layer].shadowOffset = CGSizeMake(0, 0);
    [playButton layer].shadowRadius = 10.0f;

	
	pc = [[PurchaseController alloc] initWithNibName:@"PurchaseView" bundle:nil];
	
	pc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	pc.modalPresentationStyle = UIModalPresentationFormSheet; 

	
	
	CABasicAnimation *theAnimation;
	theAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
	theAnimation.duration = 1.0;
	theAnimation.autoreverses = YES;
	theAnimation.fromValue = @0.0;
	theAnimation.toValue = @1.0;
	theAnimation.repeatCount = HUGE_VALF;
	theAnimation.removedOnCompletion = YES;
	
	[[playButton layer] addAnimation:theAnimation forKey:@"animateShadowOpacity"];
	
	
	[NSTimer scheduledTimerWithTimeInterval:(1.0f/10.0f) target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
	
	gameView.hidden = YES;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainmenuAction:) name:@"mainmenu" object:nil];
	
    
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Frozen"])
	{
		maze = [[Maze alloc] initWithMaze:[[NSUserDefaults standardUserDefaults] objectForKey:@"FrozenLevel"] Number:[[NSUserDefaults standardUserDefaults] integerForKey:@"FrozenNum"]];
		[maze setPath:[[NSUserDefaults standardUserDefaults] objectForKey:@"FrozenPath"]];
		[maze setSeconds: (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"FrozenSeconds"]];
		[[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"Frozen"];
		[[NSUserDefaults standardUserDefaults] synchronize];

		mainMenuView.hidden = YES;
		gameView.hidden = NO;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"gamestarts" object:self];

	}
	
	optionsTable.backgroundView = nil;

	achievementsTable.backgroundView = nil;
	

}

- (void)goPlay
{
	if (maze != nil)
	{
		[maze stop];

        maze = nil;
	}
	maze = [[Maze alloc] initWithMaze:[levelsNames objectAtIndex:[pickerView selectedRowInComponent:0]] Number:[pickerView selectedRowInComponent:1]+1];
	
	
	mainMenuView.hidden = YES;
	gameView.hidden = NO;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"gamestarts" object:self];
}

- (void)viewWillAppear:(BOOL)animated
{

	[pickerView reloadComponent:1];
	[achievementsTable reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight) ||
			(interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void)updateTimer:(NSTimer *)timer
{
	if (mainMenuView.isHidden && [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
	{
		[timeLabel setText:[NSString stringWithFormat:@"%i sec", [maze seconds]]];
		[levelsetLabel setText:[NSString stringWithFormat:@"%@", [maze levelset]]];
		[levelnumLabel setText:[NSString stringWithFormat:@"%i", [maze num]]];
		[scoreLabel setText:[NSString stringWithFormat:@"%i + %i", [prefs score], [prefs pointsForFinishInSeconds:[maze seconds]]]];
	}
}

- (IBAction)cutpathAction:(id)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"cutpath" object:self];
}

- (IBAction)mainmenuAction:(id)sender
{
	gameView.hidden = YES;
	mainMenuView.hidden = FALSE;

	if ([sender isKindOfClass:[NSNotification class]])
	{
		if (![[levelsNames objectAtIndex:[pickerView selectedRowInComponent:0]] isEqualToString:@"Randomized"])
		{
			[pickerView selectRow:[pickerView selectedRowInComponent:0]+1 inComponent:0 animated:YES];
			[pickerView selectRow:0 inComponent:1 animated:YES];
		}
	}
	else
	{
		[pickerView selectRow:[maze num]-1 inComponent:1 animated:YES];
	}

	[self performSelector:@selector(viewWillAppear:) withObject:[NSNumber numberWithBool:NO] afterDelay:0.5];

	if (maze != nil)
	{
		[maze stop];

        maze = nil;
	}
}


//
//-(void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    [self becomeFirstResponder];
//}
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//    [self resignFirstResponder];
//    [super viewWillDisappear:animated];
//}

- (BOOL)canBecomeFirstResponder
{
	return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.subtype == UIEventSubtypeMotionShake)
		[maze resetPath];
}

- (IBAction)playAction:(id)sender
{
	if ([[levelsNames objectAtIndex:[pickerView selectedRowInComponent:0]] isEqualToString:@"Randomized"] &&
		![[NSUserDefaults standardUserDefaults] boolForKey:@"generatorsPurchased"])
	{
		[[[UIAlertView alloc]
						  initWithTitle:@"Warning"
						  message:@"To play the random mazes you need to unlock the maze generators by clicking 'Purchase Levels…'."
						  delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles: nil] show];
		
		return;
	}
	else if (![[levelsNames objectAtIndex:[pickerView selectedRowInComponent:0]] isEqualToString:@"Free"] &&
			 ![[levelsNames objectAtIndex:[pickerView selectedRowInComponent:0]] isEqualToString:@"Randomized"] &&
			 ![[NSUserDefaults standardUserDefaults] boolForKey:@"mazesPurchased"])
	{
		NSString *str;
		
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"generatorsPurchased"])
			str = @"To play this level you need to unlock the mazes by clicking 'Purchase Levels…'. Try the 'Free' or 'Randomized' category instead.";
		else
			str = @"To play this level you need to unlock the mazes by clicking 'Purchase Levels…'. Try the 'Free' maze category instead.";
			
		
		[[[UIAlertView alloc]
		   initWithTitle:@"Warning"
		   message:str
		   delegate:nil
		   cancelButtonTitle:@"OK"
		   otherButtonTitles: nil] show];
		
		return;
	}
	
	[[NSUserDefaults standardUserDefaults] setBool:[textureBackgroundsSwitch isOn] forKey:@"TextureBackgrounds"];
	[[NSUserDefaults standardUserDefaults] setBool:[colorBackgroundsSwitch isOn] forKey:@"ColorBackgrounds"];
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"IntroShown"])
	{
		[self goPlay];
	}
	else
	{
		JMWebViewController *vc = [[JMWebViewController alloc] initWithNibName:@"IntroView" bundle:nil];

		vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
		vc.modalPresentationStyle = UIModalPresentationFormSheet; 
		
		vc.finishBlock = ^{
			[self dismissViewControllerAnimated:NO  completion:^{}];
			
			[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"IntroShown"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			
			[self goPlay];
		};
	
		
		[self presentViewController:vc animated:YES  completion:^{}];
		
		
		[vc.webView loadRequest:[NSURLRequest requestWithURL:[[NSBundle mainBundle] URLForResource:@"Help" withExtension:@"webarchive"]]];
		
	}
}

- (IBAction)resetAction:(id)sender
{
	[prefs reset];
	[self viewWillAppear:NO];
}

- (NSString *)pickerView:(UIPickerView *)_pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	NSString *returnStr = @"";

	if (component == 0)
	{
		returnStr = [levelsNames objectAtIndex:row];
	}
	else
	{
		if ([[levelsNames objectAtIndex:[pickerView selectedRowInComponent:0]] isEqualToString:@"Randomized"])
			return row <= 2 ? [[NSArray arrayWithObjects:@"Easy", @"Medium", @"Hard", nil] objectAtIndex:row] : @"";
		else
			returnStr = [@(row+1) stringValue];
	}

	return returnStr;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	CGFloat componentWidth = 0.0;

	if (component == 0)
		componentWidth = 140.0;	// first column size is wider to hold names
	else
		componentWidth = 90.0;	// second column is narrower to show numbers

	return componentWidth;
}

- (CGFloat)pickerView:(UIPickerView *)_pickerView rowHeightForComponent:(NSInteger)component
{
	return 40.0;
}

- (NSInteger)pickerView:(UIPickerView *)_pickerView numberOfRowsInComponent:(NSInteger)component
{
	if (component == 0)
		return [levelsNames count];
	else
		return [[levelsCounts objectAtIndex:[pickerView selectedRowInComponent:0]] intValue];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 2;
}


- (void)pickerView:(UIPickerView *)_pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if (component == 0)
	{
//		if (row != 0)
//		{
//			[pickerView selectRow:0 inComponent:0 animated:NO];
//		}

		[pickerView reloadComponent:1];
	}
	
	[self viewWillAppear:NO];
}

#pragma mark UITableViewDataSource protocol

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (!cell)
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
	
	
	

	

	if (tableView == achievementsTable)
	{

		if (indexPath.row == 0)
		{
			cell.textLabel.text = @"Finished Levels:";
			cell.detailTextLabel.text = makeString(@"%i", [prefs finishedLevels]);
		}
		else if (indexPath.row == 1)
		{
			cell.textLabel.text = @"Medals:";
			cell.detailTextLabel.text = makeString(@"%i Gold %i Silver", [prefs goldMedals], [prefs silverMedals]);
		}
		else if (indexPath.row == 2)
		{
			cell.textLabel.text = @"Total Score:";
			cell.detailTextLabel.text = makeString(@"%i pt",  [prefs score]);
		}
		else if (indexPath.row == 3)
		{
			NSString *fastest = ([prefs fastestLevel]) > 900 ? @"None" : [NSString stringWithFormat:@"%i sec", (int)[prefs fastestLevel]];
			
			cell.textLabel.text = @"Fastest Level:";
			cell.detailTextLabel.text = fastest;
		}
		else if (indexPath.row == 4)
		{
			NSDictionary *ls = [[NSUserDefaults standardUserDefaults] objectForKey:[levelsNames objectAtIndex:[pickerView selectedRowInComponent:0]]];
			NSDictionary *l = [ls objectForKey:[NSString stringWithFormat:@"%i", (int)[pickerView selectedRowInComponent:1]+1]];
			NSString *selected;
			
			if (l)
			{
				int points = [[l objectForKey:@"Points"] intValue];
				float secs = [[l objectForKey:@"Time"] floatValue];
				selected = [NSString stringWithFormat:@"%i sec  %i pt", (int)secs, points];
			}
			else
				selected = @"Unfinished";	
			
			cell.textLabel.text = @"Selected Level:";
			cell.detailTextLabel.text = selected;
		}
	}
	else
	{
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;

		if (indexPath.row == 0)
		{
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.textLabel.text = @"Background Textures:";
            
            textureBackgroundsSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(5, 5, 70, 10)];
            textureBackgroundsSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"TextureBackgrounds"];

            cell.accessoryView = textureBackgroundsSwitch;
		}
		else if (indexPath.row == 1)
		{
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.textLabel.text = @"Background Colors:";
            
            colorBackgroundsSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(5, 5, 70, 10)];
            colorBackgroundsSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"ColorBackgrounds"];

            cell.accessoryView = colorBackgroundsSwitch;
		}
		else if (indexPath.row == 2)
		{
			cell.textLabel.text = @"Purchase Levels…";
		}
		else if (indexPath.row == 3)
		{

			cell.textLabel.text = @"Reset Achievements…";
		}
		else if (indexPath.row == 4)
		{

			cell.textLabel.text = @"Credits & Contact…";
		}
	}
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
    if (indexPath.row == 2)
    {
        [self presentViewController:pc animated:YES completion:^{}];
		
		[tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    else if (indexPath.row == 3)
    {
		JMAlertController *a = [JMAlertController alertControllerWithTitle:@"Warning"
                                                            viewController:self
                                                                   message:@"Do you really want to reset all your achievements (scores/medals)?"
                                                               cancelBlock:nil
                                                         cancelButtonTitle:@"Cancel"
                                                                otherBlock:^(int input) { [self resetAction:nil]; }
                                                         otherButtonTitles:@[@"Reset"]];


        [a showInView:self.view];
		
    
		[tableView deselectRowAtIndexPath:indexPath animated:NO];

    }
    else if (indexPath.row == 4)
    {
		JMWebViewController *vc = [[JMWebViewController alloc] initWithNibName:@"IntroView" bundle:nil];
		
		vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
		vc.modalPresentationStyle = UIModalPresentationFormSheet; 
		
		vc.finishBlock = ^{
			[self dismissViewControllerAnimated:NO completion:^{}];

		};
		
		
		[self presentViewController:vc animated:YES completion:^{}];
		
		
		[vc.webView loadRequest:[NSURLRequest requestWithURL:[[NSBundle mainBundle] URLForResource:@"Credits" withExtension:@"webarchive"]]];
		
		
		[tableView deselectRowAtIndexPath:indexPath animated:NO];

    }
}


- (void)viewDidUnload
{
	[self setAchievementsTable:nil];
	[self setOptionsTable:nil];
	[self setPlayButton:nil];
	pc = nil;
	[super viewDidUnload];
}
@end
