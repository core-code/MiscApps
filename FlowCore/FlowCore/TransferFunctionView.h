//
//  TransferFunctionView.h
//  FlowCore
//
//  Created by CoreCode on 09.01.09.
/*	Copyright © 2018 CoreCode Limited
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */



#define POINTSIZE 8

@interface HUDHack : NSColorPanel {}
@end

/*!
 * @class TransferFunctionView
 * @abstract TransferFunctionView is a custom view that displayes an editable transfer function.
 */
@interface TransferFunctionView : NSView {
	NSMutableArray *points;    
    
	BOOL cantChangeOpacity;
    int dragging, selectedPoint, selectedPointEdit;
	
    IBOutlet NSMenu *cm, *cms;
}

@property(retain, nonatomic) NSMutableArray *points;

/*
- (id)initWithFrame:(NSRect)frame;
- (void)drawRect:(NSRect)rect;
- (BOOL)isOpaque;
- (void)mouseDown:(NSEvent *)event;
- (void)mouseDragged:(NSEvent *)event;
- (void)mouseUp:(NSEvent *)event;
- (BOOL)acceptsFirstResponder;
- (void)resetCursorRects;*/

/*!
 * @method boundsForItem:
 * @abstract Calculates a bounding rectangle for a given point.
 * @param item The point to calculate the bounds for.
 * @result The bounding rectange.
 */
- (NSRect)boundsForItem:(short)item;

/*!
 * @method getGradient:
 * @abstract Calculates the gradient object
 * @result The gradient object.
 */
- (NSGradient *)getGradient;

/*!
 * @method erasePoint:
 * @abstract Called in response to the "erase" contextual menu item
 * @param sender The object sending the message.
 */
- (IBAction)erasePoint:(id)sender;

/*!
 * @method editPoint:
 * @abstract Called in response to the "edit" contextual menu item
 * @param sender The object sending the message.
 */
- (IBAction)editPoint:(id)sender;

/*!
 * @method colorAtLocation:
 * @abstract Provides the interpolated Color at a x-position.
 * @param location The x-position to provide the color for.
 * @result The interpolated color.
 */
- (NSColor *)colorAtLocation:(float)location;

@end

@interface TransferFunctionViewRestricted : TransferFunctionView { }
@end