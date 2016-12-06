//
//  NavigateViewController.m
//  OmniMap
//
//  Created by CoreCode on 20.12.11.
/*	Copyright (c) 2016 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

#import "NavigateViewController.h"
#import "OmniOverlay.h"
#import "OmniOverlayView.h"
#import "OptionsViewController.h"


@interface NavigateViewController ()
{
	float opacity;
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *helpView;

@end



@implementation NavigateViewController

- (void)viewDidLoad
{
	opacity = 1.0;
	
	_mapView.showsUserLocation = YES;
	_mapView.userTrackingMode = MKUserTrackingModeFollow;
	
    _mapView.delegate = self;


    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	[_mapView removeOverlays:_mapView.overlays];

	for (NSDictionary *m in @"OmniMaps".defaultArray)
	{
		if (m[@"fullLatitude"])
		{
			OmniOverlay *overlay = [OmniOverlay new];
			overlay.map = m;
			overlay.opacity = 1.0;
			[_mapView addOverlay:overlay];
		}
	}

	_helpView.hidden = [_mapView.overlays count];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    OmniOverlayView *mapOverlayView = [[OmniOverlayView alloc] initWithOverlay:overlay];
    
    return mapOverlayView;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    OptionsViewController *optionsViewController = segue.destinationViewController;

    optionsViewController.mapType = _mapView.mapType;
	optionsViewController.trackingMode = _mapView.userTrackingMode;
	optionsViewController.opacity = opacity;

	optionsViewController.mapTypeChangedBlock = ^(MKMapType type){ self->_mapView.mapType = type; };
	optionsViewController.trackingModeChangedBlock = ^(MKUserTrackingMode mode){ self->_mapView.userTrackingMode = mode; };
	optionsViewController.opacityChangedBlock = ^(float opa)
	{
		self->opacity = opa;
		for (OmniOverlay *o in self->_mapView.overlays)
			o.opacity = opa;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"refreshOverlay" object:nil];		
	};
}

@end
