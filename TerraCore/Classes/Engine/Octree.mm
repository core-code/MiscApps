//
//  Octree.m
//  Core3D
//
//  Created by CoreCode on 16.11.07.
//  Copyright CoreCode 2007 - 2008. All rights reserved.
//

#import "Core3D.h"


#define RECURSION_THRESHOLD 1000

GLfloat frustum[6][4];
uint16 _visibleNodeStackTop;

static void vfcTestOctreeNode(struct octree_struct *octree, uint16 *visibleNodeStack, uint32 nodeNum);

@implementation Octree

@synthesize octree, octree_collision, color, specularColor, visibleNodeStack, visibleNodeStackTop, shininess;

- (id)initWithOctreeNamed:(NSString *)_name
{
	if ((self = [super init]))
	{
		shininess = 30.0;
		name = [[NSString alloc] initWithString:_name];
		[self setColor:COLOR_RGB(0.5, 0.5, 0.5)];
		[self setSpecularColor:COLOR_RGB(1.0, 1.0, 1.0)];

		NSData *octreeData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:@"octree"]];
	
		
		if (!octreeData)
			fatal("Error: there is no octree named: %s", [name UTF8String]);
		octree = (octree_struct *) malloc([octreeData length]);
		[octreeData getBytes:octree];

		
		if ((octree->magicWord != 0x6D616C62) && (octree->magicWord != 0xDEADBEEF))
			fatal("Error: the file named %s doesn't seem to be a valid octree", [name UTF8String]);
				
		glGenBuffers(1, &vertexVBOName);
		glGenBuffers(1, &indexVBOName);
		
		glBindBuffer(GL_ARRAY_BUFFER, vertexVBOName);
//		float *vertices = (float *) malloc(octree->vertexCount * ((octree->magicWord == 0x6D616C62) ? 6 : 8) * sizeof(float));
//		memcpy(vertices, OFFSET_VERTICES, octree->vertexCount * ((octree->magicWord == 0x6D616C62) ? 6 : 8) * sizeof(float));  // TODO: revert this fuck
		glBufferData(GL_ARRAY_BUFFER, octree->vertexCount * ((octree->magicWord == 0x6D616C62) ? 6 : 8) * sizeof(float), OFFSET_VERTICES, GL_STATIC_DRAW);
//		glBufferData(GL_ARRAY_BUFFER, octree->vertexCount * ((octree->magicWord == 0x6D616C62) ? 6 : 8) * sizeof(float), vertices, GL_STATIC_DRAW);
//		free(vertices);
		
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexVBOName);
//		float *faces = (float *) malloc(octree->rootnode.faceCount * 3 * (octree->vertexCount > 0xFFFF ? sizeof(uint32) : sizeof(uint16)));
//		memcpy(faces, OFFSET_FACES, octree->rootnode.faceCount * 3 * (octree->vertexCount > 0xFFFF ? sizeof(uint32) : sizeof(uint16)));

		if ((octree->vertexCount <= 0xFFFF) && (globalInfo.gpuVendor == kATI))
		{
			
			uint32 *faces = (uint32 *) malloc(octree->rootnode.faceCount * 3 * sizeof(uint32));		
			for (unsigned int i = 0; i < octree->rootnode.faceCount; i++)
			{
				uint16 *f = (uint16 *) FACE_NUM(i);
				
				faces[i*3] = *f;
				faces[i*3+1] = *(f+1);
				faces[i*3+2] = *(f+2);
				
				//		NSLog(@"%i: v1: %u v2: %u v3: %u\n", i, *f, *(f+1), *(f+2));
				//		NSLog(@"new %i: v1: %i v2: %i v3: %i\n", i, faces[i*3], faces[i*3+1], faces[i*3+2]);
			}
			glBufferData(GL_ELEMENT_ARRAY_BUFFER, octree->rootnode.faceCount * 3 * sizeof(uint32), faces, GL_STATIC_DRAW);
			free(faces);
		}
		else
			glBufferData(GL_ELEMENT_ARRAY_BUFFER, octree->rootnode.faceCount * 3 * (octree->vertexCount > 0xFFFF ? sizeof(uint32) : sizeof(uint16)), OFFSET_FACES, GL_STATIC_DRAW);
//		glBufferData(GL_ELEMENT_ARRAY_BUFFER, octree->rootnode.faceCount * 3 * (octree->vertexCount > 0xFFFF ? sizeof(uint32) : sizeof(uint16)), faces, GL_STATIC_DRAW);
//		free(faces);
	
		glBindBuffer(GL_ARRAY_BUFFER, 0);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);		

		
		if (octree->magicWord != 0x6D616C62)
		{
			NSString *texPath = [[NSBundle mainBundle] pathForResource:name ofType:@"png"];
			if (texPath)
				texName = LoadTexture(texPath, GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR, GL_TRUE, 4.0);
			else
				NSLog(@"Warning: could not find texture named: %@", name);	
		}
		
		visibleNodeStack = (uint16 *) malloc(octree->nodeCount * sizeof(uint16));
		
		if ([self respondsToSelector:@selector(initCollision)])
			[self initCollision];
	}
	
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    Octree *octreeCopy = NSCopyObject(self, 0, zone);
	
    octreeCopy->color = nil;
    [octreeCopy setColor:[self color]];
	octreeCopy->specularColor = nil;
    [octreeCopy setSpecularColor:[self specularColor]];
    octreeCopy->name = [[NSString alloc] initWithString:name];
	octreeCopy->visibleNodeStack = (uint16 *) malloc(octree->nodeCount * sizeof(uint16));

    return octreeCopy;
}

- (NSString *)description
{
	NSMutableString *desc = [NSMutableString stringWithString:@"Octree:\t"];
	
	[desc appendFormat:@"Name:%@\t ", name];	
	[desc appendFormat:@"NodeCount:%i\t ", octree->nodeCount];
	[desc appendFormat:@"VertexCount:%i\t ", octree->vertexCount];
	[desc appendFormat:@"FaceCount:%i\n", octree->rootnode.faceCount];
	
	if (printDetailedOctreeInfo)
	{
		[desc appendFormat:@"NodeOffset:%i\n", OFFSET_NODES];
		[desc appendFormat:@"VertexOffset:%i\n", OFFSET_VERTICES];
		[desc appendFormat:@"FaceOffset:%i\n", OFFSET_FACES];
		
		uint32 i;
		[desc appendString:@"Nodes:\n"];
		for (i = 0; i < octree->nodeCount; i++)
		{
			struct octree_node *n = (struct octree_node *) NODE_NUM(i);
			[desc appendFormat:@"%i: firstFace: %i faceCount:%i origin:%f %f %f extent: %f %f %f children: %i %i %i %i %i %i %i %i\n", i, n->firstFace, n->faceCount, n->aabbOriginX, n->aabbOriginY, n->aabbOriginZ, n->aabbExtentX, n->aabbExtentY, n->aabbExtentZ, n->childIndex1, n->childIndex2, n->childIndex3, n->childIndex4, n->childIndex5, n->childIndex6, n->childIndex7, n->childIndex8];
		}
		[desc appendString:@"\nVertices:\n"];
		for (i = 0; i < octree->vertexCount; i++)
		{
			float *v = (float *) VERTEX_NUM(i);
			if (octree->magicWord == 0x6D616C62)
				[desc appendFormat:@"%i: x: %f y: %f z: %f nx: %f ny: %f nz: %f\n", i, *v, *(v+1), *(v+2), *(v+3), *(v+4), *(v+5)];
			else
				[desc appendFormat:@"%i: x: %f y: %f z: %f nx: %f ny: %f nz: %f  tx: %f ty: %f tz: %f\n", i, *v, *(v+1), *(v+2), *(v+3), *(v+4), *(v+5), *(v+6), *(v+7), *(v+8)];		
		}
		[desc appendString:@"\nFaces:\n"];
		for (i = 0; i < octree->rootnode.faceCount; i++)
		{
			uint16 *f = (uint16 *) FACE_NUM(i);
			
			[desc appendFormat:@"%i: v1: %u v2: %u v3: %u\n", i, *f, *(f+1), *(f+2)];
		}
	}
	
	return [NSString stringWithString:[[super description] stringByAppendingString:desc]];
}

- (void)renderNode
{	
#ifndef TARGET_OS_IPHONE	
	if (globalSettings.doWireframe)
		glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
#endif

	if (globalInfo.renderpass == kMainRenderPass)
	{
		#ifndef TARGET_OS_IPHONE
		CGFloat rgba[4];
		[[color colorUsingColorSpaceName:NSCalibratedRGBColorSpace] getRed:&rgba[0] green:&rgba[1] blue:&rgba[2] alpha:&rgba[3]];
		GLfloat rgba2[4] = {rgba[0],rgba[1],rgba[2],rgba[3]};
		glColor4fv(rgba2);
		[[specularColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace] getRed:&rgba[0] green:&rgba[1] blue:&rgba[2] alpha:&rgba[3]];
		GLfloat rgba3[4] = {rgba[0],rgba[1],rgba[2],rgba[3]};
		glMaterialfv(GL_FRONT, GL_SPECULAR, rgba3);
		#else
		const CGFloat *rgba = CGColorGetComponents(color.CGColor);
		glColor4fv(rgba);
		rgba = CGColorGetComponents(specularColor.CGColor);		
		glMaterialfv(GL_FRONT, GL_SPECULAR, rgba);		
		#endif
		
		glMaterialf(GL_FRONT, GL_SHININESS, shininess);

	}

	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_NORMAL_ARRAY);
	
	glBindBuffer(GL_ARRAY_BUFFER, vertexVBOName);
	
	if ((octree->magicWord != 0x6D616C62) && (globalInfo.renderpass == kMainRenderPass))
	{
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		glEnable(GL_TEXTURE_2D);	
		glBindTexture(GL_TEXTURE_2D, texName);
		glTexCoordPointer(2, GL_FLOAT, sizeof(float) * 8, (const GLfloat *) (sizeof(float) * 6));
	}
	
	glNormalPointer(GL_FLOAT, (octree->magicWord == 0x6D616C62) ? sizeof(float) * 6 : sizeof(float) * 8, (const GLfloat *) (sizeof(float) * 3));
	glVertexPointer(3, GL_FLOAT, (octree->magicWord == 0x6D616C62) ? sizeof(float) * 6 : sizeof(float) * 8, (const GLfloat *) 0);
	
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexVBOName);
	
	if (globalSettings.disableVFC) // no view frustum culling, render everthing with a single call
	{
#ifndef TARGET_OS_IPHONE				
		if 	(octree->vertexCount > 0xFFFF)	
			glDrawElements(GL_TRIANGLES, octree->rootnode.faceCount * 3, GL_UNSIGNED_INT, (const GLuint *) 0);
		else
#endif		
			glDrawElements(GL_TRIANGLES, octree->rootnode.faceCount * 3, GL_UNSIGNED_SHORT, (const GLushort *) 0);
		
		globalInfo.renderedFaces[globalInfo.renderpass] += octree->rootnode.faceCount;
		globalInfo.visitedNodes[globalInfo.renderpass] ++;
	}
	else
	{	
		if (globalInfo.renderpass != kAdditionalRenderPass)
		{
			_visibleNodeStackTop = 0;
			
			matrix44f_c modelview;

			glGetFloatv(GL_MODELVIEW_MATRIX, modelview.data());
			
			extract_frustum_planes(modelview, globalInfo.renderpass == kShadowRenderPass ? globalInfo.lightProjectionMatrix : globalInfo.projectionMatrix, frustum, z_clip_neg_one, false);
			
			vfcTestOctreeNode(octree, visibleNodeStack, 0);
			
			visibleNodeStackTop = _visibleNodeStackTop;
		}
		
		uint16 i;
		for (i = 0; i < visibleNodeStackTop; i++)
		{
			struct octree_node *n = (struct octree_node *) NODE_NUM(visibleNodeStack[i]);	
#ifndef TARGET_OS_IPHONE				
			if 	((octree->vertexCount > 0xFFFF) || (globalInfo.gpuVendor == kATI))
				glDrawElements(GL_TRIANGLES, n->faceCount * 3, GL_UNSIGNED_INT, (const GLuint *) 0 + (n->firstFace * 3));	// TODO: glMultiDrawElements could give a speedup here
			else
#endif
				glDrawElements(GL_TRIANGLES, n->faceCount * 3, GL_UNSIGNED_SHORT, (const GLushort *) 0 + (n->firstFace * 3));
									
			globalInfo.renderedFaces[globalInfo.renderpass] += n->faceCount;
		}	
	}

	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_NORMAL_ARRAY);	
	
	if ((octree->magicWord != 0x6D616C62) && (globalInfo.renderpass == kMainRenderPass))
	{
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
		glDisable(GL_TEXTURE_2D);	
	}
	
#ifndef TARGET_OS_IPHONE		
	if (globalInfo.renderpass == kMainRenderPass)
	{
		if (drawObjectCenters)
		{
			glDisable(GL_DEPTH_TEST); 
			glPointSize(10.0);
			glBegin(GL_POINTS);
			glColor3b(100,4,4);
			glVertex3f(0, 0, 0);
			glEnd();	
			glPointSize(1.0);
			glBegin(GL_LINES);
			glColor3b(100,100,100);
			glVertex3f(0, 0, 0);
			vector3f la = [self getLookAt];
			glVertex3fv((const GLfloat *)&la);		
			glEnable(GL_DEPTH_TEST); 
		}
		
		globalInfo.totalFaces += octree->rootnode.faceCount;
		globalInfo.totalNodes += octree->nodeCount;
		
		if (globalSettings.displayOctree)
		{
			GLint prog;
			glColor3b(100,0,0);		
			glDisable(GL_LIGHTING);
			glGetIntegerv(GL_CURRENT_PROGRAM, &prog);		
			glUseProgram(0);
			
			glBegin(GL_LINES);
			uint32 j;
			for (j = 0; j < octree->nodeCount; j++)
			{
				struct octree_node *n = (struct octree_node *) NODE_NUM(j);
				
				RenderAABB(n->aabbOriginX, n->aabbOriginY, n->aabbOriginZ, n->aabbOriginX + n->aabbExtentX, n->aabbOriginY + n->aabbExtentY,  n->aabbOriginZ + n->aabbExtentZ);
			}
			glEnd();

			glEnable(GL_LIGHTING);	
			glUseProgram(prog);
		}
		
		if (globalSettings.displayNormals)
		{
			GLint prog;
			glColor3b(100,100,100);		
			glDisable(GL_LIGHTING);
			glGetIntegerv(GL_CURRENT_PROGRAM, &prog);		
			glUseProgram(0);
			
			glBegin(GL_LINES);		
			uint16 i;
			for (i = 0; i < octree->rootnode.faceCount; i++)
			{
				const float normalscale = 0.2;
				uint16 *f = (uint16 *) FACE_NUM(i); // TODO: displaying normals is broken for octrees with len(vertices) > 0xFFFF
				float *v1 = (float *) VERTEX_NUM(*f);
				float *v2 = (float *) VERTEX_NUM(*(f+1));
				float *v3 = (float *) VERTEX_NUM(*(f+2));
				
				glVertex3f(*(v1), *(v1+1), *(v1+2));
				glVertex3f(*(v1)+(*(v1+3)/normalscale), *(v1+1)+(*(v1+4)/normalscale), *(v1+2)+(*(v1+5)/normalscale));
				
				glVertex3f(*(v2), *(v2+1), *(v2+2));
				glVertex3f(*(v2)+(*(v2+3)/normalscale), *(v2+1)+(*(v2+4)/normalscale), *(v2+2)+(*(v2+5)/normalscale));
				
				glVertex3f(*(v3), *(v3+1), *(v3+2));
				glVertex3f(*(v3)+(*(v3+3)/normalscale), *(v3+1)+(*(v3+4)/normalscale), *(v3+2)+(*(v3+5)/normalscale));
			}
			glEnd();

			glEnable(GL_LIGHTING);					
			glUseProgram(prog);
		}
	}
	
	if (globalSettings.doWireframe)
		glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
#endif
}

- (void)dealloc
{
	free(octree);
	
	[super dealloc];
}

@end

static void vfcTestOctreeNode(struct octree_struct *octree, uint16 *visibleNodeStack, uint32 nodeNum) // TODO: optimization: VFC coherence (http://www.cescg.org/CESCG-2002/DSykoraJJelinek/index.html)
{
	struct octree_node *n = (struct octree_node *) NODE_NUM(nodeNum);
	char result;
	
	globalInfo.visitedNodes[globalInfo.renderpass]++;
		
	if (n->faceCount == 0)
		return;
	
	result = AABoxInFrustum((const float (*)[4])frustum, n->aabbOriginX, n->aabbOriginY, n->aabbOriginZ, n->aabbExtentX, n->aabbExtentY, n->aabbExtentZ);
	if (result == kIntersecting)
	{
		if ((n->childIndex1 == 0xFFFF) || (n->faceCount < RECURSION_THRESHOLD))	
			visibleNodeStack[_visibleNodeStackTop++] = nodeNum;
		else
		{	
			vfcTestOctreeNode(octree, visibleNodeStack, n->childIndex1);
			vfcTestOctreeNode(octree, visibleNodeStack, n->childIndex2);			
			vfcTestOctreeNode(octree, visibleNodeStack, n->childIndex3);
			vfcTestOctreeNode(octree, visibleNodeStack, n->childIndex4);
			vfcTestOctreeNode(octree, visibleNodeStack, n->childIndex5);
			vfcTestOctreeNode(octree, visibleNodeStack, n->childIndex6);
			vfcTestOctreeNode(octree, visibleNodeStack, n->childIndex7);
			vfcTestOctreeNode(octree, visibleNodeStack, n->childIndex8);
		}
	}
	else if (result == kInside)
		visibleNodeStack[_visibleNodeStackTop++] = nodeNum;	
}