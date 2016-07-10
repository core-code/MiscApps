//
//  Camera.m
//  Core3D
//
//  Created by CoreCode on 21.11.07.
/*	Copyright (c) 2016 CoreCode
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
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