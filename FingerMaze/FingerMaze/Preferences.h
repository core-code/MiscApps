//
//  Preferences.h
//  FingerMaze
//
//  Created by CoreCode on 04.04.10.
/*	Copyright (c) 2016 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//


@interface Preferences : NSObject {

	float fastestLevel;
	uint16_t goldMedals, silverMedals, score, finishedLevels;
}


@property (nonatomic, readonly) uint16_t goldMedals;
@property (nonatomic, readonly) uint16_t silverMedals;
@property (nonatomic, readonly) uint16_t finishedLevels;
@property (nonatomic, readonly) uint16_t score;
@property (nonatomic, readonly) float fastestLevel;

- (int)pointsForFinishInSeconds:(uint16_t)seconds;
- (int)finishLevel:(int)level inSet:(NSString *)levelSet afterSecs:(float)secs withSolution:(int)tiles;
- (void)addDict:(NSDictionary *)dict;
- (void)reset;


@end
