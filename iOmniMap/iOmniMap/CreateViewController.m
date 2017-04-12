//
//  FirstViewController.m
//  OmniMap
//
//  Created by CoreCode on 20.12.11.
/*	Copyright © 2017 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

#import "CreateViewController.h"
#import "JMAlertController.h"
#import "PurchaseController.h"
#import "MBProgressHUD.h"

@interface CreateViewController ()

@property (strong, nonatomic) UIPopoverController *popover;
@property (strong, nonatomic) UIImage *image;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UIImageView *rightImageView;
@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;

@end

// TODO: check pdf compatibility
// TODO: crashes
// TODO: no rotate for input image

@implementation CreateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

//    [_rightImageView.layer setMinificationFilter:kCAFilterTrilinear];
//    [_leftImageView.layer setMinificationFilter:kCAFilterTrilinear];

	[self refresh];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)refresh
{
    if (_image)
    {
        _saveButton.enabled = YES;
        _imageView.image = _image;
    }
    else
    {
        _saveButton.enabled = NO;
    }
}

- (BOOL)startMediaBrowserFromViewController:(UIViewController*)controller usingDelegate:(id <UIImagePickerControllerDelegate, UINavigationControllerDelegate>)delegate andSender:(UIButton *)sender
{
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    mediaUI.allowsEditing = NO;
    mediaUI.delegate = delegate;
    

	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
	{
		UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:mediaUI];
		[popover presentPopoverFromRect:sender.bounds inView:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		self.popover = popover;
	}
	else
		[self presentViewController:mediaUI animated:YES completion:NULL];
    
    return YES;
}

- (BOOL)startCameraControllerFromViewController:(UIViewController*)controller usingDelegate:(id <UIImagePickerControllerDelegate, UINavigationControllerDelegate>)delegate  andSender:(UIButton *)sender
{
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    cameraUI.allowsEditing = NO;
    cameraUI.delegate = delegate;
    
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
	{
		UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:cameraUI];
		[popover presentPopoverFromRect:sender.bounds inView:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		self.popover = popover;
	}
	else
		[self presentViewController:cameraUI animated:YES completion:NULL];

    return YES;
}

- (void)startDownloadOfURL:(NSString *)urlStr
{
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	hud.mode = MBProgressHUDModeIndeterminate;
	hud.label.text = @"Downloading…";
	hud.userInteractionEnabled = YES;


	dispatch_async_main(^
	{
		NSURL* url = [NSURL URLWithString: urlStr];
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
        
        request.timeoutInterval = 10.0;
        
        NSError *_error = nil;
        NSHTTPURLResponse *response = NULL;
        NSData *_data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&_error];
        
        if (_data
            && response && ([response statusCode] == 200)
            && (_error == nil))
        {
            self.image = [UIImage imageWithData:_data];
			[self refresh];
        }

		[hud hideAnimated:YES];
	});
}

#pragma mark IBAction action methods

- (IBAction)saveAndEdit:(id)sender
{
	if ([PurchaseController usedMaps] >= [PurchaseController allowedMaps])
	{
		JMAlertController *a = [JMAlertController alertControllerWithTitle:@"Warning"
                                                            viewController:self
                                                                   message:@"You have used all of your allowed maps. Do you want to purchase the ability to create more maps?"
                                                               cancelBlock:^{}
                                                         cancelButtonTitle:@"Cancel"
                                                                otherBlock:^(int p){}
                                                         otherButtonTitles:@[@"Purchase…"]];
        [a setOtherBlock:^(int index)
		{
			PurchaseController *pc = [[PurchaseController alloc] initWithNibName:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"PurchaseView_iPad" : @"PurchaseView_iPhone")
																		  bundle:nil];
			pc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
				pc.modalPresentationStyle = UIModalPresentationFormSheet;
			[self presentViewController:pc animated:YES completion:NULL];
		}];
        [a showInView:self.saveButton];
	}
	else
	{
        JMAlertController *alert = [JMAlertController alertControllerWithTitle:@"iOmniMap"
                                              viewController:self
                                                     message:@"Please name this OmniMap:\n\n\n\n"
                                                 cancelBlock:^{}
									   cancelButtonTitle:@"Cancel"
                                                  otherBlock:^(int p){}
                                           otherButtonTitles:@[@"Save"]];
		
        [alert addTextFieldWithConfigurationHandler:nil];
		__weak JMAlertController *weakAlert = alert;

		[alert setOtherBlock:^(int choice)
		{
            NSString *n = [weakAlert textFields][0].text;

			MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
			hud.mode = MBProgressHUDModeIndeterminate;
			hud.label.text = @"Saving…";
			hud.userInteractionEnabled = YES;


			dispatch_async_main(^
			{
				NSString *name = n;

				NSMutableArray *a = @"OmniMaps".defaultArray.mutableObject;
				BOOL uniqueName = FALSE;

				while (!uniqueName)
				{
					NSDictionary *map;
					for (NSDictionary *m in a)
						if ([m[@"name"] isEqualToString:name])
							map = m;

					if (map)
						name = [name stringByAppendingString:@"_"];
					else
						uniqueName = TRUE;
				}

				self.image = [self normalizedImage:self.image];
				NSDictionary *d = @{	@"imageData" : UIImageJPEGRepresentation(self.image, 0.98),
										@"name" : name,
										@"imageWidth" : @(self.image.size.width),
										@"imageHeight" : @(self.image.size.height)};
				[a insertObject:d atIndex:0];
				@"OmniMaps".defaultObject = a;
				[userDefaults synchronize];

				self.tabBarController.selectedIndex = 1;
		//        NSLog(@"post not");

				dispatch_after_main(0.25, ^{
					[notificationCenter postNotificationName:@"pushMap" object:name];
				});

				[hud hideAnimated:YES];
			});
		}];
        [alert showInView:self.saveButton];
	}
}

- (IBAction)choosePicture:(id)sender 
{
    [self startMediaBrowserFromViewController:self
                                usingDelegate:self
									andSender:sender];
}

- (IBAction)takePicture:(id)sender 
{
    [self startCameraControllerFromViewController:self
                                    usingDelegate:self
										andSender:sender];
}

- (IBAction)downloadPicture:(id)sender
{
    JMAlertController *alert = [JMAlertController alertControllerWithTitle:@"iOmniMap"
                                                      viewController:self
                                                             message:@"Please enter the URL of the picture to use:\n\n\n"
                                                         cancelBlock:^{}
                                                   cancelButtonTitle:@"Cancel"
                                                          otherBlock:^(int p){}
                                                   otherButtonTitles:@[@"Download"]];
    
    
    [alert addTextFieldWithConfigurationHandler:nil];
	__weak JMAlertController *weakAlert = alert;

	alert.otherBlock = ^(int choice)
	{
        NSString *url = [weakAlert textFields][0].text;

		[self startDownloadOfURL:url];
	};
    [alert showInView:self.downloadButton];
}

#pragma mark UIImagePickerController delegate methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker 
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info 
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
 //   UIImage *originalImage, *editedImage;
    
    // Handle a still image capture
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeImage, (CFStringCompareFlags)0)
        == kCFCompareEqualTo)
    {
     
        self.image = (UIImage *) info[UIImagePickerControllerOriginalImage];
//        editedImage = (UIImage *) [info objectForKey:
//                                   UIImagePickerControllerEditedImage];
//        originalImage = (UIImage *) [info objectForKey:
//                                     UIImagePickerControllerOriginalImage];
//        
//        if (editedImage)
//            self.image = editedImage;
//        else
//            self.image = originalImage;
        
        [self refresh];
    }
    else
        assert(0);
    
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (UIImage *)normalizedImage:(UIImage *)image
{
    if (image.imageOrientation == UIImageOrientationUp) return image;

    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    [image drawInRect:(CGRect){0, 0, image.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}
@end
