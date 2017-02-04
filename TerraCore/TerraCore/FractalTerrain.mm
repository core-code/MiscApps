//
//  FractalTerrain.m
//  fraktale
//
//  Created by CoreCode on 08.12.08.
/*	Copyright © 2017 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

#import "TerrainSimulation.h"
#include "random.h"


FractalTerrain *gFractalTerrain;

@implementation FractalTerrain

- (id)init
{
	if ((self = [super init]))
	{
		gFractalTerrain = self;

		heightScale = 30.0;
		h = 1.0;
		f = 0.5;
		terrainMeshes = [[NSMutableArray alloc] initWithObjects: @"grid_16", @"grid_32", @"grid_64", @"grid_128", @"grid_256", @"grid_512", @"grid_1024", nil]; 
	}
	
	return self;
}

- (void)awakeFromNib
{
	[subdivisionSlider setIntValue:0]; subdivisionSteps = 0;
	[self chooseSourceImage:self];
}

- (IBAction)chooseSourceImage:(id)sender
{
	int row, column;
	BOOL done = NO;
	NSImage *image;
	
	while (!done)
	{
		// determine image path
		if ([sourcePopup indexOfSelectedItem] < 4)
			sourceImagePath = [[NSBundle mainBundle] pathForResource:[sourcePopup titleOfSelectedItem] ofType:@"png"];			
		else
		{
			int result;
			NSOpenPanel *oPanel = [NSOpenPanel openPanel];
			
			result = [oPanel runModalForDirectory:NSHomeDirectory() file:nil types:[NSImage imageFileTypes]];
			if (result == NSOKButton)
				sourceImagePath = [oPanel filename];
			else
			{
				[sourcePopup selectItemAtIndex:0];
				sourceImagePath = [[NSBundle mainBundle] pathForResource:[sourcePopup titleOfSelectedItem] ofType:@"png"];			
			}
		}
		
		// get image
		image = [[NSImage alloc] initWithContentsOfFile:sourceImagePath];
		
		if (image == nil)
			NSRunAlertPanel(@"Fractal Terrain", @"The file selected doesn't seem to be a valid image file. Please try again.", @"OK", nil, nil);
		else if ([image size].width != [image size].height) 
			NSRunAlertPanel(@"Fractal Terrain", @"The image selected isn't square. Please try again.", @"OK", nil, nil);
		else if ([image size].width > 1024) 
			NSRunAlertPanel(@"Fractal Terrain", @"The image selected is too big (max. 1024x1024). Please try again.", @"OK", nil, nil);
		else if (log2([image size].width ) != (float)(int)log2([image size].width )) 
			NSRunAlertPanel(@"Fractal Terrain", @"The image selected doesn't have power-of-two dimensions (at 72 DPI!!). Please try again.", @"OK", nil, nil);
		else
			done = YES;
		
		if (!done)
			[image release];
	}
	
	
	// convert to monochrome float array	
	if (sourceImage)
		free(sourceImage);
	sourceImageSize = [image size].width;	
	sourceImage = (float *)malloc(sizeof(float) * sourceImageSize * sourceImageSize); 
	
	[image lockFocus]; 
	for (row = 0; row < sourceImageSize; row++)
	{
		for (column = 0; column < sourceImageSize; column++)
		{
			NSColor *pixelColor = NSReadPixel(NSMakePoint(column, sourceImageSize - (row +1)));
			
			sourceImage[((sourceImageSize * row) + column)] = (float)(0.299f * [pixelColor redComponent] + 0.587f * [pixelColor greenComponent] + 0.114f * [pixelColor blueComponent]);
		}
	}
	[image unlockFocus];
	
	//adjust subdivision slider
	[subdivisionSlider setIntValue:0]; subdivisionSteps = 0;
	[subdivisionSlider setMinValue:((4 - (int)log2(sourceImageSize)) < 0 ? 0 : (4 - (int)log2(sourceImageSize)))];
	[subdivisionSlider setMaxValue:(10 - (int)log2(sourceImageSize))];
	[subdivisionSlider setNumberOfTickMarks:[subdivisionSlider maxValue] - [subdivisionSlider minValue] + 1];	

	// initate rebuild
	if (sender != self)
		[self rebuild:self];
}

- (IBAction)rebuild:(id)sender
{
	if (!program_object[0]) // this will only be true on first rebuild, sent by TerrainSimulation
	{
		NSString *vertex_string = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"terrain" ofType:@"vert"] encoding:NSUTF8StringEncoding error:NULL];
		NSString *fragment_string = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"terrain" ofType:@"frag"] encoding:NSUTF8StringEncoding error:NULL];		
		NSArray *defineStrings = [NSArray arrayWithObjects:@"#define WIREFRAME\n", @"#define SHADING\n", @"#define SHADING\n#define HEIGHTCODING\n", @"#define SHADING\n#define TERRAINTEXTURING\n", nil];
								  
		for (uint8 i = 0; i < 4; i++)
		{
			program_object[i] = LoadShaders(vertex_string, fragment_string, [defineStrings objectAtIndex:i]);
			
			glUseProgram(program_object[i]);
			glUniform1i(glGetUniformLocation(program_object[i], "heightTextureUnit"), 1);
			glUniform1i(glGetUniformLocation(program_object[i], "waterTextureUnit"), 2);
			glUniform1i(glGetUniformLocation(program_object[i], "sandTextureUnit"), 3);
			glUniform1i(glGetUniformLocation(program_object[i], "grassTextureUnit"), 4);
			glUniform1i(glGetUniformLocation(program_object[i], "rockTextureUnit"), 5);
			glUniform1i(glGetUniformLocation(program_object[i], "snowTextureUnit"), 6);
			glUseProgram(0);	
		}
		
		glGenTextures(1, &heightTexture);
	
		terrainTextures[0] = LoadTexture([[NSBundle mainBundle] pathForResource:@"water" ofType:@"png"], GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR, GL_TRUE, 0.0);
		terrainTextures[1] = LoadTexture([[NSBundle mainBundle] pathForResource:@"sand" ofType:@"png"], GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR, GL_TRUE, 0.0);
		terrainTextures[2] = LoadTexture([[NSBundle mainBundle] pathForResource:@"grass" ofType:@"png"], GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR, GL_TRUE, 0.0);
		terrainTextures[3] = LoadTexture([[NSBundle mainBundle] pathForResource:@"rock" ofType:@"png"], GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR, GL_TRUE, 0.0);
		terrainTextures[4] = LoadTexture([[NSBundle mainBundle] pathForResource:@"snow" ofType:@"png"], GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR, GL_TRUE, 0.0);
		
		glActiveTexture(GL_TEXTURE1); 	
		glBindTexture(GL_TEXTURE_2D, heightTexture);
		
		for (uint8 i = 0; i < 5; i++)
		{
			glActiveTexture(GL_TEXTURE2+i); 	
			glBindTexture(GL_TEXTURE_2D, terrainTextures[i]);
		}
		glActiveTexture(GL_TEXTURE0);		
	}
	
	[self fractalSubdivision];	 
	
	[infoField setStringValue:[NSString stringWithFormat:@"%ix%i pixel\n%ix%i pixel\n%i\n%i", sourceImageSize, sourceImageSize, heightMapSize, heightMapSize, (heightMapSize+1) * (heightMapSize+1), 2 * heightMapSize * heightMapSize]];	
	[self filter:self];
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE32F_ARB, heightMapSize, heightMapSize, 0, GL_LUMINANCE, GL_FLOAT, heightMap);
	glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, 1);
	
	for (uint8 i = 0; i < 4; i++)
	{
		glUseProgram(program_object[i]);
		glUniform1f(glGetUniformLocation(program_object[i], "heightTextureSize"), heightMapSize);
		glUseProgram(0);
	}
}

- (IBAction)filter:(id)sender
{
	glBindTexture(GL_TEXTURE_2D, heightTexture);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, filterBilinearily ? GL_LINEAR : GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, filterBilinearily ? GL_LINEAR : GL_NEAREST);
}

- (void)fractalSubdivision
{
	Timer(YES);
	time_t idum = -time(NULL);
	heightMap = sourceImage;
	heightMapSize = sourceImageSize;
	
	for (int i = 1; i <= subdivisionSteps; i++)
	{
		float *oldHeightMap = heightMap; 
		heightMapSize *= 2;
		heightMap = (float *)malloc(sizeof(float) * heightMapSize * heightMapSize); 
		
		int row, column;
		
		// copy old values
		for (row = 0; row < heightMapSize; row+=2)
		{
			for (column = 0; column < heightMapSize; column+=2)
			{				
				heightMap[((heightMapSize * row) + column)] = oldHeightMap[((heightMapSize/2 * row/2) + column/2)];
			}
		}
		
		// first part displacement
		uint8 n = (subdivisionSteps - 1) * 2 + 1;
		for (row = 1; row < heightMapSize; row+=2)
		{
			for (column = 1; column < heightMapSize; column+=2)
			{	
				uint8 factors = 1;
				
				double value = heightMap[((heightMapSize * (row-1)) + (column-1))]; // could optimize by eliminating IFs if performance becomes a concern
				
				if (row < heightMapSize - 1)
				{
					value += heightMap[((heightMapSize * (row+1)) + (column-1))];
					factors++;
				}
				if (column < heightMapSize - 1)
				{
					value += heightMap[((heightMapSize * (row-1)) + (column+1))];
					factors++;
				}					
				if ((column < heightMapSize - 1) && (row < heightMapSize - 1))
				{
					value += heightMap[((heightMapSize * (row+1)) + (column+1))];
					factors++;				
				}
				
				heightMap[((heightMapSize * row) + column)] = value/factors + gasdev(&idum) * f/pow(2, n*h);
			}
		}
		
		// second part displacement
		n = (subdivisionSteps - 1) * 2 + 2;
		uint8 offsets[2][2] = {{0,1}, {1,0}};
		for (uint8 i = 0; i < 2; i++)
		{
			for (row = offsets[i][0]; row < heightMapSize; row+=2)
			{
				for (column = offsets[i][1]; column < heightMapSize; column+=2)
				{	
					uint8 factors = 0;
					
					double value = 0;
					
					if (row > 0)
					{
						value += heightMap[((heightMapSize * (row-1)) + (column))];
						factors++;
					}
					if (row < heightMapSize - 1)
					{
						value += heightMap[((heightMapSize * (row+1)) + (column))];
						factors++;
					}
					if (column > 0)
					{
						value += heightMap[((heightMapSize * (row)) + (column-1))];
						factors++;
					}					
					if (column < heightMapSize - 1)
					{
						value += heightMap[((heightMapSize * (row)) + (column+1))];
						factors++;				
					}
					
					heightMap[((heightMapSize * row) + column)] = value/factors + gasdev(&idum) * f/pow(2, n*h);
				}
			}
		}
		if (oldHeightMap != sourceImage)
			free(oldHeightMap);
	}

	[generationTimingField setStringValue:[NSString stringWithFormat:@"%.4f ms", ((float)Timer(NO)) / (1000.0 * 1000.0)]];
}

- (void)render // override render instead of implementing renderNode
{
	Timer(YES);

	globalSettings.doWireframe = !renderMode;
	
	glUseProgram(program_object[renderMode]);
	glUniform1f(glGetUniformLocation(program_object[renderMode], "waterHeight"), [waterSlider floatValue]);
	glUniform1f(glGetUniformLocation(program_object[renderMode], "heightScale"), [scaleSlider floatValue]);

	uint8 i = ((int)log2(sourceImageSize)+subdivisionSteps-4);
	id obj = [terrainMeshes objectAtIndex:i];
	if ([[obj class] isSubclassOfClass:[NSString class]])
	{
		Octree *newOctree = [[Octree alloc] initWithOctreeNamed:obj];
		[terrainMeshes replaceObjectAtIndex:i withObject:newOctree]; // lazy loading cause the 1024 mesh takes a few seconds at startup otherwise

		struct octree_struct *oc = [newOctree octree];	// fixup the octree of the mesh (because it is displaced in the shader) for the VFC
		
		for (uint32 i = 0; i < oc->nodeCount; i++)
		{
			struct octree_node *n = (struct octree_node *) _NODE_NUM(oc, i);	
			
			n->aabbExtentY += 100; // if we wanted to be perfect we should have tight octrees not maximum height
		}
		[newOctree render];
		obj = newOctree;
	}
	else
		[obj render];
	
	
	if ((renderMode != 0) && addWireframe)
	{
		globalSettings.doWireframe = 1;
		glDisable(GL_DEPTH_TEST);
		glUseProgram(program_object[0]);
		glUniform1f(glGetUniformLocation(program_object[0], "waterHeight"), [waterSlider floatValue]);
		glUniform1f(glGetUniformLocation(program_object[0], "heightScale"), [scaleSlider floatValue]);		
		[obj render];
		glEnable(GL_DEPTH_TEST);
	}
	glUseProgram(0);
	
	if (overlayHeightmap) RenderTexture(heightTexture, heightMapSize);
	
	
	glFinish();
	float duration = ((float)Timer(NO)) / (1000.0 * 1000.0);
	[frameTimingField setStringValue:[NSString stringWithFormat:@"%.2f ms (%.1f fps)", duration, 1000.0/duration]];
}

- (IBAction)stopCamera:(id)sender { [[scene simulator] stopCamera]; }
- (IBAction)resetCamera:(id)sender { [[scene simulator] resetCamera]; }

@end