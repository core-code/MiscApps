//
//  LSystemSimulation.m
//  fraktale
//
//  Created by CoreCode on 07.02.09.
/*	Copyright (c) 2016 CoreCode
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

#import "LSystemSimulation.h"

extern LSystem *gLSystem;

NSMutableArray *tmpMsg;

@implementation LSystemSimulation

- (id)init
{
	if ((self = [super init]))
	{	
		Light *light = [[Light alloc] init];
		[light setPosition:vector3f(0, 70, 0)];		
		[[scene lights] addObject:light];

		[[scene camera] setAxisConfiguration:AXIS_CONFIGURATION(kXAxis, kYAxis, kZAxis)];
		[gLSystem setAxisConfiguration:AXIS_CONFIGURATION(kXAxis, kYAxis, kZAxis)];
		
		[[scene objects] addObject:gLSystem];	
		
		globalSettings.disableVBLSync = YES;
		[gLSystem rebuild:self];
		[gLSystem resetCameraFront:self];
		speed = 0.0;
	}
	return self;
}

- (void)update
{
	[[scene camera] setPositionByMovingForward:speed];
}

- (void)render
{
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	vector3f rot;
	if ([gLSystem cameraMode] == 0)
	{
		rot = [[scene camera] rotation];
		rot[1] 	-= [theEvent deltaX] / 10.0;
		rot[0] -= [theEvent deltaY] / 10.0;
		[[scene camera] setRotation:rot];
	}
	else
	{
		rot = [gLSystem rotation];
		rot[1] += [theEvent deltaX] / 10.0;
		rot[0] -= [theEvent deltaY] / 10.0;
		[gLSystem setRotation:rot];
	}
}

- (void)scrollWheel:(NSEvent *)theEvent
{
	speed += [theEvent deltaY] / 100.0;
}

- (void)stopCamera
{
	speed = 0.0;
}
@end	