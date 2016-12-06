//
//  DetailViewController.m
//  XMPV
//
//  Created by CoreCode on 07.11.12.
/*	Copyright (c) 2016 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

@import MessageUI;
#import "DetailViewController.h"
#import "JMAlertView.h"
#import "JMActionSheet.h"
#import "RegexHighlightView.h"
#import <Chromatism/Chromatism.h>

void pseudomain(int argc, char **argv, FILE *buffer);
FILE* open_memstream(char** bufp, size_t* sizep);


@interface DetailViewController ()

	@property (strong, nonatomic) UIPopoverController *masterPopoverController;
	@property (strong, nonatomic) NSArray *tableObjects;
	@property (assign, nonatomic) NSStringEncoding usedEncoding;
    @property (assign, nonatomic) float keyboardHeight;

@end


@implementation DetailViewController

- (void)loadView
{
	[super loadView];

	_usedEncoding = NSUTF8StringEncoding;
	
	[self setupToolbar:NO];
	



	if ([[UIDevice currentDevice].systemVersion floatValue] >= 7)
	{
		JLTextView *v = [[JLTextView alloc] initWithFrame:_textView.frame];
		[self.view insertSubview:v aboveSubview:_textView];
		[_textView removeFromSuperview];
		_textView = v;

	}
	else
	{
		RegexHighlightView *v = [[RegexHighlightView alloc] initWithFrame:_textView.frame];
		[self.view insertSubview:v aboveSubview:_textView];
		[_textView removeFromSuperview];
		_textView = v;
	}
	_textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;


	
	[[NSNotificationCenter defaultCenter] addObserver:self
											  forName:UIKeyboardWillShowNotification
											   object:nil queue:nil usingBlock:^(NSNotification *note, DetailViewController *observer)
	 {
		 NSDictionary* info = [note userInfo];
		 CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
		 observer.keyboardHeight = UIInterfaceOrientationIsLandscape(observer.interfaceOrientation) ?kbSize.width : kbSize.height;
	 }];



	[[NSNotificationCenter defaultCenter] addObserver:self
											  forName:UITextViewTextDidBeginEditingNotification object:_textView queue:nil usingBlock:^(NSNotification *note, DetailViewController *observer)
	 {
		 [observer setupToolbar:YES];

         CGRect tmpFrame = observer.textView.frame;
         tmpFrame.size.height -= observer.keyboardHeight;
         observer.textView.frame = tmpFrame;
	 }];

	[[NSNotificationCenter defaultCenter] addObserver:self
											  forName:UITextViewTextDidEndEditingNotification object:_textView queue:nil usingBlock:^(NSNotification *note, DetailViewController *observer)
	 {
		 [observer setupToolbar:NO];


         CGRect tmpFrame = observer.textView.frame;
         tmpFrame.size.height += observer.keyboardHeight;
         observer.textView.frame = tmpFrame;
	 }];

	[[NSNotificationCenter defaultCenter] addObserver:self
											  forName:UIApplicationWillTerminateNotification object:[UIApplication sharedApplication] queue:nil usingBlock:^(NSNotification *note, DetailViewController *observer)
	 {
		 [observer saveFile];
	 }];

	[[NSNotificationCenter defaultCenter] addObserver:self
											  forName:UIApplicationWillResignActiveNotification object:[UIApplication sharedApplication] queue:nil usingBlock:^(NSNotification *note, DetailViewController *observer)
	 {
		 [observer saveFile];
	 }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self configureView];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[self saveFile];
	
	[super viewWillDisappear:animated];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
	return [self shouldRowBeSelectable:[self.tableView indexPathForSelectedRow].row];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	DetailViewController *vc = [segue destinationViewController];
	NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	NSString *objectName = _tableObjects[indexPath.row];
	NSDictionary *dict = _xcodeObjects[objectName];
	LOG(self.currentPath);
	LOG(dict[@"path"]);
	LOG(vc.currentPath);
	
	NSString *path = dict[@"sourceTree"];
	path = [path stringByReplacingOccurrencesOfString:@"<group>" withString:self.currentPath];
	path = [path stringByReplacingOccurrencesOfString:@"SOURCE_ROOT" withString:[self.projectDict[@"rootFolder"] stringByAppendingPathComponent:self.projectDict[@"xcodeFolder"]]];
	
	vc.currentPath = [path stringByAppendingPathComponent:NON_NIL_STR(dict[@"path"])];
	vc.xcodeObjects = self.xcodeObjects;
	vc.itemHash = objectName;
	vc.projectDict = self.projectDict;
}

#pragma mark IBAction

- (void)rewind:(UIBarButtonItem *)sender
{
	__weak DetailViewController *weakSelf = self;
	NSDictionary *dict = _xcodeObjects[self.itemHash];
	NSString *type = [dict[@"isa"] isEqualToString:@"PBXFileReference"] ? @"file" : @"folder";
	JMAlertView *alert = [[JMAlertView alloc] initWithTitle:@""
													message:makeString(@"Are you sure you want to revert all changes in this %@?", type)
												   delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
	
	alert.otherBlock = ^(int choice)
	{
		NSString *path1 = [weakSelf.currentPath stringByReplacingOccurrencesOfString:weakSelf.projectDict[@"rootFolder"]
																		  withString:weakSelf.projectDict[@"origFolder"]];
		NSString *path2 = weakSelf.currentPath;
		
		[fileManager copyItemAtPath:path1 toPath:path2 error:NULL];
		
		[weakSelf configureView];
	};
	
	[alert show];
}

- (void)share:(UIBarButtonItem *)sender
{
	__weak DetailViewController *weakSelf = self;
	NSDictionary *dict = _xcodeObjects[self.itemHash];
	NSString *type = [dict[@"isa"] isEqualToString:@"PBXFileReference"] ? @"file" : @"folder";
	JMActionSheet *sheet = [[JMActionSheet alloc] initWithTitle:makeString(@"Do you want to send/share this %@?", type)
													   delegate:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
											  otherButtonTitles:
							makeString(@"Send %@", type),
							makeString(@"Send %@ Diff", type),
							makeString(@"Print %@", type),
							makeString(@"Print %@ Diff", type), nil];
	
	sheet.alternativeBlock = ^(int res)
	{
		[self saveFile];
		
		NSString *content;
		if (res % 2 == 1)
			content = [weakSelf getDiff];
		else
		{
			if ([dict[@"isa"] isEqualToString:@"PBXFileReference"])
				content = weakSelf.textView.text;
			else
			{
			}
		}
		if (res <= 1)
			[self sendMail:content];
		else
			[self printText:content];
	};
	
	[sheet showFromToolbar:self.navigationController.toolbar];
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _tableObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
	if ([tableView respondsToSelector:@selector(dequeueReusableCellWithIdentifier:forIndexPath:)])
		cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
	else
		cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

	NSString *objectName = _tableObjects[indexPath.row];
	NSDictionary *dict = _xcodeObjects[objectName];
	cell.textLabel.text = OBJECT_OR(dict[@"name"], dict[@"path"]);

	if ([dict[@"isa"] isEqualToString:@"PBXGroup"])
		cell.imageView.image = [UIImage imageNamed:@"folder"];
	else if (dict[@"path"])
	{
		NSString *path = [self.currentPath stringByAppendingPathComponent:dict[@"path"]];
		LOG(path);
		NSURL *url = [NSURL fileURLWithPath:path];
		NSString *itemUTI;
		[url getResourceValue:&itemUTI forKey:NSURLTypeIdentifierKey error:nil];	
		UIDocumentInteractionController *dc = [UIDocumentInteractionController interactionControllerWithURL:url];
		dc.UTI = itemUTI;
		
		if (dc.icons.count)
			cell.imageView.image = dc.icons[0];
	}
	
	if (![self shouldRowBeSelectable:indexPath.row])
	{
		cell.textLabel.enabled = NO;
        cell.detailTextLabel.enabled = NO;
        cell.userInteractionEnabled = NO;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
	else
	{
        cell.textLabel.enabled = YES;
        cell.detailTextLabel.enabled = YES;
        cell.userInteractionEnabled = YES;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}


    return cell;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor darkGrayColor];
}

#pragma mark UISplitView

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Projects", nil);
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}


#pragma mark DetailViewController

- (void)setupToolbar:(BOOL)editing
{
	if (editing)
	{
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:_textView action:@selector(resignFirstResponder)];
	}
	else if (self.itemHash)
	{
		UIBarButtonItem *b1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(rewind:)];
		UIBarButtonItem *b3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share:)];

		self.navigationItem.rightBarButtonItems = @[b1, b3];
	}
	else
		self.navigationItem.rightBarButtonItem = nil;
}

- (NSString *)getDiff
{
	NSString *path1 = [self.currentPath stringByReplacingOccurrencesOfString:_projectDict[@"rootFolder"] withString:_projectDict[@"origFolder"]];
	NSString *path2 = self.currentPath;

	const char *params[5] = {"bla", "-r", "-u", [path1 UTF8String], [path2 UTF8String]};

	char *printfBuffer;
    size_t length;
	
	FILE *bufferBackedFile = open_memstream(&printfBuffer, &length);

	
	pseudomain(5, (char **)&params, bufferBackedFile);
	fflush(bufferBackedFile);

	NSString *result = [[NSString alloc] initWithBytes:printfBuffer length:length encoding:NSUTF8StringEncoding];
	fclose(bufferBackedFile);
	free(printfBuffer);
	return result;
}

- (void)saveFile
{
	NSDictionary *dict = _xcodeObjects[self.itemHash];
	
	if ([dict[@"isa"] isEqualToString:@"PBXFileReference"])
	{
		if (![dict[@"lastKnownFileType"] hasPrefix:@"image"])
		{
			[_textView.text writeToFile:self.currentPath atomically:YES encoding:_usedEncoding error:NULL];
		}
	}
}

- (void)setItemHash:(id)newItemHash
{
    if (_itemHash != newItemHash)
	{
        _itemHash = newItemHash;
        if (_imageView)
			[self configureView];
    }
	
    if (self.masterPopoverController != nil)
	{
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)configureView
{
	if (self.itemHash)
	{
		LOG(self.currentPath);
		
		NSDictionary *dict = _xcodeObjects[self.itemHash];
		if ([dict[@"isa"] isEqualToString:@"PBXGroup"] || [dict[@"isa"] isEqualToString:@"PBXVariantGroup"])
		{
			_tableObjects = dict[@"children"];
			self.title = OBJECT_OR(dict[@"name"], dict[@"path"]);
			_tableView.hidden = NO;
			_textView.hidden = YES;
			_imageScrollView.hidden = YES;
			[_tableView reloadData];
		}
		else if ([dict[@"isa"] isEqualToString:@"PBXFileReference"])
		{
			self.title = dict[@"path"];
			
			
			_tableView.hidden = YES;
			
			if ([dict[@"lastKnownFileType"] hasPrefix:@"image"])
			{
				_imageView.image = [UIImage imageWithContentsOfFile:self.currentPath];
				_imageScrollView.hidden = NO;
				_textView.hidden = YES;
			}
			else
			{
// TODO: rtf, icns
//				if ([dict[@"lastKnownFileType"] hasSuffix:@"rtf"])
//				{
//					NSAttributedString *string = [[NSAttributedString alloc] initWithFileURL:self.currentPath.URL
//																					 options:nil
//																		  documentAttributes:NULL
//																					   error:NULL];
//					_textView.attributedText = string;
//				}
//				else
				{
					NSError *err;
					NSString *text = [NSString stringWithContentsOfFile:self.currentPath usedEncoding:&_usedEncoding error:&err];

					_textView.text = text;
				}
				_textView.hidden = NO;

				//_textView.textColor = [UIColor clearColor];
				if ([[UIDevice currentDevice].systemVersion floatValue] < 7)
				{
					RegexHighlightView *v = (RegexHighlightView *)_textView;
					[v setHighlightDefinitionWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"objectivec" ofType:@"plist"]];
					[v setHighlightTheme:kRegexHighlightViewThemeDusk];
				}
				_imageScrollView.hidden = YES;
			}
		}
	}
	else
	{
		_tableView.hidden = YES;
		_textView.hidden = YES;
		_imageScrollView.hidden = YES;
	}
}

- (void)printText:(NSString *)text
{
    UIPrintInteractionController *pic = [UIPrintInteractionController sharedPrintController];
    //pic.delegate = self;
	
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.outputType = UIPrintInfoOutputGeneral;
    printInfo.jobName = @"XMPV Print Job";
    pic.printInfo = printInfo;
	
    UISimpleTextPrintFormatter *htmlFormatter = [[UISimpleTextPrintFormatter alloc] initWithText:text];
    htmlFormatter.startPage = 0;
    htmlFormatter.contentInsets = UIEdgeInsetsMake(72.0, 72.0, 72.0, 72.0); // 1 inch margins
    pic.printFormatter = htmlFormatter;
    pic.showsPageRange = YES;
	
	[pic presentAnimated:YES completionHandler:^(UIPrintInteractionController *printController, BOOL completed, NSError *error)
	{
		if (!completed && error)
		{
			asl_NSLog_debug(@"Printing could not complete because of error: %@", error);
		}
	}];
}

- (void)sendMail:(NSString *)text
{
    if ([MFMailComposeViewController canSendMail])
	{
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        
        mail.mailComposeDelegate = self;
        
        [mail setSubject:@"XMPV Mail"];
 
        [mail setMessageBody:text isHTML:NO];
        
        [self presentViewController:mail animated:YES completion:nil];
    }
}

- (BOOL)shouldRowBeSelectable:(NSInteger)row
{
	NSString *objectName = _tableObjects[row];
	NSDictionary *dict = _xcodeObjects[objectName];
	NSString *type = dict[@"lastKnownFileType"];

	if (type)
	{
		return [type hasPrefix:@"text"] || [type hasPrefix:@"image"] || [type hasPrefix:@"sourcecode"];
	}
	else
	{
		if ([dict[@"isa"] isEqualToString:@"PBXGroup"])
			return YES;
		else if ([dict[@"isa"] isEqualToString:@"PBXVariantGroup"])
			return YES;
		else
			return NO;
	}
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
