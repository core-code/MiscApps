//
//  PDFullscreenView.m
//  PDFullscreen
//
//  Created by CoreCode on 19.01.05.
/*	Copyright (c) 2016 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import "PDFullscreenView.h"


@implementation PDFullscreenView

- (void)drawText:(CGContextRef)myContext rect:(CGRect)contextRect text:(NSString *)text
{
/*
Call the function CGContextGetTextPosition to obtain the current text position.
Set the text drawing mode to kCGTextInvisible using the function CContextSetTextDrawingMode
Draw the text by calling the function CGContextShowTextAtPoint.
Determine the final text position by calling the function CGContextGetTextPosition.
Subtract the starting position from the ending position to determine the width of the text.
*/
	float w, h;

	w = contextRect.size.width;
	h = contextRect.size.height;


	//CGAffineTransform myCTM, myTextTransform;

	CGContextSelectFont (myContext, "LucidaGrande-Bold", 24, kCGEncodingMacRoman);

	CGContextSetCharacterSpacing (myContext, 10);

	CGContextSetTextDrawingMode (myContext, kCGTextFill);

	CGContextSetRGBFillColor (myContext, 1, 1, 1, .5);


	CGContextShowTextAtPoint (myContext, w - 90, 40, [text cString], [text cStringLength]);
}

- (void)drawRect:(NSRect)rect
{
	// TODO: zoom, rotation
	CGAffineTransform	m;	
	CGContextRef		gc = [[NSGraphicsContext currentContext] graphicsPort];
	CGPDFBox			box = kCGPDFCropBox; 	// kCGPDFMediaBox kCGPDFCropBox kCGPDFBleedBox kCGPDFTrimBox kCGPDFArtBox
	CGRect				screenRect = convertToCGRect(rect);
	CGRect				pdfRect = CGPDFPageGetBoxRect ([self page], box);
	float				screenAspect = screenRect.size.width / screenRect.size.height;		// > 1 if BREIT // = 0 if QUADRAT // < 1 if HOCH
	float				pdfAspect = pdfRect.size.width / pdfRect.size.height;				// > 1 if BREIT // = 0 if QUADRAT // < 1 if HOCH

	// DESTINATION RECT
	CGRect destRect = screenRect;
	if (screenAspect > pdfAspect) // if screen BREITER than pdf
		destRect.size.width = pdfRect.size.width * (screenRect.size.height / pdfRect.size.height); // then dest BREITE becomes
	else
		destRect.size.height = pdfRect.size.height * (screenRect.size.width / pdfRect.size.width); // then dest H…HE becomes

NSLog(@"%@", [NSString stringWithFormat:@"screenAspect: %f pdfAspect:%f", screenAspect, pdfAspect]);
NSLog(@"%@", [NSString stringWithFormat:@"pdfRect: %f %f %f %f", pdfRect.size.width, pdfRect.size.height, pdfRect.origin.x, pdfRect.origin.y]);
NSLog(@"%@", [NSString stringWithFormat:@"destRect: %f %f %f %f", destRect.size.width, destRect.size.height, destRect.origin.x, destRect.origin.y]);

	// BACKGROUND GREY
	if (screenAspect == pdfAspect) // if they are the same aspect we want the whole screen white
		CGContextSetGrayFillColor(gc, 1.0, 1.0);	
	else
		CGContextSetGrayFillColor(gc, 1.0, 0.2);
	CGContextFillRect(gc, screenRect);
	
	// PDF WHITE
	CGContextSetGrayFillColor(gc, 1.0, 1.0);
	if (screenAspect > pdfAspect) // if screen BREITER than pdf
		CGContextFillRect(gc, CGRectMake((screenRect.size.width - destRect.size.width) / 2, 0, destRect.size.width, destRect.size.height));
	else if (screenAspect < pdfAspect)
		CGContextFillRect(gc, CGRectMake(0, (screenRect.size.height - destRect.size.height) / 2, destRect.size.width, destRect.size.height));
				
	// PAGE NUMBER
	[self drawText:gc rect:screenRect text:[NSString stringWithFormat:@"%i", [self pageNumber]]];

	// PDF TRANSFORMATION
	m = CGPDFPageGetDrawingTransform([self page], box, screenRect, [self angle], true);
	CGContextConcatCTM(gc, m);
	
	// SCALING
	if ((screenRect.size.width > pdfRect.size.width) && (destRect.size.height > pdfRect.size.height)) // we only scale when the pdf is smaller
	{
		float factor = destRect.size.width / pdfRect.size.width;

		NSLog(@"%@", [NSString stringWithFormat:@"SCALING: %f", factor]);

		CGContextTranslateCTM (gc, -((screenRect.size.width - pdfRect.size.width) / 2), -((screenRect.size.height - pdfRect.size.height) / 2));

		if (screenAspect > pdfAspect) // if screen BREITER than pdf
			CGContextTranslateCTM (gc, (screenRect.size.width - destRect.size.width) / 2, 0);
		else if (screenAspect < pdfAspect)
			CGContextTranslateCTM (gc, 0, (screenRect.size.height - destRect.size.height) / 2);
		
		CGContextScaleCTM (gc, factor, factor);
	}

	CGContextDrawPDFPage(gc, page);
}

- (void)scrollWheel:(NSEvent *)theEvent
{
	int i;
	for (i = abs((int)[theEvent deltaY]); i > 0 ; i--)
		[theEvent deltaY] > 0 ? [self decrementPageNumber:self] : [self incrementPageNumber:self];
}

- (void)mouseDown:(NSEvent *)theEvent
{
	[self incrementPageNumber:self];
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
	[self decrementPageNumber:self];
}

- (void)keyDown:(NSEvent *)theEvent
{
	switch ([[theEvent charactersIgnoringModifiers] characterAtIndex:0])
	{
		case NSUpArrowFunctionKey:
			[self setPageNumber:1];
			break;
			
		case NSDownArrowFunctionKey:
			[self setPageNumber:[self pageCount]];
			break;
			
		case NSLeftArrowFunctionKey:
			[self decrementPageNumber:self];
			break;
			
		case NSRightArrowFunctionKey:
			[self incrementPageNumber:self];
			break;
			
		default: break;
	}
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}
@end
