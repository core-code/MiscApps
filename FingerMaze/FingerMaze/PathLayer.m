//
//  PathLayer.m
//  FingerMaze
//
//  Created by CoreCode on 07.09.10.
/*	Copyright (c) 2016 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

#import "PathLayer.h"
#import "MazeView.h"
#import "Maze.h"
#import "Preferences.h"

extern Maze *maze;
extern Preferences *prefs;
extern CGImageRef duck;


@implementation PathLayer


- (void)drawInContext:(CGContextRef)context
{
	int dir = -1;
	float x = 0, y = 0;
	// path
	NSMutableArray *points = [maze path];
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetLineWidth(context, PATH);
	CGContextSetLineJoin(context, kCGLineJoinRound);
	if ([self.ourdelegate cutMode])
		CGContextSetRGBStrokeColor(context, 0.0, 1.0, 1.0, 1.0);
	else
		CGContextSetRGBStrokeColor(context, 0.0, 0.0, 1.0, 1.0);
	
	CGContextMoveToPoint(context,
						 BORDER + [maze start] * kTilesizeX + ((float)kTilesizeX / 2.0),
						 BORDER + kMaxY * kTilesizeY + BORDER / 2) ;
	for (NSDictionary *point in points)
	{
		float _x = BORDER + ((float)kTilesizeX / 2.0) + [[point objectForKey:@"x"] intValue] * kTilesizeX;
		float _y = BORDER + ((float)kTilesizeY / 2.0) + [[point objectForKey:@"y"] intValue] * kTilesizeY;
		

		if (_x > x + 0.1)
			dir = 0; // rechts
		if (_y > y + 0.1)
			dir = 1; // unten
		if (_x + 0.1 < x)
			dir = 2; // links
		if (_y + 0.1 < y)
			dir = 3; // oben
		
		x = _x;
		y = _y;
		CGContextAddLineToPoint(context, x, y);
	}
	if ([points count] == 1)
		dir = 3;
	
	CGContextStrokePath(context);	
	CGContextTranslateCTM(context, x - 15.0/2.0, y - 19.0/2.0);
	if (dir == 0)
	{
		CGContextTranslateCTM(context, 0, 17.0);
		CGContextRotateCTM(context, -M_PI/2.0);
	}
	if (dir == 2)
	{
		CGContextTranslateCTM(context, 15, 0);
		CGContextRotateCTM(context, M_PI/2.0);
	}
	if (dir == 3)
	{
		CGContextTranslateCTM(context, 0, 19.0);
		CGContextScaleCTM(context, 1.0, -1.0);
	}
	CGContextDrawImage(context, CGRectMake(0, 0, 15, 19), duck); 
}
@end
