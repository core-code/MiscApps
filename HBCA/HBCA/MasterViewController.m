//
//  MasterViewController.m
//  HBCA
//
//  Created by CoreCode on 07.06.19.
/*	Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

// TODO: unified syntax highlighter? RPSyntaxHighlighter?

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "SSZipArchive.h"
#import "MBProgressHUD.h"


@interface MasterViewController ()

	@property (strong, nonatomic) NSArray <NSString *> *casks;
    @property (strong, nonatomic) NSArray <NSString *> *filteredCasks;
    @property (weak, nonatomic) IBOutlet UITextField *filterField;

@end


@implementation MasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
		
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshCasks:)];
	self.navigationItem.rightBarButtonItem = addButton;
	
    [self scanCasks];
    if (!self.casks.count)
        [self refreshCasks:nil];
    
    [self.filterField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)textFieldDidChange:(id)sender
{
    [self filterCasks];
    [self.tableView reloadData];
}

- (void)refreshCasks:(id)sender
{
    self.filterField.text = @"";
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.label.text = @"Refreshing Cask List…";
    hud.userInteractionEnabled = YES;


    dispatch_after_main(0.1, ^
    {
        let zipData = @"https://github.com/Homebrew/homebrew-cask/archive/master.zip".download;
        let zipPath = @[cc.docDir, @"master.zip"].path;
        zipPath.contents = zipData;
        
        
        if (![SSZipArchive unzipFileAtPath:zipPath toDestination:cc.docDir])
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Could not download or extract archive" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [alert dismissViewControllerAnimated:YES completion:nil]; }];

            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else
            [self scanCasks];
        
        [self.tableView reloadData];
        
        [hud hideAnimated:YES];
    });
}

- (void)scanCasks
{
    let caskPath = @[cc.docDir, @"homebrew-cask-master", @"Casks"].path;
    let caskNames = caskPath.directoryContents;
    let caskNamesWithoutExtension = [caskNames mapped:^id(NSString *input) { return input.stringByDeletingPathExtension; }];
    
    self.casks = [caskNamesWithoutExtension.sorted subarrayFromIndex:1];
    
    [self filterCasks];
}

- (void)filterCasks
{
    if (!self.filterField.text.length)
        self.filteredCasks = self.casks;
    else
        self.filteredCasks = [self.casks filtered:^BOOL(NSString *input)
        {
            return [input contains:self.filterField.text];
        }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"])
	{
		DetailViewController *vc = segue.destinationViewController;
		
        vc.caskName = self.filteredCasks[self.tableView.indexPathForSelectedRow.row];
	}
}

#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.filteredCasks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    cell.textLabel.text = self.filteredCasks[indexPath.row];
	
    return cell;
}
@end
