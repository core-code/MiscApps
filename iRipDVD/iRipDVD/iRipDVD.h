//
//  iRipDVD.h
//  iRipDVD
//
//  Created by CoreCode on Sat Mar 01 2003.
/*	Copyright © 2017 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import <Cocoa/Cocoa.h>
#import "TaskWrapper.h"
#import "PreferenceController.h"

@class PreferenceController;
@interface iRipDVD : NSObject <TaskWrapperController>
{
	IBOutlet NSButton *animated, *preview, *convert;
	IBOutlet NSPopUpButton *audio, *language, *size, *width;
	IBOutlet NSProgressIndicator *progress;
	IBOutlet NSTextField *status, *minutes;
	IBOutlet NSButtonCell *dvd, *vob;
	IBOutlet NSWindow *window, *sheet;
	IBOutlet NSMenuItem *menuitem;
	IBOutlet NSSlider *quality;

	PreferenceController *preferenceController;

	TaskWrapper *task;
	NSMutableString *taskOutput;
	NSString *devicePath, *languageNumber, *crop, *bitrate, *filename, *vobfile;

	BOOL first;
	int state, track;
	long length;
}

- (IBAction)preferences:(id)sender;
- (void)removeTempFiles;
- (void)start;
- (void)quit;
- (void)done;
- (IBAction)convert:(id)sender;
- (IBAction)endSheet:(id)sender;
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contectInfo;
@end