//
//  DriveList.h
//  SMARTReporter
//
//  Created by CoreCode on Sat Feb 28 2004.
/*	Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "Drive.h"
#import "JMEmailSender.h"

@interface DriveList : NSWindowController <NSCoding>
{
	time_t							lastPollTime;

	NSMutableArray					*drives;

	IBOutlet NSTextField			*emailUsernameTextField;
	IBOutlet NSTextField			*emailPasswordTextField;
	IBOutlet NSProgressIndicator	*progressindicator;
	IBOutlet NSPopUpButton			*executemenu;
	IBOutlet NSPopUpButton			*iconmenu;
	IBOutlet NSImageView			*verifiedview;
	IBOutlet NSImageView			*unknownview;
	IBOutlet NSImageView			*failingview;
	IBOutlet NSButton				*startbutton;
	IBOutlet NSButton				*redbutton;
	IBOutlet NSButton				*emailbutton;
	IBOutlet NSButton				*sendbutton;
	IBOutlet NSPanel				*emailpanel;
	IBOutlet NSTableView			*drivetable;

	NSTimer							*ioerrorTimer;
	NSTimer							*raiderrorTimer;

	id								delegate;

	BOOL							isGrowlInstalled;
}

- (void)sendMail:(Drive *)drive testMode:(BOOL)testmode;
- (void)refreshDriveList:(id)del;
- (BOOL)detectDrives:(io_iterator_t)iter;
- (void)setMenuIconIfFailing;
- (void)writeDriveDataFile;
- (NSUInteger)indexOfDriveEqualToDrive:(Drive *)drive;
- (void)getPassword;

//action methods
- (IBAction)toggleIOErrorCheckAction:(id)sender;
- (IBAction)toggleRAIDErrorCheckAction:(id)sender;
- (IBAction)logfileAction:(id)sender;
- (IBAction)updatecheckAction:(id)sender;
- (IBAction)invisibleAction:(id)sender;
- (IBAction)iconAction:(id)sender;
- (IBAction)commitAction:(id)sender;
- (IBAction)configureAction:(id)sender;
- (IBAction)sendAction:(id)sender;
- (IBAction)startAction:(id)sender;
- (IBAction)selectApplicationAction:(id)sender;
- (IBAction)updatePassword:(id)sender;

@property (retain, nonatomic) NSMutableArray *drives;
@property (assign, nonatomic) BOOL isGrowlInstalled;
@end
