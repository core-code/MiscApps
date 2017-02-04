//
//  AppDelegate.m
//  LayoutTest
//
//  Created by CoreCode on 04.05.12.
/*	Copyright © 2017 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize scrollView = _scrollView;

- (void)dealloc
{
    [super dealloc];
}

- (void)addTestWithName:(NSString *)name font:(NSFont *)font width:(int)width strings:(NSArray *)strings
{
	for (NSString *string in strings)
	{
		NSAttributedString *as = [[NSAttributedString alloc] initWithString:string attributes:[NSDictionary dictionaryWithObject:font forKey: NSFontAttributeName]];
		
		NSTextField *tf = [[NSTextField alloc] initWithFrame:NSMakeRect(10, y, width, 30)];

		[tf setAttributedStringValue:as];

		[_scrollView.documentView addSubview:tf];
		if ([as size].width > width)
			[tf setBackgroundColor:[NSColor redColor]];

		y += 35;
		[as release];
	}
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	y = 20;
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	NSFont *LGB17 = [NSFont fontWithName:@"LucidaGrande-Bold" size:17];
	NSFont *S13 = [NSFont fontWithName:@"LucidaGrande" size:13];
	NSFont *S11 = [NSFont fontWithName:@"LucidaGrande" size:11];

	[self addTestWithName:@"statusText" font:LGB17 width:546 strings:$array(
																			   NSLocalizedString(@"Status: Warning", nil),
																			   NSLocalizedString(@"Status: Error!", nil),
																			   NSLocalizedString(@"Status: O.K.", nil),
																			   NSLocalizedString(@"Status: Check not yet performed", nil),
																			   NSLocalizedString(@"Status: Check disabled", nil))];
	
	[self addTestWithName:@"lastcheckText" font:S13 width:546 strings:$array(
																			$stringf(NSLocalizedString(@"Last check was performed at %@ (Boot Disk Status Check).", nil), [dateFormatter stringFromDate:[NSDate date]]),
																			$stringf(NSLocalizedString(@"Last check was performed at %@ (Disk Status Check).", nil), [dateFormatter stringFromDate:[NSDate date]]),
																			$stringf(NSLocalizedString(@"Last check was performed at %@ (Short Self-Test).", nil), [dateFormatter stringFromDate:[NSDate date]]))];
	
	[self addTestWithName:@"resultText" font:S13 width:546 strings:$array(
																		   $stringf(NSLocalizedString(@"Disk-Space check did not find any problems on all %i checked disk(s).", nil), 9),
																		   $stringf(NSLocalizedString(@"Disk-Space check did not find a problem on the boot disk.", nil)),
																		   $stringf(NSLocalizedString(@"Disk-Space check discovered problems on %i of %i checked disk(s)!", nil), 2, 9),
																		   $stringf(NSLocalizedString(@"Disk-Space check discovered a problem on the boot disk!", nil)),
																		   $stringf(NSLocalizedString(@"I/O-Error check did not find any problems on all %i checked disk(s).", nil), 9),
																		   $stringf(NSLocalizedString(@"I/O-Error check found %i problems on %i of %i checked disk(s)!", nil), 9, 9, 9),
																		   NSLocalizedString(@"I/O-Error check was not able to read the system logfile.", nil),
																		   NSLocalizedString(@"R.A.I.D. check was not able to execute 'diskutil'.", nil),
																		   $stringf(NSLocalizedString(@"R.A.I.D. check did not find any problems on all %i checked set(s).", nil), 9),
																		   $stringf(NSLocalizedString(@"R.A.I.D. check found %i of %i connected set(s) to be degraded!", nil), 9, 9),
																		   $stringf(NSLocalizedString(@"R.A.I.D. check found %i of %i connected set(s) to be offline!", nil), 9, 9),
																		   $stringf(NSLocalizedString(@"R.A.I.D. check found %i of %i connected set(s) to be degraded or offline!", nil), 9, 9),
																		   $stringf(NSLocalizedString(@"S.M.A.R.T. status check and self-test both found some of your disks to be failing!", nil), 9),
																		   $stringf(NSLocalizedString(@"S.M.A.R.T. self-test determined %i disk(s) to be failing soon! Summary status check O.K.", nil), 9),
																		   $stringf(NSLocalizedString(@"S.M.A.R.T. status check determined %i disk(s) to be failing soon! Self-test status O.K.", nil), 9),
																		   $stringf(NSLocalizedString(@"S.M.A.R.T. status check determined %i disk(s) to be failing soon!", nil), 9),
																		   $stringf(NSLocalizedString(@"S.M.A.R.T. status check & self-test did not find any problems on all %i checked disk(s).", nil), 9),
																		   $stringf(NSLocalizedString(@"S.M.A.R.T. status check did not find any problems on all %i checked disk(s).", nil), 9))];

	
	[self addTestWithName:@"statusOnscreenText" font:S13 width:401 strings:$array(
																			NSLocalizedString(@"Notification not in use", nil),
																			NSLocalizedString(@"Notification misconfigured", nil),
																			NSLocalizedString(@"Notification not available", nil),
																			NSLocalizedString(@"Notification configuration O.K.", nil))];	
	
	[self addTestWithName:@"emailText" font:S13 width:374 strings:$array(
																		 $stringf(NSLocalizedString(@"O.K.: successfully sent email at: %@", nil), [dateFormatter stringFromDate:[NSDate date]]),
																		 NSLocalizedString(@"Warning: delivery may fail - Mail configured to 'check spelling on send'", nil),
																		 NSLocalizedString(@"ERROR: email username or password wrong", nil),
																		 NSLocalizedString(@"Warning: could not verify account (no internet connection?)", nil),
																		 $stringf(NSLocalizedString(@"O.K.: successfully sent email at: %@", nil), [dateFormatter stringFromDate:[NSDate date]]),
																		 NSLocalizedString(@"Warning: never sent an email with current configuration", nil),
																		 NSLocalizedString(@"ERROR: no SMTP server specified", nil),
																		 NSLocalizedString(@"ERROR: no account address specified", nil),
																		 NSLocalizedString(@"ERROR: no username specified", nil),
																		 NSLocalizedString(@"ERROR: no valid email recipient address", nil),
																		 $stringf(NSLocalizedString(@"ERROR: last email delivery failed (%@)", nil), NSLocalizedString(@"error sending with Apple Mail", nil)),
																		 $stringf(NSLocalizedString(@"ERROR: last email delivery failed (%@)", nil), NSLocalizedString(@"check settings", nil)),
																		 $stringf(NSLocalizedString(@"ERROR: last email delivery failed (%@)", nil), NSLocalizedString(@"no address to deliver to set", nil)),
																		 $stringf(NSLocalizedString(@"ERROR: last email delivery failed (%@)", nil), NSLocalizedString(@"no address to deliver from set", nil)))];

	[self addTestWithName:@"emailDescription" font:S11 width:123 strings:$array(NSLocalizedString(@"Multiple recipients", nil))];
	
	
    NSView *docView = [_scrollView documentView];
    NSSize oldFrameSize = [docView frame].size;
    [docView setFrameSize:NSMakeSize(oldFrameSize.width,
									 y + 20)];

}


@end
