//
//  Scene.m
//  Core3D
//
//  Created by CoreCode on 16.11.07.
/*	Copyright (c) 2016 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

#import "Core3D.h"

extern NSMutableArray *tmpMsg;

Info globalInfo;
Settings globalSettings;
Scene *scene = nil;

@implementation Scene

@synthesize camera, lights, objects, simulator;

+ sharedScene
{
	if (scene == nil)
		scene = [[self alloc] init];

	return scene;
}

- (id)init
{
	if ((self = [super init]))
	{
		globalInfo.renderpass = kMainRenderPass;	
		globalInfo.frame = 0;
			
		([[NSString stringWithCString:(const char *)glGetString(GL_VENDOR)] hasPrefix:@"NVIDIA"]) ? globalInfo.gpuVendor = kNVIDIA : globalInfo.gpuVendor = kATI; // FIXME: if we ever get intel ogl 2.0 cards ...

		globalSettings.shadowFiltering = (shadowFilteringEnum) [[NSUserDefaults standardUserDefaults] integerForKey:@"shadowFiltering"];
		globalSettings.shadowMode = (shadowModeEnum) [[NSUserDefaults standardUserDefaults] integerForKey:@"shadowMode"];
		
		std::srand(time(NULL));

		glShadeModel(GL_SMOOTH);
		glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
	#if defined(TARGET_OS_IPHONE) && TARGET_OS_IPHONE
		glClearDepthf(1.0f);	
	#else
        glClearDepth(1.0f);
	#endif
		glEnable(GL_DEPTH_TEST); 
		glEnable(GL_CULL_FACE);
		glEnable(GL_COLOR_MATERIAL);
		glEnable(GL_RESCALE_NORMAL);
		glEnable(GL_MULTISAMPLE);

		glDepthFunc(GL_LESS);
		glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
			
		lights = [[NSMutableSet alloc] initWithCapacity:2];
		objects = [[NSMutableArray alloc] initWithCapacity:20];
		camera = [[Camera alloc] init];	

		glError()
	}
	
	return self;
}

- (void)reshape:(NSArray *)size
{
	[camera reshape:size];

	[objects makeObjectsPerformSelector:@selector(reshape:) withObject:size];	
}

- (void)processKeys
{
	NSString *keyToErase = nil;			
	for (NSString *keyHit in pressedKeys)
	{		
		keyToErase = keyHit;
		switch ([keyHit intValue])
		{	
			case NSF1FunctionKey:
				globalSettings.enablePostprocessing = !globalSettings.enablePostprocessing;
				[tmpMsg replaceObjectsInRange:NSMakeRange(0, 1) withObjectsFromArray:[NSArray arrayWithObjects:[NSDate date], globalSettings.enablePostprocessing ? @"PostProcessing: ON" : @"PostProcessing: OFF", nil]];			
				break;			
			case NSF2FunctionKey:
				globalSettings.displayFPS = !globalSettings.displayFPS;
				break;
			case NSF3FunctionKey:
				globalSettings.doWireframe = !globalSettings.doWireframe;				
				[tmpMsg replaceObjectsInRange:NSMakeRange(0, 1) withObjectsFromArray:[NSArray arrayWithObjects:[NSDate date], globalSettings.doWireframe ? @"Wireframe: ON" : @"Wireframe: OFF", nil]];
				break;
			case NSF4FunctionKey:
				globalSettings.displayNormals = !globalSettings.displayNormals;				
				[tmpMsg replaceObjectsInRange:NSMakeRange(0, 1) withObjectsFromArray:[NSArray arrayWithObjects:[NSDate date],  globalSettings.displayNormals ? @"Displaying Normals: ON" : @"Displaying Normals: OFF", nil]];
				break;
			case NSF5FunctionKey:
				globalSettings.displayOctree = !globalSettings.displayOctree;				
				[tmpMsg replaceObjectsInRange:NSMakeRange(0, 1) withObjectsFromArray:[NSArray arrayWithObjects:[NSDate date], globalSettings.displayOctree ? @"Displaying Octree: ON" : @"Displaying Octree: OFF", nil]];
				break;							
			case NSF6FunctionKey:
				globalSettings.disableVFC = !globalSettings.disableVFC;				
				[tmpMsg replaceObjectsInRange:NSMakeRange(0, 1) withObjectsFromArray:[NSArray arrayWithObjects:[NSDate date],  globalSettings.disableVFC ? @"VFC: OFF" : @"VFC: ON", nil]];
				break;	
			default:
				keyToErase = nil;
				break;
		}		
	}
	if (keyToErase)	[pressedKeys removeObject:keyToErase];	
}

- (void)update
{
	globalInfo.frame++;

	[self processKeys];
	
	[simulator update];
	[camera update];
	[lights makeObjectsPerformSelector:@selector(update)];	
	[objects makeObjectsPerformSelector:@selector(update)];
}

- (void)render
{
	uint8 i;
	for (i = 0; i < 3; i++)
		globalInfo.renderedFaces[i] = globalInfo.visitedNodes[i] = globalInfo.totalFaces = globalInfo.totalNodes = 0;
	
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glLoadIdentity();
	[camera applyCameraTransformation];
		
	[simulator render];
	[lights makeObjectsPerformSelector:@selector(render)];
	[objects makeObjectsPerformSelector:@selector(render)];
	
	glError()
}
@end	