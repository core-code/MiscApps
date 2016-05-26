//
//  TerrainSimulation.h
//  fraktale
//
//  Created by CoreCode on 08.12.08.
//  Copyright CoreCode 2008. All rights reserved.
//

#import "Core3D.h"

#import "FractalTerrain.h"


@interface TerrainSimulation : NSObject
{
	float speed;
}

- (void)update;
- (void)render;
- (void)stopCamera;
- (void)resetCamera;
@end