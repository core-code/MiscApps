//
//  EditMatchViewController.m
//  iOmniMap
//
//  Created by CoreCode on 23.12.11.
/*	Copyright (c) 2016 CoreCode
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

#import "EditMatchViewController.h"


@interface EditMatchViewController ()
{
    NSMutableDictionary *map;
    CALayer *arrowLayer;
    CGPoint point;
    MKPointAnnotation *annotation;
}

@property (weak, nonatomic) IBOutlet MKMapView *gmapView;
@property (weak, nonatomic) IBOutlet UIImageView *omapView;
@property (weak, nonatomic) IBOutlet UIScrollView *oscrollView;
@property (weak, nonatomic) IBOutlet UIButton *helpSaveButton;
@property (weak, nonatomic) IBOutlet UILabel *helpSaveLabel;
@property (weak, nonatomic) IBOutlet UIButton *helpGoogleButton;
@property (weak, nonatomic) IBOutlet UILabel *helpGoogleLabel;
@property (weak, nonatomic) IBOutlet UIButton *helpOmniButton;
@property (weak, nonatomic) IBOutlet UILabel *helpOmniLabel;

@end



@implementation EditMatchViewController

#define BORDER 35

- (void)viewDidLoad
{
    self.navigationItem.title = makeString(@"Match %i. location", _index+1);

    for (NSDictionary *m in @"OmniMaps".defaultArray)
        if ([m[@"name"] isEqualToString:_omniMapName])
            map = m.mutableObject;

    assert(map);

	// setup map view
    _gmapView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGoogle = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGoogle:)];
	//    tapGoogle.numberOfTouchesRequired = 1;
    [_gmapView addGestureRecognizer:tapGoogle];

	UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [_gmapView addGestureRecognizer:longTap];
	
	// setup omni view
    _omapView.image = [UIImage imageWithData:map[@"imageData"]];
    _omapView.frame = CGRectMake(BORDER, BORDER, _omapView.image.size.width, _omapView.image.size.height);
    _oscrollView.contentSize = CGSizeMake(_omapView.image.size.width + (BORDER*2), _omapView.image.size.height + (BORDER*2));
    _omapView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapOmni = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOmni:)];
	//    tapOmni.numberOfTouchesRequired = 1;
    [_omapView addGestureRecognizer:tapOmni];

	// insert existing pins & zoom
    NSString *omniPointString = map[[self omniPointString]];
    if (omniPointString)
    {
        [self tapOmniWithPoint:CGPointFromString(omniPointString)];
    }

    NSNumber *lo = map[makeString(@"%@PointLongitude", [self indexString])];
    NSNumber *la = map[makeString(@"%@PointLatitude", [self indexString])];
    if (lo && la)
    {
        [self tapGoogleWithCoordinate:CLLocationCoordinate2DMake([la doubleValue], [lo doubleValue])];

		// point already defined, zoom to it
		_gmapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake([la doubleValue], [lo doubleValue]),
												  MKCoordinateSpanMake(1, 1));
    }
	else if ((_index == 1) && map[@"firstPointLongitude"] && map[@"firstPointLatitude"]) // second screen, no point, zoom to first point
	{
		_gmapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake([map[@"firstPointLatitude"] doubleValue], [map[@"firstPointLongitude"] doubleValue]),
												  MKCoordinateSpanMake(1, 1));
	}
	else if ((_index == 2) && map[@"firstPointLongitude"] && map[@"firstPointLatitude"] && map[@"secondPointLongitude"] && map[@"secondPointLatitude"]) // third screen, no point, zoom to area
	{
		_gmapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(([map[@"firstPointLatitude"] doubleValue] + [map[@"secondPointLatitude"] doubleValue]) / 2.0,
																			 ([map[@"firstPointLongitude"] doubleValue] + [map[@"secondPointLongitude"] doubleValue]) / 2.0),
												  MKCoordinateSpanMake(fabs(([map[@"firstPointLatitude"] doubleValue] - [map[@"secondPointLatitude"] doubleValue]) / 2.0),
																	   fabs(([map[@"firstPointLongitude"] doubleValue] - [map[@"secondPointLongitude"] doubleValue]) / 2.0)));
	}

	[self refresh];

    [super viewDidLoad];
}

- (void)refresh
{
    _helpGoogleLabel.hidden = annotation != nil;
    _helpGoogleButton.hidden = annotation != nil;

    _helpOmniLabel.hidden = arrowLayer != NULL;
    _helpOmniButton.hidden = arrowLayer != NULL;

    _helpSaveLabel.hidden = !(arrowLayer && annotation);
    _helpSaveButton.hidden = !(arrowLayer && annotation);

    if (arrowLayer && annotation)
    {
    	UIBarButtonItem *modalBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];

        self.navigationItem.rightBarButtonItem = modalBarButtonItem;
    }
}

- (void)save
{
    NSMutableArray *maps = @"OmniMaps".defaultArray.mutableObject;

    for (NSUInteger i = 0; i < [maps count]; i++)
        if ([maps[i][@"name"] isEqualToString:_omniMapName])
            maps[i] = map;


	if (map[@"firstPointLongitude"] && map[@"firstPointLatitude"] && map[@"secondPointLongitude"] && map[@"secondPointLatitude"] && map[@"thirdPointLongitude"] && map[@"thirdPointLatitude"])
	{
		assert(map[@"firstPointOmni"]);
		assert(map[@"secondPointOmni"]);
		assert(map[@"thirdPointOmni"]);

		double imageWidth = [map[@"imageWidth"] doubleValue];
        double imageHeight = [map[@"imageHeight"] doubleValue];
        double halfW = imageWidth / 2.0;
        double halfH = imageHeight / 2.0;

		// points and vectors between points in our image
        CGPoint p1 = CGPointFromString(map[@"firstPointOmni"]);
        CGPoint p2 = CGPointFromString(map[@"secondPointOmni"]);
        CGPoint p3 = CGPointFromString(map[@"thirdPointOmni"]);
        p1 = CGPointMake(p1.x, imageHeight - p1.y);
        p2 = CGPointMake(p2.x, imageHeight - p2.y);
        p3 = CGPointMake(p3.x, imageHeight - p3.y);						// locations of points in omnimap  (in pixel coordinates from lower left)
        CGPoint v12 = CGPointMake(p2.x - p1.x, p2.y - p1.y);			// vector from first to second point (in pixels)
		CGPoint v13 = CGPointMake(p3.x - p1.x, p3.y - p1.y);			// vector from first to third point (in pixels)

		// factors for expressing corner points in image
        double xHalf =		-(v13.x * (p1.y - halfH) + halfW * v13.y - p1.x * v13.y) / (v13.x * v12.y - v12.x * v13.y);
        double yHalf =		 (v12.x * (p1.y - halfH) + halfW * v12.y - p1.x * v12.y) / (v13.x * v12.y - v12.x * v13.y);
        double xOrigin =		-(v13.x * (p1.y - 0    ) + 0     * v13.y - p1.x * v13.y) / (v13.x * v12.y - v12.x * v13.y);
        double yOrigin =		 (v12.x * (p1.y - 0    ) + 0     * v12.y - p1.x * v12.y) / (v13.x * v12.y - v12.x * v13.y);
        double xFull = -(v13.x * (p1.y - imageHeight) + imageWidth * v13.y - p1.x * v13.y) / (v13.x * v12.y - v12.x * v13.y);
        double yFull =  (v12.x * (p1.y - imageHeight) + imageWidth * v12.y - p1.x * v12.y) / (v13.x * v12.y - v12.x * v13.y);
        double xFullHeight = -(v13.x * (p1.y - imageHeight) + 0 * v13.y - p1.x * v13.y) / (v13.x * v12.y - v12.x * v13.y);
        double yFullHeight = (v12.x * (p1.y - imageHeight) + 0 * v12.y - p1.x * v12.y) / (v13.x * v12.y - v12.x * v13.y);
        double xFullWidth = -(v13.x * (p1.y - 0) + imageWidth * v13.y - p1.x * v13.y) / (v13.x * v12.y - v12.x * v13.y);
        double yFullWidth = (v12.x * (p1.y - 0) + imageWidth * v12.y - p1.x * v12.y) / (v13.x * v12.y - v12.x * v13.y);

		// points and vectors between points in worldmap
        double p1x = [map[@"firstPointLongitude"] doubleValue];
        double p1y = [map[@"firstPointLatitude"] doubleValue];
        double p2x = [map[@"secondPointLongitude"] doubleValue];
        double p2y = [map[@"secondPointLatitude"] doubleValue];
        double p3x = [map[@"thirdPointLongitude"] doubleValue];
        double p3y = [map[@"thirdPointLatitude"] doubleValue];
        double v12x = p2x - p1x;
        double v12y = p2y - p1y;
        double v13x = p3x - p1x;
        double v13y = p3y - p1y;


        double centerlong = p1x + xHalf * v12x + yHalf * v13x;
        double centerlat = p1y + xHalf * v12y + yHalf * v13y;
        double originlong = p1x + xOrigin * v12x + yOrigin * v13x;
        double originlat = p1y + xOrigin * v12y + yOrigin * v13y;
        double fulllong = p1x + xFull * v12x + yFull * v13x;
        double fulllat = p1y + xFull * v12y + yFull * v13y;
        double fullwidthlong = p1x + xFullWidth * v12x + yFullWidth * v13x;
        double fullwidthlat = p1y + xFullWidth * v12y + yFullWidth * v13y;
        double fullheightlong = p1x + xFullHeight * v12x + yFullHeight * v13x;
        double fullheightlat = p1y + xFullHeight * v12y + yFullHeight * v13y;

        map[@"centerLatitude"] = @(centerlat);
        map[@"centerLongitude"] = @(centerlong);
        map[@"originLatitude"] = @(originlat);
        map[@"originLongitude"] = @(originlong);
        map[@"fullLatitude"] = @(fulllat);
        map[@"fullLongitude"] = @(fulllong);
        map[@"fullwidthLatitude"] = @(fullwidthlat);
        map[@"fullwidthLongitude"] = @(fullwidthlong);
        map[@"fullheightLatitude"] = @(fullheightlat);
        map[@"fullheightLongitude"] = @(fullheightlong);

		{
			#define RAD2DEG(r) (r * (180.0/3.141592653589793238))
			
			CLLocationCoordinate2D o_ = CLLocationCoordinate2DMake(originlat, originlong);
			CLLocationCoordinate2D fw_ = CLLocationCoordinate2DMake(fullwidthlat, fullwidthlong);
			MKMapPoint fw = MKMapPointForCoordinate(fw_);
			MKMapPoint o = MKMapPointForCoordinate(o_);
			double _v12x = fw.x - o.x;
			double _v12y = fw.y - o.y;
			double _v12len = sqrt(_v12x * _v12x + _v12y * _v12y);
			double _v12normx = _v12x/ _v12len;
			double _v12normy = _v12y / _v12len;
			double _v12deg = RAD2DEG(atan2(_v12normx, _v12normy));

			map[@"degrees"] = @(90 - _v12deg);
		}


		//NSLog(@"Angle: %f OmniPoint\n#1 (%f|%f)\n#2 (%f|%f)\nGMapPoint\n#1 (%f|%f)\n#2 (%f|%f)\n#c (%f|%f)\n#o (%f|%f)\n#f (%f|%f)\n#w (%f|%f)\n#h (%f|%f)", [map[@"degrees"] floatValue],  p1.x, p1.y, p2.x, p2.y, p1x, p1y, p2x, p2y, centerlong, centerlat, originlong, originlat, fulllong, fulllat, fullwidthlong, fullwidthlat, fullheightlong, fullheightlat);
	}
	else if (map[@"firstPointLongitude"] && map[@"firstPointLatitude"] && map[@"secondPointLongitude"] && map[@"secondPointLatitude"])
    {
		assert(map[@"firstPointOmni"]);
		assert(map[@"secondPointOmni"]);

        double imageWidth = [map[@"imageWidth"] doubleValue];
        double imageHeight = [map[@"imageHeight"] doubleValue];


        CGPoint p1 = CGPointFromString(map[@"firstPointOmni"]);
        CGPoint p2 = CGPointFromString(map[@"secondPointOmni"]);
        p1 = CGPointMake(p1.x, imageHeight - p1.y);
        p2 = CGPointMake(p2.x, imageHeight - p2.y);						// locations of points in omnimap  (in pixel coordinates from lower left)
        CGPoint v12 = CGPointMake(p2.x - p1.x, p2.y - p1.y);			// vector from first to second point (in pixels)


		double x0 = (0 - p1.x) / v12.x;									// factors for expressing outer borders in relation to first point and diffvector
		double y0 = (0 - p1.y) / v12.y;
		double x1 = (imageWidth - p1.x) / v12.x;
		double y1 = (imageHeight - p1.y) / v12.y;

        double p1x = [map[@"firstPointLongitude"] doubleValue];
        double p1y = [map[@"firstPointLatitude"] doubleValue];
        double p2x = [map[@"secondPointLongitude"] doubleValue];
        double p2y = [map[@"secondPointLatitude"] doubleValue];
        double v12x = p2x - p1x;
        double v12y = p2y - p1y;


        double originlong = p1x + x0 * v12x;
        double originlat = p1y + y0 * v12y;
        double fulllong = p1x + x1 * v12x;
        double fulllat = p1y + y1 * v12y;

        double centerlong = (fulllong + originlong) / 2.0;
        double centerlat = (fulllat + originlat) / 2.0;

        double fullwidthlong = fulllong;
        double fullwidthlat = originlat;
        double fullheightlong = originlong;
        double fullheightlat = fulllat;


		map[@"centerLatitude"] = @(centerlat);
		map[@"centerLongitude"] = @(centerlong);
		map[@"originLatitude"] = @(originlat);
		map[@"originLongitude"] = @(originlong);
		map[@"fullLatitude"] = @(fulllat);
		map[@"fullLongitude"] = @(fulllong);
		map[@"fullwidthLatitude"] = @(fullwidthlat);
		map[@"fullwidthLongitude"] = @(fullwidthlong);
		map[@"fullheightLatitude"] = @(fullheightlat);
		map[@"fullheightLongitude"] = @(fullheightlong);
		map[@"degrees"] = @(0);


       // NSLog(@"OmniPoint\n#1 (%f|%f)\n#2 (%f|%f)\nGMapPoint\n#1 (%f|%f)\n#2 (%f|%f)\n#c (%f|%f)\n#o (%f|%f)\n#f (%f|%f)\n#w (%f|%f)\n#h (%f|%f)",  p1.x, p1.y, p2.x, p2.y, p1x, p1y, p2x, p2y, centerlong, centerlat, originlong, originlat, fulllong, fulllat, fullwidthlong, fullwidthlat, fullheightlong, fullheightlat);
    }


    @"OmniMaps".defaultObject = maps;
	[userDefaults synchronize];

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tapOmniWithPoint:(CGPoint)p
{
    if (!arrowLayer)
    {
        arrowLayer = [CALayer layer];
		arrowLayer.contents = (__bridge id)([UIImage imageNamed:@"cross"].CGImage);
        [[_omapView layer] addSublayer:arrowLayer];
    }

    point = p;
	arrowLayer.frame = CGRectMake(point.x - 18, point.y - 29, 35, 30);

    map[[self omniPointString]] = NSStringFromCGPoint(point);

    [self refresh];
}

- (void)tapGoogleWithCoordinate:(CLLocationCoordinate2D)p
{
    if (!annotation)
    {
        annotation = [[MKPointAnnotation alloc] init];
        [_gmapView addAnnotation:annotation];
    }
    annotation.coordinate = p;

    map[makeString(@"%@PointLongitude", [self indexString])] = @(annotation.coordinate.longitude);
    map[makeString(@"%@PointLatitude", [self indexString])] = @(annotation.coordinate.latitude);


    [self refresh];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)tapGoogle:(UITapGestureRecognizer *)g
{
    CGPoint p = [g locationInView:_gmapView];

    CLLocationCoordinate2D c = [_gmapView convertPoint:p toCoordinateFromView:_gmapView];

    [self tapGoogleWithCoordinate:c];
}

- (void)tapOmni:(UITapGestureRecognizer *)g
{
    [self tapOmniWithPoint:[g locationInView:_omapView]];
}

- (NSString *)omniPointString
{
	return makeString(@"%@PointOmni", [self indexString]);
}

- (NSString *)indexString
{
	return @[@"first", @"second", @"third"][_index];
}

- (void)longPress:(id)sender
{
	_gmapView.mapType = (MKMapType)((_gmapView.mapType + 1) % 3);
}
@end