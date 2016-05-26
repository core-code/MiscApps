//
//  LSystemSimulation.m
//  fraktale
//
//  Created by CoreCode on 07.02.09.
//  Copyright CoreCode 2009. All rights reserved.
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