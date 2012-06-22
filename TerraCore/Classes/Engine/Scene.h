//
//  Scene.h
//  Core3D
//
//  Created by CoreCode on 16.11.07.
//  Copyright CoreCode 2007 - 2008. All rights reserved.
//


@interface Scene : NSObject
{
	Camera *camera;
	NSMutableSet *lights;
	NSMutableArray *objects;
	Simulation *simulator;	
}

@property(readonly, nonatomic) Camera *camera;
@property(retain, nonatomic) NSMutableSet *lights;
@property(retain, nonatomic) NSMutableArray *objects;
@property(retain, nonatomic) Simulation *simulator;

+ sharedScene;
- (void)update;
- (void)render;
- (void)reshape:(NSArray *)size;

@end