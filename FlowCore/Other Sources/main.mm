#include "FlowCore.h"

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [NSApplication sharedApplication];
	
	if (!PreCheckOpenGL())
	{
		NSRunAlertPanel(@"Error", @"FlowCore requires OpenGL 2.0", @"OK, I'll upgrade", @"", nil);
		exit(1);
	}

	[NSBundle loadNibNamed:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSMainNibFile"] owner:NSApp];
	[pool release];
	[NSApp run];
}

/*!
 * @function LoadShaders
 * @abstract LoadShaders() loads and compiles a glsl vertex and fragment shader.
 * @param vertexString A string containing the vertex shader.
 * @param fragmentString A string containing the fragment shader.
 * @param preprocessorDefines A string the will be prepended to the shaders, possibly to enable preprocessor defines.
 * @result The shader object.
 */

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
glGetShaderInfoLog((shader), infoLogLength, NULL, (char *)infoLog);			\
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
		fatal("Error: couldn't compile shaders!\n"); // should do cleanup iff we don't wanna panic here
	
	
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

/*!
 * @function LoadTexture
 * @abstract LoadTexture() loads and binds a texture.
 * @param imagePath A string the path to the image.
 * @param minFilter Value for GL_TEXTURE_MIN_FILTER.
 * @param magFilter Value for GL_TEXTURE_MAG_FILTER.
 * @param mipmap Value for GL_GENERATE_MIPMAP.
 * @param anisontropy Value for GL_TEXTURE_MAX_ANISOTROPY_EXT.
 * @result The image object.
 */
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
	
	//glPixelStorei(GL_UNPACK_ROW_LENGTH, width);	// TODO: is this neccesary? if so revert it after use
	//glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	
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