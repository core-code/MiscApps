//
//  EditViewController.m
//  OmniMap
//
//  Created by CoreCode on 20.12.11.
/*	Copyright (c) 2016 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

#import "EditListViewController.h"
#import "EditHomeViewController.h"


@interface EditListViewController ()

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIView *helpView;

@end



@implementation EditListViewController


- (void)viewDidLoad
{
//    NSLog(@"vdl adding observer");
    [[NSNotificationCenter defaultCenter] addObserverForName:@"pushMap"
                                                      object:nil 
                                                       queue:[NSOperationQueue mainQueue] 
                                                  usingBlock:^(NSNotification *not)
	{
//        NSLog(@"got not");

        NSMutableArray *maps = @"OmniMaps".defaultArray.mutableObject;
        NSUInteger i;
        for (i = 0; i < [maps count]; i++)
        {
            NSDictionary *m = maps[i];
            
            if ([m[@"name"] isEqualToString:[not object]])
                break;
        }
        
        [self->_table selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]
                           animated:NO
                     scrollPosition:UITableViewScrollPositionTop];
        
        [self performSegueWithIdentifier:@"editHome" sender:[not object]];
    }];


    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [_table reloadData];
	_helpView.hidden = @"OmniMaps".defaultArray.count;

	[self.navigationController setNavigationBarHidden:YES animated:animated];

    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
   [self.navigationController setNavigationBarHidden:NO animated:animated];
	
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    int row = [table indexPathForCell:sender].row;
    UITableViewCell *cell = sender;
    EditHomeViewController *home = [segue destinationViewController];
    
    if ([sender isKindOfClass:[NSString class]])
        home.omniMapName = sender;
    else  if ([sender isKindOfClass:[UITableViewCell class]])
        home.omniMapName = cell.textLabel.text;
    else
        assert(0);
}

#pragma UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return @"OmniMaps".defaultArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"MapCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
	{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

	cell.textLabel.text = @"OmniMaps".defaultArray[indexPath.row][@"name"];

    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	@"OmniMaps".defaultObject = [@"OmniMaps".defaultArray arrayByRemovingObjectAtIndex:indexPath.row];
	
	[userDefaults synchronize];

	[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}
@end
