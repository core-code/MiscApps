//
//  TerrainSimulation.m
//  fraktale
//
//  Created by CoreCode on 08.12.08.
//  Copyright CoreCode 2008. All rights reserved.
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