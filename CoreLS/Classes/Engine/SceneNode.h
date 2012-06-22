//
//  SceneNode.h
//  Core3D
//
//  Created by CoreCode on 21.11.07.
//  Copyright CoreCode 2007 - 2008. All rights reserved.
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