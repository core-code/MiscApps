//
//  Maze.h
//  FingerMaze
//
//  Created by CoreCode on 30.03.10.
/*	Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

#import <UIKit/UIKit.h>



enum {
	kWallAbove = 1,
	kWallBelow = 2,
	kWallLeft = 4,
	kWallRight = 8,
};

@interface Maze : NSObject {
	BOOL paused;
	int seconds;
	uint8_t start, end, num;
	uint8_t gridWall[kMaxX][kMaxY];
	NSMutableArray *path;
	NSDate *startDate;
	NSString *levelset;
	NSTimer *updateTimer;
}

@property (nonatomic, readonly, strong) NSString *levelset;
@property (nonatomic, readonly) uint8_t start;
@property (nonatomic, readonly) uint8_t end;
@property (nonatomic, readonly) uint8_t num;
@property (nonatomic, strong) NSMutableArray *path;
@property (nonatomic, assign) int seconds;

- (id)initWithMaze:(NSString *)_levelset Number:(uint16_t)_num;
- (uint8_t)wallsForTileX:(uint8_t)x Y:(uint8_t)y;
- (void)addTileToPathX:(uint8_t)x Y:(uint8_t)y;
- (void)resetPath;
- (int)levelsForCurrentSet;
- (BOOL)existsPathFromTileX:(int)lx Y:(int)ly toTileX:(int)x Y:(int)y withSteps:(int)steps;
- (NSArray *)pathFromTileX:(int)lx Y:(int)ly toTileX:(int)x Y:(int)y withSteps:(int)steps;
- (void)freeze;
- (void)stop;
@end
