//
//  Octree.h
//  Core3D
//
//  Created by CoreCode on 16.11.07.
/*	Copyright (c) 2016 CoreCode
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//


struct octree_node
{
	uint32 firstFace;
	uint32 faceCount;
	float aabbOriginX, aabbOriginY, aabbOriginZ;
	float aabbExtentX, aabbExtentY, aabbExtentZ;
	uint16 childIndex1, childIndex2, childIndex3, childIndex4, childIndex5, childIndex6, childIndex7, childIndex8;
};

struct octree_struct // TODO: optimization: add optimized prefetch indices for glDrawRangeElements, convert to aabbCenter
{
	uint32 magicWord;
	uint32 nodeCount;
	uint32 vertexCount;
	struct octree_node rootnode;
};

#define _OFFSET_NODES(oct)		((char *)oct + sizeof(struct octree_struct) - sizeof(struct octree_node))
#define _OFFSET_VERTICES(oct)	(_OFFSET_NODES(oct) + oct->nodeCount * sizeof(struct octree_node))
#define _OFFSET_FACES(oct)		(_OFFSET_VERTICES(oct) + oct->vertexCount * ((oct->magicWord == 0x6D616C62) ? 6 : 8) * sizeof(float))
#define _NODE_NUM(oct, x)		(_OFFSET_NODES(oct) + (x) * sizeof(struct octree_node))
#define _VERTEX_NUM(oct, x)		(_OFFSET_VERTICES(oct) + (x) * ((oct->magicWord == 0x6D616C62) ? 6 : 8) * sizeof(float))
#define _FACE_NUM(oct, x)		(_OFFSET_FACES(oct) + (x) * 3 * sizeof(uint16))

#define OFFSET_NODES	(_OFFSET_NODES(octree))
#define OFFSET_VERTICES	(_OFFSET_VERTICES(octree))
#define OFFSET_FACES	(_OFFSET_FACES(octree))
#define NODE_NUM(x)		(_NODE_NUM(octree, x))
#define VERTEX_NUM(x)	(_VERTEX_NUM(octree, x))
#define FACE_NUM(x)		(_FACE_NUM(octree, x))


@interface Octree : SceneNode
{
	struct octree_struct	*octree_collision;
	struct octree_struct	*octree;
	int						octree_length;
	GLuint					vertexVBOName, indexVBOName, texName, displayListName;
	
	Color					*color, *specularColor;

	uint16					*visibleNodeStack;
	uint16					visibleNodeStackTop;
	float					shininess;
	NSString				*name;
}

@property(readonly, nonatomic) struct octree_struct *octree;
@property(readonly, nonatomic) struct octree_struct *octree_collision;
@property(retain, nonatomic) Color *color;
@property(retain, nonatomic) Color *specularColor;
@property(readonly, nonatomic) float shininess;
@property(readonly, nonatomic) uint16 *visibleNodeStack;
@property(readonly, nonatomic) uint16 visibleNodeStackTop;


- (id)initWithOctreeNamed:(NSString *)_name;

@end