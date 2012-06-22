//
//  LSystemSimulation.h
//  fraktale
//
//  Created by CoreCode on 07.02.09.
//  Copyright CoreCode 2009. All rights reserved.
//

#import "Core3D.h"

#import "LSystem.h"

@interface LSystemSimulation : NSObject
{
	float speed;
}

- (void)update;
- (void)render;
- (void)stopCamera;
@end