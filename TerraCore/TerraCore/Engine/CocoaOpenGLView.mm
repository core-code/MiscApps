//
//  CocoaOpenGLView.m
//  Core3D
//
//  Created by CoreCode on 14.11.07.
/*	Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

#import "Core3D.h"
#import "CocoaOpenGLView.h"


NSMutableArray *pressedKeys;


@implementation CocoaOpenGLView

- (void)awakeFromNib
{
	timer = [NSTimer timerWithTimeInterval:(1.0f/60.0f) target:self selector:@selector(animationTimer:) userInfo:nil repeats:YES];
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSEventTrackingRunLoopMode]; // ensure timer fires during resize
		
	pressedKeys = [[NSMutableArray alloc] initWithCapacity:5];

	[[self window] zoom:self];
}

- (void)animationTimer:(NSTimer *)timer
{
	//[self drawRect:[self bounds]]; // redraw now instead dirty to enable updates during live resize
	[self setNeedsDisplay:YES];
}

- (void)prepareOpenGL
{
	scene = [Scene sharedScene];
	
	[scene setSimulator:[[[NSClassFromString([[NSBundle mainBundle] objectForInfoDictionaryKey:@"SimulationClass"]) alloc] init] autorelease]];
	
	const GLint swap = !globalSettings.disableVBLSync;
	CGLSetParameter(CGLGetCurrentContext(), kCGLCPSwapInterval, &swap);
}

- (void)reshape
{ 
	[[self openGLContext] update];

	[scene reshape:[NSArray arrayWithObjects:[NSNumber numberWithInt:[self bounds].size.width], [NSNumber numberWithInt:[self bounds].size.height], nil]];
}

- (void)drawRect:(NSRect)rect
{
	[scene update];
	[scene render];

	[[self openGLContext] flushBuffer];
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
	return YES;
}

- (void)keyDown:(NSEvent *)theEvent
{	
	[pressedKeys addObject:[[NSNumber numberWithUnsignedInt:[[theEvent characters] characterAtIndex:0]] stringValue]];
}

- (void)keyUp:(NSEvent *)theEvent
{
	[pressedKeys removeObject:[[NSNumber numberWithUnsignedInt:[[theEvent characters] characterAtIndex:0]] stringValue]];	
}

- (void)mouseDown:(NSEvent *)theEvent
{
	if ([[scene simulator] respondsToSelector:@selector(mouseDown:)])		[[scene simulator] mouseDown:theEvent];
}

- (void)mouseUp:(NSEvent *)theEvent
{
	if ([[scene simulator] respondsToSelector:@selector(mouseUp:)])			[[scene simulator] mouseUp:theEvent];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	if ([[scene simulator] respondsToSelector:@selector(mouseDragged:)])	[[scene simulator] mouseDragged:theEvent];
}

- (void)scrollWheel:(NSEvent *)theEvent
{
	if ([[scene simulator] respondsToSelector:@selector(scrollWheel:)])	[[scene simulator] scrollWheel:theEvent];
}

@end

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [NSApplication sharedApplication];
	
	if (!PreCheckOpenGL())
	{
		NSRunAlertPanel(@"Error", @"FlowCore requires OpenGL 2.0", @"OK, I'll upgrade", @"", nil);
		exit(1);
	}
	
	[NSBundle loadNibNamed:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSMainNibFile"] owner:NSApp];
	[pool release];
	[NSApp run];
}