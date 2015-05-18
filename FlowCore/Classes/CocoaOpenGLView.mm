//
//  CocoaOpenGLView.mm
//  FlowCore
//
//  Created by CoreCode on 09.01.09.
/*	Copyright (c) 2008 - 2009 CoreCode
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */


#import "FlowCore.h"

@implementation CocoaOpenGLView

@synthesize doc;


- (void)awakeFromNib
{			
	scalefactor = 1.0;
	timer = [NSTimer timerWithTimeInterval:(1.0f/10.0f) target:self selector:@selector(animationTimer:) userInfo:nil repeats:YES];
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSEventTrackingRunLoopMode];
		
	[[self window] zoom:self];
}

- (void)dealloc
{
	[timer invalidate];

    [super dealloc];  
}

- (void)animationTimer:(NSTimer *)timer
{
	[self setNeedsDisplay:YES];
}

- (void)loadTransferFunction:(id)sender
{
	unsigned char tft [256*4];
	for(int i = 0; i < 256; i++)
	{
		NSColor *c = [[doc transferFunctionView] colorAtLocation:(float) i / 255.0];
		tft[i*4 + 0] = [c redComponent] * 255;
		tft[i*4 + 1] = [c greenComponent] * 255;
		tft[i*4 + 2] = [c blueComponent] * 255;
		tft[i*4 + 3] = [c alphaComponent] * 255;
	}

	glActiveTexture(GL_TEXTURE0); 
	glBindTexture(GL_TEXTURE_1D, transfer_function_texture);

	glTexParameteri(GL_TEXTURE_1D, GL_TEXTURE_WRAP_S, GL_CLAMP); 
	glTexParameteri(GL_TEXTURE_1D, GL_TEXTURE_MAG_FILTER, GL_LINEAR); 
	glTexParameteri(GL_TEXTURE_1D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); 	
	glTexImage1D(GL_TEXTURE_1D, 0, GL_RGBA8, 256, 0, GL_RGBA, GL_UNSIGNED_BYTE, tft); 	
}

- (void)loadData:(id)sender
{
	flip = 0;
	NSData *datData = NULL, *griData = NULL;
	
	if ([[doc datasetPopUp] indexOfSelectedItem] > 1)
	{
		int result;
		NSOpenPanel *oPanel = [NSOpenPanel openPanel];
		
		result = [oPanel runModalForDirectory:NSHomeDirectory() file:nil types:[NSArray arrayWithObjects:@"dat", nil]];
		if (result == NSOKButton)
		{			
			datData = [NSData dataWithContentsOfFile:[oPanel filename]];
			
			result = [oPanel runModalForDirectory:NSHomeDirectory() file:nil types:[NSArray arrayWithObjects:@"gri", nil]];
			if (result == NSOKButton)
			{			
				griData = [NSData dataWithContentsOfFile:[oPanel filename]];

			}
			else
				[[doc datasetPopUp] selectItemAtIndex:1];			
		}
		else
			[[doc datasetPopUp] selectItemAtIndex:1];
	}
	
	if ([[doc datasetPopUp] indexOfSelectedItem] < 1)
	{
		NSArray *array = [NSArray arrayWithObjects:@"block", nil];
		datData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[array objectAtIndex:[[doc datasetPopUp] indexOfSelectedItem]] ofType:@"dat"]];
		griData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[array objectAtIndex:[[doc datasetPopUp] indexOfSelectedItem]] ofType:@"gri"]];
	}

	char buf[40];
	[griData getBytes:buf length:40];
	int sizeZ, additionalSets, numberTimesteps;
	float timestepDelta;
	int e = sscanf(buf, "SN4DB %d %d %d %d %d %f", &sizeX, &sizeY, &sizeZ, &additionalSets, &numberTimesteps, &timestepDelta);
	if (e < 4) fatal("Error: .gri header damaged");
	if (sizeZ != 1) fatal("Error: sizeZ != 1");
	
	int gri_data_size = sizeX * sizeY * 3 * sizeof(float);
	float *gri_data = (float*)malloc(gri_data_size);
	[griData getBytes:gri_data range:NSMakeRange(40, gri_data_size)];
	
	if (fabsf(gri_data[GRID(0,0,01)] - gri_data[GRID(sizeX -1 ,0,1)]) > 0.01) // convert fucked up data files
	{
		int bla = sizeX;
		sizeX = sizeY;
		sizeY = bla;
		
		flip = 1;
		for (int x = 0; x < sizeX; x++)
		{
			for (int y = 0; y < sizeY; y++)
			{	
				gri_data[GRID(x,y,2)] = gri_data[GRID(x,y,1)];
				gri_data[GRID(x,y,1)] = gri_data[GRID(x,y,0)];
				gri_data[GRID(x,y,0)] = gri_data[GRID(x,y,2)];
				gri_data[GRID(x,y,2)] = 0.0;				
			}
		}
	}
	
	// properties berechnen
	vector2f min = vector2f(gri_data[GRID(0,0,0)], gri_data[GRID(0,0,1)]);
	vector2f max = vector2f(gri_data[GRID(sizeX-1,sizeY-1,0)], gri_data[GRID(sizeX-1,sizeY-1,1)]);
	diffX = max[0] - min[0];
	diffY = max[1] - min[1];
	minX = min[0];
	minY = min[1];
	stepX = diffX / sizeX; 
	stepY = diffY / sizeY;

	// inverse grid berechnen und texturen herrichten
	if (inverseGridX) free(inverseGridX);
	if (inverseGridY) free(inverseGridY);
	inverseGridX = (float*) malloc(sizeof(float) * sizeX * sizeY);
	inverseGridY = (float*) malloc(sizeof(float) * sizeX * sizeY);

	for (int x = 0; x < sizeX; x++)	
	{
		for (int y = 0; y < sizeY; y++)
		{	
			int nx, ny;
			vector2f pos = min + vector2f(stepX * x, stepY * y);
			
			for (nx = 0; nx < sizeX - 1; nx++)
				if (gri_data[GRID(nx,0,0)] <= pos[0] && gri_data[GRID(nx+1,0,0)] >= pos[0])
					break;
			
			for (ny = 0; ny < sizeY - 1; ny++)
				if (gri_data[GRID(0,ny,1)] <= pos[1] && gri_data[GRID(0,ny+1,1)] >= pos[1])
					break;
		
			inverseGridX[ARRAY(x,y)] = (nx + (pos[0] - gri_data[GRID(nx,0,0)]) / (gri_data[GRID(nx+1,0,0)] - gri_data[GRID(nx,0,0)]));
			inverseGridY[ARRAY(x,y)] = (ny + (pos[1] - gri_data[GRID(0,ny,1)]) / (gri_data[GRID(0,ny+1,1)] - gri_data[GRID(0,ny,1)]));
		}
	}
			   
	for (int i = 0; i < 2; i++)
	{		
		glActiveTexture(GL_TEXTURE1+i);		
		glBindTexture(GL_TEXTURE_RECTANGLE_ARB, inverseGridTexture[i]);
		glTexParameteri(GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexImage2D(GL_TEXTURE_RECTANGLE_ARB, 0, GL_LUMINANCE16F_ARB, sizeY, sizeX, 0, GL_LUMINANCE, GL_FLOAT, (i == 0) ? inverseGridX : inverseGridY);
	}

	// channels berechnen und texturen herrichten
	if (additionalSets > 2) additionalSets = 2;
	if (channels) free(channels);
	channels = (float*)malloc(sizeof(float) * 5* sizeX * sizeY);;
	float *dat_data = (float*)malloc([datData length]);
	[datData getBytes:dat_data];
	float *flowVisualizationSucksMonkeyBalls = dat_data;
	
	for (int x = 0; x < sizeX; x++)
	{
		for (int y = 0; y < sizeY; y++)
		{
			if (flip)
			{
				channels[ARRAY3(1,x,y)] = *flowVisualizationSucksMonkeyBalls++;
				channels[ARRAY3(0,x,y)] = *flowVisualizationSucksMonkeyBalls++;			
			}
			else
			{
				channels[ARRAY3(0,x,y)] = *flowVisualizationSucksMonkeyBalls++;
				channels[ARRAY3(1,x,y)] = *flowVisualizationSucksMonkeyBalls++;
			}
			
			for (int i = 2; i < 3 + additionalSets; i++)
			{
				channels[ARRAY3(i,x,y)] = *flowVisualizationSucksMonkeyBalls++;
			}
		}
	}
	
	for (int x = 0; x < sizeX; x++)
		for (int y = 0; y < sizeY; y++)
				channels[ARRAY3(2,x,y)] = sqrtf(channels[ARRAY3(0,x,y)] * channels[ARRAY3(0,x,y)] + channels[ARRAY3(1,x,y)] * channels[ARRAY3(1,x,y)]);
	

	float cmin[5], cmax[5];
	for (int t = 0; t < 5; t++)
	{
		cmin[t] = 50000.00;
		cmax[t] = - 50000.00;
		
		for (int x = 0; x < sizeX; x++)
		{
			for (int y = 0; y < sizeY; y++)
			{
				if (channels[ARRAY3(t,x,y)] < cmin[t])	cmin[t] = channels[ARRAY3(t,x,y)];
				if (channels[ARRAY3(t,x,y)] > cmax[t])	cmax[t] = channels[ARRAY3(t,x,y)];
			}
		}
	}
	
	for (int i = 0; i < 5; i++)
	{		
		glActiveTexture(GL_TEXTURE3+i);		
		glBindTexture(GL_TEXTURE_RECTANGLE_ARB, channelTextures[i]);
		glTexParameteri(GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexImage2D(GL_TEXTURE_RECTANGLE_ARB, 0, GL_LUMINANCE16F_ARB, sizeY, sizeX, 0, GL_LUMINANCE, GL_FLOAT, &channels[ARRAY3(i,0,0)]);
	}
	glActiveTexture(GL_TEXTURE0);
	
	
	// properties an shader uebergeben
	for (int i = 0; i < 2; i++)
	{
		glUseProgram(shaders[i]);		
		glUniform2fv(glGetUniformLocation(shaders[i], "min"), 1, min.data());		
		glUniform2fv(glGetUniformLocation(shaders[i], "max"), 1, max.data());		
		glUniform2f(glGetUniformLocation(shaders[i], "step"), stepX, stepY);		
		glUniform1fv(glGetUniformLocation(shaders[i], "channelMin"), 5, cmin);
		glUniform1fv(glGetUniformLocation(shaders[i], "channelMax"), 5, cmax);

		const GLint blah[] = {3,4,5,6,7};
		glUniform1iv(glGetUniformLocation(shaders[i], "channelTexture"), 5, blah);				
	}	
	
	free(gri_data);
	free(dat_data);
}

- (void)prepareOpenGL
{	
	if (![[NSString stringWithCString:(const char *)glGetString(GL_VENDOR)] hasPrefix:@"NVIDIA"])
	{
		NSBeginAlertSheet(@"Warning", @"I'll use it at my own risk", nil, nil, [self window], self, NULL, NULL, nil, @"NOTE:	ATI videocards have a problem with FlowCore as of Mac OS X 10.5.6. Maybe future system updates resolve driver problems and thus fix FlowCore");
	}	
	
	// enable VBL
	GLint swapInterval = 1;
	CGLSetParameter(CGLGetCurrentContext(), kCGLCPSwapInterval, &swapInterval);
	
	// enable & name & load textures
	glEnable(GL_LINE_SMOOTH);
	glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
	glShadeModel(GL_SMOOTH);	
	glEnable(GL_TEXTURE_1D);
	glEnable(GL_TEXTURE_RECTANGLE_ARB);
	glEnable(GL_VERTEX_PROGRAM_POINT_SIZE);
	glGenTextures(1, &transfer_function_texture);
	glGenTextures(2, inverseGridTexture);
	glGenTextures(5, channelTextures);
	
	pointsprite_texture = LoadTexture([[NSBundle mainBundle] pathForResource:@"arrow" ofType:@"png"], GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR, GL_TRUE, 0.0);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);	
	glActiveTexture(GL_TEXTURE8);		
	glBindTexture(GL_TEXTURE_2D, pointsprite_texture);
	glActiveTexture(GL_TEXTURE0);		
	
	// load shaders
	NSArray *array = [NSArray arrayWithObjects:@"color", @"arrows", @"streamlines", nil];
	for (int i = 0; i < 2; i++)
	{
		NSString *vertex_string = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[array objectAtIndex:i] ofType:@"vert"] encoding:NSUTF8StringEncoding error:NULL];
		NSString *fragment_string = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[array objectAtIndex:i] ofType:@"frag"] encoding:NSUTF8StringEncoding error:NULL];
		shaders[i] = LoadShaders(vertex_string, fragment_string, NULL);	
		glUseProgram(shaders[i]);
		glUniform1i(glGetUniformLocation(shaders[i], "transferFunctionTexture"), 0);
		glUniform1i(glGetUniformLocation(shaders[i], "inverseGridTextureX"), 1);
		glUniform1i(glGetUniformLocation(shaders[i], "inverseGridTextureY"), 2);
		
		if (i == 1)
			glUniform1i(glGetUniformLocation(shaders[i], "pointspriteTexture"), 8);
	}
	
	[self loadData:self];
	[self loadTransferFunction:self];	
}

- (void)reshape
{ 	
	[[self openGLContext] update];

	w = [self bounds].size.width;
	h = [self bounds].size.height;
	
	glMatrixMode(GL_PROJECTION); 
	glLoadIdentity(); 
	
	glViewport(0, 0, w, h);
	gluOrtho2D(0.0, w, 0.0, h);
	
	glMatrixMode(GL_MODELVIEW);
}

- (void)drawRect:(NSRect)rect
{
	float scale = MIN((w / diffY), (h / diffX)) * scalefactor;
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	for (int i = 0; i < 2; i++)
	{
		glUseProgram(shaders[i]);
		glUniform1f(glGetUniformLocation(shaders[i], "scale"), scale);
		glUniform1i(glGetUniformLocation(shaders[i], "channel"), [[[self doc] colorChannelPopUp] indexOfSelectedItem]);
		glUniform2f(glGetUniformLocation(shaders[i], "offset"), offsetX, offsetY);		
		glUniform2f(glGetUniformLocation(shaders[i], "size"), sizeY, sizeX);		
	}	
	glUseProgram(0);

	// color coding
	if ([[[self doc] colorsEnabledButton] state] == NSOnState)
	{		
		glUseProgram(shaders[0]);		
		glBegin(GL_QUADS); 
		glTexCoord2f(0.0, 0.0);
		glVertex2i(0, 0);
		
		glTexCoord2f(w, 0);
		glVertex2i(w, 0);
		
		glTexCoord2f(w, h);
		glVertex2i(w, h);
		
		glTexCoord2f(0.0, h);
		glVertex2i(0, h);
		glEnd();
		glUseProgram(0);
	}

	// arrows
	if ([[[self doc] arrowsEnabledButton] state] == NSOnState)
	{
		glUseProgram(shaders[1]);		
		glUniform1f(glGetUniformLocation(shaders[1], "particleScale"), [[[self doc] sizeSlider] floatValue] * scalefactor);
		glUniform1i(glGetUniformLocation(shaders[1], "velocityScale"), [[[self doc] scalewithvelocityButton] state]);

		int amount = [[[self doc] amountSlider] intValue];
		float positions[amount][amount][2];
		for (int x = 0; x < amount; x++)
		{
			for (int y = 0; y < amount; y++)
			{
				positions[x][y][0] = ((float)(x+0.5) / (float)amount) * diffY * scale + offsetX;
				positions[x][y][1] = ((float)(y+0.5) / (float)amount) * diffX * scale + offsetY;
			}
		}

		glDepthMask(GL_FALSE);
		glEnable(GL_TEXTURE_2D);
		glEnable(GL_BLEND); glBlendFunc (GL_ONE, GL_ONE);
		
		glEnable(GL_POINT_SPRITE);
		glTexEnvi(GL_POINT_SPRITE, GL_COORD_REPLACE, GL_TRUE);
				
		glEnableClientState(GL_VERTEX_ARRAY);
		glVertexPointer(2, GL_FLOAT, 0, positions);

		glDrawArrays(GL_POINTS, 0, amount*amount);
		glDisableClientState(GL_VERTEX_ARRAY);
		
		glUseProgram(0);
		
		glDisable(GL_BLEND);
		glDisable(GL_POINT_SPRITE);	
		glDisable(GL_TEXTURE_2D);
		glDepthMask(GL_TRUE);

	}
	
	// streamlines
	if (([[[self doc] streamlinesEnabledButton] state] == NSOnState))
	{
		float stepsize = [[[self doc] stepsizeSlider] floatValue];
		BOOL euler = ![[doc methodPopUp] indexOfSelectedItem];
		int amount = [[[self doc] slAmountSlider] intValue],
			steps = [[[self doc] stepsSlider] intValue];
		float positions[amount][amount][2];
		
		for (int x = 0; x < amount; x++)
		{
			for (int y = 0; y < amount; y++)
			{
				positions[x][y][0] = ((float)(x+0.5) / (float)amount) * diffX * scale + offsetX;
				positions[x][y][1] = ((float)(y+0.5) / (float)amount) * diffY * scale + offsetY;
			}
		}
		
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		
		glBegin(GL_LINES);
		for (int x = 0; x < amount; x++)
		{
			for (int y = 0; y < amount; y++)
			{
				vector2f pos = vector2f(positions[x][y][0], positions[x][y][1]);
				
				for (int i = 0; i < steps; i++)
				{
					vector2f cell = [self cellForPosition:pos withScale:scale];
					if (cell[0] == -1.0)
						break;

					vector2f flow = [self interpolatedFlowForCell:cell];
					flow *= stepsize;
					
					if (!euler)
					{
						cell = [self cellForPosition:(pos + (flow * 0.5)) withScale:scale];
						if (cell[0] == -1.0)
							break;

						
						flow = [self interpolatedFlowForCell:cell];	
						flow *= stepsize;						
					}
					
					glVertex2f(pos[1] + offsetX - offsetY, pos[0] - offsetX + offsetY);
					pos += flow;
					glVertex2f(pos[1] + offsetX - offsetY, pos[0] - offsetX + offsetY);					
				}
			}
		}		
		glEnd();

		glDisable(GL_BLEND);
	}
	
	glError() 	
	[[self openGLContext] flushBuffer];
}

- (void)scrollWheel:(NSEvent *)theEvent
{
	scalefactor += [theEvent deltaY] / 100.0;
}

- (void)mouseDragged:(NSEvent *)theEvent
{	
	offsetX += [theEvent deltaX];
	offsetY -= [theEvent deltaY];
}

- (vector2f)cellForPosition:(vector2f)pos withScale:(float)scale
{
	int gposX = (pos[0] - offsetX - minX) / (scale * stepX); 
	int gposY = (pos[1] - offsetY - minY) / (scale * stepY); 
	
	if ((gposX < sizeX) && (gposY < sizeY) && (gposX > 0) && (gposY > 0))
		return vector2f(inverseGridX[ARRAY(gposX, gposY)], inverseGridY[ARRAY(gposX, gposY)]);
	else
		return vector2f(-1.0, -1.0);
}

- (vector2f)interpolatedFlowForCell:(vector2f)cell
{
	float x1 = channels[ARRAY3(1,(int)cell[0],(int)cell[1])];
	float y1 = channels[ARRAY3(0,(int)cell[0],(int)cell[1])];
	
	float x2 = channels[ARRAY3(1,((int)cell[0])+1,(int)cell[1])];
	float y2 = channels[ARRAY3(0,((int)cell[0])+1,(int)cell[1])];
	
	float x3 = channels[ARRAY3(1,(int)cell[0],((int)cell[1])+1)];
	float y3 = channels[ARRAY3(0,(int)cell[0],((int)cell[1])+1)];
	
	float x4 = channels[ARRAY3(1,((int)cell[0])+1,((int)cell[1])+1)];
	float y4 = channels[ARRAY3(0,((int)cell[0])+1,((int)cell[1])+1)];			
	
	int factorXHigh = cell[0] - ((int)cell[0]);
	int factorYHigh = cell[1] - ((int)cell[1]);
	
	return vector2f(((y2 * (1.0 - factorYHigh) + y4 * factorYHigh) * factorXHigh) + (y1 * (1.0 - factorYHigh) + y3 * factorYHigh) * (1.0 - factorXHigh),
					((x2 * (1.0 - factorYHigh) + x4 * factorYHigh) * factorXHigh) + (x1 * (1.0 - factorYHigh) + x3 * factorYHigh) * (1.0 - factorXHigh));
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
	return YES;
}
@end


// DEAD TEST CODE

//cout << pos << endl;
//printf("\n%f %f %f\n", gri_data[GRID(nx,ny,0)], gri_data[GRID(nx,ny,1)], gri_data[GRID(nx,ny,2)]);  
//printf("\n%f %f %f\n", gri_data[GRID(nx+1,ny+1,0)], gri_data[GRID(nx+1,ny+1,1)], gri_data[GRID(nx+1,ny+1,2)]);  
//
//{
//	// manual min max calculation
//	float maxX = -1000, maxY = -1000, maxZ = -1000;
//	float minX = 1000, minY = 1000, minZ = 1000;
//	for (int x = 0; x < sizeX; x++)
//	{
//		for (int y = 0; y < sizeY; y++)
//		{
//			float vx = gri_data[GRID(x,y,0)];
//			float vy = gri_data[GRID(x,y,1)];
//			float vz = gri_data[GRID(x,y,2)];
//			//	printf("h: %f %f %f\n", vx, vy, vz);
//			
//			if (vx > maxX) maxX = vx;
//				if (vy > maxY) maxY = vy;
//					if (vz > maxZ) maxZ = vz;
//						
//						if (vx < minX) minX = vx;
//							if (vy < minY) minY = vy;
//								if (vz < minZ) minZ = vz;
//									
//									}
//	}
//	printf("premin %f %f %f\n", minX, minY, minZ);
//	printf("premax %f %f %f\n", maxX, maxY, maxZ);
//	
//	
//	printf("%f %f %f\n", gri_data[GRID(sizeX-1,0,0)], gri_data[GRID(sizeX-1,0,1)], gri_data[GRID(sizeX-1,0,2)]);
//	printf("%f %f %f\n", gri_data[GRID(0,sizeY-1,0)], gri_data[GRID(0,sizeY-1,1)], gri_data[GRID(0,sizeY-1,2)]);
//}
//
//{
//	// grid debug
//	//	printf("\n\nGRID DEBUG:\n\n\n");		
//	//	for (int x = 0; x < sizeX; x++)
//	//	{
//	//		for (int y = 0; y < 13; y++)
//	//		{
//	//			printf("%.2f %.2f %.2f   ", gri_data[GRID(x,y,0)], gri_data[GRID(x,y,1)], gri_data[GRID(x,y,2)]);
//	//		}
//	//		printf("\n");		
//	//	}
//	
//	// inversegrid debug
//	//	printf("\n\nINVERSE GRID DEBUG:\n\n\n");		
//	//	for (int x = 0; x < sizeX; x++)
//	//	{
//	//		for (int y = 0; y < 16; y++)
//	//		{
//	//			printf("\%.2f %.2f   ", inverseGridX[ARRAY(x,y)], inverseGridY[ARRAY(x,y)]);
//	//		}
//	//		printf("\n");		
//	//	}
//	
//	// channel debug
//	//	for (int i = 0; i < 3 + additionalSets; i++)
//	//	{
//	//		printf("\nset %i\n", i);
//	//		
//	//		for (int x = 0; x < 5; x++)
//	//		{
//	//			for (int y = 0; y < 5; y++)
//	//			{
//	//				printf("%f", channels[i][x][y]);
//	//			}
//	//		}
//	//	}
//	
//	// inverse grid test 1
//	//	for (int x = 0; x < sizeX; x++)
//	//	{
//	//		for (int y = 0; y < sizeY; y++)
//	//		{
//	//			float x_ = inverseGridX[ARRAY(x,y)];
//	//			float y_ = inverseGridY[ARRAY(x,y)];
//	//			
//	//			vector2f pos = min + vector2f(stepX * x, stepY * y);
//	//			vector2f low = vector2f(gri_data[GRID((int)x_,(int)y_,0)], gri_data[GRID((int)x_,(int)y_,1)]);
//	//			vector2f high = vector2f(gri_data[GRID(((int)x_)+1,((int)y_)+1,0)], gri_data[GRID(((int)x_)+1,((int)y_)+1,1)]);
//	//			
//	//			if ((low[0] > pos[0]) ||
//	//				(pos[0] > high[0]) ||
//	//				(low[1] > pos[1]) ||
//	//				(pos[1] > high[1]))
//	//			{
//	//				
//	//				cout << low << endl;
//	//				cout << pos << endl;
//	//				cout << high << endl;
//	//				
//	//				printf("fuck");
//	//			}
//	//		}
//	//	}
//	
//	// inverse grid test 2
//	//	for (int x = (int)(min[0]+1.0); x <= (int)max[0]; x++)
//	//	{
//	//		for (int y = (int)(min[1]+1.0); y <= (int)max[1]; y++)
//	//		{	
//	//			vector2f test = vector2f(x, y);
//	//			vector2f newtest = test - min;
//	//			vector2f blah = vector2f(newtest[0] / stepX, newtest[1] / stepY);
//	//			float cx = inverseGridX[ARRAY((int)blah[0], (int)blah[1])];
//	//			float cy = inverseGridY[ARRAY((int)blah[0], (int)blah[1])];
//	//			
//	//			int nx, ny;
//	//			for (nx = 0; nx < sizeX - 1; nx++)
//	//				if (gri_data[GRID(nx,0,0)] <= test[0] && gri_data[GRID(nx+1,0,0)] >= test[0])
//	//					break;
//	//			
//	//			for (ny = 0; ny < sizeY - 1; ny++)
//	//				if (gri_data[GRID(0,ny,1)] <= test[1] && gri_data[GRID(0,ny+1,1)] >= test[1])
//	//					break;
//	//			
//	//			if ((fabs(cx - nx) > 2) ||
//	//				(fabs(cy - ny) > 2))
//	//				printf("\n%f %f %i %i\n", cx, cy, nx, ny);
//	//		}
//	//	}
//}