/*
 PDFView.m
 PDFViewer

 Author: Nick Kocharhook
 Created 11 July 2003

 Copyright (c) 2003, Apple Computer, Inc., all rights reserved.
*/

/*
 IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. ("Apple") in
 consideration of your agreement to the following terms, and your use, installation,
 modification or redistribution of this Apple software constitutes acceptance of these
 terms.  If you do not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.

 In consideration of your agreement to abide by the following terms, and subject to these
 terms, Apple grants you a personal, non-exclusive license, under Apple's copyrights in
 this original Apple software (the "Apple Software"), to use, reproduce, modify and
 redistribute the Apple Software, with or without modifications, in source and/or binary
 forms; provided that if you redistribute the Apple Software in its entirety and without
 modifications, you must retain this notice and the following text and disclaimers in all
 such redistributions of the Apple Software.  Neither the name, trademarks, service marks
 or logos of Apple Computer, Inc. may be used to endorse or promote products derived from
 the Apple Software without specific prior written permission from Apple. Except as expressly
 stated in this notice, no other rights or licenses, express or implied, are granted by Apple
 herein, including but not limited to any patent rights that may be infringed by your
 derivative works or by other works in which the Apple Software may be incorporated.

 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES,
 EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT,
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS
 USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE,
 REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND
 WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR
 OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PDFView.h"
#import <ApplicationServices/ApplicationServices.h>

/*@interface PDFView (Private) // JM

CGRect convertToCGRect(NSRect inRect);

@end*/

@implementation PDFView

- (id)initWithFrame:(NSRect)frameRect
{
    [super initWithFrame:frameRect];
    angle = 0; // We don't want to rotate the page by default.
    return self;
}

- (void)dealloc
{
    CGPDFDocumentRelease(pdfDocument);
    [super dealloc];
}

// This is where the real work gets done.
- (void)drawRect:(NSRect)rect
{
    CGContextRef gc = [[NSGraphicsContext currentContext] graphicsPort];
    CGAffineTransform m;

    CGContextSetGrayFillColor(gc, 1.0, 1.0);
    CGContextFillRect(gc, convertToCGRect(rect));
    
    // These next two calls do everything that's necessary to prepare for drawing the
    // page. The last argument of the first function defines whether or not to maintain
    // the document's aspect ratio.
    //
    // NOTE: The angle must be a multiple of 90. This is why we control angle's value
    // precisely in -rotateRight and -rotateLeft.
    m = CGPDFPageGetDrawingTransform([self page], kCGPDFMediaBox, convertToCGRect(rect),
                                     [self angle], true);
    CGContextConcatCTM(gc, m);

    // Now that the page is rotated and scaled correctly, all that remains is to draw it.
    CGContextDrawPDFPage(gc, page);
}

//
// Document
//

- (CGPDFDocumentRef)pdfDocument
{
    return pdfDocument;
}

// We shouldn't need to set the document multiple times, but there's no reason to cause
// things to break if we did.
- (void)setPDFDocument:(CGPDFDocumentRef)newPDFDocument
{
    if (newPDFDocument != pdfDocument) {
        CGPDFDocumentRelease(pdfDocument);
        pdfDocument = CGPDFDocumentRetain(newPDFDocument);
    }

    // We need to create the first CGPDFPageRef so it can be displayed.
    [self setPageNumber:1];
}

//
// Pages
//

- (CGPDFPageRef)page
{
    return page;
}

- (int)pageNumber
{
    return pageNumber;
}

// In addition to setting the integer page number, this method creates the new
// CGPDFPageRef and saves it to the 'page' variable. This is later referenced in
// -drawRect:.
- (void)setPageNumber:(int)newPageNumber
{
    CGPDFPageRef newPage;
    
    if ([self pageNumber] == newPageNumber)
        return;

    if (newPageNumber < 1 || newPageNumber > [self pageCount]) {
        NSLog(@"Invalid newPage number `%d': not in range [1, %d].",
            newPageNumber, [self pageCount]);
        return;
    }
    
    newPage = CGPDFDocumentGetPage([self pdfDocument], newPageNumber);
    if (newPage == NULL) {
        NSLog(@"Failed to create page %d.", newPageNumber);
        return;
    }
    
    pageNumber = newPageNumber;

    // There's no need to worry about retaining this page because the CGPDFDocument is
    // hanging on to it for us.
    page = newPage;

    [self setNeedsDisplay:YES];
}

// This method just asks the document for its page count. We could cache the number,
// but the function already does that, so we would only be saving a single function
// call.
- (int)pageCount
{
    return (int)CGPDFDocumentGetNumberOfPages([self pdfDocument]);
}

// These two are convenience methods for the Page Up and Page Down toolbar items.
- (void)incrementPageNumber:(id)sender
{
    if ([self pageNumber] < [self pageCount])
        [self setPageNumber:[self pageNumber] + 1];
}

- (void)decrementPageNumber:(id)sender
{
    if ([self pageNumber] > 1)
        [self setPageNumber:[self pageNumber] - 1];
}

//
// Rotation
//

// As mentioned in -drawRect:, `angle' must be a multiple of 90. These methods
// guarantee that it is.
- (void)rotateRight:(id)sender
{
    angle += 90;
    [self setNeedsDisplay:YES];
}

- (void)rotateLeft:(id)sender
{
    angle -= 90;
    [self setNeedsDisplay:YES];
}

- (int)angle
{
    return angle;
}

// A convenience function to get a CGRect from an NSRect. You can also use the
// *(CGRect *)&nsRect sleight of hand, but this way is a bit clearer.
CGRect convertToCGRect(NSRect inRect)
{
    return CGRectMake(inRect.origin.x, inRect.origin.y, inRect.size.width, inRect.size.height);
}

@end
