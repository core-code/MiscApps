//
//  Drive.h
//  SMARTReporter
//
//  Created by CoreCode on Sat Feb 28 2004.
/*	Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

@class DriveList;

@interface Drive : NSObject <NSCoding>
{
	NSString		*model;
	NSString		*size;
	NSString		*smart;

	NSString		*name;
	NSString		*serial;
	NSNumber		*bsdnum;

	BOOL			watch;
	char			status;

	NSDecimalNumber	*interval;
	NSTimer			*timer;
	DriveList		*driveList;
}

- (void)getSMARTData;
- (void)createTimer;
- (void)updateTimer;
- (void)timerTarget:(NSTimer *)ourtimer;
- (void)notifyIfDriveIsFailing;

//<NSCoding>
- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;


@property (assign, nonatomic) DriveList	*driveList;
@property (retain, nonatomic) NSString *name;
@property (retain, nonatomic) NSString *smart;
@property (retain, nonatomic) NSString *model;
@property (retain, nonatomic) NSString *serial;
@property (retain, nonatomic) NSString *size;
@property (retain, nonatomic) NSNumber *bsdnum;
@property (retain, nonatomic) NSTimer *timer;
@property (retain, nonatomic) NSDecimalNumber *interval;
@property (assign, nonatomic) char status;
@property (assign, nonatomic) BOOL watch;

@end
