//
//  AppDelegate.m
//  STOCKings
//
//  Created by CoreCode on 10.01.14.
/*	Copyright (c) 2014 CoreCode
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "AppDelegate.h"
@import WebKit;
CUSTOM_MUTABLE_ARRAY(NSDate)
CUSTOM_DICTIONARY(MutableNSNumberArray)
CUSTOM_DICTIONARY(MutableNSDateArray)
CUSTOM_DICTIONARY(MutableNSStringArray)

@interface AppDelegate ()

@property (strong) IBOutlet WebView *webView;
@property (strong) NSMenu *menu;
@property (strong) NSStatusItem *statusItem;
@property (strong) MutableNSNumberArray *dax;
@property (strong) MutableNSDateArray *daxDates;
@property (strong) MutableNSNumberArrayDictionary *values;
@property (strong) MutableNSDateArrayDictionary *dates;
@property (strong) MutableNSStringArrayDictionary *percents;

@end

#define kDAXURL @"http://www.finanzen.net/index/DAX-Realtime"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	cc = [CoreLib new];

	self.webView = [[WebView alloc] init];
	self.webView.frameLoadDelegate = self;
	[self.webView setShouldUpdateWhileOffscreen:YES];
	[self load];

	self.menu = [[NSMenu alloc] init];
	self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	[self.statusItem setMenu:self.menu];


	self.dax = makeMutableNSNumberArray();
	self.daxDates = makeMutableNSDateArray();

	self.values = (MutableNSNumberArrayDictionary *)
	@{ @"TecDAX" : makeMutableNSNumberArray(),
		 @"MDAX" : makeMutableNSNumberArray(),
		 @"E-STOXX 50" : makeMutableNSNumberArray(),
		 @"DOW Jones" : makeMutableNSNumberArray(),
		 @"NASDAQ100" : makeMutableNSNumberArray(),
		 @"S&amp;P 500" : makeMutableNSNumberArray(),
		 @"NIKKEI 225" : makeMutableNSNumberArray(),
		 @"ATX" : makeMutableNSNumberArray(),
		 @"Goldpreis" : makeMutableNSNumberArray(),
		 @"Ölpreis" : makeMutableNSNumberArray(),
		 @"Dollarkurs" : makeMutableNSNumberArray()};

	self.dates = (MutableNSDateArrayDictionary *)
	@{ @"TecDAX" : makeMutableNSDateArray(),
	   @"MDAX" : makeMutableNSDateArray(),
	   @"E-STOXX 50" : makeMutableNSDateArray(),
	   @"DOW Jones" : makeMutableNSDateArray(),
	   @"NASDAQ100" : makeMutableNSDateArray(),
	   @"S&amp;P 500" : makeMutableNSDateArray(),
	   @"NIKKEI 225" : makeMutableNSDateArray(),
	   @"ATX" : makeMutableNSDateArray(),
	   @"Goldpreis" : makeMutableNSDateArray(),
	   @"Ölpreis" : makeMutableNSDateArray(),
	   @"Dollarkurs" : makeMutableNSDateArray()};

	self.percents = (MutableNSStringArrayDictionary *)
	@{ @"TecDAX" : makeMutableNSStringArray(),
	   @"MDAX" : makeMutableNSStringArray(),
	   @"E-STOXX 50" : makeMutableNSStringArray(),
	   @"DOW Jones" : makeMutableNSStringArray(),
	   @"NASDAQ100" : makeMutableNSStringArray(),
	   @"S&amp;P 500" : makeMutableNSStringArray(),
	   @"NIKKEI 225" : makeMutableNSStringArray(),
	   @"ATX" : makeMutableNSStringArray(),
	   @"Goldpreis" : makeMutableNSStringArray(),
	   @"Ölpreis" : makeMutableNSStringArray(),
	   @"Dollarkurs" : makeMutableNSStringArray()};
}

- (void)clicked:(id)sender
{
	[kDAXURL.URL open];
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

	int interval = 5*50;
	if (hour >= 8 && hour <= 22 && ![@[@"Sat", @"Sun"] contains:day])
		interval = 60.0;

	[self performSelector:@selector(load) withObject:nil afterDelay:interval];


	NSStringArray *comp = title.words;
	if ([comp.firstObject isEqualToString:@"DAX"] && comp.count == 3)
	{
		[self.dax addObject:comp[1].numberValue];
		[self.daxDates addObject:now];


		[self.statusItem setTitle:title];
	}

	NSString *str = [(DOMHTMLElement *)[[[self.webView mainFrame] DOMDocument] documentElement] outerHTML];
	NSArray *links = @[@"/index/TecDAX-Realtime", @"/index/MDAX-Realtime", @"/index/Euro_Stoxx_50-Realtime", @"/index/Dow_Jones-Realtime", @"/index/Nasdaq_100-Realtime", @"/index/S&amp;P_500-Realtime", @"/index/Nikkei_225-Realtime", @"/index/ATX-Realtime", @"/rohstoffe/goldpreis/Realtimekurse", @"/rohstoffe/oelpreis@brent/Realtimekurse", @"/devisen/realtimekurs/dollarkurs"];
	NSArray *names = @[@"TecDAX", @"MDAX", @"E-STOXX 50", @"DOW Jones", @"NASDAQ100", @"S&amp;P 500", @"NIKKEI 225", @"ATX", @"Goldpreis", @"Ölpreis", @"Dollarkurs"];
	for (NSString *name in names)
	{
		NSString *link = links[[names indexOfObject:name]];
		NSStringArray *comp1 = [str split:makeString(@"<a href=\"%@\">%@</a>", link, name)];

		if (comp1.count > 1)
		{
			NSStringArray *comp2 = [comp1[1] split:@"</div>"];
			NSStringArray *comp3 = [comp2[0] split:@">"];
			NSString *percent = [[comp1[1] split:@"\"changeper\">"][1] split:@"</div>"][0];

			MutableNSNumberArray *valarray = self.values[name];
			MutableNSDateArray *datearray = self.dates[name];
			MutableNSStringArray *percarray = self.percents[name];
			NSString *valstr = [[comp3.lastObject replaced:@"." with:@""] replaced:@"," with:@"."];
			[valarray addObject:valstr.numberValue];
			[datearray addObject:now];
			[percarray addObject:percent];

			while (valarray.count > 50) [valarray removeFirstObject];
			while (datearray.count > 50) [datearray removeFirstObject];
			while (percarray.count > 50) [percarray removeFirstObject];
		}
	}


	[self.menu removeAllItems];
	for (NSString *name in names)
	{
		MutableNSNumberArray *valarray = self.values[name];
		MutableNSStringArray *percarray = self.percents[name];

		[self.menu addItemWithTitle:makeString(@"%@ %@ (%@)", [name replaced:@"&amp;" with:@"&"], valarray.lastObject, percarray.lastObject) action:@selector(clicked:) keyEquivalent:@""];
	}

	while (self.dax.count > 50) [self.dax removeFirstObject];
	while (self.daxDates.count > 50) [self.daxDates removeFirstObject];


	for (int i = (int)self.dax.count - 1; i > 0; i--)
	{
		NSDate *date = self.daxDates[i];

		if ([now timeIntervalSinceDate:date] < 3 && (self.dax.lastObject.floatValue - self.dax[i].floatValue > 3))
		{
			NSUserNotification *notification = [[NSUserNotification alloc] init];

			notification.title = makeString(@"DAX Rising %.1f fast", self.dax.lastObject.floatValue);

			[[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
		}
		if ([now timeIntervalSinceDate:date] < 20 && (self.dax.lastObject.floatValue - self.dax[i].floatValue > 6))
		{
			NSUserNotification *notification = [[NSUserNotification alloc] init];

			notification.title = makeString(@"DAX Rising %.1f", self.dax.lastObject.floatValue);

			[[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
		}
		if ([now timeIntervalSinceDate:date] < 60 && (self.dax.lastObject.floatValue - self.dax[i].floatValue > 10))
		{
			NSUserNotification *notification = [[NSUserNotification alloc] init];

			notification.title = makeString(@"DAX Rising %.1f slowly", self.dax.lastObject.floatValue);

			[[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
		}


		if ([now timeIntervalSinceDate:date] < 3 && (self.dax.lastObject.floatValue - self.dax[i].floatValue < -3))
		{
			NSUserNotification *notification = [[NSUserNotification alloc] init];

			notification.title = makeString(@"DAX Falling %.1f fast", self.dax.lastObject.floatValue);

			[[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
		}
		if ([now timeIntervalSinceDate:date] < 20 && (self.dax.lastObject.floatValue - self.dax[i].floatValue < -6))
		{
			NSUserNotification *notification = [[NSUserNotification alloc] init];

			notification.title = makeString(@"DAX Falling %.1f", self.dax.lastObject.floatValue);

			[[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
		}
		if ([now timeIntervalSinceDate:date] < 60 && (self.dax.lastObject.floatValue - self.dax[i].floatValue < -10))
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