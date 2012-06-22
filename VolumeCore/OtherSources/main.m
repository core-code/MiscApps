#import "VolumeCore.h"

BOOL PreCheckOpenGL(void);

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [NSApplication sharedApplication];
	
#ifndef __linux__
	if (!PreCheckOpenGL())
	{
		NSRunAlertPanel(@"Error", @"FlowCore requires OpenGL 2.0", @"OK, I'll upgrade", @"", nil);
		exit(1);
	}
#endif
	
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

#ifdef __linux__
uint64_t Timer(bool start)
{
    static uint64_t						_start;
    uint64_t							_end;
    uint64_t							elapsed;
	
	if (start)
	{
		struct timespec time;
		clock_gettime(CLOCK_REALTIME, &time);
		
		_start = time.tv_nsec + (uint64_t) time.tv_sec * (1000 * 1000 * 1000);
		return 0;
	}
	else
	{
		struct timespec time;
		clock_gettime(CLOCK_REALTIME, &time);
		
		_end = time.tv_nsec + (uint64_t) time.tv_sec * (1000 * 1000 * 1000);
		
		elapsed = _end - _start;
		
		return elapsed;
	}
}
#else
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
#endif

#ifndef __linux__
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
#endif
