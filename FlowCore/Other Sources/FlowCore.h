#import "TransferFunctionView.h"
#ifdef __cplusplus
#import "CocoaOpenGLView.h"
#endif
#import "FlowDocument.h"

GLuint LoadShaders(NSString *vertexString, NSString *fragmentString, NSString *preprocessorDefines);
GLuint LoadTexture(NSString *imagePath, GLint minFilter, GLint magFilter, GLint mipmap, GLfloat anisontropy);
BOOL PreCheckOpenGL();