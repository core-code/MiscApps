GLuint LoadShaders(NSString *vertexString, NSString *fragmentString, NSString *preprocessorDefines);
GLuint LoadTexture(NSString *imagePath, GLint minFilter, GLint magFilter, GLint mipmap, GLfloat anisontropy);
void DrawFullscreenQuad(short screenWidth, short screenHeight, short textureWidth, short textureHeight);
char AABoxInFrustum(const float frustum[6][4], float x, float y, float z, float ex, float ey, float ez);
void RenderAABB(float minX, float minY, float minZ, float maxX, float maxY, float maxZ);
void RenderTexture(GLuint texture, GLuint size);
uint64 Timer(bool start);
BOOL PreCheckOpenGL();