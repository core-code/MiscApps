//
//  LSystem.h
//  fraktale
//
//  Created by CoreCode on 17.02.09.
//  Copyright CoreCode 2009. All rights reserved.
//

@interface LSystem : SceneNode {
	IBOutlet NSTextField *axiomField, *fField, *gField, *stacksField, *slicesField, *frameTimingField, *generationTimingField;
	IBOutlet NSButton *rotationButton, *freeButton, *animateButton;
	uint8 subdivision, length, radius, angle;
	BOOL drawAABB, cameraMode, primitiveMode;
	GLuint displayList;
	NSColor *color;
	float max[3], min[3];
}

+ (NSString *)performLSystemDerivation:(NSString *)input usingFReplacement:(NSString *)fReplacement andGReplacement:(NSString *)gReplacement steps:(uint8)steps;

- (IBAction)rebuild:(id)sender;
- (IBAction)switchCameraMode:(id)sender;
- (IBAction)stopCamera:(id)sender;
- (IBAction)resetCameraTop:(id)sender;
- (IBAction)resetCameraFront:(id)sender;
- (IBAction)resetCameraSide:(id)sender;
- (IBAction)presetActivated:(id)sender;

@property(retain, nonatomic) NSColor *color;
@property(assign, nonatomic) uint8 angle;
@property(assign, nonatomic) uint8 subdivision;
@property(assign, nonatomic) uint8 length;
@property(assign, nonatomic) uint8 radius;
@property(assign, nonatomic) BOOL cameraMode;
@end
