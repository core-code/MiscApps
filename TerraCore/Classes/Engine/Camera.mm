//
//  Camera.m
//  Core3D
//
//  Created by CoreCode on 21.11.07.
//  Copyright CoreCode 2007 - 2008. All rights reserved.
//

#import "Core3D.h"


@implementation Camera

@synthesize fov, nearPlane, farPlane;

- (id)init
{
	if ((self = [super init]))
	{		
		fov = 45.0f;
		nearPlane = 1.0f;
		farPlane = 8000.0f;
		
		[self addObserver:self forKeyPath:@"fov" options:NSKeyValueObservingOptionNew context:NULL];
		[self addObserver:self forKeyPath:@"nearPlane" options:NSKeyValueObservingOptionNew context:NULL];		
		[self addObserver:self forKeyPath:@"farPlane" options:NSKeyValueObservingOptionNew context:NULL];		
	}
	
	return self;
}

- (void)reshapeNode:(NSArray *)size
{
	globalInfo.width = [[size objectAtIndex:0] intValue];
	globalInfo.height = [[size objectAtIndex:1] intValue];

	[self updateProjection];
}

- (void)applyCameraTransformation
{		
	[self transform:axisConfiguration reverse:TRUE];

	if (relativeModeTarget != nil)
		[relativeModeTarget transform:relativeModeAxisConfiguration reverse:TRUE];

	glGetFloatv(GL_MODELVIEW_MATRIX, globalInfo.viewMatrix.data());	
}

- (void)updateProjection
{
	glViewport(0, 0, globalInfo.width, globalInfo.height);
	
	glMatrixMode(GL_PROJECTION);
	
	matrix_perspective_yfov_RH(globalInfo.projectionMatrix, rad(fov), globalInfo.width / globalInfo.height, nearPlane, farPlane, z_clip_neg_one);
	glLoadMatrixf(globalInfo.projectionMatrix.data());	
	
    glMatrixMode(GL_MODELVIEW);
} 

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	[self updateProjection];
}

@end