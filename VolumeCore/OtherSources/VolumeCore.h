#import "TransferFunctionView.h"
#import "CocoaOpenGLView.h"
#import "VoxelDocument.h"

GLuint LoadShaders(NSString *vertexString, NSString *fragmentString, NSString *preprocessorDefines);
uint64_t Timer(bool start);
