//
//  AppDelegate.m
//  Unquarantine
//
//  Created by CoreCode on 17.06.14.
/*	Copyright © 2018 CoreCode Limited
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "AppDelegate.h"
#import "DragDestinationView.h"
#import "JMSUFileManager.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSPathControl *dirPathControl;
@property (weak) IBOutlet DragDestinationView *dirDragView;
@property (assign) BOOL fileSelected;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	cc = [CoreLib new];

    _dirDragView.destinationPathControl = _dirPathControl;
}

- (BOOL)pathControl:(NSPathControl *)pathControl acceptDrop:(id <NSDraggingInfo>)info;
{
	NSPasteboard *pboard = [info draggingPasteboard];

	if (![[pboard types] containsObject:NSURLPboardType])
		return NO;

	NSURL *file = [NSURL URLFromPasteboard:pboard];

    if (!file.fileIsDirectory || ![file.path hasSuffix:@".app"])
        return NO;

    self.fileSelected = YES;

	return YES;
}

- (IBAction)choose:(id)sender
{
    self.fileSelected = YES;
}

- (IBAction)continue:(id)sender
{
    NSURL *file = _dirPathControl.URL;

    if (!file.fileIsDirectory || ![file.path hasSuffix:@".app"])
        alert_apptitled(@"You need to select an app", @"D'oh", nil, nil);
    


    JMSUFileManager *fm = [JMSUFileManager new];
    NSError *err;
    int res = [fm releaseItemFromQuarantineAtRootURL:file error:&err];
    
    if (res == -1)
    {
        alert_apptitled(@"This application is not quarantined, so there is nothing to do.", @"OK", nil, nil);
    }
    else if (res == 1)
    {
        alert_apptitled(@"The 'quarantine' on this application has has been sucessfully removed.", @"Awesome", nil, nil);
    }
    else if (res == 0)
    {
        alert_apptitled(makeString(@"The 'quarantine' on this application could not be removed (Error: %@)", err.description), @"D'oh", nil, nil);
    }
    else
        alert_apptitled(@"?¿?", @"D'oh", nil, nil);
}

@end

int main(int argc, const char * argv[])
{
	return NSApplicationMain(argc, argv);
}
