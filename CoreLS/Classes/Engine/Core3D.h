typedef struct _TriangleIntersectionInfo {
	BOOL intersects;
	uint32 intersectingFaceNumber;
	uint32 otherIntersectingFaceNumber;
} TriangleIntersectionInfo;

enum {
	kIntersecting = -1,
	kOutside,
	kInside
};

typedef enum {
	kXAxis = 0,
	kYAxis = 1,
	kZAxis = 2,
	kDisabledAxis = 3,
	kYXZRotation = 33,
	kXYZRotation = 36,
	kDisabledRotation = 63
} axisConfigurationEnum;

typedef enum {
	kNoVendor = 0,
	kATI,
	kNVIDIA
} gpuVendorEnum;

typedef enum {
	kMainRenderPass = 0,
	kShadowRenderPass,
	kAdditionalRenderPass
} renderPassEnum;

typedef enum {
	kNoFiltering = 0,
	kPCFNvidia,
	kPCF4Random,
	kPCF16
} shadowFilteringEnum;

typedef enum {
	kNoShadow = 0,
	kShipOnly,
	kEverythingSmall,
	kEverythingMedium,
	kEverythingLarge
} shadowModeEnum;

typedef struct _Settings {
	BOOL enablePostprocessing;
	BOOL disableVFC;
	BOOL disableVBLSync;
	BOOL doWireframe;
	BOOL doBenchmark;	

	BOOL displayFPS;
	BOOL displayOctree;
	BOOL displayNormals;
	shadowModeEnum shadowMode;		
	shadowFilteringEnum shadowFiltering;	
} Settings;

typedef struct _Info {
	gpuVendorEnum gpuVendor;
	float width;
	float height;
	float fps;
	matrix44f_c projectionMatrix;
	matrix44f_c viewMatrix;
	matrix44f_c lightProjectionMatrix;	
	uint64 frame;
	renderPassEnum renderpass;
	uint32 renderedFaces[3];
	uint32 visitedNodes[3];
	uint32 totalFaces;
	uint32 totalNodes;
} Info;

@class Simulation;
#import "Utilities.h"
#import "SceneNode.h"
#import "Camera.h"
#import "Light.h"
#import "Scene.h"

#define AXIS_CONFIGURATION(x,y,z) ((axisConfigurationEnum)(x | y << 2 | z << 4))

#ifdef TARGET_OS_IPHONE
#define PLAY_SOUND(x) \
{ \
	SystemSoundID soundID; \
	AudioServicesCreateSystemSoundID((CFURLRef)[NSURL URLWithString:[[NSBundle mainBundle] pathForResource:(x) ofType:@"wav"]], &soundID); \
	AudioServicesPlaySystemSound (soundID); \
	AudioServicesDisposeSystemSoundID(soundID); \
}
#else 
#define PLAY_SOUND(x) [[NSSound soundNamed:(x)] play];
#endif

#ifdef TARGET_OS_IPHONE
#define COLOR_RGB(x, y, z)  [Color colorWithRed:x green:y blue:z alpha:1.0]
#else 
#define COLOR_RGB(x, y, z)  [Color colorWithCalibratedRed:x green:y blue:z alpha:1.0]
#endif


extern Info globalInfo;
extern Settings globalSettings;
extern NSMutableArray *pressedKeys;
extern Scene *scene;





const uint8 debugRenderShadowmap = 0;
const uint8 printDetailedOctreeInfo = 0;
const uint8 drawObjectCenters = 0;
const uint8 disableFBO = 0;