//
//  EditVerifyViewController.m
//  iOmniMap
//
//  Created by CoreCode on 23.12.11.
/*	Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

#import "EditVerifyViewController.h"
#import "OmniOverlayView.h"
#import "OmniOverlay.h"


@interface EditVerifyViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISlider *opacitySlider;

@end



@implementation EditVerifyViewController

- (void)viewDidLoad
{
    NSDictionary *map;
	for (NSDictionary *m in @"OmniMaps".defaultArray)
        if ([m[@"name"] isEqualToString:_omniMapName])
            map = m;

	assert(map);
    
    
//    {
//        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
//        [_mapView addAnnotation:annotation];
//  		annotation.title = @"center";
//		annotation.coordinate = CLLocationCoordinate2DMake([map[@"centerLatitude"] doubleValue],
//														   [map[@"centerLongitude"] doubleValue]);
//    }
//
//    {
//        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
//		annotation.title = @"full";
//        [_mapView addAnnotation:annotation];
//        annotation.coordinate = CLLocationCoordinate2DMake([map[@"fullLatitude"] doubleValue],
//                                                           [map[@"fullLongitude"] doubleValue]);
//    }
//    
//    {
//        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
//		annotation.title = @"fullheight";
//        [_mapView addAnnotation:annotation];
//        annotation.coordinate = CLLocationCoordinate2DMake([map[@"fullheightLatitude"] doubleValue],
//                                                           [map[@"fullheightLongitude"] doubleValue]);
//    }
//    
//    
//    {
//        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
//		annotation.title = @"fullwidth";
//        [_mapView addAnnotation:annotation];
//        annotation.coordinate = CLLocationCoordinate2DMake([map[@"fullwidthLatitude"] doubleValue],
//                                                           [map[@"fullwidthLongitude"] doubleValue]);
//    }
//    
//    {
//        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
// 		annotation.title = @"origin";
//       [_mapView addAnnotation:annotation];
//        annotation.coordinate = CLLocationCoordinate2DMake([map[@"originLatitude"] doubleValue],
//                                                           [map[@"originLongitude"] doubleValue]);
//    }

    _mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake([map[@"centerLatitude"] doubleValue], [map[@"centerLongitude"] doubleValue]),
											MKCoordinateSpanMake(fabs([map[@"originLatitude"] doubleValue] - [map[@"fullLatitude"] doubleValue]),
																 fabs([map[@"originLongitude"] doubleValue] - [map[@"fullLongitude"] doubleValue])));
    
    _mapView.delegate = self;
    
    OmniOverlay *overlay = [OmniOverlay new];
    overlay.map = map;
    overlay.opacity = [_opacitySlider value];
    [_mapView addOverlay:overlay];
    
    [super viewDidLoad];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)modeChanged:(UISegmentedControl *)sender
{
	_mapView.mapType = (MKMapType)sender.selectedSegmentIndex;
}

- (IBAction)opacityChanged:(id)sender 
{
    ((CALayer *)_mapView.overlays[0]).opacity = _opacitySlider.value;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshOverlay" object:nil];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    OmniOverlayView *mapOverlayView = [[OmniOverlayView alloc] initWithOverlay:overlay];
    
    return mapOverlayView;
}
@end
