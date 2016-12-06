//
//  Light.m
//  Core3D
//
//  Created by CoreCode on 22.11.07.
/*	Copyright (c) 2016 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

#import "Core3D.h"

static uint8 numlights = 0;
uint8 num;

@implementation Light

- (id)init
{
	if ((self = [super init]))
	{
		num = numlights++;
		
		GLfloat lightDiffuse[]= {1.0f, 1.0f, 1.0f, 1.0f};
		GLfloat lightPosition[]= {position[0], position[1], position[2], 1.0f};
		GLfloat lightSpecular[]= {1.0f, 1.0f, 1.0f, 1.0f};
		GLfloat lightAmbient[]= {0.1f, 0.1f, 0.1f, 1.0f};
		
		if (num == 0)
			glEnable(GL_LIGHTING);
		else if (num > 8)
			fatal("Error: more than 8 lights instantiated");
			
		glLightfv(GL_LIGHT0 + num, GL_AMBIENT, lightAmbient);	
		glLightfv(GL_LIGHT0 + num, GL_DIFFUSE, lightDiffuse);	
		glLightfv(GL_LIGHT0 + num, GL_POSITION, lightPosition);
		glLightfv(GL_LIGHT0 + num, GL_SPECULAR, lightSpecular);
		glEnable(GL_LIGHT0 + num);
	}
	return self;
}

- (void)dealloc
{
	glDisable(GL_LIGHT0 + num);
	if ([[scene lights] count] == 0)
		glDisable(GL_LIGHTING);	
			
	[super dealloc];
}
@end