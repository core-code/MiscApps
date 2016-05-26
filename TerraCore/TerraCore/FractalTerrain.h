//
//  FractalTerrain.h
//  fraktale
//
//  Created by CoreCode on 08.12.08.
//  Copyright CoreCode 2008. All rights reserved.
//


@interface FractalTerrain : SceneNode
{
	IBOutlet NSPopUpButton *sourcePopup;
	IBOutlet NSSlider *subdivisionSlider, *waterSlider, *scaleSlider;
	IBOutlet NSTextField *infoField, *frameTimingField, *generationTimingField, *waterField, *scaleField;
	
	float *sourceImage;
	uint16 sourceImageSize, heightMapSize;
	NSString *sourceImagePath;
	float h, f, waterHeight, heightScale;
	uint8 subdivisionSteps, renderMode;
	BOOL overlayHeightmap, addWireframe, filterBilinearily;
	float *heightMap;
	
	NSMutableArray *terrainMeshes;
	GLuint heightTexture, terrainTextures[5], program_object[4];
}

- (void)fractalSubdivision;
- (IBAction)chooseSourceImage:(id)sender;
- (IBAction)rebuild:(id)sender;
- (IBAction)filter:(id)sender;
- (IBAction)stopCamera:(id)sender;
- (IBAction)resetCamera:(id)sender;
@end