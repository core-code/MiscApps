//
//  SceneNode.h
//  Core3D
//
//  Created by CoreCode on 21.11.07.
/*	Copyright (c) 2016 CoreCode
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//


@interface SceneNode : NSObject
{	
	BOOL					enabled;
	vector3f				position, rotation, speed, angularSpeed;
	SceneNode				*relativeModeTarget;	
	axisConfigurationEnum	relativeModeAxisConfiguration, axisConfiguration;
	NSMutableArray			*children;
}

@property(assign, nonatomic) BOOL enabled;
@property(assign, nonatomic) axisConfigurationEnum relativeModeAxisConfiguration;
@property(assign, nonatomic) axisConfigurationEnum axisConfiguration;
@property(assign, nonatomic) vector3f position;
@property(assign, nonatomic) vector3f rotation;
@property(assign, nonatomic) vector3f speed;
@property(assign, nonatomic) vector3f angularSpeed;
@property(retain, nonatomic) SceneNode *relativeModeTarget;
@property(retain, nonatomic) NSMutableArray *children;

- (void)setPositionByMovingForward:(float)amount;
- (void)setRotationFromLookAt:(vector3f)lookAt;
- (vector3f)getLookAt;

- (void)transform:(axisConfigurationEnum)axisRotation reverse:(BOOL)reverse;

- (void)reshapeNode:(NSArray *)size;
- (void)renderNode;
- (void)updateNode;

- (void)reshape:(NSArray *)size;
- (void)render;
- (void)update;

@end