//
//  PRHOnOffButtonCell.m
//  PRHOnOffButton
//
//  Created by Peter Hosey on 2010-01-10.
//  Copyright 2010 Peter Hosey. All rights reserved.
//

#import "PRHOnOffButtonCell.h"

#include <Carbon/Carbon.h>

#define ONE_THIRD  (1.0 / 3.0)
#define ONE_HALF   (1.0 / 2.0)
#define TWO_THIRDS (2.0 / 3.0)

#define THUMB_WIDTH_FRACTION 0.45f
#define THUMB_CORNER_RADIUS 2.5f
#define FRAME_CORNER_RADIUS 2.5f

#define THUMB_GRADIENT_MAX_Y_WHITE 1.0f
#define THUMB_GRADIENT_MIN_Y_WHITE 0.9f
#define BACKGROUND_GRADIENT_MAX_Y_WHITE 0.5f
#define BACKGROUND_GRADIENT_MIN_Y_WHITE TWO_THIRDS
#define BACKGROUND_SHADOW_GRADIENT_WHITE 0.0f
#define BACKGROUND_SHADOW_GRADIENT_MAX_Y_ALPHA 0.35f
#define BACKGROUND_SHADOW_GRADIENT_MIN_Y_ALPHA 0.0f
#define BACKGROUND_SHADOW_GRADIENT_HEIGHT 4.0f
#define BORDER_WHITE 0.125f

#define THUMB_SHADOW_WHITE 0.0f
#define THUMB_SHADOW_ALPHA 0.5f
#define THUMB_SHADOW_BLUR 3.0f

#define DISABLED_OVERLAY_GRAY  1.0f
#define DISABLED_OVERLAY_ALPHA TWO_THIRDS

#define DOWNWARD_ANGLE_IN_DEGREES_FOR_VIEW(view) ([view isFlipped] ? 90.0f : 270.0f)

struct PRHOOBCStuffYouWouldNeedToIncludeCarbonHeadersFor {
	EventTime clickTimeout;
	HISize clickMaxDistance;
};

@implementation PRHOnOffButtonCell

- (void)dealloc
{
    NSZoneFree([self zone], stuff);
    [super dealloc];
}
+ (BOOL) prefersTrackingUntilMouseUp {
	return /*YES, YES, a thousand times*/ YES;
}

+ (NSFocusRingType) defaultFocusRingType {
	return NSFocusRingTypeExterior;
}

- (void) furtherInit {
	[self setFocusRingType:[[self class] defaultFocusRingType]];
	stuff = NSZoneMalloc([self zone], sizeof(struct PRHOOBCStuffYouWouldNeedToIncludeCarbonHeadersFor));
	OSStatus err = HIMouseTrackingGetParameters(kMouseParamsSticky, &(stuff->clickTimeout), &(stuff->clickMaxDistance));
	if (err != noErr) {
		//Values returned by the above function call as of 10.6.3.
		stuff->clickTimeout = ONE_THIRD * kEventDurationSecond;
		stuff->clickMaxDistance = (HISize){ 6.0f, 6.0f };
	}
}

- (id) initImageCell:(NSImage *)image {
	if ((self = [super initImageCell:image])) {
		[self furtherInit];
	}
	return self;
}
- (id) initTextCell:(NSString *)str {
	if ((self = [super initTextCell:str])) {
		[self furtherInit];
	}
	return self;
}
//HAX: IB (I guess?) sets our focus ring type to None for some reason. Nobody asks defaultFocusRingType unless we do it (in furtherInit).
- (id) initWithCoder:(NSCoder *)decoder {
	if ((self = [super initWithCoder:decoder])) {
		[self furtherInit];
	}
	return self;
}

- (NSRect) thumbRectInFrame:(NSRect)cellFrame {
	cellFrame.size.width -= 2.0f;
	cellFrame.size.height -= 2.0f;
	cellFrame.origin.x += 1.0f;
	cellFrame.origin.y += 1.0f;

	NSRect thumbFrame = cellFrame;
	thumbFrame.size.width *= THUMB_WIDTH_FRACTION;

	NSCellStateValue state = [self state];
	switch (state) {
		case NSOffState:
			//Far left. We're already there; don't do anything.
			break;
		case NSOnState:
			//Far right.
			thumbFrame.origin.x += (cellFrame.size.width - thumbFrame.size.width);
			break;
		case NSMixedState:
			//Middle.
			thumbFrame.origin.x = (cellFrame.size.width / 2.0f) - (thumbFrame.size.width / 2.0f);
			break;
	}

	return thumbFrame;
}

- (void) drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	if (tracking)
		trackingCellFrame = cellFrame;

	NSGraphicsContext *context = [NSGraphicsContext currentContext];
	CGContextRef quartzContext = [context graphicsPort];
	CGContextBeginTransparencyLayer(quartzContext, /*auxInfo*/ NULL);

	//Draw the background, then the frame.
	NSBezierPath *borderPath = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(cellFrame, 1.0f, 1.0f) xRadius:FRAME_CORNER_RADIUS yRadius:FRAME_CORNER_RADIUS];

	[[NSColor colorWithCalibratedWhite:BORDER_WHITE alpha:1.0f] setStroke];
	[borderPath stroke];

	NSGradient *background = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:BACKGROUND_GRADIENT_MAX_Y_WHITE alpha:1.0f] endingColor:[NSColor colorWithCalibratedWhite:BACKGROUND_GRADIENT_MIN_Y_WHITE alpha:1.0f]] autorelease];
	[background drawInBezierPath:borderPath angle:DOWNWARD_ANGLE_IN_DEGREES_FOR_VIEW(controlView)];

	[context saveGraphicsState];

	[[NSBezierPath bezierPathWithRoundedRect:cellFrame xRadius:FRAME_CORNER_RADIUS yRadius:FRAME_CORNER_RADIUS] addClip];

	NSGradient *backgroundShadow = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:BACKGROUND_SHADOW_GRADIENT_WHITE alpha:BACKGROUND_SHADOW_GRADIENT_MAX_Y_ALPHA] endingColor:[NSColor colorWithCalibratedWhite:BACKGROUND_SHADOW_GRADIENT_WHITE alpha:BACKGROUND_SHADOW_GRADIENT_MIN_Y_ALPHA]] autorelease];
	NSRect backgroundShadowRect = cellFrame;
	if (![controlView isFlipped])
		backgroundShadowRect.origin.y += backgroundShadowRect.size.height - BACKGROUND_SHADOW_GRADIENT_HEIGHT;
	backgroundShadowRect.size.height = BACKGROUND_SHADOW_GRADIENT_HEIGHT;
	[backgroundShadow drawInRect:backgroundShadowRect angle:DOWNWARD_ANGLE_IN_DEGREES_FOR_VIEW(controlView)];

	[context restoreGraphicsState];

	[self drawInteriorWithFrame:cellFrame inView:controlView];

	if (![self isEnabled]) {
		CGColorRef color = CGColorCreateGenericGray(DISABLED_OVERLAY_GRAY, DISABLED_OVERLAY_ALPHA);
		if (color) {
			CGContextSetBlendMode(quartzContext, kCGBlendModeLighten);
			CGContextSetFillColorWithColor(quartzContext, color);
			CGContextFillRect(quartzContext, NSRectToCGRect(cellFrame));

			CFRelease(color);
		}
	}
	CGContextEndTransparencyLayer(quartzContext);
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	//Draw the thumb.
	NSRect thumbFrame = [self thumbRectInFrame:cellFrame];

	NSGraphicsContext *context = [NSGraphicsContext currentContext];
	[context saveGraphicsState];

	cellFrame.size.width -= 2.0f;
	cellFrame.size.height -= 2.0f;
	cellFrame.origin.x += 1.0f;
	cellFrame.origin.y += 1.0f;
	NSBezierPath *clipPath = [NSBezierPath bezierPathWithRoundedRect:cellFrame xRadius:THUMB_CORNER_RADIUS yRadius:THUMB_CORNER_RADIUS];
	[clipPath addClip];

	if (tracking) {
		thumbFrame.origin.x += trackingPoint.x - initialTrackingPoint.x;

		//Clamp.
		CGFloat minOrigin = cellFrame.origin.x;
		CGFloat maxOrigin = cellFrame.origin.x + (cellFrame.size.width - thumbFrame.size.width);
		if (thumbFrame.origin.x < minOrigin)
			thumbFrame.origin.x = minOrigin;
		else if (thumbFrame.origin.x > maxOrigin)
			thumbFrame.origin.x = maxOrigin;

		trackingThumbCenterX = NSMidX(thumbFrame);
	}

	NSBezierPath *thumbPath = [NSBezierPath bezierPathWithRoundedRect:thumbFrame xRadius:THUMB_CORNER_RADIUS yRadius:THUMB_CORNER_RADIUS];
	NSShadow *thumbShadow = [[[NSShadow alloc] init] autorelease];
	[thumbShadow setShadowColor:[NSColor colorWithCalibratedWhite:THUMB_SHADOW_WHITE alpha:THUMB_SHADOW_ALPHA]];
	[thumbShadow setShadowBlurRadius:THUMB_SHADOW_BLUR];
	[thumbShadow setShadowOffset:NSZeroSize];
	[thumbShadow set];
	[[NSColor whiteColor] setFill];
	if ([self showsFirstResponder] && ([self focusRingType] != NSFocusRingTypeNone))
		NSSetFocusRingStyle(NSFocusRingBelow);
	[thumbPath fill];
	NSGradient *thumbGradient = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:THUMB_GRADIENT_MAX_Y_WHITE alpha:1.0f] endingColor:[NSColor colorWithCalibratedWhite:THUMB_GRADIENT_MIN_Y_WHITE alpha:1.0f]] autorelease];
	[thumbGradient drawInBezierPath:thumbPath angle:DOWNWARD_ANGLE_IN_DEGREES_FOR_VIEW(controlView)];

	[context restoreGraphicsState];

	if (tracking && (getenv("PRHOnOffButtonCellDebug") != NULL)) {
		NSBezierPath *thumbCenterLine = [NSBezierPath bezierPath];
		[thumbCenterLine moveToPoint:(NSPoint){ NSMidX(thumbFrame), thumbFrame.origin.y +thumbFrame.size.height * ONE_THIRD }];
		[thumbCenterLine lineToPoint:(NSPoint){ NSMidX(thumbFrame), thumbFrame.origin.y +thumbFrame.size.height * TWO_THIRDS }];
		[thumbCenterLine stroke];

		NSBezierPath *sectionLines = [NSBezierPath bezierPath];
		if ([self allowsMixedState]) {
			[sectionLines moveToPoint:(NSPoint){ cellFrame.origin.x + cellFrame.size.width * ONE_THIRD, NSMinY(cellFrame) }];
			[sectionLines lineToPoint:(NSPoint){ cellFrame.origin.x + cellFrame.size.width * ONE_THIRD, NSMaxY(cellFrame) }];
			[sectionLines moveToPoint:(NSPoint){ cellFrame.origin.x + cellFrame.size.width * TWO_THIRDS, NSMinY(cellFrame) }];
			[sectionLines lineToPoint:(NSPoint){ cellFrame.origin.x + cellFrame.size.width * TWO_THIRDS, NSMaxY(cellFrame) }];
		} else {
			[sectionLines moveToPoint:(NSPoint){ cellFrame.origin.x + cellFrame.size.width * ONE_HALF, NSMinY(cellFrame) }];
			[sectionLines lineToPoint:(NSPoint){ cellFrame.origin.x + cellFrame.size.width * ONE_HALF, NSMaxY(cellFrame) }];
		}
		[sectionLines stroke];
	}
}

- (NSUInteger)hitTestForEvent:(NSEvent *)event inRect:(NSRect)cellFrame ofView:(NSView *)controlView {
	NSPoint mouseLocation = [controlView convertPoint:[event locationInWindow] fromView:nil];
	return NSPointInRect(mouseLocation, cellFrame) ? (NSCellHitContentArea | NSCellHitTrackableArea) : NSCellHitNone;
}

- (BOOL) startTrackingAt:(NSPoint)startPoint inView:(NSView *)controlView {
	//We rely on NSControl behavior, so only start tracking if this is a control.
	tracking = YES;
	trackingPoint = initialTrackingPoint = startPoint;
	trackingTime = initialTrackingTime = [NSDate timeIntervalSinceReferenceDate];
	return [controlView isKindOfClass:[NSControl class]];
}
- (BOOL) continueTracking:(NSPoint)lastPoint at:(NSPoint)currentPoint inView:(NSView *)controlView {
	NSControl *control = [controlView isKindOfClass:[NSControl class]] ? (NSControl *)controlView : nil;
	if (control) {
		trackingPoint = currentPoint;
		//No need to update the time here as long as nothing cares about it.
		[control drawCell:self];
		return YES;
	}
	tracking = NO;
	return NO;
}
- (void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView *)controlView mouseIsUp:(BOOL)flag {
	tracking = NO;
	trackingTime = [NSDate timeIntervalSinceReferenceDate];

	NSControl *control = [controlView isKindOfClass:[NSControl class]] ? (NSControl *)controlView : nil;
	if (control) {
		CGFloat xFraction = trackingThumbCenterX / trackingCellFrame.size.width;

		BOOL isClickNotDragByTime = (trackingTime - initialTrackingTime) < stuff->clickTimeout;
		BOOL isClickNotDragBySpaceX = (stopPoint.x - initialTrackingPoint.x) < stuff->clickMaxDistance.width;
		BOOL isClickNotDragBySpaceY = (stopPoint.y - initialTrackingPoint.y) < stuff->clickMaxDistance.height;
		BOOL isClickNotDrag = isClickNotDragByTime && isClickNotDragBySpaceX && isClickNotDragBySpaceY;

		if (!isClickNotDrag) {
			NSCellStateValue desiredState;

			if ([self allowsMixedState]) {
				if (xFraction < ONE_THIRD)
					desiredState = NSOffState;
				else if (xFraction >= TWO_THIRDS)
					desiredState = NSOnState;
				else
					desiredState = NSMixedState;
			} else {
				if (xFraction < ONE_HALF)
					desiredState = NSOffState;
				else
					desiredState = NSOnState;
			}

			//We actually need to set the state to the one *before* the one we want, because NSCell will advance it. I'm not sure how to thwart that without breaking -setNextState, which breaks AXPress and the space bar.
			NSCellStateValue stateBeforeDesiredState = 0;
			switch (desiredState) {
				case NSOnState:
					if ([self allowsMixedState]) {
						stateBeforeDesiredState = NSMixedState;
						break;
					}
					//Fall through.
				case NSMixedState:
					stateBeforeDesiredState = NSOffState;
					break;
				case NSOffState:
					stateBeforeDesiredState = NSOnState;
					break;
			}

			[self setState:stateBeforeDesiredState];
		}
	}
}

@end
