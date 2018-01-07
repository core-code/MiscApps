//
//  CocoaOpenGLView.h
//  FlowCore
//
//  Created by CoreCode on 09.01.09.
/*	Copyright © 2018 CoreCode Limited
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#define GRID(_x,_y,_c) (ARRAY_3(_x,_y,_c,sizeY,3))
#define ARRAY(_x,_y) (ARRAY_3(_x,_y,0,sizeY,1))
#define ARRAY3(_x,_y,_z) (ARRAY_3(_x,_y,_z,sizeX,sizeY))

#define ARRAY_3(_x,_y,_z,_sY,_sZ) (((_x) * (_sZ * _sY) + (_y) * (_sZ) + (_z)))		

@class FlowDocument;

/*!
 * @class CocoaOpenGLView
 * @abstract CocoaOpenGLView is responsible for the OpenGL flow drawing.
 */
@interface CocoaOpenGLView : NSOpenGLView
{
	BOOL flip;
	float *inverseGridX, *inverseGridY, *channels;
	NSTimer *timer;
	int w, h, sizeX, sizeY;
	GLuint transfer_function_texture, pointsprite_texture, shaders[3], inverseGridTexture[2], channelTextures[5];
	float diffX, diffY, scalefactor, offsetX, offsetY, minX, minY, stepX, stepY;
	
	FlowDocument *doc;
}

@property(retain, nonatomic) FlowDocument *doc;

/*!
 * @method loadData:
 * @abstract (Re)loads the flow data.
 * @param sender The object sending the message.
 */
- (void)loadData:(id)sender;
/*!
 * @method loadTransferFunction:
 * @abstract (Re)loads the 1D transfer function into GL_TEXTURE1.
 * @param sender The object sending the message.
 */
- (void)loadTransferFunction:(id)sender;


/*!
 * @method interpolatedFlow
 * @abstract Bilinearly interpolates the flow 
 * @param cell The cell position to get the flow for.
 * @result The interpolated vector.
 */
- (vector2f)interpolatedFlowForCell:(vector2f)cell;

- (vector2f)cellForPosition:(vector2f)pos withScale:(float)scale;
@end
