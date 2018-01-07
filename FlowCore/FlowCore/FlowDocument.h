//
//  FlowDocument.h
//  FlowCore
//
//  Created by CoreCode on 09.01.09.
/*	Copyright © 2018 CoreCode Limited
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */


@class CocoaOpenGLView;

/*!
 * @class FlowDocument
 * @abstract FlowDocument manages a flow document with all its settings, provides support for saving and loading files and notifies the opengl view about change events.
 */
@interface FlowDocument : NSDocument
{
	NSDictionary *initDict;
	
	IBOutlet CocoaOpenGLView *oglview;

	IBOutlet NSPanel *settingsPanel;
	IBOutlet NSButton *arrowsEnabledButton, *colorsEnabledButton, *streamlinesEnabledButton, *scalewithvelocityButton;
	IBOutlet NSSlider *amountSlider, *sizeSlider, *slAmountSlider, *stepsSlider, *stepsizeSlider;
	IBOutlet NSPopUpButton *datasetPopUp, *colorChannelPopUp, *methodPopUp;
	IBOutlet TransferFunctionViewRestricted *transferFunctionView;	
}

@property(retain, nonatomic) NSButton *arrowsEnabledButton, *colorsEnabledButton, *streamlinesEnabledButton, *scalewithvelocityButton;
@property(retain, nonatomic) NSSlider *amountSlider, *sizeSlider, *slAmountSlider, *stepsSlider, *stepsizeSlider;
@property(retain, nonatomic) NSPopUpButton *datasetPopUp, *colorChannelPopUp, *methodPopUp;
@property(retain, nonatomic) TransferFunctionViewRestricted *transferFunctionView;

- (void)transferFunctionChanged:(id)sender;
- (IBAction)dataSettingsChanged:(id)sender;
- (IBAction)settingsChanged:(id)sender;

@end