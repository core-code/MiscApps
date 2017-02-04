//
//  AppDelegate.m
//  STOCKings
//
//  Created by CoreCode on 10.01.14.
/*	Copyright © 2017 CoreCode Limited
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "AppDelegate.h"


@interface AppDelegate ()

@property (strong) IBOutlet WebView *webView;
@property (strong) NSMenu *menu;
@property (strong) NSStatusItem *statusItem;
@property (strong) NSMutableArray <NSNumber *> *dax;
@property (strong) NSMutableArray <NSDate *> *daxDates;
@property (strong) NSDictionary <NSString *, NSMutableArray <NSNumber *> *> *values;
@property (strong) NSDictionary <NSString *, NSMutableArray <NSDate *> *> *dates;
@property (strong) NSDictionary <NSString *, NSMutableArray <NSString *> *> *percents;

@end

#define kDAXURL @"http://www.finanzen.net/index/DAX-Realtime"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	cc = [CoreLib new];


	self.menu = [[NSMenu alloc] init];
	self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	[self.statusItem setMenu:self.menu];


	self.dax = makeMutableArray();
	self.daxDates = makeMutableArray();

	self.values =
	@{ @"TecDAX" : makeMutableArray(),
		 @"MDAX" : makeMutableArray(),
		 @"ESTX50" : makeMutableArray(),
		 @"DOW.J" : makeMutableArray(),
		 @"NAS100" : makeMutableArray(),
		 @"S&amp;P 500" : makeMutableArray(),
		 @"NIKKEI" : makeMutableArray(),
		 @"ATX" : makeMutableArray(),
		 @"Goldpreis" : makeMutableArray(),
		 @"Ölpreis" : makeMutableArray(),
		 @"Dollarkurs" : makeMutableArray()};

	self.dates =
	@{ @"TecDAX" : makeMutableArray(),
	   @"MDAX" : makeMutableArray(),
	   @"ESTX50" : makeMutableArray(),
	   @"DOW.J" : makeMutableArray(),
	   @"NAS100" : makeMutableArray(),
	   @"S&amp;P 500" : makeMutableArray(),
	   @"NIKKEI" : makeMutableArray(),
	   @"ATX" : makeMutableArray(),
	   @"Goldpreis" : makeMutableArray(),
	   @"Ölpreis" : makeMutableArray(),
	   @"Dollarkurs" : makeMutableArray()};

	self.percents =
	@{ @"TecDAX" : makeMutableArray(),
	   @"MDAX" : makeMutableArray(),
	   @"ESTX50" : makeMutableArray(),
	   @"DOW.J" : makeMutableArray(),
	   @"NAS100" : makeMutableArray(),
	   @"S&amp;P 500" : makeMutableArray(),
	   @"NIKKEI" : makeMutableArray(),
	   @"ATX" : makeMutableArray(),
	   @"Goldpreis" : makeMutableArray(),
	   @"Ölpreis" : makeMutableArray(),
	   @"Dollarkurs" : makeMutableArray()};

	[self reload];
}

- (void)clicked:(id)sender
{
	[kDAXURL.URL open];
}

- (void)quit:(id)sender
{
	[NSApp terminate:self];
}

- (void)reload
{
	asl_NSLog_debug(@"reload");
	for (NSMutableArray *array in @[self.dax, self.daxDates, self.values, self.dates, self.percents])
		[array removeAllObjects];

	[[self.webView mainFrame] stopLoading];
	[self.webView removeFromSuperview];
	self.webView = nil;
	self.webView = [[WebView alloc] init];
	self.webView.frameLoadDelegate = self;
	[self.webView setShouldUpdateWhileOffscreen:YES];

	[self load];
}

- (void)load
{
	[[self.webView mainFrame] loadRequest:kDAXURL.URL.request];
}

- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame
{
	[AppDelegate cancelPreviousPerformRequestsWithTarget:self];
	NSDate *now = [NSDate date];
	NSInteger hour = [now descriptionWithCalendarFormat:@"%H" timeZone:[NSTimeZone timeZoneWithAbbreviation:@"CEST"] locale:nil].integerValue;
	NSString *day = [now descriptionWithCalendarFormat:@"%a" timeZone:[NSTimeZone timeZoneWithAbbreviation:@"CEST"] locale:nil];

	int interval = 10*60;
	if (hour >= 8 && hour <= 22 && ![@[@"Sat", @"Sun"] contains:day])
		interval = 1*60.0;

	NSDate *lastDate = self.daxDates.lastObject;
	NSString *lastDay = [lastDate descriptionWithCalendarFormat:@"%a" timeZone:[NSTimeZone timeZoneWithAbbreviation:@"CEST"] locale:nil];

	if (!lastDate || [now timeIntervalSinceDate:lastDate] > 3600)
		asl_NSLog_debug(@"Info: %@ %@  %@", day, lastDay, _daxDates);

	if (lastDate && ![day isEqualToString:lastDay])
	{
		LOGSUCC;
		[self reload];
		return;
	}
	else
		[self performSelector:@selector(load) withObject:nil afterDelay:interval];


	NSArray <NSString *> *comp = title.words;
	if ([comp.firstObject isEqualToString:@"DAX"] && comp.count == 3)
	{
		[self.dax addObject:@(comp[1].floatValue)];
		[self.daxDates addObject:now];

		if (title.length)
			[self.statusItem setTitle:title];
	}

	NSString *str = [(DOMHTMLElement *)[[[self.webView mainFrame] DOMDocument] documentElement] outerHTML];
	NSArray *links = @[@"/index/TecDAX-Realtime", @"/index/MDAX-Realtime", @"/index/Euro_Stoxx_50-Realtime", @"/index/Dow_Jones-Realtime", @"/index/Nasdaq_100-Realtime", @"/index/S&amp;P_500-Realtime", @"/index/Nikkei_225-Realtime", @"/index/ATX-Realtime", @"/rohstoffe/goldpreis/Realtimekurse", @"/rohstoffe/oelpreis@brent/Realtimekurse", @"/devisen/realtimekurs/dollarkurs"];
	NSArray *names = @[@"TecDAX", @"MDAX", @"ESTX50", @"DOW.J", @"NAS100", @"S&amp;P 500", @"NIKKEI", @"ATX", @"Goldpreis", @"Ölpreis", @"Dollarkurs"];
	for (NSString *name in names)
	{
		NSString *link = links[[names indexOfObject:name]];
		NSString *splitter = makeString(@"<a href=\"%@\">%@</a></td>", link, name);
		NSArray <NSString *> *comp1 = [str split:splitter];

		if (comp1.count > 1)
		{


			@try {
				NSString *field = [comp1[1] split:@"</tr>"][0];
				NSString *percent = [[field split:@"\"changeper\">"][1] split:@"</div>"][0];
				NSString *valstr = [[[[field split:@"field=\"bid\">"][1] split:@"<"][0] replaced:@"." with:@""] replaced:@"," with:@"."];

				assert(percent);
				NSMutableArray <NSNumber *> *valarray = self.values[name];
				NSMutableArray <NSDate *> *datearray = self.dates[name];
				NSMutableArray <NSString *>*percarray = self.percents[name];

				[valarray addObject:@(valstr.floatValue)];
				[datearray addObject:now];
				[percarray addObject:percent];

				while (valarray.count > 50) [valarray removeFirstObject];
				while (datearray.count > 50) [datearray removeFirstObject];
				while (percarray.count > 50) [percarray removeFirstObject];
			}
			@catch (NSException *exception) {


			}
			@finally {



			}

		}
		else
		{
			asl_NSLog_debug(@"could not find splitter %@", splitter);
		}
	}


	// regenerate menu
	[self.menu removeAllItems];
	for (NSString *name in names)
	{
		NSMutableArray <NSNumber *>*valarray = self.values[name];
		NSMutableArray <NSString *> *percarray = self.percents[name];

		[self.menu addItemWithTitle:makeString(@"%@ %@ (%@)", [name replaced:@"&amp;" with:@"&"], valarray.lastObject, percarray.lastObject) action:@selector(clicked:) keyEquivalent:@""];
	}
	[self.menu addItem:[NSMenuItem separatorItem]];
	[self.menu addItemWithTitle:@"Quit" action:@selector(quit:) keyEquivalent:@""];


	// prune data structures
	while (self.dax.count > 50) [self.dax removeFirstObject];
	while (self.daxDates.count > 50) [self.daxDates removeFirstObject];


	// notifications
	for (int i = (int)self.dax.count - 1; i > 0; i--)
	{
		NSDate *date = self.daxDates[i];

		if ([now timeIntervalSinceDate:date] < 10 && (self.dax.lastObject.floatValue - self.dax[i].floatValue > 10))
		{
			NSUserNotification *notification = [[NSUserNotification alloc] init];

			notification.title = makeString(@"DAX Rising %.1f fast", self.dax.lastObject.floatValue);

			[[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
		}
		if ([now timeIntervalSinceDate:date] < 50 && (self.dax.lastObject.floatValue - self.dax[i].floatValue > 20))
		{
			NSUserNotification *notification = [[NSUserNotification alloc] init];

			notification.title = makeString(@"DAX Rising %.1f", self.dax.lastObject.floatValue);

			[[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
		}
		if ([now timeIntervalSinceDate:date] < 250 && (self.dax.lastObject.floatValue - self.dax[i].floatValue > 30))
		{
			NSUserNotification *notification = [[NSUserNotification alloc] init];

			notification.title = makeString(@"DAX Rising %.1f slowly", self.dax.lastObject.floatValue);

			[[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
		}


		if ([now timeIntervalSinceDate:date] < 10 && (self.dax.lastObject.floatValue - self.dax[i].floatValue < -10))
		{
			NSUserNotification *notification = [[NSUserNotification alloc] init];

			notification.title = makeString(@"DAX Falling %.1f fast", self.dax.lastObject.floatValue);

			[[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
		}
		if ([now timeIntervalSinceDate:date] < 50 && (self.dax.lastObject.floatValue - self.dax[i].floatValue < -20))
		{
			NSUserNotification *notification = [[NSUserNotification alloc] init];

			notification.title = makeString(@"DAX Falling %.1f", self.dax.lastObject.floatValue);

			[[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
		}
		if ([now timeIntervalSinceDate:date] < 250 && (self.dax.lastObject.floatValue - self.dax[i].floatValue < -30))
		{
			NSUserNotification *notification = [[NSUserNotification alloc] init];

			notification.title = makeString(@"DAX Falling %.1f slowly", self.dax.lastObject.floatValue);

			[[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
		}
	}
}
@end


int main(int argc, const char * argv[])
{
	return NSApplicationMain(argc, argv);
}