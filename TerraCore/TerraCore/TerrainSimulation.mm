//
//  TerrainSimulation.m
//  fraktale
//
//  Created by CoreCode on 08.12.08.
/*	Copyright (c) 2016 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

#import "TerrainSimulation.h"

extern FractalTerrain *gFractalTerrain;

NSMutableArray *tmpMsg;

@implementation TerrainSimulation

- (id)init
{
	if ((self = [super init]))
	{	
		Light *light = [[Light alloc] init];
		[light setPosition:vector3f(0, 70, 0)];		
		[[scene lights] addObject:light];

		[[scene objects] addObject:gFractalTerrain];	
		[[scene camera] setAxisConfiguration:AXIS_CONFIGURATION(kXAxis, kYAxis, kZAxis)];

		[self resetCamera];
		
		globalSettings.disableVBLSync = YES;
		
		[gFractalTerrain rebuild:self];
		speed = 0.0;
		
		if (globalInfo.gpuVendor == kATI)
		{
			NSBeginAlertSheet(@"Warning", @"I'll use it at my own risk", nil, nil, nil, self, NULL, NULL, nil, @"NOTE:	ATI videocards have a problem with TerraCore as of Mac OS X 10.5.6. Maybe future system updates resolve driver problems and thus fix TerraCore");
		}	
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
	vector3f rot = [[scene camera] rotation];

	rot[1] -= [theEvent deltaX] / 10.0;
	rot[0] -= [theEvent deltaY] / 10.0;
	
	//cout << rot << endl;
	
	[[scene camera] setRotation:rot];
}

- (void)scrollWheel:(NSEvent *)theEvent
{
	speed += [theEvent deltaY] / 100.0;
}

- (void)stopCamera
{
	speed = 0.0;
}

- (void)resetCamera
{
	[[scene camera] setPosition:vector3f(300, 250, 0)];
	[[scene camera] setRotation:vector3f(-45, 90, 0)];
	speed = 0.0;
}
@end