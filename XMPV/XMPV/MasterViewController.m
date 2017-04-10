//
//  MasterViewController.m
//  XMPV
//
//  Created by CoreCode on 07.11.12.
/*	Copyright © 2017 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

// TODO: unified syntax highlighter? RPSyntaxHighlighter?

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "SSZipArchive.h"
#import "JMAlertController.h"
#import "JMActionSheet.h"
#import "MBProgressHUD.h"
extern NSString *_origdir, *_projectdir;


@interface MasterViewController ()

	@property (strong, nonatomic) NSMutableArray <NSDictionary *> *projects;

@end


@implementation MasterViewController

- (void)awakeFromNib
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
	{
	    self.clearsSelectionOnViewWillAppear = NO;
	    self.preferredContentSize = CGSizeMake(320.0, 600.0);
	}
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	//self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(preferences:)];
	
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addProject:)];
	self.navigationItem.rightBarButtonItem = addButton;
	self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
	
	_projects = kProjectsKey.defaultArray.mutableObject;


	[[NSNotificationCenter defaultCenter] addObserver:self
											  forName:UIApplicationDidBecomeActiveNotification object:nil queue:nil usingBlock:^(NSNotification *note, MasterViewController *observer)
	 {
		 [observer checkNewZIPs];
	 }];
    [self checkNewZIPs];


}

- (void)addNewZIP:(NSString *)name
{
	NSString *zipPath = [cc.docDir stringByAppendingPathComponent:name];
	NSString *dstPath1 = [[_origdir stringByAppendingPathComponent:name] stringByDeletingPathExtension].uniqueFile;
	NSString *dstPath2 = [[_projectdir stringByAppendingPathComponent:name] stringByDeletingPathExtension].uniqueFile;

    if (![SSZipArchive unzipFileAtPath:zipPath toDestination:dstPath1] ||
		![SSZipArchive unzipFileAtPath:zipPath toDestination:dstPath2])
	{
		[[[UIAlertView alloc] initWithTitle:@"" message:@"Could not extract archive" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
		return;
	}
    
	NSArray *pbprojFilePaths = [dstPath2.dirContentsRecursive filteredUsingPredicateString:@"self ENDSWITH[cd] 'project.pbxproj' and NOT self CONTAINS '__MACOSX'"];
	if ([pbprojFilePaths count])
	{
		NSString *pbproj = NON_NIL_STR([[pbprojFilePaths sortedArrayByKey:@"length"] safeObjectAtIndex:0]);
		NSDictionary *dict = @{	@"zipName" : name,
								@"origFolder" : dstPath1,
								@"rootFolder" : dstPath2,
								@"xcodeFolder" : [[pbproj stringByDeletingLastPathComponent] stringByDeletingLastPathComponent],
								@"pbprojPath" : pbproj};
		
		[_projects addObject:dict];
		kProjectsKey.defaultObject = _projects;

		[userDefaults synchronize];
		[self.tableView reloadData];
	}
	else
		[[[UIAlertView alloc] initWithTitle:@"" message:@"This project didn't seem to include a Xcode project." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
}

- (void)checkNewZIPs
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Extracting new projects…";
    hud.userInteractionEnabled = YES;
    
    
    dispatch_after_main(0.1, ^
    {
    for (NSString *file in [cc.docDir.dirContents filteredUsingPredicateString:@"self ENDSWITH[cd] '.zip'"])
    {
        if (![self->_projects containsDictionaryWithKey:@"zipName" equalTo:file])
        {


            [self addNewZIP:file];

        }
    }
    
    [hud hide:YES];
    });

}

- (void)addProject:(id)sender
{
	JMActionSheet *sheet = [JMActionSheet actionSheetWithTitle:@"You can add projects by transferring the zipped project folder with iTunes or by downloading projects from github." viewController:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@[@"I'll transfer ZIPs", @"Dowload from github"]];
	
	sheet.alternativeBlock = ^(int res)
	{
		if (res == 1)
		{
			JMAlertController *alert = [JMAlertController alertControllerWithTitle:@""
                                                     viewController:self
                                                            message:@"Please enter the user-name to import a github project:"
                                                        cancelBlock:nil
                                                  cancelButtonTitle:@"Cancel"
                                                         otherBlock:nil
                                                  otherButtonTitles:@[@"Continue"]];
            [alert addTextFieldWithConfigurationHandler:nil];

            __weak JMAlertController *weakAlert = alert;


            alert.otherBlock = ^(int choice)
			{
                NSString *user = [weakAlert textFields][0].text;

				JMAlertController *alert2 = [JMAlertController alertControllerWithTitle:@""
                                                          viewController:self
                                                                 message:@"Please enter the project-name to import a github project:"
                                                             cancelBlock:nil
                                                       cancelButtonTitle:@"Cancel"
                                                              otherBlock:nil
                                                       otherButtonTitles:@[@"Import"]];

                [alert2 addTextFieldWithConfigurationHandler:nil];

                __weak JMAlertController *weakAlert2 = alert2;

				
                alert2.otherBlock = ^(int choice)
				 {
                     NSString *project = [weakAlert2 textFields][0].text;

                     MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                     hud.mode = MBProgressHUDModeIndeterminate;
                     hud.labelText = @"Downloading…";
                     hud.userInteractionEnabled = YES;

                    dispatch_after_main(0.1, ^(void)
                                        {

						 NSString *filename = makeString(@"%@/%@-%@.zip", cc.docDir, user, project).uniqueFile;
						 NSData *data = makeString(@"https://github.com/%@/%@/archive/master.zip", user, project).download;

						 if (data)
						 {
							 [data writeToFile:filename atomically:YES];
							 
							 [self performSelector:@selector(addNewZIP:)
										withObject:[filename replaced:makeString(@"%@/", cc.docDir) with:@""]
										afterDelay:0.1];
						 }
						 else
						 {
							dispatch_after_main(0.1, ^(void)
							{
								[[[UIAlertView alloc] initWithTitle:@"" message:@"There doesn't seem to exist such a project. Check the entered username and projectname." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
							});
						 }
              
                     [hud hide:YES];
                                        });
				 };
				[alert2 showInView:self.view];
			};
            [alert showInView:self.view];
		}
		else
			[self checkNewZIPs];
	};
	
	[sheet showFromBarButtonItem:sender animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"])
	{
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
		DetailViewController *vc = segue.destinationViewController;
		
		NSDictionary *project = _projects[indexPath.row];
		NSString *pbxProjPath = @[project[@"rootFolder"], project[@"pbprojPath"]].path;
		NSData *data = pbxProjPath.contents;
		NSDictionary *plist = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:0 format:0 errorDescription:nil];
		NSString *rootObjectName = plist[@"rootObject"];
		NSDictionary *xcodeObjects = plist[@"objects"];
		NSDictionary *rootObject = xcodeObjects[rootObjectName];
		NSString *mainGroupName = rootObject[@"mainGroup"];
		
		
		
 		vc.currentPath = @[project[@"rootFolder"], project[@"xcodeFolder"]].path;
 		vc.xcodeObjects = xcodeObjects;
		vc.itemHash = mainGroupName;
		vc.projectDict = project;
	}
}

#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _projects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
	NSDictionary *object = _projects[indexPath.row];

	cell.textLabel.text = [object[@"xcodeFolder"] lastPathComponent];
	
    return cell;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor darkGrayColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
	{
		NSDictionary *project = _projects[indexPath.row];
		NSString *pbxProjPath = @[project[@"rootFolder"], project[@"pbprojPath"]].path;
		NSData *data = pbxProjPath.contents;
		NSDictionary *plist = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:0 format:0 errorDescription:nil];
		NSString *rootObjectName = plist[@"rootObject"];
		NSDictionary *xcodeObjects = plist[@"objects"];
		NSDictionary *rootObject = xcodeObjects[rootObjectName];
		NSString *mainGroupName = rootObject[@"mainGroup"];

		if (mainGroupName)
		{
			self.detailViewController.currentPath = @[project[@"rootFolder"], project[@"xcodeFolder"]].path;
			self.detailViewController.xcodeObjects = xcodeObjects;
			self.detailViewController.itemHash = mainGroupName;
			self.detailViewController.projectDict = project;
			[self.detailViewController configureView];
		}
		else
		{
			[[[UIAlertView alloc] initWithTitle:@"Erro" message:@"The project is empty." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
		}
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		NSString *path = [cc.docDir stringByAppendingPathComponent:_projects[indexPath.row][@"zipName"]];
		LOG(path);
		LOG(_projects[indexPath.row][@"rootFolder"]);
		LOG(_projects[indexPath.row][@"origFolder"]);

		[[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
		[[NSFileManager defaultManager] removeItemAtPath:_projects[indexPath.row][@"rootFolder"] error:NULL];
		[[NSFileManager defaultManager] removeItemAtPath:_projects[indexPath.row][@"origFolder"] error:NULL];
	

		[_projects removeObjectAtIndex:indexPath.row];
		
		kProjectsKey.defaultObject = _projects;
        [userDefaults synchronize];
		

        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}
@end
