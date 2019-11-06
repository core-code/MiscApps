//
//  DetailViewController.m
//  HBCA
//
//  Created by CoreCode on 07.11.12.
/*	Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

#import "DetailViewController.h"
#import "CaskHelperLite.h"
#import "MBProgressHUD.h"


@interface DetailViewController ()

@end


@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    let caskPath = @[cc.docDir, @"homebrew-cask-master", @"Casks", makeString(@"%@.rb", self.caskName)].path;
    self.textView.text = caskPath.contents.string;
    
    dispatch_async_back(^
    {
        let url = makeString(@"https://raw.githubusercontent.com/Homebrew/homebrew-cask/master/Casks/%@.rb", self.caskName);
        let caskContents = url.download.string;
        
        if ([caskContents contains:@"cask"] && [caskContents contains:@"end"])
            dispatch_async_main(^{
                self.textView.text = caskContents;
            });
    });

    
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editCask:)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)editCask:(id)sender
{
    let url = makeString(@"https://github.com/Homebrew/homebrew-cask/edit/master/Casks/%@.rb", self.caskName);
    
     [[UIApplication sharedApplication] openURL:url.URL options:@{} completionHandler:^(BOOL success) { }];
}

- (IBAction)newVersion:(id)sender
{
    let caskfileContents = self.textView.text;
    let cv = [CaskHelper getVersionFromCaskfile:caskfileContents];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"New Version" message:@"You can calculate the checksum of a new version of this app using local download or via CGI server" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = cv;
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Local" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
    {
        [self getNewVersion:alertController.textFields.firstObject.text useCGI:NO];
    }];
    [alertController addAction:confirmAction];
    UIAlertAction *cgiAction = [UIAlertAction actionWithTitle:@"CGI" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
    {
        [self getNewVersion:alertController.textFields.firstObject.text useCGI:YES];
    }];
    [alertController addAction:cgiAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
    {
    }];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
    #if TARGET_OS_MACCATALYST
      
    #endif
}

- (void)getNewVersion:(NSString *)version useCGI:(BOOL)useCGI
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.label.text = @"Determinig New SHA…";
    hud.userInteractionEnabled = YES;
    
    
    dispatch_after_main(0.1, ^
    {
        let caskfileContents = self.textView.text;
        let url = [CaskHelper getDownloadURLFromCaskfile:caskfileContents withVersion:version];
        var success = YES;
        var checksum = @"";
        if (useCGI)
        {
            let cgiServerURL = (NSString *)[bundle objectForInfoDictionaryKey:@"__CGI_SHA_CALCULATION_URL_"];
            let cgiURL = [cgiServerURL replaced:@"%@" with:url.escaped];
            let response = cgiURL.download.string;
            success = [response contains:@"SHA: "];
            if (success)
            {
                checksum = [[response split:@"SHA: "][1] split:@"<br>"][0];
                let sizeStr = [[response split:@"SIZE: "][1] split:@"</body>"][0].trimmedOfWhitespaceAndNewlines;
                if (sizeStr.integerValue < MB_TO_BYTES(1))
                    success = NO;
            }
        }
        else
        {
            let file = url.download;
            checksum = file.SHA256;
            if (file.length < MB_TO_BYTES(1))
                success = NO;
        }
        
        if (success)
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Success" message:@"You can copy the checksum or the whole new caskfile for updating the cask online" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Copy SHA" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
            {
                UIPasteboard.generalPasteboard.string = checksum;
            }];
            [alertController addAction:confirmAction];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Copy File" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
            {
                var newCaskfile = caskfileContents;
                newCaskfile = [newCaskfile replaced:[CaskHelper getSHA256FromCaskfile:caskfileContents] with:checksum];
                newCaskfile = [newCaskfile replaced:[CaskHelper getVersionFromCaskfile:caskfileContents] with:version];
                
                UIPasteboard.generalPasteboard.string = newCaskfile;
            }];
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Could not get checksum" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"D'Oh" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [alert dismissViewControllerAnimated:YES completion:nil]; }];
            
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
        }
        
        
        [hud hideAnimated:YES];
    });
}
@end
