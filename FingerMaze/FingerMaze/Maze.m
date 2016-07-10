//
//  Maze.m
//  FingerMaze
//
//  Created by CoreCode on 30.03.10.
/*	Copyright (c) 2016 CoreCode
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

#import "Maze.h"

int ___maze(char maz[], int y, int x, char vc, char hc, char fc);
void generate_maze(void);
extern char maze_data[kMaxY * 2 + 1][kMaxX * 2 + 1];
void randgen_init(void);
void get_openings(unsigned char *start, unsigned char *end);
typedef struct {
    unsigned int up      : 1;
    unsigned int right   : 1;
    unsigned int down    : 1;
    unsigned int left    : 1;
    unsigned int path    : 1;
    unsigned int visited : 1;
} cell_t;
typedef cell_t *maze_t;

void CreateMaze (maze_t maze, int width, int height);
void SolveMaze (maze_t maze, int width, int height);
void PrintMaze (maze_t maze, int width, int height);
void PrintMazeArray (maze_t maze, int width, int height, NSMutableArray *a);

NSMutableArray * maze_main();

extern NSArray *levelsNames;
extern NSArray *levelsCounts;

@implementation Maze

@synthesize start, end, path, num, levelset, seconds;

- (id)initWithMaze:(NSString *)_levelset Number:(uint16_t)_num
{
    if ((self = [super init]))
	{
		
		NSArray *lines;
		levelset = _levelset;
		num = _num;
		
		if ([levelset isEqualToString:@"Randomized"])
		{
			NSMutableArray *l = [NSMutableArray arrayWithCapacity:kMaxY];
			
			if (num == 1) // maz.c
			{
				int x = kMaxX * 2 + 1;
				int y = kMaxY * 2 + 1;
				char            maz[x * y];

				if (___maze(maz, y, x, '#', '#', ' ') == 0)
				{
					for (int i = 0; i < (x * y); ++i)
					{
//						(void) putchar(maz[i]);
						if ((i % x) == 0)
						//	[l addObject:[NSString stringWithCString:&maz[i] length:x]];
							[l addObject:[[NSString alloc] initWithBytes:&maz[i] length:x encoding:NSASCIIStringEncoding]];
//						if (((i + 1) % x) == 0)
//							putchar('\n');
					}
							 
				}
				else
					 fprintf(stderr, "Couldn't make the maze\n");
				
				start = 0;
				end = kMaxX-1;
 			}
			else if (num == 2) // maze.m
			{
				l = maze_main();
				
				start = 0;
				end = kMaxX-1;	
			}
			else if (num == 3) // MazeGen.m
			{
				srand ((int) time ((time_t *) NULL));
				
				maze_t _maze = (maze_t) calloc (kMaxX * kMaxY, sizeof (cell_t));
				if (_maze == NULL) {
					(void) fprintf (stderr, "Cannot allocate memory!\n");
					exit (EXIT_FAILURE);
				}
				CreateMaze (_maze, kMaxX, kMaxY);
				
				PrintMazeArray (_maze, kMaxX, kMaxY, l);
				
				start = 0;
				end = kMaxX-1;				
			}

			
			lines = l;
		}
		else
		{
			NSString *maze1 = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@%i", _levelset, num] ofType:@"txt"] encoding:NSUTF8StringEncoding error:NULL];
			lines = [maze1 componentsSeparatedByString:@"\n"];
			
			
			
			start = (([[lines objectAtIndex:0] rangeOfString:@" "].location+1) / 2) - 1;
			end = (([[lines objectAtIndex:56] rangeOfString:@" "].location+1) / 2) - 1;
			
			
			//	printf("%i %i", start, end);			
		}
		
		NSMutableArray *newLines = [NSMutableArray arrayWithCapacity:[lines count]];
		NSEnumerator *enumerator = [lines reverseObjectEnumerator];
		for (NSString *element in enumerator)
		{
			if ([element length] > 5)
				 [newLines addObject:element];

		}
		lines = newLines;
		for (int i = 1; i < (kMaxY * 2); i+=2)
		{
			for (int c = 1; c < (kMaxX * 2); c+=2)
			{
				gridWall[c/2][i/2] = 0;

				if ([[lines objectAtIndex:i-1] characterAtIndex:c] == '#')
					gridWall[c/2][i/2] |= kWallAbove;

				if ([[lines objectAtIndex:i+1] characterAtIndex:c] == '#')
					gridWall[c/2][i/2] |= kWallBelow;

				if ([[lines objectAtIndex:i] characterAtIndex:c-1] == '#')
					gridWall[c/2][i/2] |= kWallLeft;

				if ([[lines objectAtIndex:i] characterAtIndex:c+1] == '#')
					gridWall[c/2][i/2] |= kWallRight;
			}
		}

		gridWall[start][kMaxY - 1] |= kWallBelow;
		gridWall[end][0] |= kWallAbove;
		
		
		NSMutableArray *p = [[NSMutableArray alloc] initWithCapacity:200];
		[p addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:start], @"x", [NSNumber numberWithInt:kMaxY-1], @"y", nil]];
		[self setPath:p];
		
		seconds = 0;
		paused = FALSE;
		updateTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0f) target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(togglePause:) name:@"pausegame" object:nil];
	}

    return self;
}

- (void)togglePause:(NSNotification *)notification
{
	paused = !paused;
}

- (void)updateTimer:(NSTimer *)timer
{	
	if (!paused)
		seconds++;
}

- (uint8_t)wallsForTileX:(uint8_t)x Y:(uint8_t)y
{
	return gridWall[x][y];
}

- (void)addTileToPathX:(uint8_t)x Y:(uint8_t)y
{
//	BOOL done = FALSE;
//
//	if (([path count] > 1))
//	{
//		NSDictionary *prev = [path objectAtIndex:[path count] - 2];
//		uint8_t px = [[prev objectForKey:@"x"] intValue];
//		uint8_t py = [[prev objectForKey:@"y"] intValue];
//
//		if (x == px && y == py)
//		{
//			[path removeLastObject];
//			done = TRUE;
//		}
//	}
//	if (!done)
	{
		int erase = -1;
		
		for (int i = [path count]-1; i >= 0; i--)
			if (([[[path objectAtIndex:i] valueForKey:@"x"] intValue] == x) && ([[[path objectAtIndex:i] valueForKey:@"y"] intValue] == y))
				erase = i;
		
		if (erase >= 0 && erase < (int)[path count] - 1)
			[path removeObjectsInRange:NSMakeRange(erase+1, [path count] - erase - 1)];
		else
			[path addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:x], @"x", [NSNumber numberWithInt:y], @"y", nil]];
	}
}

- (void)resetPath
{
	id first = [path objectAtIndex:0];
	[path removeAllObjects];
	[path addObject:first];
}

- (int)levelsForCurrentSet
{
	return [[levelsCounts objectAtIndex:[levelsNames indexOfObject:levelset]] intValue];
}

- (BOOL)existsPathFromTileX:(int)lx Y:(int)ly toTileX:(int)x Y:(int)y withSteps:(int)steps
{
	if (!steps || lx < 0 || ly < 0 || lx >= kMaxX || ly >= kMaxY)
		return NO;
	else if ((lx == x) && (ly == y))
		return YES;
	else
	{
		uint8_t l_tile = gridWall[lx][ly];

		return ((!(l_tile & kWallBelow) && [self existsPathFromTileX:lx Y:ly+1 toTileX:x Y:y withSteps:steps-1]) ||
				(!(l_tile & kWallAbove) && [self existsPathFromTileX:lx Y:ly-1 toTileX:x Y:y withSteps:steps-1]) ||
				(!(l_tile & kWallRight) && [self existsPathFromTileX:lx+1 Y:ly toTileX:x Y:y withSteps:steps-1]) ||
				(!(l_tile & kWallLeft) && [self existsPathFromTileX:lx-1 Y:ly toTileX:x Y:y withSteps:steps-1]));
	}
}

- (NSArray *)pathFromTileX:(int)lx Y:(int)ly toTileX:(int)x Y:(int)y withSteps:(int)steps
{
	if (!steps || lx < 0 || ly < 0 || lx >= kMaxX || ly >= kMaxY)
		return nil;
	else if ((lx == x) && (ly == y))
		return [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:x], @"x", [NSNumber numberWithInt:y], @"y", nil]];
	else
	{
		uint8_t l_tile = gridWall[lx][ly];
		
		NSArray *a;
		if (!(l_tile & kWallBelow) && (a = [self pathFromTileX:lx Y:ly+1 toTileX:x Y:y withSteps:steps-1]))
			return [a arrayByAddingObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:lx], @"x", [NSNumber numberWithInt:ly], @"y", nil]];
		if (!(l_tile & kWallAbove) && (a = [self pathFromTileX:lx Y:ly-1 toTileX:x Y:y withSteps:steps-1]))
			return [a arrayByAddingObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:lx], @"x", [NSNumber numberWithInt:ly], @"y", nil]];		
		if (!(l_tile & kWallRight) && (a = [self pathFromTileX:lx+1 Y:ly toTileX:x Y:y withSteps:steps-1]))
			return [a arrayByAddingObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:lx], @"x", [NSNumber numberWithInt:ly], @"y", nil]];
		if (!(l_tile & kWallLeft) && (a = [self pathFromTileX:lx-1 Y:ly toTileX:x Y:y withSteps:steps-1]))
			return [a arrayByAddingObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:lx], @"x", [NSNumber numberWithInt:ly], @"y", nil]];
		
		return nil;
	}
}

- (void)freeze
{
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Frozen"];
	[[NSUserDefaults standardUserDefaults] setObject:path forKey:@"FrozenPath"];
	[[NSUserDefaults standardUserDefaults] setObject:levelset forKey:@"FrozenLevel"];	
	[[NSUserDefaults standardUserDefaults] setInteger:num forKey:@"FrozenNum"];
	[[NSUserDefaults standardUserDefaults] setInteger:seconds forKey:@"FrozenSeconds"];

	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)stop
{
	[updateTimer invalidate];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

}
@end
