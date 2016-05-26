//
//  Light.m
//  Core3D
//
//  Created by CoreCode on 22.11.07.
//  Copyright CoreCode 2007 - 2008. All rights reserved.
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