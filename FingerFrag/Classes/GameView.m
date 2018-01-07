//
//  GameView.m
//  FingerFrag
//
//  Created by CoreCode on 30.03.10.
/*	Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

#import "GameView.h"
#import "FingerFragViewController.h"
#import "HighScoreViewController.h"

#define CELLS_W [[[ffViewController enemyx] text] intValue]
#define CELLS_H [[[ffViewController enemyy] text] intValue]

@implementation GameView

CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};

- (instancetype)initWithCoder:(NSCoder *)decoder
{
	self = [super initWithCoder:decoder];

	if(self != nil)
	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gamestarts:) name:@"gamestarts" object:nil];


		//self.backgroundColor = [UIColor blackColor];
		self.opaque = YES;
		self.clearsContextBeforeDrawing = YES;



		[NSTimer scheduledTimerWithTimeInterval:(1.0f/30.0f) target:self selector:@selector(animationTimer:) userInfo:nil repeats:YES];
				
		[self reset];


	}
	return self;
}

- (void)animationTimer:(NSTimer *)timer
{
	if (self.superview.hidden)
		return;
	
	if (ffViewController.gameMode == 1)
	{
		fragLabel.text = [NSString stringWithFormat:@"Frags: %i of %i", frags, ffViewController.count.text.intValue];		
		timeLabel.text = [NSString stringWithFormat:@"Time: %.2f", [[NSDate date] timeIntervalSinceDate:startDate]];
	}
	else
	{
		fragLabel.text = [NSString stringWithFormat:@"Frags: %i", frags];
		timeLabel.text = [NSString stringWithFormat:@"Time: %.2f of %i", [[NSDate date] timeIntervalSinceDate:startDate],  ffViewController.time.text.intValue];
	}
}
	
- (void)finishTimer:(NSTimer *)timer
{
	HighScoreViewController *hsController = [[HighScoreViewController alloc] initWithNibName:@"HighScoreViewController" bundle:nil];
	hsController.delegate = ffViewController;
	hsController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	hsController.modalPresentationStyle = UIModalPresentationFormSheet;
	hsController.text = [NSString stringWithFormat:@"Congratulations u managed %i enemies in the %i seconds!", frags, ffViewController.time.text.intValue];
    [ffViewController presentViewController:hsController animated:YES completion:^{}];
}													

- (IBAction)mainmenuAction:(id)sender
{
	if (ffViewController.gameMode == 2)
	{
		[finishTimer invalidate];
		finishTimer = nil;
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"mainmenu" object:self];
}

- (void)gamestarts:(NSNotification *)notification
{
	frags = 0;
	startDate = [NSDate date];
	if (ffViewController.gameMode == 2)
		finishTimer = [NSTimer scheduledTimerWithTimeInterval:(ffViewController.time.text.intValue) target:self selector:@selector(finishTimer:) userInfo:nil repeats:NO];

	int cellwidth = WIDTH / CELLS_W;
	int cellheight = HEIGHT / CELLS_H;
	
	if (tileLayers)
	{
		for (NSArray *a in tileLayers)
			for (CALayer *l in a)
				[l removeFromSuperlayer];
				
		tileLayers = nil;
	}
	
	tileLayers = [NSMutableArray arrayWithCapacity:CELLS_W];
	for (int _x = 0; _x < CELLS_W; _x++)
	{
		[tileLayers addObject:[NSMutableArray arrayWithCapacity:CELLS_H]];
		
		for (int _y = 0; _y < CELLS_H; _y++)
		{
			CALayer *l = [CALayer layer];

			
			if (!(_y > CELLS_H - 1 - ffViewController.scorey.text.intValue && fabs(_x - (((float)CELLS_W - 1.0) / 2.0)) <= (ffViewController.scorex.text.intValue / 2)))
			{
				
				CGImageRef imageRef = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"empty" ofType:@"png"]].CGImage;
				l.contents = (__bridge id)imageRef;
				l.frame = CGRectMake(_x * cellwidth, _y * cellheight, cellwidth, cellheight);				
				
			}
			
			[tileLayers[_x] addObject:l];
			[self.layer addSublayer:l];

		}
	}
	
	int w = ffViewController.scorex.text.intValue * cellwidth;
	int h = ffViewController.scorey.text.intValue * cellheight;

	scoreView.frame = CGRectMake((WIDTH - w) / 2, HEIGHT - h, w, h);
	
	
	[self performSelector:@selector(popupEnemy) withObject:nil afterDelay:ffViewController.delay.text.floatValue];
}

- (void)popupEnemy
{
	x = RandomIntBetween(0, CELLS_W-1);
	y = RandomIntBetween(0, CELLS_H-1);
	
	while (y > CELLS_H - 1 - ffViewController.scorey.text.intValue && fabs(x - (((float)CELLS_W - 1.0) / 2.0)) <= (ffViewController.scorex.text.intValue / 2))
	{
		x = RandomIntBetween(0, CELLS_W-1);
		y = RandomIntBetween(0, CELLS_H-1);
	}
	
	CALayer *l = tileLayers[x][y];
	CGImageRef imageRef = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"full" ofType:@"png"]].CGImage;
	l.contents = (__bridge id)imageRef;
}

- (void)reset
{

}

- (void)drawRect:(CGRect)rect
{

}

- (void)touch:(NSSet *)touches withEvent:(UIEvent *)event
{		
	int cellwidth = WIDTH / CELLS_W;
	int cellheight = HEIGHT / CELLS_H;
	CGPoint loc = [[touches anyObject] locationInView:self];

	int w = ffViewController.scorex.text.intValue * cellwidth;
	int h = ffViewController.scorey.text.intValue * cellheight;
	
	if (CGRectContainsPoint(CGRectMake((WIDTH - w) / 2, HEIGHT - h, w, h), loc))
		return;
	
	
	if (loc.x >=  x * cellwidth  &&  loc.x <  (x+1) * cellwidth &&
		loc.y >=  y * cellheight  &&  loc.y <  (y+1) * cellheight)
	{
	
		CALayer *l = tileLayers[x][y];
		CGImageRef imageRef = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"empty" ofType:@"png"]].CGImage;
		l.contents = (__bridge id)imageRef;
		
		frags++;
		
		if ((ffViewController.gameMode == 1) && (frags == ffViewController.count.text.intValue))
		{
			HighScoreViewController *hsController = [[HighScoreViewController alloc] initWithNibName:@"HighScoreViewController" bundle:nil];
			hsController.delegate = ffViewController;
			hsController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
			hsController.modalPresentationStyle = UIModalPresentationFormSheet;
			hsController.text = [NSString stringWithFormat:@"Congratulations u took %.2f sec for all %i enemies!", [[NSDate date] timeIntervalSinceDate:startDate], ffViewController.count.text.intValue];
            [ffViewController presentViewController:hsController animated:YES completion:^{}];
        }
		else
			[self performSelector:@selector(popupEnemy) withObject:nil afterDelay:ffViewController.delay.text.floatValue];
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touch:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
//	[self touch:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}

@end
