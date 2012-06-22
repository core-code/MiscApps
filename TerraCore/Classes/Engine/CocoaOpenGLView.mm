//
//  CocoaOpenGLView.m
//  Core3D
//
//  Created by CoreCode on 14.11.07.
//  Copyright CoreCode 2007 - 2008. All rights reserved.
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