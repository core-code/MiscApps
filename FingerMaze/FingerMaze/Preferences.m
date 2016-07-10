//
//  Preferences.m
//  FingerMaze
//
//  Created by CoreCode on 04.04.10.
/*	Copyright (c) 2016 CoreCode
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

#import "Preferences.h"

extern NSArray *levelsNames;
extern NSArray *levelsCounts;

@implementation Preferences

@synthesize goldMedals, silverMedals, fastestLevel, score, finishedLevels;

- (id)init
{
    if ((self = [super init]))
	{
		fastestLevel = 999;

		for (NSString *levelName in levelsNames)
		{
			NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:levelName];
			for (NSString *key in dict) [self addDict:[dict objectForKey:key]];
		}
	}

    return self;
}

- (int)pointsForFinishInSeconds:(uint16_t)seconds
{	
	return MAX(600.0 / log10f(5+seconds) - 250, 0);
}

- (int)finishLevel:(int)level inSet:(NSString *)levelSet afterSecs:(float)secs withSolution:(int)tiles
{
//	NSLog(@"FINISHED: %@ %i %f %i", levelSet, level, secs, tiles);
	int goldtime = 25 + (tiles / 10);
	int silvertime = 50 + (tiles / 8);
	int newmedal;

	if (secs < goldtime)
		newmedal = 2;
	else if (secs < silvertime)
		newmedal = 1;
	else
		newmedal = 0;
	
	
	NSMutableDictionary *levels = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@", levelSet]]];
	NSDictionary *l = [levels objectForKey:[NSString stringWithFormat:@"%i", level]];

	
	if ((!l) || (secs < [[l objectForKey:@"Time"] floatValue]))
	{
		if (l)
		{
			int medal = [[l objectForKey:@"Medal"] intValue];
			if (medal == 1) silverMedals--;
			if (medal == 2) goldMedals--;
			if ([[l objectForKey:@"Time"] intValue] < 999)
				finishedLevels--;
			score -= [[l objectForKey:@"Points"] intValue];
		}
		
		NSDictionary *newDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[self pointsForFinishInSeconds:secs]], @"Points", [NSNumber numberWithInt:newmedal], @"Medal", [NSNumber numberWithFloat:secs], @"Time", nil];
		[levels setObject:newDict forKey:[NSString stringWithFormat:@"%i", level]];
		
		[self addDict:newDict];
		
		[[NSUserDefaults standardUserDefaults] setObject:levels forKey:[NSString stringWithFormat:@"%@", levelSet]];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
	
	return newmedal;
}

- (void)reset
{
	for (NSString *levelName in levelsNames)
		[[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionary] forKey:levelName];
	
	[[NSUserDefaults standardUserDefaults] synchronize];

	fastestLevel = 999;
	goldMedals = silverMedals = score = finishedLevels = 0;
}


- (void)addDict:(NSDictionary *)dict
{
	int medal = [[dict objectForKey:@"Medal"] intValue];
	float time = [[dict objectForKey:@"Time"] floatValue];

	if (medal == 1) silverMedals++;
	if (medal == 2) goldMedals++;
	if (time < 999)
		finishedLevels ++;
	if (time < fastestLevel) fastestLevel = time;
	score += [[dict objectForKey:@"Points"] intValue];
}

@end
