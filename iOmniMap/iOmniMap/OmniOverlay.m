//
//  OmniOverlay.m
//  iOmniMap
//
//  Created by CoreCode on 28.12.11.
/*	Copyright (c) 2016 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

#import "OmniOverlay.h"


//@interface OmniOverlay ()
//
//@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
//@property (nonatomic, readonly) MKMapRect boundingMapRect;
//
//@end



@implementation OmniOverlay

- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake([_map[@"centerLatitude"] doubleValue], [_map[@"centerLongitude"] doubleValue]);
}

- (MKMapRect)boundingMapRect
{
	MKMapRect r = MKMapRectNull;

	for (NSArray *keys in @[@[@"originLatitude", @"originLongitude"], @[@"fullLatitude", @"fullLongitude"], @[@"fullheightLatitude", @"fullheightLongitude"], @[@"fullwidthLatitude", @"fullwidthLongitude"]])
	{
		CLLocationCoordinate2D co = CLLocationCoordinate2DMake([_map[keys[0]] doubleValue],
																 [_map[keys[1]] doubleValue]);
		MKMapPoint po = MKMapPointForCoordinate(co);
		MKMapRect re = MKMapRectMake(po.x, po.y, 0, 0);

		r = MKMapRectUnion(r, re);
	}

    
    return r;
}

- (MKMapRect)unrotatedBoundingMapRect
{

	MKMapPoint o = MKMapPointForCoordinate(CLLocationCoordinate2DMake(	[_map[@"originLatitude"] doubleValue],																				[_map[@"originLongitude"] doubleValue]));


//	MKMapPoint f = MKMapPointForCoordinate(CLLocationCoordinate2DMake(	[_map[@"fullLatitude"] doubleValue],																				[_map[@"fullLongitude"] doubleValue]));

	MKMapPoint fh = MKMapPointForCoordinate(CLLocationCoordinate2DMake(	[_map[@"fullheightLatitude"] doubleValue],																			[_map[@"fullheightLongitude"] doubleValue]));

	MKMapPoint fw = MKMapPointForCoordinate(CLLocationCoordinate2DMake(	[_map[@"fullwidthLatitude"] doubleValue],																			[_map[@"fullwidthLongitude"] doubleValue]));

	MKMapPoint c = MKMapPointForCoordinate(CLLocationCoordinate2DMake(	[_map[@"centerLatitude"] doubleValue],																				[_map[@"centerLongitude"] doubleValue]));

	double loweredge_width = fabs(fw.x - o.x);
	double loweredge_height = fabs(fw.y - o.y);
	double realwidth = sqrt(loweredge_width * loweredge_width + loweredge_height * loweredge_height);

	double leftedge_width = fabs(fh.x - o.x);
	double leftedge_height = fabs(fh.y - o.y);
	double realheight = sqrt(leftedge_width * leftedge_width + leftedge_height * leftedge_height);


	MKMapRect rect = MKMapRectMake(c.x - realwidth / 2.0, c.y - realheight / 2.0, realwidth, realheight);

    return rect;
}
@end
