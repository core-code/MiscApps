//
//  iRipCD.h
//  iRipCD
//
//  Created by CoreCode on Son Aug 18 2002.
/*	Copyright © 2017 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import <Cocoa/Cocoa.h>
#import "TaskWrapper.h"
#import "MyTextField.h"
#import "PreferenceController.h"

@class PreferenceController;

@interface iRipCD : NSObject <TaskWrapperController>
{
	TaskWrapper 					*task;
	NSMutableString 				*taskOutput;
	NSMutableArray 					*fileList;
	NSString 						*lamePath;
	NSTimer 						*timer;
	NSString 						*destpath;

	PreferenceController 			*preferenceController;

	IBOutlet NSMatrix 				*sourceMatrixOutlet;
	IBOutlet MyTextField 			*filesTextFieldOutlet;
	IBOutlet NSButton				*selectButtonOutlet;	
	IBOutlet NSButton				*encodeButtonOutlet;
	IBOutlet NSPopUpButton			*optionsPopupOutlet;
	IBOutlet NSWindow				*windowOutlet;
	IBOutlet NSProgressIndicator	*progressOutlet;
}

- (void)setFilesToArray:(NSArray *)array;
- (void)setLamePath:(NSString *)path;

- (IBAction)showPreferencePanelAction:(id)sender;
- (IBAction)setSourceAction:(id)sender;
- (IBAction)encodeAction:(id)sender;
- (IBAction)selectFilesAction:(id)sender;

- (void)appendOutput:(NSString *)output;
- (void)processStarted;
- (void)processFinished;

- (NSString *)makeUniqueFilename:(NSString *)name;
- (void)filesWereDragged:(NSTimer *)aTimer;
@end