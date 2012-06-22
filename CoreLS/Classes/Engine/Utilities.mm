#import "Core3D.h"


// Based on Apple sample code:
// http://developer.apple.com/samplecode/GLSLShowpiece/listing6.html

GLuint LoadShaders(NSString *vertexString, NSString *fragmentString, NSString *preprocessorDefines)
{
#define LOAD_SHADER(shaderString, shader_string, shader, shader_compiled, GL_SHADER)	\
if ((shaderString))																		\
{																						\
if (preprocessorDefines)															\
(shaderString) = [preprocessorDefines stringByAppendingString:(shaderString)];	\
(shader) = glCreateShader((GL_SHADER));												\
(shader_string) = (GLchar *) [(shaderString) UTF8String];							\
glShaderSource((shader), 1, &(shader_string), NULL);								\
glCompileShader((shader));															\
glGetShaderiv((shader), GL_COMPILE_STATUS, &(shader_compiled));						\
GLint infoLogLength;																\
glGetShaderiv((shader), GL_INFO_LOG_LENGTH, &infoLogLength);						\
if (infoLogLength > 0)																\
{																					\
char infoLog[infoLogLength];													\
glGetProgramInfoLog ((shader), infoLogLength, NULL, (char *)infoLog);			\
NSLog(@"Warning: shader log: %s\n", infoLog);									\
}																					\
}
	
	
	GLuint vertex_shader = 0, fragment_shader = 0, program_object;
	const GLchar *vertex_string, *fragment_string;
	GLint vertex_compiled = 1, fragment_compiled = 1, linked;
	
	if (!vertexString && !fragmentString) fatal("Error: can't load empty shaders");
	
	
	LOAD_SHADER(vertexString, vertex_string, vertex_shader, vertex_compiled, GL_VERTEX_SHADER)
	LOAD_SHADER(fragmentString, fragment_string, fragment_shader, fragment_compiled, GL_FRAGMENT_SHADER)
	
	if (!vertex_compiled || !fragment_compiled) 
		fatal("Error: couldn't compile shaders:\n%s\n%s\n", [vertexString UTF8String], [fragmentString UTF8String]); // should do cleanup if we don't wanna panic here
	
	
	program_object = glCreateProgram();
	if (vertex_shader != 0)
	{
		glAttachShader(program_object, vertex_shader);
		glDeleteShader(vertex_shader);
	}
	if (fragment_shader != 0)
	{
		glAttachShader(program_object, fragment_shader);
		glDeleteShader(fragment_shader);
	}
	glLinkProgram(program_object);
	glGetProgramiv(program_object, GL_LINK_STATUS, &linked);
	
	if (!linked)
	{	
		GLint infoLogLength;
		glGetProgramiv(program_object, GL_INFO_LOG_LENGTH, &infoLogLength);
		char infoLog[infoLogLength];
		glGetProgramInfoLog (program_object, infoLogLength, NULL, (char *)infoLog);
		
		fatal("Error: couldn't link shaders:\n%s\n%s\n%s\n", infoLog, [vertexString UTF8String], [fragmentString UTF8String]);
	}
	return program_object;
}

// Based on Apple sample code:
// http://developer.apple.com/DOCUMENTATION/GraphicsImaging/Conceptual/OpenGL-MacProgGuide/opengl_texturedata/chapter_10_section_5.html#//apple_ref/doc/uid/TP40001987-CH407-SW31

GLuint LoadTexture(NSString *imagePath, GLint minFilter, GLint magFilter, GLint mipmap, GLfloat anisontropy)
{
	if (!imagePath) fatal("Error: can't load nil texture");
	CGImageSourceRef imageSourceRef = CGImageSourceCreateWithURL((CFURLRef)[NSURL fileURLWithPath:imagePath], NULL);
	CGImageRef imageRef = CGImageSourceCreateImageAtIndex (imageSourceRef, 0, NULL);
	GLuint texName;
	size_t width = CGImageGetWidth(imageRef);
	size_t height = CGImageGetHeight(imageRef);
	CGRect rect = {{0, 0}, {width, height}};
	void *data = calloc(width * 4, height);
	CGContextRef bitmapContext = CGBitmapContextCreate (data, width, height, 8, width * 4, CGColorSpaceCreateDeviceRGB(), kCGBitmapByteOrder32Host | kCGImageAlphaPremultipliedFirst);
														  														  
	CGContextDrawImage(bitmapContext, rect, imageRef);
	CGContextRelease(bitmapContext);

	glGenTextures(1, &texName);
	glBindTexture(GL_TEXTURE_2D, texName);
	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,  minFilter);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,  magFilter);
	glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP,  mipmap);

	if (anisontropy > 1.0)
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, anisontropy);
	
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, width, height, 0, GL_BGRA_EXT, GL_UNSIGNED_INT_8_8_8_8_REV, data); // TODO: experiment with compression

	free(data);
	
	return texName;
}

void DrawFullscreenQuad(short screenWidth, short screenHeight, short textureWidth, short textureHeight) 
{
	glMatrixMode(GL_PROJECTION); 
	glPushMatrix();
	
	matrix44f_c orthographicMatrix;
	matrix_orthographic_RH(orthographicMatrix, 0.0f, (float)screenWidth, 0.0f, (float)screenHeight, -1.0f, 1.0f, z_clip_neg_one);
	glLoadMatrixf(orthographicMatrix.data());	

	glMatrixMode(GL_MODELVIEW); 
	glPushMatrix();
	glLoadIdentity(); 

	GLshort vertices[] = {0, 0,  screenWidth, 0,  screenWidth, screenHeight,  0, screenHeight};
	GLshort texCoords[] = {0, 0,  textureWidth, 0,  textureWidth, textureHeight,  0, textureHeight};
	GLubyte indices[] = {0,1,3, 1,2,3};
					 								
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
	glTexCoordPointer(2, GL_SHORT, 0, texCoords);
	glVertexPointer(2, GL_SHORT, 0, vertices);
	
	glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_BYTE, indices);

	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);	
	
	glPopMatrix();
	glMatrixMode(GL_PROJECTION); 
	glPopMatrix();
	glMatrixMode(GL_MODELVIEW);
}

char AABoxInFrustum(const float frustum[6][4], float x, float y, float z, float ex, float ey, float ez) // adapted code from glm and lighthouse tutorial
{
	int p;
	int result = kInside, out,in;	// TODO: optimiziation: http://www.lighthouse3d.com/opengl/viewfrustum/index.php?gatest3
	
	for(p = 0; p < 6; p++)
	{
		out = 0;
		in = 0;
		
		if (frustum[p][0]*(x-ex) + frustum[p][1]*(y-ey) + frustum[p][2]*(z-ez) + frustum[p][3] < 0) out++; else in++;
		if (frustum[p][0]*(x+ex) + frustum[p][1]*(y-ey) + frustum[p][2]*(z-ez) + frustum[p][3] < 0) out++; else in++;
		if (frustum[p][0]*(x-ex) + frustum[p][1]*(y+ey) + frustum[p][2]*(z-ez) + frustum[p][3] < 0) out++; else in++;
		if (frustum[p][0]*(x+ex) + frustum[p][1]*(y+ey) + frustum[p][2]*(z-ez) + frustum[p][3] < 0) out++; else in++;
		if (frustum[p][0]*(x-ex) + frustum[p][1]*(y-ey) + frustum[p][2]*(z+ez) + frustum[p][3] < 0) out++; else in++;
		if (frustum[p][0]*(x+ex) + frustum[p][1]*(y-ey) + frustum[p][2]*(z+ez) + frustum[p][3] < 0) out++; else in++;
		if (frustum[p][0]*(x-ex) + frustum[p][1]*(y+ey) + frustum[p][2]*(z+ez) + frustum[p][3] < 0) out++; else in++;
		if (frustum[p][0]*(x+ex) + frustum[p][1]*(y+ey) + frustum[p][2]*(z+ez) + frustum[p][3] < 0) out++; else in++;

		if (!in)			// if all corners are out
			return (kOutside);
		else if (out)		// if some corners are out and others are in	
			result = kIntersecting;
	}
	
	return(result);
}

void RenderTexture(GLuint texture, GLuint size)
{
	glBindTexture(GL_TEXTURE_2D, texture);
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();		
	glLoadIdentity();
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();		
	glLoadIdentity();
	glMatrixMode(GL_TEXTURE);
	glPushMatrix();
	glLoadIdentity();
	glEnable(GL_TEXTURE_2D);
	glDisable(GL_LIGHTING);
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_MODE, GL_NONE);
	
	GLint showWidth = (size > globalInfo.width) ? globalInfo.width : size;
	GLint showHeight = (size > globalInfo.height) ? globalInfo.height : size;

	glBegin(GL_QUADS);
	glTexCoord2f(0.0f, 0.0f);
	glVertex2f(-1.0f, -1.0f);
	
	glTexCoord2f(1.0f, 0.0f);
	glVertex2f(((GLfloat)showWidth/(GLfloat) globalInfo.width )*2.0f-1.0f, -1.0f);
	
	glTexCoord2f(1.0f, 1.0f);
	glVertex2f(((GLfloat)showWidth/(GLfloat) globalInfo.width )*2.0f-1.0f, ((GLfloat)showHeight/(GLfloat) globalInfo.height)*2.0f-1.0f);
	
	glTexCoord2f(0.0f, 1.0f);
	glVertex2f(-1.0f, ((GLfloat)showHeight/(GLfloat) globalInfo.height)*2.0f-1.0f);
	glEnd();
	glDisable(GL_TEXTURE_2D);
	glEnable(GL_LIGHTING);
	glPopMatrix();
	glMatrixMode(GL_PROJECTION);
	glPopMatrix();
	glMatrixMode(GL_MODELVIEW);	
	glPopMatrix();
}

void RenderAABB(float minX, float minY, float minZ, float maxX, float maxY, float maxZ)
{
	glVertex3f(minX, minY, minZ);
	glVertex3f(maxX, minY, minZ);
	
	glVertex3f(minX, minY, minZ);
	glVertex3f(minX, maxY, minZ);
	
	glVertex3f(minX, minY, minZ);
	glVertex3f(minX, minY, maxZ);
	
	glVertex3f(maxX, maxY, maxZ);			
	glVertex3f(minX, maxY, maxZ);			
	
	glVertex3f(maxX, maxY, maxZ);			
	glVertex3f(maxX, minY, maxZ);			
	
	glVertex3f(maxX, maxY, maxZ);			
	glVertex3f(maxX, maxY, minZ);				
	
	glVertex3f(minX, maxY, minZ);
	glVertex3f(maxX, maxY, minZ);
	
	glVertex3f(minX, maxY, minZ);
	glVertex3f(minX, maxY, maxZ);	
	
	glVertex3f(minX, minY, maxZ);
	glVertex3f(maxX, minY, maxZ);				
	
	glVertex3f(minX, minY, maxZ);
	glVertex3f(minX, maxY, maxZ);				
	
	glVertex3f(maxX, minY, minZ);
	glVertex3f(maxX, minY, maxZ);		
	
	glVertex3f(maxX, minY, minZ);
	glVertex3f(maxX, maxY, minZ);		
}

uint64 Timer(bool start)
{
	static mach_timebase_info_data_t    sTimebaseInfo;
    static uint64_t						_start;
    uint64_t							_end;
    uint64_t							elapsed;
    uint64_t							elapsedNano;
	
	if (start)
	{
		_start = mach_absolute_time();
		return 0;
	}
	else
	{
		_end = mach_absolute_time();
		
		elapsed = _end - _start;
		
		if (sTimebaseInfo.denom == 0)
			mach_timebase_info(&sTimebaseInfo);
		
		elapsedNano = elapsed * sTimebaseInfo.numer / sTimebaseInfo.denom;
		
		return elapsedNano;
	}
}

BOOL PreCheckOpenGL(void)
{
	BOOL hasOpenGL2 = FALSE;
	CGLPixelFormatAttribute attribs[] = {kCGLPFADisplayMask, kCGLPFAAccelerated, (CGLPixelFormatAttribute)NULL};
	CGLPixelFormatObj pixelFormat = NULL;
	long numPixelFormats = 0;
	CGLContextObj myCGLContext = 0, curr_ctx = CGLGetCurrentContext ();
	CGLChoosePixelFormat(attribs, &pixelFormat, (GLint*)&numPixelFormats);
	if (pixelFormat)
	{
		CGLCreateContext(pixelFormat, NULL, &myCGLContext);
		CGLDestroyPixelFormat(pixelFormat);
		CGLSetCurrentContext(myCGLContext);
		
		if (myCGLContext)
		{
			hasOpenGL2 = ([[[NSString stringWithCString:(const char *)glGetString(GL_VERSION)] substringToIndex:1] intValue] >= 2);
		}
	}
	CGLDestroyContext(myCGLContext);
	CGLSetCurrentContext(curr_ctx); 
	
	return hasOpenGL2;
}