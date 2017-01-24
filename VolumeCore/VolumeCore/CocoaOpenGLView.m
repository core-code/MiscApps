//
//  CocoaOpenGLView.m
//  VolumeCore
//
//  Created by CoreCode on 22.10.08.
/*	Copyright © 2017 CoreCode Limited
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import "VolumeCore.h"


@implementation CocoaOpenGLView

@synthesize doc;

- (void)awakeFromNib
{
	timer = [NSTimer timerWithTimeInterval:(1.0f/10.0f) target:self selector:@selector(animationTimer:) userInfo:nil repeats:YES];
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSEventTrackingRunLoopMode]; // ensure timer fires during res
		
#ifdef __APPLE__ // not fine if the panel doesn't float, but #34926
	[[self window] zoom:self];
#endif
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
		NSColor *c = [(([[doc modusPopUp] indexOfSelectedItem] == 0) ? [doc transferFunction2DView] : [doc transferFunction3DView]) colorAtLocation:(float) i / 255.0];
		tft[i*4 + 0] = [c redComponent] * 255;
		tft[i*4 + 1] = [c greenComponent] * 255;
		tft[i*4 + 2] = [c blueComponent] * 255;
		tft[i*4 + 3] = [c alphaComponent] * 255;
	}

	glActiveTexture(GL_TEXTURE1); 
	glBindTexture(GL_TEXTURE_1D, transfer_function_texture);

	glTexParameteri(GL_TEXTURE_1D, GL_TEXTURE_WRAP_S, GL_CLAMP); 
	glTexParameteri(GL_TEXTURE_1D, GL_TEXTURE_MAG_FILTER, GL_LINEAR); 
	glTexParameteri(GL_TEXTURE_1D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); 	
	glTexImage1D(GL_TEXTURE_1D, 0, GL_RGBA8, 256, 0, GL_RGBA, GL_UNSIGNED_BYTE, tft); 	
}

- (void)loadData:(id)sender
{
	NSData *data = nil;
	
	if ([[doc datasetPopUp] indexOfSelectedItem] > 1)
	{
		int result;
		NSOpenPanel *oPanel = [NSOpenPanel openPanel];
		
		result = [oPanel runModalForDirectory:NSHomeDirectory() file:nil types:[NSArray arrayWithObjects:@"dat", nil]];
		if (result == NSOKButton)
		{
			NSString *destpath = [oPanel filename];
			
			data = [NSData dataWithContentsOfFile:destpath];
		}
		else
		{
			[[doc datasetPopUp] selectItemAtIndex:1];
		}
	}
	if ([[doc datasetPopUp] indexOfSelectedItem] < 2)
	{
		NSArray *array = [NSArray arrayWithObjects:@"stagbeetle277x277x164", @"XMasTree", nil];

		data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[array objectAtIndex:[[doc datasetPopUp] indexOfSelectedItem]] ofType:@"dat"]];
	}
	voxels = malloc([data length]);
	[data getBytes:voxels];	

	if ([data length] != voxels->sizeX * voxels->sizeY * voxels->sizeZ * 2 + 6)
		fatal("Error: data doesn't seem to be in .dat format");
	
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_3D, voxel_texture);	
	glPixelStorei(GL_UNPACK_ALIGNMENT,1);
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_S, GL_CLAMP); 
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_T, GL_CLAMP); 
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_R, GL_CLAMP); 
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MAG_FILTER, GL_LINEAR); 
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); 
	glTexImage3D(GL_TEXTURE_3D, 0, GL_LUMINANCE16, voxels->sizeX, voxels->sizeY, voxels->sizeZ, 0, GL_LUMINANCE, GL_UNSIGNED_SHORT, OFFSET_VOXELS);
	
	float maxab = (voxels->sizeX > voxels->sizeY) ? voxels->sizeX : voxels->sizeY;
	size_max = (maxab > voxels->sizeZ) ? maxab : voxels->sizeZ;
	float minab = (voxels->sizeX < voxels->sizeY) ? voxels->sizeX : voxels->sizeY;
	size_min = (minab < voxels->sizeZ) ? maxab : voxels->sizeZ;

	size_x = voxels->sizeX / size_max;
	size_y = voxels->sizeY / size_max;
	size_z = voxels->sizeZ / size_max;	
	
	int x,y,z;
	float sum;
	
	maxsum = 0.0;
	for (x = 0; x < voxels->sizeX; x++)
	{		
		for (y = 0; y < voxels->sizeY; y++)
		{	
			sum = 0.0f;
			for (z = 0; z < voxels->sizeZ; z++)
			{
				uint16_t *vox = (uint16_t *) VOXEL(x,y,z);
				sum += (*vox) * 16 / 65535.0;
			}
			if (sum > maxsum) maxsum = sum;
		}
	}
	maxsum /= voxels->sizeZ;

	free(voxels);	
}

- (void)prepareOpenGL
{
	// enable VBL
#ifdef __APPLE__
	GLint swapInterval = 1;
	CGLSetParameter(CGLGetCurrentContext(), kCGLCPSwapInterval, &swapInterval);
#else
	init_opengl_function_pointers();
#endif
	// enable & name & load textures
	glShadeModel(GL_SMOOTH);	
	glEnable(GL_CULL_FACE);
	glEnable(GL_TEXTURE_1D);
	glEnable(GL_TEXTURE_RECTANGLE_ARB);
	glEnable(GL_TEXTURE_3D);
	glGenTextures(1, &voxel_texture);
	glGenTextures(1, &transfer_function_texture);
	[self loadData:self];
	[self loadTransferFunction:self];

	// load shader 2d
	NSString *vertex_string = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"2d" ofType:@"vert"] encoding:NSUTF8StringEncoding error:NULL];
	NSString *fragment_string = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"2d" ofType:@"frag"] encoding:NSUTF8StringEncoding error:NULL];
	shader_2d = LoadShaders(vertex_string, fragment_string, NULL);	
	glUseProgram(shader_2d);
	glUniform1i(glGetUniformLocation(shader_2d, "voxelTexture"), 0);
	glUniform1i(glGetUniformLocation(shader_2d, "transferFunctionTexture"), 1);

	// load shader 3d	
	vertex_string = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"3d" ofType:@"vert"] encoding:NSUTF8StringEncoding error:NULL];
	fragment_string = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"3d" ofType:@"frag"] encoding:NSUTF8StringEncoding error:NULL];
	shader_3d = LoadShaders(vertex_string, fragment_string, NULL);	
	glUseProgram(shader_3d);
	glUniform1i(glGetUniformLocation(shader_3d, "voxelTexture"), 0);
	glUniform1i(glGetUniformLocation(shader_3d, "transferFunctionTexture"), 1);	
	glUniform1i(glGetUniformLocation(shader_3d, "rayStartTexture"), 2);	
	glUniform1i(glGetUniformLocation(shader_3d, "rayEndTexture"), 3);	

	// load shader shader_raypos
	vertex_string = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"raypos" ofType:@"vert"] encoding:NSUTF8StringEncoding error:NULL];
	fragment_string = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"raypos" ofType:@"frag"] encoding:NSUTF8StringEncoding error:NULL];
	shader_raypos = LoadShaders(vertex_string, fragment_string, NULL);	
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

	{
		if (!fboFront) glGenFramebuffersEXT(1, &fboFront);
		if (!fboBack) glGenFramebuffersEXT(1, &fboBack);
		if (!frontTexture) glGenTextures(1, &frontTexture);
		if (!backTexture) glGenTextures(1, &backTexture);

		if (!fboFront || !fboBack || !frontTexture || !backTexture)
		{
			NSLog(@"shit");
			return;
		}
			
		glActiveTexture(GL_TEXTURE2);		
		glBindTexture(GL_TEXTURE_RECTANGLE_ARB, frontTexture);
		glTexParameteri(GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_MIN_FILTER, GL_LINEAR);	
		glTexImage2D(GL_TEXTURE_RECTANGLE_ARB, 0, GL_RGBA8, w, h, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);	
		
		glActiveTexture(GL_TEXTURE3);
		glBindTexture(GL_TEXTURE_RECTANGLE_ARB, backTexture);
		glTexParameteri(GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_MIN_FILTER, GL_LINEAR);	
		glTexImage2D(GL_TEXTURE_RECTANGLE_ARB, 0, GL_RGBA8, w, h, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);	
		
		glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, fboFront);	
		glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_RECTANGLE_ARB, frontTexture, 0);
		
		if (glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT) != GL_FRAMEBUFFER_COMPLETE_EXT)
			fatal("Error: couldn't setup FBO %04x", (unsigned int)glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT));
		
		glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, fboBack);	
		glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_RECTANGLE_ARB, backTexture, 0);
		
		if (glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT) != GL_FRAMEBUFFER_COMPLETE_EXT)
			fatal("Error: couldn't setup FBO %04x", (unsigned int)glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT));
		glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
	}
}

- (void)drawRect:(NSRect)rect
{
#ifdef PROFILE
	Timer(YES);
#endif

	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	if ([[doc modusPopUp] indexOfSelectedItem] == 0)
	{		
		glUseProgram(shader_2d);		
		glUniform1f(glGetUniformLocation(shader_2d, "stepsize"), 1.0 / [[doc steps2DSlider] floatValue]);
		glUniform1f(glGetUniformLocation(shader_2d, "depth"), [[doc sliceSlider] floatValue]);
		glUniform1i(glGetUniformLocation(shader_2d, "side"), [[doc directionPopUp] indexOfSelectedItem]);
		glUniform1i(glGetUniformLocation(shader_2d, "method"), [[doc method2DPopUp] indexOfSelectedItem]);
		glUniform1f(glGetUniformLocation(shader_2d, "maxsum"), maxsum);	
		
		glLoadIdentity(); 
		
		float zoom = (1.0f / [[doc zoom2DSlider] floatValue]);
		float xoff = [[doc offsetX2DSlider] floatValue] + 0.5;
		float yoff = [[doc offsetY2DSlider] floatValue] + 0.5;
		int  xwidth, ywidth, xmid, ymid;
				
		xmid = w/2;
		xwidth = (w > h) ? xmid : xmid + (h-w)/2; // so the volumeset is rectangular even when the screen is not
		
		ymid = h/2;
		ywidth = (w > h) ? ymid + (w-h)/2 : ymid;
		
		
		// so the volume has the given scaling instead of being rectangular
		if ([[doc directionPopUp] indexOfSelectedItem] == 1) // top 
		{
			xwidth *= size_x * (size_max / size_min);
			ywidth *= size_y * (size_max / size_min);

			zoom *= fmaxf(size_x * (size_max / size_min), size_y * (size_max / size_min));
		}
		else if ([[doc directionPopUp] indexOfSelectedItem] == 0) // front
		{
			xwidth *= size_x * (size_max / size_min);
			ywidth *= size_z * (size_max / size_min);

			zoom *= fmaxf(size_x * (size_max / size_min), size_z * (size_max / size_min)); // if you understand this code you should get your head examined
		}
		else if ([[doc directionPopUp] indexOfSelectedItem] == 2) // side
		{
			xwidth *= size_y * (size_max / size_min);
			ywidth *= size_z * (size_max / size_min);
			
			zoom *= fmaxf(size_y * (size_max / size_min), size_z * (size_max / size_min));
		}			
		
		glBegin(GL_QUADS); 
		glTexCoord2f(xoff - zoom, yoff - zoom);
		glVertex2i(xmid - xwidth, ymid - ywidth);
		glTexCoord2f(xoff + zoom, yoff - zoom);
		glVertex2i(xmid + xwidth, ymid - ywidth);
		glTexCoord2f(xoff + zoom, yoff + zoom);
		glVertex2i(xmid + xwidth, ymid + ywidth);
		glTexCoord2f(xoff - zoom, yoff + zoom);
		glVertex2i(xmid - xwidth, ymid + ywidth);
		glEnd();
	}
	else
	{
		const GLfloat vertices[] = {	-size_x, -size_y, -size_z,		-size_x, -size_y,  size_z,		-size_x,  size_y,  size_z,		-size_x,  size_y, -size_z,		// Left Face
								size_x, -size_y, -size_z,		size_x,  size_y, -size_z,		size_x,  size_y,  size_z,		size_x, -size_y,  size_z,		// Right face
								-size_x, -size_y, -size_z,		size_x, -size_y, -size_z,		size_x, -size_y,  size_z,		-size_x, -size_y,  size_z,		// Bottom Face
								-size_x,  size_y, -size_z,		-size_x,  size_y,  size_z,		size_x,  size_y,  size_z,		size_x,  size_y, -size_z,		// Top Face
								-size_x, -size_y, -size_z,		-size_x,  size_y, -size_z,		size_x,  size_y, -size_z,		size_x, -size_y, -size_z,		// Back Face
								-size_x, -size_y,  size_z,		size_x, -size_y,  size_z,		size_x,  size_y,  size_z,		-size_x,  size_y,  size_z};		// Front Face
		
		const GLshort texCoords[] = {	1,1,	0,1,	0,0,	1,0,	// Left Face
			0,1,	0,0,	1,0,	1,1,	// Right face
			1,0,	1,1,	0,1,	0,0,	// Bottom Face
			1,1,	0,1,	0,0,	1,0,	// Top Face
			0,1,	0,0,	1,0,	1,1,	// Back Face
			1,1,	0,1,	0,0,	1,0};	// Front Face
		int i;
	
		glMatrixMode(GL_PROJECTION); 
		glPushMatrix();
		glLoadIdentity(); 
		gluPerspective([[doc zoom3DSlider] floatValue], (GLfloat)w/(GLfloat)h, 0.1, 100.0);
		glError() 			
		
		glMatrixMode(GL_MODELVIEW);
		glPushMatrix();		
		glLoadIdentity(); 
		glTranslatef([[doc offsetX3DSlider] floatValue], [[doc offsetY3DSlider] floatValue], -3.0);
		glRotatef([[doc latitudeSlider] floatValue],1,0,0);
		glRotatef([[doc longitudeSlider] floatValue],0,1,0);
		glRotatef([[doc orientationSlider] floatValue],0,0,1);
		glColor4f(1.0, 1.0, 1.0, 1.0);

		glEnableClientState(GL_VERTEX_ARRAY);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);	
		glTexCoordPointer(2, GL_SHORT, 0, texCoords);
		glVertexPointer(3, GL_FLOAT, 0, vertices);

		float size[3] = {1.0/size_x, 1.0/size_y, 1.0/size_z};
		glUseProgram(shader_raypos);
		glUniform3fv(glGetUniformLocation(shader_raypos, "size"), 1, size);


		glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, fboFront);
		
		glClear(GL_COLOR_BUFFER_BIT);
		glCullFace(GL_BACK);

		for (i = 0; i < 6; i++)
			glDrawArrays(GL_QUADS, i*4, 4);		
	
		glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, fboBack);
		
		glClear(GL_COLOR_BUFFER_BIT);
		glCullFace(GL_FRONT);
	
		for (i = 0; i < 6; i++)
			glDrawArrays(GL_QUADS, i*4, 4);		
		glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
		glCullFace(GL_BACK);

		glDisableClientState(GL_VERTEX_ARRAY);
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
		glMatrixMode(GL_PROJECTION); 
		glPopMatrix();
		glMatrixMode(GL_MODELVIEW);
		glPopMatrix();
		
		
		GLfloat lightDiffuse[]= {1.0f, 1.0f, 1.0f, 1.0f};
		GLfloat lightPosition[]= {1.0f, 2.0f, 0.0f, 1.0f};
		GLfloat lightAmbient[]= {0.2f, 0.2f, 0.2f, 1.0f};
		GLfloat lightSpecular[]= {0.5f, 0.5f, 0.5f, 1.0f};
		
		glEnable(GL_LIGHTING);
		glLightfv(GL_LIGHT0, GL_AMBIENT, lightAmbient);	
		glLightfv(GL_LIGHT0 , GL_DIFFUSE, lightDiffuse);	
		glLightfv(GL_LIGHT0 , GL_SPECULAR, lightSpecular);	
		glLightfv(GL_LIGHT0, GL_POSITION, lightPosition);
		glEnable(GL_LIGHT0);
		
		
		glUseProgram(shader_3d);
		glUniform1i(glGetUniformLocation(shader_3d, "width"), w);
		glUniform1i(glGetUniformLocation(shader_3d, "height"), h);
		glUniform1i(glGetUniformLocation(shader_3d, "method"), [[doc method3DPopUp] indexOfSelectedItem]);
		glUniform1i(glGetUniformLocation(shader_3d, "steps"), [[doc steps3DSlider] intValue]);
		glUniform1i(glGetUniformLocation(shader_3d, "stepmethod"), [[doc stepsize3DButton] state]);
		glUniform1f(glGetUniformLocation(shader_3d, "stepsize"), [[doc stepsize3DSlider] floatValue]);
		glUniform1f(glGetUniformLocation(shader_3d, "size_max"), size_max);
		glUniform1f(glGetUniformLocation(shader_3d, "maxsum"), maxsum);
		glUniform3f(glGetUniformLocation(shader_3d, "dataset_dimension"), size_x * size_max, size_y * size_max, size_z * size_max);
		glLoadIdentity(); 
	
		glBegin(GL_QUADS); 
		glTexCoord2f(0.0, 0.0);
		glVertex2i(0, 0);
		glTexCoord2f(w, 0.0);
		glVertex2i(w, 0);
		glTexCoord2f(w, h);
		glVertex2i(w, h);
		glTexCoord2f(0.0, h);
		glVertex2i(0, h);
		glEnd();
	}	
		
	glError() 	
	[[self openGLContext] flushBuffer];
	
#ifdef PROFILE
	glFinish();
	float duration = ((float)Timer(NO)) / (1000.0 * 1000.0);
	NSLog(@"%@", [NSString stringWithFormat:@"%.2f ms (%.1f fps)", duration, 1000.0/duration]);
#endif
}

//- (BOOL)acceptsFirstResponder
//{
//	return YES;
//}

- (id)initWithFrame:(NSRect)frameRect
{
	NSOpenGLPixelFormatAttribute attributes[] = {NSOpenGLPFAWindow, NSOpenGLPFADoubleBuffer, (NSOpenGLPixelFormatAttribute)nil};
    NSOpenGLPixelFormat * pf = [[[NSOpenGLPixelFormat alloc] initWithAttributes:attributes] autorelease];
	
	self = [super initWithFrame: frameRect pixelFormat: pf];
	
    return self;
}
@end
