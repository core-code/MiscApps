//
//  SceneNode.m
//  Core3D
//
//  Created by CoreCode on 21.11.07.
/*	Copyright (c) 2016 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

#import "Core3D.h"


@implementation SceneNode

@synthesize position, rotation, relativeModeTarget, relativeModeAxisConfiguration, axisConfiguration, children, enabled, speed, angularSpeed;

- (id)init
{
	if ((self = [super init]))
	{
		axisConfiguration = kYXZRotation;
		relativeModeAxisConfiguration = kYXZRotation;
		relativeModeTarget = nil;
		children = [[NSMutableArray alloc] initWithCapacity:5];
		enabled = YES;
	}
	
	return self;
}

- (void)transform:(axisConfigurationEnum)axisRotation reverse:(BOOL)reverse
{
	if (!reverse)
		glTranslatef(position[0], position[1], position[2]);
	
	uint8 i;
	
	for (i = 0; i < 3; i++)	// this allows us to configure per-node the rotation order and axis to ignore (which is mostly useful for target mode)
	{
		uint8 axis = (axisRotation >> (i * 2)) & 3;

		if (axis != kDisabledAxis)
			glRotatef(reverse ? -rotation[axis] : rotation[axis], axis == kXAxis ? 1.0f : 0.0f, axis == kYAxis ? 1.0f : 0.0f, axis == kZAxis ? 1.0f : 0.0f);			
	}
	
	if (reverse)	// reverse is used for the camera
		glTranslatef(-position[0], -position[1], -position[2]);
}

- (void)update
{	
	if (enabled)
	{
		[self updateNode];
		position += speed;
		rotation += angularSpeed;
	}
	
	[children makeObjectsPerformSelector:@selector(update)];	
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@ 0x%8@>\n position: %f %f %f\n rotation: %f %f %f \n children:%@", [self class], self, position[0], position[1], position[2], rotation[0], rotation[1], rotation[2], [children description]];
}	

- (void)render
{	
	glPushMatrix(); 
	
	if (relativeModeTarget != nil)
		[relativeModeTarget transform:relativeModeAxisConfiguration reverse:FALSE];
	
	[self transform:axisConfiguration reverse:FALSE];

	if (enabled)
		[self renderNode];
		
	[children makeObjectsPerformSelector:@selector(render)];
	
	glPopMatrix();
}

- (void)reshape:(NSArray *)size
{
	[self reshapeNode:size];
	[children makeObjectsPerformSelector:@selector(reshapeNode:) withObject:size];
}

- (void)updateNode {}
- (void)renderNode {}
- (void)reshapeNode:(NSArray *)size {}

- (void)setRotationFromLookAt:(vector3f)lookAt
{
	static const vector3f forward = vector3f(0, 0, -1);
	vector3f direction = lookAt - position;
	vector3f direction_without_y = vector3f(direction[0], 0, direction[2]);
	
	float yrotdeg = deg(unsigned_angle(forward, direction_without_y));
	float xrotdeg = deg(unsigned_angle(direction_without_y, direction));
	
	rotation[0] = direction[1] > 0 ? xrotdeg : -xrotdeg;
	rotation[1] = direction[0] > 0 ? -yrotdeg : yrotdeg;
	rotation[2] = 0;
}

- (void)setPositionByMovingForward:(float)amount
{
	position += [self getLookAt] * amount;
}

- (vector3f)getLookAt
{
	matrix33f_c m;
	static const vector3f forward = vector3f(0, 0, -1);	
	vector3f rot = rotation;
	
	if (relativeModeTarget != nil)
	{
		NSLog(@"Warning: getLookAt for target mode probably broken"); // FIXME: fix this
		rot +=  [relativeModeTarget rotation];
	}
		
	matrix_rotation_euler(m, rad(rot[0]), rad(rot[1]), rad(rot[2]), euler_order_xyz);
	
	return transform_vector(m, forward);
}
@end