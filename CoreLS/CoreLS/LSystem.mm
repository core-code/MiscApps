//
//  LSystem.m
//  fraktale
//
//  Created by CoreCode on 17.02.09.
/*	Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

#import "LSystemSimulation.h"


LSystem *gLSystem;

@implementation LSystem

@synthesize color, angle, cameraMode, subdivision, length, radius;

+ (NSString *)performLSystemDerivation:(NSString *)input usingFReplacement:(NSString *)fReplacement andGReplacement:(NSString *)gReplacement steps:(uint8)steps
{
	if (steps > 0)
	{
		fReplacement = [fReplacement stringByReplacingOccurrencesOfString:@"G" withString:@"?"];
		
		NSString *output = [input stringByReplacingOccurrencesOfString:@"F" withString:fReplacement];
		output = [output stringByReplacingOccurrencesOfString:@"G" withString:gReplacement];
		output = [output stringByReplacingOccurrencesOfString:@"?" withString:@"G"];
		
		return [LSystem performLSystemDerivation:output usingFReplacement:fReplacement andGReplacement:gReplacement steps:--steps];
	}
	else
		return input;
}

- (id)init
{
	if ((self = [super init]))
	{
		gLSystem = self;
		length = 100.0;
		angle = 45.0;
		radius = 2.0;
		primitiveMode = 1;
		subdivision = 3;
		[self setColor:[NSColor whiteColor]];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(colorDidChange:) name:NSColorPanelColorDidChangeNotification object:nil];				
	}
	
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSColorPanelColorDidChangeNotification object:nil];
		
    [super dealloc];  
}

- (void)colorDidChange:(id)sender
{
	[self setColor:[[sender object] color]];
}

- (IBAction)switchCameraMode:(id)sender
{
	[self setRotation:vector3f(0,0,0)];
}

- (IBAction)stopCamera:(id)sender
{
	[[scene simulator] stopCamera];
}

- (IBAction)presetActivated:(id)sender
{
	[gField setStringValue:@""];
	primitiveMode = 1;

	if ([sender indexOfSelectedItem] == 1)
	{
		[axiomField setStringValue:@"F[zF][F][ZF][xF][XF][yF][YF]"];
		[fField setStringValue:@"F[zF][F][ZF][xF][XF][yF][YF]"];	
		[self setAngle:30];
		[self setColor:[NSColor greenColor]];
		[self setSubdivision:3];
		[self setLength:100];		
		[self rebuild:self];
		[self resetCameraFront:self];
	}
	else if ([sender indexOfSelectedItem] == 2)
	{
		[axiomField setStringValue:@"F[zF][F][ZF][xF][XF][yF][YF]"];
		[fField setStringValue:@"FxFF"];	
		[self setAngle:45];
		[self setColor:[NSColor cyanColor]];
		[self setSubdivision:5];
		[self setLength:100];		
		[self rebuild:self];
		[self resetCameraFront:self];	
	}
	else if ([sender indexOfSelectedItem] == 3)
	{
		[axiomField setStringValue:@"FYFZF"];
		[fField setStringValue:@"FXFFzF"];	
		[self setAngle:90];
		[self setColor:[NSColor whiteColor]];
		[self setSubdivision:6];
		[self setLength:100];		
		[self rebuild:self];
		[self resetCameraFront:self];	
	}
	else if ([sender indexOfSelectedItem] == 4)
	{
		[axiomField setStringValue:@"FzzFzzF"];
		[fField setStringValue:@"FZFzzFZF"];	
		[self setAngle:60];
		[self setColor:[NSColor whiteColor]];
		[self setSubdivision:4];
		[self setLength:100];
		[self setRadius:10];
		[self rebuild:self];
		[self resetCameraFront:self];	
	}

	else if ([sender indexOfSelectedItem] == 5)
	{
		primitiveMode = 0;
		[axiomField setStringValue:@"CF"];
		[fField setStringValue:@"FzGCz"];
		[gField setStringValue:@"ZCFZG"];
		[self setAngle:90];
		[self setColor:[NSColor whiteColor]];
		[self setSubdivision:14];
		[self setLength:1];
		[self setRadius:1];
		[self rebuild:self];
		[self resetCameraFront:self];
	}
}

#define MAGICNUM 1.35 // why do we need this magic number? my trigonometry sucks

- (IBAction)resetCameraTop:(id)sender
{
	float fovy = [[scene camera] fov], fovx = yfov_to_xfov(fovy, globalInfo.width / globalInfo.height);
	
	float distance = fmaxf( ((max[0] - min[0]) / 2.0) / tanf(fovx / 2.0),
						    ((max[2] - min[2]) / 2.0) / tanf(fovy / 2.0));
	
	[[scene simulator] stopCamera];
	[[scene camera] setPosition:vector3f((max[0] + min[0]) / 2.0, max[1] + distance * MAGICNUM, (max[2] + min[2]) / 2.0)];
	[[scene camera] setRotation:vector3f(-90, 0, 0)];	
}

- (IBAction)resetCameraFront:(id)sender
{
	float fovy = [[scene camera] fov], fovx = yfov_to_xfov(fovy, globalInfo.width / globalInfo.height);
	
	float distance = fmaxf( ((max[0] - min[0]) / 2.0) / tanf(fovx / 2.0),
							((max[1] - min[1]) / 2.0) / tanf(fovy / 2.0));
	
	[[scene simulator] stopCamera];
	[[scene camera] setPosition:vector3f((max[0] + min[0]) / 2.0, (max[1] + min[1]) / 2.0, max[2] + distance * MAGICNUM)];
	[[scene camera] setRotation:vector3f(0, 0, 0)];
}

- (IBAction)resetCameraSide:(id)sender
{
	float fovy = [[scene camera] fov], fovx = yfov_to_xfov(fovy, globalInfo.width / globalInfo.height);
	
	float distance = fmaxf( ((max[2] - min[2]) / 2.0) / tanf(fovx / 2.0),
						   ((max[1] - min[1]) / 2.0) / tanf(fovy / 2.0));
	
	[[scene simulator] stopCamera];
	[[scene camera] setPosition:vector3f(max[0] + distance * MAGICNUM, (max[1] + min[1]) / 2.0, (max[2] + min[2]) / 2.0)];
	[[scene camera] setRotation:vector3f(0, 90, 0)];	
}

- (IBAction)rebuild:(id)sender
{	
	if (displayList == 0)
	{
		displayList = glGenLists(1);
		glEnable(GL_LINE_SMOOTH);
		glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
		glShadeModel(GL_SMOOTH);	
	}

	Timer(YES);

	NSString *system = [LSystem performLSystemDerivation:[axiomField stringValue] usingFReplacement:[fField stringValue] andGReplacement:[gField stringValue] steps:subdivision];
	//NSLog(system);
	
	min[0] = min[1] = min[2] = max[0] = max[1] = max[2] = 0;
	
	glLoadIdentity(); // we don't want the camera to mess with our AABB measurement
	glDeleteLists(displayList, 1);
	glColorMask(0, 0, 0, 0);
	glDepthMask(GL_FALSE);
	glNewList(displayList, GL_COMPILE_AND_EXECUTE); // we have to "execute" because of the aabb measurement although we don't wanna see this misplaced (no camera transform) rendering => glColorMask

	GLUquadric *quadric = gluNewQuadric(); 

	for (uint32 i = 0; i < [system length]; i++)
	{
		switch ([system characterAtIndex:i])
		{
			case 'x':
				glRotatef(-angle, 1, 0, 0);			
				break;
			case 'X':
				glRotatef(angle, 1, 0, 0);	
				break;
			case 'y':
				glRotatef(-angle, 0, 1, 0);			
				break;
			case 'Y':
				glRotatef(angle, 0, 1, 0);						
				break;
			case 'z':
				glRotatef(-angle, 0, 0, 1);			
				break;
			case 'Z':
				glRotatef(angle, 0, 0, 1);						
				break;		
			case '[':
				glPushMatrix();		
				break;
			case ']':
				glPopMatrix();				
				break;
			case 'F':
			case 'G':
			default:
				if (primitiveMode)
				{
					glPushMatrix();
					glTranslatef(0, length, 0);
					glRotatef(90, 1, 0, 0);
					gluCylinder(quadric, radius, radius, length, [slicesField intValue], [stacksField intValue]);
					glPopMatrix();
				}
				else
				{
					glBegin(GL_LINES);
					glVertex3f(0, 0, 0);
					glVertex3f(0, length, 0);
					glEnd();
				}

				glTranslatef(0, length, 0);

				GLfloat mvm[16];
				glGetFloatv(GL_MODELVIEW_MATRIX, mvm);		// (ab)use opengl to record maximum extents for camera placement
				if  (mvm[12] < min[0]) min[0] = mvm [12];
				if  (mvm[13] < min[1]) min[1] = mvm [13];
				if  (mvm[14] < min[2]) min[2] = mvm [14];
				if  (mvm[12] > max[0]) max[0] = mvm [12];
				if  (mvm[13] > max[1]) max[1] = mvm [13];
				if  (mvm[14] > max[2]) max[2] = mvm [14];
				break;
		}
	}

	glEndList();
	glColorMask(1, 1, 1, 1);
	glDepthMask(GL_TRUE);
	gluDeleteQuadric(quadric);
	float duration = ((float)Timer(NO)) / (1000.0 * 1000.0);
	[generationTimingField setStringValue:[NSString stringWithFormat:@"%.2f ms (%.1f fps)", duration, 1000.0/duration]];	
	
	[[scene camera] setFarPlane:fmaxf(fmaxf((max[0] - min[0]) * 3, (max[1] - min[1]) * 3), (max[2] - min[2]) * 3)];
}

- (void)renderNode
{
	Timer(YES);

	if (drawAABB)
	{
		glColor3b(100,0,0);		
		glBegin(GL_LINES);
		RenderAABB(min[0], min[1], min[2], max[0], max[1], max[2]);
		glEnd();
	}
	
	CGFloat red,green,blue,alpha;
	[[color colorUsingColorSpaceName:NSCalibratedRGBColorSpace] getRed:&red green:&green blue:&blue alpha:&alpha];
	glColor4f(red, green, blue, alpha);
	
	glCallList(displayList);
	
	if ([animateButton state] == NSOnState && globalInfo.frame % 10 == 0)
	{
		[self setAngle:angle+1];
		if (angle > 180) 
			[self setAngle:0];
		[self rebuild:self];
	}

	glFinish();
	float duration = ((float)Timer(NO)) / (1000.0 * 1000.0);
	[frameTimingField setStringValue:[NSString stringWithFormat:@"%.2f ms (%.1f fps)", duration, 1000.0/duration]];	
}
@end
