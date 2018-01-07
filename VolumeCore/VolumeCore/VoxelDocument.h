//
//  VoxelDocument.h
//  VolumeCore
//
//  Created by CoreCode on 16.10.08.
/*	Copyright © 2018 CoreCode Limited
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

/*!
 * @class VoxelDocument
 * @abstract VoxelDocument manages a voxel document with all its settings, provides support for saving and loading files and notifies the opengl view about change events.
 */
@interface VoxelDocument : NSDocument
{
	NSDictionary *initDict;
	
	IBOutlet CocoaOpenGLView *oglview;

	IBOutlet NSView *view2d, *view3d;
	IBOutlet NSPanel *settingsPanel;
	IBOutlet NSTextField *sliceLabel, *steps2DLabel, *steps3DLabel, *stepsize3DLabel, *stepsize3DTextField;
	
	IBOutlet NSButton *stepsize3DButton;
	IBOutlet NSSlider *sliceSlider, *steps2DSlider, *offsetX2DSlider, *offsetY2DSlider, *zoom2DSlider, *steps3DSlider, *stepsize3DSlider, *latitudeSlider, *longitudeSlider, *orientationSlider, *offsetX3DSlider, *offsetY3DSlider, *zoom3DSlider;
	IBOutlet NSPopUpButton *directionPopUp, *datasetPopUp, *modusPopUp, *method2DPopUp, *method3DPopUp;
	IBOutlet TransferFunctionView *transferFunction2DView, *transferFunction3DView;	
}

@property(retain, nonatomic) NSButton *stepsize3DButton;
@property(retain, nonatomic) NSSlider *sliceSlider, *steps2DSlider, *offsetX2DSlider, *offsetY2DSlider, *zoom2DSlider, *steps3DSlider, *stepsize3DSlider, *latitudeSlider, *longitudeSlider, *orientationSlider, *offsetX3DSlider, *offsetY3DSlider, *zoom3DSlider;
@property(retain, nonatomic) NSPopUpButton *directionPopUp, *datasetPopUp, *modusPopUp, *method2DPopUp, *method3DPopUp;
@property(retain, nonatomic) TransferFunctionView *transferFunction2DView, *transferFunction3DView;

/*!
 * @method stepsizeSettingsChanged:
 * @abstract Called when the user switches between relative and absolute stepsize. We want to switch the displayed slider in this case.
 * @param sender The object sending the message.
 */
- (IBAction)stepsizeSettingsChanged:(id)sender;
/*!
 * @method method2DSettingsChanged:
 * @abstract Called when the user switches between the 2D rendering methods (slicing, maximum, etc). We want to switch the displayed slider in this case.
 * @param sender The object sending the message.
 */
- (IBAction)method2DSettingsChanged:(id)sender;
/*!
 * @method settingsChanged:
 * @abstract Called when the user does any non-specific change of settings. We want to mark the document dirty in this case.
 * @param sender The object sending the message.
 */
- (IBAction)settingsChanged:(id)sender;
/*!
 * @method dataSettingsChanged:
 * @abstract Called when the user switches the voxel set to display. Tell the opengl view to load new data.
 * @param sender The object sending the message.
 */
- (IBAction)dataSettingsChanged:(id)sender;
/*!
 * @method modusSettingsChanged:
 * @abstract Called when the user switches between 2D and 3D rendering. Resize window, load new transfer function, etc.
 * @param sender The object sending the message.
 */
- (IBAction)modusSettingsChanged:(id)sender;
/*!
 * @method stepsize3DSettingsChanged:
 * @abstract Called when the user changes the 3D stepsize. Update the text field displaying the value.
 * @param sender The object sending the message.
 */
- (IBAction)stepsize3DSettingsChanged:(id)sender;
/*!
 * @method presetAction:
 * @abstract Called when the user chooses a 3D view preset. Adjust camera.
 * @param sender The object sending the message.
 */
- (IBAction)presetAction:(id)sender;
@end
