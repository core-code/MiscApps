//
//  JoystickView.m
//  FingerMaze
//
//  Created by CoreCode on 05.11.10.
/*	Copyright (c) 2016 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

#import "JoystickView.h"

CGFloat DistanceBetweenTwoPoints(CGPoint point1, CGPoint point2);

@implementation JoystickView
@synthesize nearestPoint;


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		nearestPoint = -1;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainmenuAction:) name:@"mainmenu" object:nil];
	}
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];

}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint loc = [[touches anyObject] locationInView:self];

	CGPoint top = CGPointMake(67, 14);
	CGPoint bottom = CGPointMake(67, 55);
	CGPoint left = CGPointMake(29, 35);
	CGPoint right = CGPointMake(109, 35);	

	float distTop = DistanceBetweenTwoPoints(loc, top);
	float distBottom = DistanceBetweenTwoPoints(loc, bottom);
	float distLeft = DistanceBetweenTwoPoints(loc, left);
	float distRight = DistanceBetweenTwoPoints(loc, right);
	
	if (distTop < MIN(MIN(distBottom, distLeft), distRight))
		nearestPoint = 1;
	if (distBottom < MIN(MIN(distTop, distLeft), distRight))
		nearestPoint = 3;
	if (distLeft < MIN(MIN(distBottom, distTop), distRight))
		nearestPoint = 4;
	if (distRight < MIN(MIN(distBottom, distLeft), distTop))		
		nearestPoint = 2;
	
	[self timer:nil];
	timer = [NSTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector(timer:) userInfo:nil repeats:YES];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint loc = [[touches anyObject] locationInView:self];

	if (loc.x < 0 || loc.y < 0)
	{
		nearestPoint = -1;
		return;
	}
	
	CGPoint top = CGPointMake(67, 14);
	CGPoint bottom = CGPointMake(67, 55);
	CGPoint left = CGPointMake(29, 35);
	CGPoint right = CGPointMake(109, 35);	
	
	float distTop = DistanceBetweenTwoPoints(loc, top);
	float distBottom = DistanceBetweenTwoPoints(loc, bottom);
	float distLeft = DistanceBetweenTwoPoints(loc, left);
	float distRight = DistanceBetweenTwoPoints(loc, right);
	
	if (distTop < MIN(MIN(distBottom, distLeft), distRight))
		nearestPoint = 1;
	if (distBottom < MIN(MIN(distTop, distLeft), distRight))
		nearestPoint = 3;
	if (distLeft < MIN(MIN(distBottom, distTop), distRight))
		nearestPoint = 4;
	if (distRight < MIN(MIN(distBottom, distLeft), distTop))		
		nearestPoint = 2;	
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	nearestPoint = -1;	
	[timer invalidate];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	nearestPoint = -1;	
	[timer invalidate];
}

- (IBAction)mainmenuAction:(id)sender
{
	nearestPoint = -1;	
	[timer invalidate];
}
			 
- (void)timer:(NSTimer *)theTimer
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"moveduck" object:self];
}
@end

CGFloat DistanceBetweenTwoPoints(CGPoint point1, CGPoint point2)
{
	CGFloat dx = point2.x - point1.x;
	CGFloat dy = point2.y - point1.y;
	return sqrt(dx*dx + dy*dy );
}
