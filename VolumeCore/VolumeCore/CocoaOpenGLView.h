//
//  CocoaOpenGLView.h
//  VolumeCore
//
//  Created by CoreCode on 22.10.08.
/*	Copyright (c) 2008 - 2009 CoreCode
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

@class VoxelDocument;

struct voxel_struct
{
	uint16_t sizeX, sizeY, sizeZ;
};

#define OFFSET_VOXELS		((char *)voxels + sizeof(struct voxel_struct))
#define VOXEL(x,y,z)		(OFFSET_VOXELS + (z * (voxels->sizeX * voxels->sizeY) + y * (voxels->sizeX) + x))

/*!
 * @class CocoaOpenGLView
 * @abstract CocoaOpenGLView is responsible for the OpenGL volume drawing.
 */
@interface CocoaOpenGLView : NSOpenGLView
{
	NSTimer *timer;
	uint32_t w, h;
	float size_x, size_y, size_z, size_max, size_min, maxsum;
	struct voxel_struct	*voxels;	
	GLuint shader_2d, shader_3d, shader_raypos, voxel_texture, transfer_function_texture, fboFront, fboBack, frontTexture, backTexture;

	VoxelDocument *doc;
}

@property(retain, nonatomic) VoxelDocument *doc;

/*!
 * @method loadData:
 * @abstract (Re)loads the 3D voxel data into GL_TEXTURE0.
 * @param sender The object sending the message.
 */
- (void)loadData:(id)sender;
/*!
 * @method loadTransferFunction:
 * @abstract (Re)loads the 1D transfer function into GL_TEXTURE1.
 * @param sender The object sending the message.
 */
- (void)loadTransferFunction:(id)sender;

@end
