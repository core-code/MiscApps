//
//  CarTableViewController.h
//  CarDB
//
//  Created by CoreCode on 19.05.14.
//  Copyright © 2018 CoreCode Limited. All rights reserved.
//


@interface CarTableViewController : UITableViewController <UIWebViewDelegate>

@property (nonatomic, strong) NSArray <NSString *> *titles;
@property (nonatomic, strong) NSArray <NSString *> *details;
@property (nonatomic, strong) NSArray <NSString *> *details2;
@property (nonatomic, strong) NSArray <NSString *> *images;
@property (nonatomic, strong) NSArray <NSString *> *images2;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *url2;
@end
