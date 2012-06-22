//
//  TransferFunctionView.m
//  FlowCore
//
//  Created by CoreCode on 09.01.09.
/*	Copyright (c) 2008 - 2009 CoreCode
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */


#import "FlowCore.h"

#define NSNUM(x)		[NSNumber numberWithInt:x]
#define NSCOL(x, y, z)  [NSColor colorWithCalibratedRed:x green:y blue:z alpha:1.0]

@implementation TransferFunctionView

@synthesize points;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    
	if (self)
	{
//		cantChangeOpacity = TRUE;
		dragging = -1;
		float h = [self bounds].size.height, w = [self bounds].size.width;
		[[HUDHack class] poseAsClass:[NSColorPanel class]];
		
		dragging = 0;
		points = [[NSMutableArray alloc] initWithCapacity:10];
		
		[points addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:NSNUM(0),			@"x", NSNUM(cantChangeOpacity ? h / 2.0 : 0),	@"y", NSCOL(0.0, 0.0, 0.2), @"color", nil]];
		[points addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:NSNUM(w / 3.0),		@"x", NSNUM(h / 2.0),							@"y", NSCOL(0.0, 0.0, 0.6), @"color", nil]];
		[points addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:NSNUM(w * 2 / 3.0),	@"x", NSNUM(h / 2.0),							@"y", NSCOL(0.6, 0.0, 0.0), @"color", nil]];
		[points addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:NSNUM(w),			@"x", NSNUM(cantChangeOpacity ? h / 2.0 : h),	@"y", NSCOL(1.0, 1.0, 1.0), @"color", nil]];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(colorDidChange:) name:NSColorPanelColorDidChangeNotification object:nil];		
	}
    return self;
}

- (void)colorDidChange:(id)sender
{
	[[points objectAtIndex:selectedPointEdit] setObject:[[sender object] color] forKey:@"color"];

	[[NSNotificationCenter defaultCenter] postNotificationName: @"TransferFunctionChanged" object: self];
	[self setNeedsDisplayInRect:[self bounds]];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSColorPanelColorDidChangeNotification object:nil];

    [points release];
	
    [super dealloc];  
}

- (void)drawRect:(NSRect)rect
{
	// background
    [[self getGradient] drawInRect:[self bounds] angle:0.0];
	
	// points and line
    NSBezierPath* line = [NSBezierPath bezierPath];
	for (int i = 0; i < [points count]; i++)
	{
		if (i == 0) 
			[line moveToPoint:NSMakePoint([[[points objectAtIndex:i] objectForKey:@"x"] intValue], [[[points objectAtIndex:i] objectForKey:@"y"] intValue])];
		else
			[line lineToPoint:NSMakePoint([[[points objectAtIndex:i] objectForKey:@"x"] intValue], [[[points objectAtIndex:i] objectForKey:@"y"] intValue])];
	
		[[NSColor whiteColor] set];		
		NSBezierPath* kreis = [NSBezierPath bezierPath];
		[kreis appendBezierPathWithOvalInRect:[self boundsForItem:i]];		
		[kreis stroke];	
		
		[[NSColor blackColor] set];		
		NSBezierPath* kugel = [NSBezierPath bezierPath];
		[kugel appendBezierPathWithOvalInRect:[self boundsForItem:i]];		
		[kugel fill];
	}
	[line stroke];
}

- (BOOL)isOpaque
{
    return YES;
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
	NSPoint clickLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	
	for (int i = 0; i < ([points count]); i++)
	{
		if (NSPointInRect(clickLocation, [self boundsForItem:i]))
		{
			selectedPoint = i;
			((i == 0) || (i == [points count] - 1)) ? [NSMenu popUpContextMenu:cms withEvent:theEvent forView:self] : [NSMenu popUpContextMenu:cm withEvent:theEvent forView:self];	
		}
	}
}

- (void)mouseDown:(NSEvent *)event
{
    NSPoint clickLocation = [self convertPoint:[event locationInWindow] fromView:nil];
	BOOL anyHit = FALSE;
	
	for (int i = 0; i < [points count]; i++)
	{		
		if (NSPointInRect(clickLocation, [self boundsForItem:i]))
		{
			dragging = i;

			[[NSCursor closedHandCursor] push];
			
			anyHit = TRUE;
			
			break;
		}		
	}
	
	if (!anyHit)
	{
		for (int i = 1; i < [points count]; i++)
		{
			if ((clickLocation.x > [[[points objectAtIndex:i - 1] objectForKey:@"x"] intValue]) && (clickLocation.x < [[[points objectAtIndex:i] objectForKey:@"x"] intValue]))
			{
				[points insertObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:clickLocation.x], @"x", [NSNumber numberWithInt:cantChangeOpacity ? [self bounds].size.height / 2.0 : clickLocation.y], @"y", NSCOL(1.0, 1.0, 1.0), @"color", nil] atIndex:i];

				[[NSNotificationCenter defaultCenter] postNotificationName: @"TransferFunctionChanged" object: self];
				[self setNeedsDisplayInRect:[self bounds]];	
				break;
			}
		}
	}	
}

- (void)mouseDragged:(NSEvent *)event
{
    if (dragging >= 0)
	{
		NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
		
		if ((dragging != [points count]-1) && (dragging != 0))
		{
			if ((point.x < [[[points objectAtIndex:dragging + 1] objectForKey:@"x"] intValue]) &&
				(point.x > [[[points objectAtIndex:dragging - 1] objectForKey:@"x"] intValue]))
				[[points objectAtIndex:dragging] setObject:[NSNumber numberWithInt:point.x] forKey:@"x"];
		}
		
		if (!cantChangeOpacity)
		{
			NSNumber *num;
			if (point.y < 0)
				num = [NSNumber numberWithInt:0];
			else if (point.y > [self bounds].size.height)
				num = [NSNumber numberWithInt:[self bounds].size.height];
			else
				num = [NSNumber numberWithInt:point.y];
			
			[[points objectAtIndex:dragging] setObject:num forKey:@"y"];
		}
		
		[[NSNotificationCenter defaultCenter] postNotificationName: @"TransferFunctionChanged" object: self];
		[self setNeedsDisplayInRect:[self bounds]];
		
		[self autoscroll:event];
    }
}

- (void)mouseUp:(NSEvent *)event
{
    dragging = -1;
    
    [NSCursor pop];
    
    [[self window] invalidateCursorRectsForView:self];
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)resetCursorRects
{
    [self discardCursorRects];
    
	for (int i = 0; i < [points count]; i++)
		[self addCursorRect:[self boundsForItem:i] cursor:[NSCursor openHandCursor]];
}

- (NSRect)boundsForItem:(short)item
{
	NSRect calculatedRect;
	NSDictionary *dict = [points objectAtIndex:item];
	
	calculatedRect.origin.x = [[dict objectForKey:@"x"] intValue] - POINTSIZE / 2.0;
	calculatedRect.origin.y = [[dict objectForKey:@"y"] intValue] - POINTSIZE / 2.0;
	
	calculatedRect.size.width  = POINTSIZE;
	calculatedRect.size.height = POINTSIZE;
	
	return calculatedRect;
}

- (NSGradient *)getGradient
{
	NSMutableArray *colors = [NSMutableArray arrayWithCapacity:[points count]];
	CGFloat locations[[points count]];
	for (int i = 0; i < [points count]; i++)
	{
		[colors addObject:[[points objectAtIndex:i] objectForKey:@"color"]];
		locations[i] = [[[points objectAtIndex:i] objectForKey:@"x"] floatValue] / [self bounds].size.width;
	}
	
	return [[[NSGradient alloc] initWithColors:colors atLocations:locations colorSpace:[NSColorSpace genericRGBColorSpace]] autorelease];
}

- (IBAction)erasePoint:(id)sender
{
	[points removeObjectAtIndex:selectedPoint];

	[[NSNotificationCenter defaultCenter] postNotificationName: @"TransferFunctionChanged" object: self];
	[self setNeedsDisplayInRect:[self bounds]];	
}

- (IBAction)editPoint:(id)sender
{
	selectedPointEdit = selectedPoint;

	[[NSColorPanel sharedColorPanel] setColor:[[points objectAtIndex:selectedPointEdit] objectForKey:@"color"]];
	[[NSApplication sharedApplication] orderFrontColorPanel:nil];
}

- (NSColor *)colorAtLocation:(float)location
{
	NSColor *color = [[[self getGradient] interpolatedColorAtLocation:location] colorUsingColorSpaceName:NSCalibratedRGBColorSpace];

	for (int i = 0; i < [points count]-1; i++)
	{
		float lochere = [[[points objectAtIndex:i] objectForKey:@"x"] floatValue] / [self bounds].size.width;
		float locnext = [[[points objectAtIndex:i+1] objectForKey:@"x"] floatValue] / [self bounds].size.width;

		if ((location >= lochere) && (location <= locnext))
		{
			float factor = 1.0 / (locnext - lochere);
			float alpha = [[[points objectAtIndex:i] objectForKey:@"y"] floatValue] * ((locnext - location) * factor) + [[[points objectAtIndex:i+1] objectForKey:@"y"] floatValue] * ((location - lochere) * factor) ;

			return [NSColor colorWithCalibratedRed:[color redComponent] green:[color greenComponent] blue:[color blueComponent] alpha:alpha / [self bounds].size.height];			 
		}
	}
	
	return [NSColor whiteColor];
}
@end


@implementation TransferFunctionViewRestricted
- (id)initWithFrame:(NSRect)frame {
	cantChangeOpacity = TRUE;

    self = [super initWithFrame:frame];
    
    return self;
}
@end

@implementation HUDHack
- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)windowStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation
{
	return [super initWithContentRect:contentRect styleMask:windowStyle | 8223 backing:bufferingType defer:deferCreation];
}
@end