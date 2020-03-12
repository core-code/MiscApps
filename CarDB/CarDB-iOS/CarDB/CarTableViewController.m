//
//  CarTableViewController.m
//  CarDB
//
//  Created by CoreCode on 19.05.14.
//  Copyright © 2018 CoreCode Limited. All rights reserved.
//

#import "CarTableViewController.h"
#import "JMAlertController.h"
#import "JMWebViewController.h"
#import "JMSlideshowController.h"

@interface CarTableViewController ()

@end


@implementation CarTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.tableView.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0);
	self.title = self.details2 ? @"Comparison" : self.details[0];

	UIBarButtonItem *pic = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
															   target:self
															   action:@selector(pic:)];


	self.navigationItem.rightBarButtonItem = pic;
}

- (void)pic:(id)sender
{
	if (self.details2)
	{
		JMAlertController *a = [JMAlertController alertControllerWithTitle:@"Info"
                                       viewController:self
                                              message:@"Which of the cars do you want to view images of?"
                                          cancelBlock:^{
                                                            [self viewCar:0];
                                                        }
						 cancelButtonTitle:self.details[1]
                                           otherBlock:^(int choice){
                                                            [self viewCar:1];
                                                        }
						 otherButtonTitles:@[self.details2[1]]];

        [a showInView:self.view];
	}
	else
		[self viewCar:0];
}

- (void)viewCar:(int)car
{
	JMWebViewController *wc = [[JMWebViewController alloc] init];
	JMSlideshowController *sc = [[JMSlideshowController alloc] init];

	if (car && self.images2)
		sc.images = self.images2;
	else if (car && !self.images2)
		wc.url = self.url2.escaped.URL;
	else if (!car && self.images)
		sc.images = self.images;
	else if (!car && !self.images)
		wc.url = self.url.escaped.URL;

	wc.navigationTitle = (car ? self.details2[1] : self.details[1]);
	sc.navigationTitle = (car ? self.details2[1] : self.details[1]);

	wc.delegate = self;
	[self.navigationController pushViewController:sc.images ? sc : wc animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bla"];
	if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"bla"];



	cell.textLabel.text = self.titles[indexPath.row];

	if (self.details2)
	{
		cell.detailTextLabel.text = [self.details[indexPath.row].stringValue stringByAppendingFormat:@"\n%@", self.details2[indexPath.row].stringValue];
		cell.detailTextLabel.numberOfLines = 2;
	}
	else
	{
		cell.detailTextLabel.text = self.details[indexPath.row].stringValue;
		cell.detailTextLabel.numberOfLines = 1;
	}


    return cell;
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	LOG(request.URL.absoluteString);
	BOOL result;
	if ([request.URL.absoluteString contains:@"http://www.bing.com/images/search?"])
	{
		result = [request.URL.absoluteString hasPrefix:self.url.escaped.URL.absoluteString];
	}
	else if ([request.URL.absoluteString contains:@"about:blank"])
		result = YES;
	else if ([request.URL.absoluteString contains:@"bing.com"])
	{
		if ([request.URL.absoluteString contains:@"bing.com/news/"])
			result = NO;
		else if ([request.URL.absoluteString contains:@"bing.com/?scope=news"])
			result = NO;
		else if ([request.URL.absoluteString contains:@"bing.com/explore?"])
			result = NO;
		else if ([request.URL.absoluteString contains:@"bing.com/search?q="])
			result = NO;
		else if ([request.URL.absoluteString contains:@"bing.com/?"])
			result = NO;
		else
			result = YES;
	}
	else
		result = NO;


	cc_log(@"%i", result);

	return result;
}

@end


#if !defined(APPSTORE_VALIDATERECEIPT) && !defined(TRYOUT) && !defined(DEBUG)
#warning Time-Limited Release-Beta build
#elif !defined(APPSTORE_VALIDATERECEIPT) && !defined(TRYOUT) && defined(DEBUG)
#warning Time-Limited Debug-Beta build
#elif !defined(APPSTORE_VALIDATERECEIPT) && defined(TRYOUT) && !defined(DEBUG)
#warning Tryout build
#elif !defined(APPSTORE_VALIDATERECEIPT) && defined(TRYOUT) && defined(DEBUG)
#error invalid_config
#elif defined(APPSTORE_VALIDATERECEIPT) && !defined(TRYOUT) && !defined(DEBUG)
#warning MacAppStore build
#elif defined(APPSTORE_VALIDATERECEIPT) && !defined(TRYOUT) && defined(DEBUG)
#error invalid_config
#elif defined(APPSTORE_VALIDATERECEIPT) && defined(TRYOUT) && !defined(DEBUG)
#error invalid_config
#elif defined(APPSTORE_VALIDATERECEIPT) && defined(TRYOUT) && defined(DEBUG)
#error invalid_config
#endif
