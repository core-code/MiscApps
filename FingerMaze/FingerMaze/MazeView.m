//
//  MazeView.m
//  FingerMaze
//
//  Created by CoreCode on 30.03.10.
/*	Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

#import "MazeView.h"
#import "Maze.h"
#import "Preferences.h"
#import "PathLayer.h"
#import "JoystickView.h"

//#include <mach/mach_time.h>
//mach_timebase_info_data_t sTimebaseInfo;
//void NanosecondsInit()
//{
//	mach_timebase_info(&sTimebaseInfo);
//}
//
//uint64_t GetNanoseconds()
//{
//#ifdef DEBUG
//	if (sTimebaseInfo.denom == 0)
//		fatal("Error: Nano timer not inited");
//#endif
//	
//	return (mach_absolute_time() * sTimebaseInfo.numer / sTimebaseInfo.denom);
//}


extern Maze *maze;
extern Preferences *prefs;

@implementation MazeView
@synthesize cutMode;

CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super initWithCoder:decoder];

	if(self != nil)
	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCut:) name:@"cutpath" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(togglePause:) name:@"pausegame" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gamestarts:) name:@"gamestarts" object:nil];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveduck:) name:@"moveduck" object:nil];

		cutMode = FALSE;
		paused = FALSE;

		//self.backgroundColor = [UIColor blackColor];
		self.opaque = YES;
		self.clearsContextBeforeDrawing = YES;

//		[NSTimer scheduledTimerWithTimeInterval:(1.0f/30.0f) target:self selector:@selector(animationTimer:) userInfo:nil repeats:YES];


        textLayer = [CATextLayer layer];
		textLayer.frame = CGRectMake((1024 - 270) / 2, 400, 270, 300);
		textLayer.opaque = NO;
		textLayer.string = @"Time:     50 sec\n\nPoints:   437\n\nMedals:  None";
		textLayer.foregroundColor = [UIColor whiteColor].CGColor;
		textLayer.font = (__bridge CFTypeRef _Nullable)(@"Arial Black");
		textLayer.fontSize = 40;
		textLayer.shadowOffset = CGSizeMake(0, 0);
		textLayer.shadowOpacity = 1.0;
		textLayer.shadowColor = [UIColor blackColor].CGColor;

		duckLayer = [CALayer layer];
		CGImageRef imageRef = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"LevelFinished" ofType:@"png"]].CGImage;
		duckLayer.frame = CGRectMake((1024 - 650) / 2, 50, 650, 350);
		duckLayer.contents = (__bridge id)imageRef;
		duckLayer.opaque = YES;
		
		flashLayer = [CALayer layer];
		imageRef = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"red_sprite" ofType:@"png"]].CGImage;
		flashLayer.contents = (__bridge id)imageRef;
		flashLayer.frame = CGRectMake((1024 - 20) / 2, (768 - 20) / 2 - 20, 20, 20);
		
		goldmedalLayer = [CALayer layer];
		imageRef = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"gold" ofType:@"png"]].CGImage;
		goldmedalLayer.contents = (__bridge id)imageRef;
		goldmedalLayer.frame = CGRectMake(1024 - 281  - 50, 0, 281, 429);
		
		silvermedalLayer = [CALayer layer];
		imageRef = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"silver" ofType:@"png"]].CGImage;
		silvermedalLayer.contents = (__bridge id)imageRef;
		silvermedalLayer.frame = CGRectMake(50, 0 , 281, 429);
		[silvermedalLayer setValue:[NSNumber numberWithFloat:0.5] forKeyPath:@"transform.scale"];

		mazeLayer =  [MazeViewLayer new];
		mazeLayer.frame = [self bounds];
		mazeLayer.opaque = NO;
		mazeLayer.opacity = 1.0;

		pathLayer = [PathLayer new];
		pathLayer.frame = [self bounds];
		pathLayer.opaque = NO;
		pathLayer.opacity = 1.0;
		[pathLayer setOurdelegate:self];
		
		[self reset];

		[[self layer] addSublayer:mazeLayer];
		[[self layer] addSublayer:pathLayer];
		[[self layer] addSublayer:duckLayer];
		[[self layer] addSublayer:textLayer];
		[[self layer] addSublayer:flashLayer];
		[[self layer] addSublayer:goldmedalLayer];
		[[self layer] addSublayer:silvermedalLayer];


	}
	return self;
}

- (void)moveduck:(NSNotification *)notification
{
	NSDictionary *lpoint = [[maze path] lastObject];
	uint8_t lx = [[lpoint objectForKey:@"x"] intValue];
	uint8_t ly = [[lpoint objectForKey:@"y"] intValue];
	BOOL _done = FALSE;
	int direction = [(JoystickView *)[notification object] nearestPoint];
	
	if (direction == -1)
		return;
	
	while (!_done)
	{
		if (direction == 1) // top
		{
			if (_done)
				break;
			
			int walls = [maze wallsForTileX:lx Y:ly];

			if (walls & kWallAbove)
				break;
	
			ly--;
			
			walls = [maze wallsForTileX:lx Y:ly];
			
			if ((!(walls & kWallRight)) || (!(walls & kWallLeft)))
				_done = TRUE;
				
			[maze addTileToPathX:lx Y:ly];
		}
		if (direction == 2) // right
		{
			if (_done)
				break;
			
			int walls = [maze wallsForTileX:lx Y:ly];
			
			if (walls & kWallRight)
				break;
			
			lx++;
			
			walls = [maze wallsForTileX:lx Y:ly];
			
			if ((!(walls & kWallAbove)) || (!(walls & kWallBelow)))
				_done = TRUE;
			
			[maze addTileToPathX:lx Y:ly];
		}
	
		if (direction == 3) // bottom
		{
			if (_done)
				break;
			
			int walls = [maze wallsForTileX:lx Y:ly];
			
			if (walls & kWallBelow)
				break;
			
			ly++;
			
			walls = [maze wallsForTileX:lx Y:ly];
			
			if ((!(walls & kWallRight)) || (!(walls & kWallLeft)))
				_done = TRUE;
			
			[maze addTileToPathX:lx Y:ly];
		}
		
		if (direction == 4) // left
		{
			if (_done)
				break;
			
			int walls = [maze wallsForTileX:lx Y:ly];
			
			if (walls & kWallLeft)
				break;
			
			lx--;
			
			walls = [maze wallsForTileX:lx Y:ly];
			
			if ((!(walls & kWallAbove)) || (!(walls & kWallBelow)))
				_done = TRUE;
			
			[maze addTileToPathX:lx Y:ly];
		}		
	}

	[pathLayer setNeedsDisplay];
	
	[self checkVictory];
}

- (void)gamestarts:(NSNotification *)notification
{
	[mazeLayer setNeedsDisplay];
	[pathLayer setNeedsDisplay];

}

- (void)toggleCut:(NSNotification *)notification
{
	cutMode = !cutMode;
	[pathLayer setNeedsDisplay];
}

- (void)togglePause:(NSNotification *)notification
{
	paused = !paused;
}

- (void)advance
{
	[self reset];

	if (maze)
	{
		int num = [maze num];
		int levels = [maze levelsForCurrentSet];
		NSString *ls = [NSString stringWithString:[maze levelset]];


		[maze stop];

        maze = nil;
		
		if (![ls isEqualToString:@"Randomized"] && ++num <= levels)
		{
			maze = [[Maze alloc] initWithMaze:ls Number:num];
			
			[self gamestarts:nil];
		}
		else
			[[NSNotificationCenter defaultCenter] postNotificationName:@"mainmenu" object:self];
	}
}

- (void)reset
{
	if ([[UIDevice currentDevice].systemVersion doubleValue] >=5.0) {
		[starEmitter removeFromSuperlayer];
		starEmitter = nil;
	}
	
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:0.0f] forKey:kCATransactionAnimationDuration];


	textLayer.opacity = 0.0;
	duckLayer.opacity = 0.0;
	flashLayer.opacity = 0.0;
	goldmedalLayer.opacity = 0.0;
	silvermedalLayer.opacity = 0.0;
	[goldmedalLayer removeAllAnimations];
	[silvermedalLayer removeAllAnimations];
	
	[duckLayer setValue:[NSNumber numberWithFloat:0.1] forKeyPath:@"transform.scale"];

	[CATransaction commit];

	done = FALSE;
}

//- (void)animationTimer:(NSTimer *)timer
//{
////	if (!paused && ![[self superview] isHidden])
////		[pathLayer setNeedsDisplay];
//}


- (void)touch:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSMutableArray *path = [maze path];
	CGPoint loc = [[touches anyObject] locationInView:self];
	int x = ((int)loc.x - BORDER) / kTilesizeX;
	int y = ((int)loc.y - BORDER) / kTilesizeY;
	int x_center_deviation = abs(((int)loc.x - BORDER) % kTilesizeX - ((kTilesizeX - 1) / 2));
	int y_center_deviation = abs(((int)loc.y - BORDER) % kTilesizeY - ((kTilesizeY - 1) / 2));
	NSDictionary *lastPosition = [path lastObject];
	int lastx = [[lastPosition objectForKey:@"y"] intValue];
	int lasty = [[lastPosition objectForKey:@"x"] intValue];
	NSUInteger pathLen = [path count];
	
	if (!(loc.x > BORDER && loc.x < MAZE_W - BORDER) ||
		!(loc.y > BORDER && loc.y < MAZE_H - BORDER) ||
		((x == lastx) && (y == lasty)))
		return;
	
//	printf("\n");
//	printf("x %f\n", loc.x - BORDER);
//	printf("x %i\n", x);
//	printf("x %i\n",x_center_deviation);
//	printf("y %f\n", loc.y - BORDER);
//	printf("y %i\n", y);
//	printf("y %i\n", y_center_deviation);
//	printf("\n");

	if (cutMode)
	{

		int i = 0;
		int eraseFrom = 0xFFFF;

		for (NSDictionary *point in path)
		{
			if (y == [[point objectForKey:@"y"] intValue] && x == [[point objectForKey:@"x"] intValue])
			{
				eraseFrom = i+1;
				break;
			}

			i++;
		}

		if (eraseFrom != 0xFFFF)
		{
			[path removeObjectsInRange:NSMakeRange(eraseFrom, [path count] - eraseFrom)];
			cutMode = !cutMode;
			[pathLayer setNeedsDisplay];
		}

		return;
	}

	NSUInteger prev = [path count];
	if (done)
		return;

	NSDictionary *currentPosition = [path lastObject];
	uint8_t lx = [[currentPosition objectForKey:@"x"] intValue];
	uint8_t ly = [[currentPosition objectForKey:@"y"] intValue];
	uint8_t l_tile = [maze wallsForTileX:lx Y:ly];

	
	// fucking fixups
	float tmp = loc.x;
	loc.x = loc.y;
	loc.y = tmp;
	loc.x = MAZE_H - loc.x;


	if (CGRectContainsPoint(CGRectMake(BORDER + kDeadRegion + ((kMaxY-1)-ly-1) * kTilesizeX,
									   BORDER + kDeadRegion + (lx+1) * kTilesizeY,
									   kTilesizeX - kDeadRegion*2,
									   kTilesizeY - kDeadRegion*2), loc))
	{	// below right
		if (!(l_tile & kWallRight) && !([maze wallsForTileX:lx+1 Y:ly] & kWallBelow))
		{
			[maze addTileToPathX:lx+1 Y:ly];
			[maze addTileToPathX:lx+1 Y:ly+1];
		}
		else if (!(l_tile & kWallBelow) && !([maze wallsForTileX:lx Y:ly+1] & kWallRight))
		{
			[maze addTileToPathX:lx Y:ly+1];
			[maze addTileToPathX:lx+1 Y:ly+1];
		}
	}
	else if (CGRectContainsPoint(CGRectMake(BORDER + kDeadRegion + ((kMaxY-1)-ly-1) * kTilesizeX,
											BORDER + kDeadRegion + (lx-1) * kTilesizeY,
											kTilesizeX - kDeadRegion*2,
											kTilesizeY - kDeadRegion*2), loc))
	{	// below left
		if (!(l_tile & kWallLeft) && !([maze wallsForTileX:lx-1 Y:ly] & kWallBelow))
		{
			[maze addTileToPathX:lx-1 Y:ly];
			[maze addTileToPathX:lx-1 Y:ly+1];
		}
		else if (!(l_tile & kWallBelow) && !([maze wallsForTileX:lx Y:ly+1] & kWallLeft))
		{
			[maze addTileToPathX:lx Y:ly+1];
			[maze addTileToPathX:lx-1 Y:ly+1];
		}
	}
	// above right
	else if (CGRectContainsPoint(CGRectMake(BORDER + kDeadRegion + ((kMaxY-1)-ly+1) * kTilesizeX,
											BORDER + kDeadRegion + (lx+1) * kTilesizeY,
											kTilesizeX - kDeadRegion*2,
											kTilesizeY - kDeadRegion*2), loc))
	{
		if (!(l_tile & kWallRight) && !([maze wallsForTileX:lx+1 Y:ly] & kWallAbove))
		{
			[maze addTileToPathX:lx+1 Y:ly];
			[maze addTileToPathX:lx+1 Y:ly-1];
		}
		else if (!(l_tile & kWallAbove) && !([maze wallsForTileX:lx Y:ly-1] & kWallRight))
		{
			[maze addTileToPathX:lx Y:ly-1];
			[maze addTileToPathX:lx+1 Y:ly-1];
		}
	}
	// above left
	else if (CGRectContainsPoint(CGRectMake(BORDER + kDeadRegion + ((kMaxY-1)-ly+1) * kTilesizeX,
											BORDER + kDeadRegion + (lx-1) * kTilesizeY,
											kTilesizeX - kDeadRegion*2,
											kTilesizeY - kDeadRegion*2), loc))
	{
		if (!(l_tile & kWallLeft) && !([maze wallsForTileX:lx-1 Y:ly] & kWallAbove))
		{
			[maze addTileToPathX:lx-1 Y:ly];
			[maze addTileToPathX:lx-1 Y:ly-1];
		}
		else if (!(l_tile & kWallAbove) && !([maze wallsForTileX:lx Y:ly-1] & kWallLeft))
		{
			[maze addTileToPathX:lx Y:ly-1];
			[maze addTileToPathX:lx-1 Y:ly-1];
		}
	}
	else if (CGRectContainsPoint(CGRectMake(BORDER + kDeadRegion + ((kMaxY-1)-ly+1) * kTilesizeX,
											BORDER + kDeadRegion + lx * kTilesizeY,
											kTilesizeX * ly,
											kTilesizeY - kDeadRegion*2), loc))
	{ // far above
		//printf("above");
		int oury = BORDER + ((kMaxY-1)-ly+1) * kTilesizeY;
		int steps = ((loc.x - oury) / kTilesizeY) + 1;
		BOOL free = TRUE;

		for (int i = 0; i < steps; i++)
			if ([maze wallsForTileX:lx Y:ly-i] & kWallAbove)
				free = FALSE;

		if (free)
			for (int i = 1; i <= steps; i++)
				[maze addTileToPathX:lx Y:ly-i];
	}
	else if (CGRectContainsPoint(CGRectMake(BORDER + kDeadRegion + ((kMaxY-1)-ly) * kTilesizeX,
											BORDER + kDeadRegion + (lx+1) * kTilesizeY,
											kTilesizeX - kDeadRegion*2,
											kTilesizeY * (kMaxX - lx - 1)), loc))
	{ // far right
		//printf("right");
		int ourx = BORDER + (lx+1) * kTilesizeX;
		int steps = ((loc.y - ourx) / kTilesizeX) + 1;
		BOOL free = TRUE;

		for (int i = 0; i < steps; i++)
			if ([maze wallsForTileX:lx+i Y:ly] & kWallRight)
				free = FALSE;

		if (free)
			for (int i = 1; i <= steps; i++)
				[maze addTileToPathX:lx+i Y:ly];

	}
	else if (CGRectContainsPoint(CGRectMake(BORDER + kDeadRegion + ((kMaxY-1)-ly) * kTilesizeX,
											BORDER,
											kTilesizeX - kDeadRegion*2,
											lx * kTilesizeY), loc))
	{ // far left
		//printf("left");
		int ourx = BORDER + (lx+1) * kTilesizeX;
		int steps = ((loc.y - ourx) / -kTilesizeX);
		BOOL free = TRUE;


		for (int i = 0; i < steps; i++)
			if ([maze wallsForTileX:lx-i Y:ly] & kWallLeft)
				free = FALSE;

		if (free)
			for (int i = 1; i <= steps; i++)
				[maze addTileToPathX:lx-i Y:ly];
	}
	else if (CGRectContainsPoint(CGRectMake(BORDER,
											BORDER + kDeadRegion + lx * kTilesizeY,
											(kMaxY-ly-1) * kTilesizeX,
											kTilesizeY - kDeadRegion*2), loc))
	{ // far below
		//printf("below");
		int oury = BORDER + ((kMaxY-1)-ly+1) * kTilesizeY;
		int steps = ((loc.x - oury) / -kTilesizeY);
		BOOL free = TRUE;

		for (int i = 0; i < steps; i++)
			if ([maze wallsForTileX:lx Y:ly+i] & kWallBelow)
				free = FALSE;

		if (free)
			for (int i = 1; i <= steps; i++)
				[maze addTileToPathX:lx Y:ly+i];
	}
	
	if (pathLen == [path count] && sqrtf(x_center_deviation * x_center_deviation + y_center_deviation * y_center_deviation) < 10) // hit pretty center and nothing done yet
	{
		BOOL exists = [maze existsPathFromTileX:lx Y:ly toTileX:x Y:y withSteps:6];
		
		if (exists)
		{
			NSArray * a = [maze pathFromTileX:lx Y:ly toTileX:x Y:y withSteps:6];

			//NSLog([a description]);

			for (NSUInteger i = 0; i < [a count]; i++)
			{
				for (NSUInteger v = i+1; v < [a count]; v++)
				{
					uint8_t hx = [[[a objectAtIndex:i] valueForKey:@"x"] intValue];
					uint8_t hy = [[[a objectAtIndex:i] valueForKey:@"y"] intValue];
					uint8_t tx = [[[a objectAtIndex:v] valueForKey:@"x"] intValue];
					uint8_t ty = [[[a objectAtIndex:v] valueForKey:@"y"] intValue];	
					if (hx == tx && hy == ty)
					{
						NSMutableArray *ma = [NSMutableArray arrayWithArray:a];
						[ma removeObjectsInRange:NSMakeRange(i, v-i)];
						a = ma;
						//NSLog(@"rem");

						//NSLog([a description]);
						break;

					}
				}
			}
			for (int i = (int)[a count]-2; i >= 0; i--)
				[maze addTileToPathX:[[[a objectAtIndex:i] valueForKey:@"x"] intValue] Y:[[[a objectAtIndex:i] valueForKey:@"y"] intValue]];
		}
	}
	
	NSUInteger post = [path count];
	
	if (prev != post)
		[pathLayer setNeedsDisplay];


	[self checkVictory];
}

- (void)checkVictory
{
	NSDictionary *lpoint = [[maze path] lastObject];
	uint8_t lx = [[lpoint objectForKey:@"x"] intValue];
	uint8_t ly = [[lpoint objectForKey:@"y"] intValue];
	
	if ((ly == 0) && (lx == [maze end]))
	{
		[CATransaction begin];
		[CATransaction setValue:[NSNumber numberWithFloat:3.0f] forKey:kCATransactionAnimationDuration];
		
		
		duckLayer.opacity = 1.0;
		[duckLayer setValue:[NSNumber numberWithFloat:1.0] forKeyPath:@"transform.scale"];
		[CATransaction commit];
		
		NSString *medalStr;
		int secs = [maze seconds];
		int points = [prefs pointsForFinishInSeconds:secs];
		int medal = [prefs finishLevel:[maze num]
                                 inSet:[maze levelset]
                             afterSecs:secs
                          withSolution:(int)[[maze path] count]];
		//int score = [prefs score];
		
		if (medal == 2)
			medalStr = @"Gold";
		else if (medal == 1)
			medalStr = @"Silver";
		else
			medalStr = @"None";
		
		
		textLayer.string = [NSString stringWithFormat:@"Time:     %i sec\n\nPoints:   %i\n\nMedal:   %@", [maze seconds], points, medalStr];
		
		[CATransaction begin];
		[CATransaction setValue:[NSNumber numberWithFloat:1.0f] forKey:kCATransactionAnimationDuration];
		textLayer.opacity = 1.0;
		[CATransaction commit];
		
		[self performSelector:@selector(advance) withObject:nil afterDelay:5.0];
		
		
		if (medal == 2)
		{
			goldmedalLayer.opacity = 1.0;
			CABasicAnimation *b;
			b=[CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
			b.duration=3.0;
			b.repeatCount=0;
			b.fromValue=[NSNumber numberWithFloat:-300.0];
			b.toValue=[NSNumber numberWithFloat:300.0];
			[b setFillMode:kCAFillModeForwards];
			[b setRemovedOnCompletion:NO];
			[goldmedalLayer addAnimation:b forKey:@"animateTranslation"];
		}
		else if (medal == 1)
		{
			silvermedalLayer.opacity = 1.0;
			CABasicAnimation *a;
			a=[CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
			a.duration=3.0;
			a.repeatCount=0;
			a.fromValue=[NSNumber numberWithFloat:-300.0];
			a.toValue=[NSNumber numberWithFloat:300.0];
			[a setFillMode:kCAFillModeForwards];
			[a setRemovedOnCompletion:NO];
			[silvermedalLayer addAnimation:a forKey:@"animateTranslation"];
		}
		
		
		flashLayer.opacity = 0.5;
		
		CABasicAnimation *theAnimation;
		theAnimation=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
		theAnimation.duration=1.0;
		theAnimation.repeatCount=0;
		theAnimation.autoreverses=YES;
		theAnimation.fromValue=[NSNumber numberWithFloat:1.0];
		theAnimation.toValue=[NSNumber numberWithFloat:100.0];
		[flashLayer addAnimation:theAnimation forKey:@"animateScale"];
		
		done = TRUE;
		
		
		
		
		
		if ([[UIDevice currentDevice].systemVersion doubleValue] >=5.0) {
			starEmitter = [NSClassFromString(@"CAEmitterLayer") layer];
			((CAEmitterLayer*)starEmitter).opacity = 0;
			((CAEmitterLayer*)starEmitter).emitterPosition = CGPointMake(1024/2, 300);
			((CAEmitterLayer*)starEmitter).emitterSize = CGSizeMake(10, 10);
			((CAEmitterLayer*)starEmitter).emitterMode = kCAEmitterLayerOutline;
			((CAEmitterLayer*)starEmitter).emitterShape = kCAEmitterLayerCircle;
			
			NSObject* fire = [NSClassFromString(@"CAEmitterCell") emitterCell];
			((CAEmitterCell*)fire).birthRate = 50;
			((CAEmitterCell*)fire).lifetime = 2.0;
			((CAEmitterCell*)fire).lifetimeRange = 0.5;
			((CAEmitterCell*)fire).contents = (id)[[UIImage imageNamed:@"star_sprite.png"] CGImage];
			((CAEmitterCell*)fire).velocity = 300;
			((CAEmitterCell*)fire).velocityRange = 100;
			((CAEmitterCell*)fire).emissionRange = 100;
			((CAEmitterCell*)fire).spinRange = 10;
			
			[((CAEmitterCell*)fire) setName:@"fire"];
			
			//add the cell to the layer and we're done
			((CAEmitterLayer*)starEmitter).emitterCells = [NSArray arrayWithObject:fire];
			
			
			
			[[self layer] insertSublayer:starEmitter atIndex:1];
			
			CABasicAnimation *a;
			a=[CABasicAnimation animationWithKeyPath:@"opacity"];
			a.duration=0.5;
			a.repeatCount= 0;
			a.autoreverses=NO;
			a.fromValue=[NSNumber numberWithFloat:0.0];
			a.toValue=[NSNumber numberWithFloat:1.0];
			[a setRemovedOnCompletion:NO];
			[a setFillMode:kCAFillModeForwards];
			[starEmitter addAnimation:a forKey:@"animateOpacity1"];
			
			a=[CABasicAnimation animationWithKeyPath:@"opacity"];
			a.beginTime = CACurrentMediaTime()+2.5;
			[a setFillMode:kCAFillModeForwards];
			a.duration=0.5;
			a.repeatCount= 0;
			a.autoreverses=NO;
			[a setRemovedOnCompletion:NO];
			a.fromValue=[NSNumber numberWithFloat:1.0];
			a.toValue=[NSNumber numberWithFloat:0.0];
			[starEmitter addAnimation:a forKey:@"animateOpacity2"];
		}
	}
	
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touch:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touch:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}

@end
