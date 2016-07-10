//
//  LSystem.h
//  fraktale
//
//  Created by CoreCode on 17.02.09.
/*	Copyright (c) 2016 CoreCode
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
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
