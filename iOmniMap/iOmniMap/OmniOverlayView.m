//
//  OmniOverlayView.m
//  iOmniMap
//
//  Created by CoreCode on 28.12.11.
/*	Copyright © 2017 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

#import "OmniOverlayView.h"
#import "OmniOverlay.h"


@interface OmniOverlayView ()
{
    UIImage *image;
	OmniOverlay *omniOverlay;
}

@end



@implementation OmniOverlayView

- (id)initWithOverlay:(id <MKOverlay>)overlay
{
    if ((self = [super initWithOverlay:overlay]))
    {
        omniOverlay = overlay;
		
        [[NSNotificationCenter defaultCenter] addObserverForName:@"refreshOverlay" 
                                                          object:nil 
                                                           queue:[NSOperationQueue mainQueue] 
                                                      usingBlock:^(NSNotification *not) { 
                                                          [self setNeedsDisplayInMapRect:[self.overlay boundingMapRect]];
                                                      }];
    }
    return self;
}

- (void)drawMapRect:(MKMapRect)mapRect
          zoomScale:(MKZoomScale)zoomScale
          inContext:(CGContextRef)ctx
{
	if (!image)
		image = [UIImage imageWithData:[omniOverlay map][@"imageData"]];

	MKMapRect unrotatedBoundingMapRect    = [(OmniOverlay *)self.overlay unrotatedBoundingMapRect];
	MKMapRect boundingMapRect    = [(OmniOverlay *)self.overlay boundingMapRect];
    CGRect boundingRect          = [self rectForMapRect:boundingMapRect];
    CGRect clipRect         = [self rectForMapRect:mapRect];
    
    CGContextAddRect(ctx, clipRect);
    CGContextClip(ctx);

    CGContextSetAlpha(ctx, [(OmniOverlay *)self.overlay opacity]);
    CGContextTranslateCTM(ctx, 0.5f * boundingRect.size.width, 0.5f * boundingRect.size.height ) ;
    CGContextRotateCTM(ctx, ([[(OmniOverlay *)self.overlay map][@"degrees"] doubleValue]) * M_PI / 180.0);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    CGContextTranslateCTM(ctx, -0.5f * boundingRect.size.width, -0.5f * boundingRect.size.height ) ;
    CGContextDrawImage(ctx, [self rectForMapRect:unrotatedBoundingMapRect], image.CGImage);
}
@end