//
//  Camera.h
//  Core3D
//
//  Created by CoreCode on 21.11.07.
//  Copyright CoreCode 2007 - 2008. All rights reserved.
//


@interface Camera : SceneNode
{
	float fov, nearPlane, farPlane;
}

@property(assign, nonatomic) float fov;
@property(assign, nonatomic) float nearPlane;
@property(assign, nonatomic) float farPlane;

- (void)updateProjection;
- (void)applyCameraTransformation;

@end