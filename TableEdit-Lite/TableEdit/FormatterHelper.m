//
//  FormatterHelper.m
//  TableEdit-Lite
//
//  Created by CoreCode on 22.10.15.
/*    Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/


#import "FormatterHelper.h"

@implementation FormatterHelper


+ (NSString *)formattedStringFromTime:(NSNumber *)number type:(formatTimeKind)type format:(int)format
{
	double value = number.doubleValue;
	long seconds = 0;

	if (type == formatTimeSeconds)
		seconds = (long)value;
	else if (type == formatTimeMinutes)
		seconds = (long) (value * 60.0);
	else if (type == formatTimeHours)
		seconds = (long) (value * 60.0 * 60.0);
	else
		assert(0);

	int minutes = (int) (seconds / 60);
	seconds -= minutes * 60;

	int hours = minutes / 60;
	minutes -= hours * 60;


	if (format == 0)
		return makeString(@"%02dh %02dm %02lds", hours, minutes, seconds);
	else if (format == 1)
		return makeString(@"%02dm %02lds", minutes, seconds);
	else if (format == 2)
		return makeString(@"%02dh %02dm", hours, minutes);
	else if (format == 3)
		return makeString(@"%02d:%02d:%02ld", hours, minutes, seconds);
	else if (format == 4)
		return makeString(@"%02d:%02d", hours, minutes);
	else if (format == 5)
		return makeString(@"%02d:%02ld", minutes, seconds);
	else
    {
        assert(0);
        return @"";
    }
}

+ (NSString *)formattedStringFromDate:(NSDate *)date dateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle
{
	static NSArray <NSArray <NSDateFormatter *>*> *dateOutputFormatters;

	ONCE_PER_FUNCTION(^
	{
		NSMutableArray <NSArray <NSDateFormatter *>*> *tmp = makeMutableArray();
		NSTimeZone *tz = [NSTimeZone timeZoneForSecondsFromGMT:0];

		for (NSDateFormatterStyle d = NSDateFormatterNoStyle; d <= NSDateFormatterFullStyle; d++)
		{
			NSMutableArray <NSDateFormatter *> *tmp2 = [NSMutableArray new];

			for (NSDateFormatterStyle t = NSDateFormatterNoStyle; t <= NSDateFormatterFullStyle; t++)
			{
				NSDateFormatter *df = [NSDateFormatter new];

				df.dateStyle = d;
				df.timeStyle = t;
				df.timeZone = tz;

				[tmp2 addObject:df];
			}
			[tmp addObject:tmp2.immutableObject];
		}

		dateOutputFormatters = tmp.immutableObject;
	});

	return [dateOutputFormatters[dateStyle][timeStyle] stringFromDate:date];
}

+ (NSString *)formattedStringFromNumber:(NSNumber *)number attributes:(NSDictionary *)attributes
{
	static NSMutableDictionary <NSString *, NSNumberFormatter *> *numberOutputFormatters;
    static NSMutableDictionary <NSString *, NSString *> *cache; // this would be a perfect usecase for cocoa's built in cache API
    static int times = 0, cached = 0;


	ONCE_PER_FUNCTION(^
    {   // double caching
        numberOutputFormatters = makeMutableDictionary();   // cache for number formatters
        cache = makeMutableDictionary();                    // cache for results
    });
	assert(numberOutputFormatters);
    assert(cache);

	NSNumber *formatNumberObject = attributes[kFormatNumberTypeKey];
	NSNumber *formatDecimalsObject = attributes[kFormatNumberDecimalsKey];
	NSNumber *formatGroupingObject = attributes[kFormatNumberGroupingKey];
    NSNumber *formatCurrencySymbolIndexObject = attributes[kFormatNumberCurrencyCurrencyKey];

	formatNumberKind formatNumber = (formatNumberKind) formatNumberObject.intValue;
	int formatDecimals = formatDecimalsObject.intValue;
	BOOL formatGrouping = formatGroupingObject.boolValue;
    int formatCurrencySymbolIndex = formatCurrencySymbolIndexObject.intValue;

	int hash = formatNumber | (formatDecimals << 8) | (formatGrouping << 16) | (formatCurrencySymbolIndex << 20);
    NSString *hashString = @(hash).stringValue; // TODO: optimize this line and the one below
    NSString *cacheString = [number.stringValue stringByAppendingString:hashString];
    NSString *cachedData = cache[cacheString];

    times++;
    if (cachedData)
    {
        cached++;
        return cachedData;
    }

    if (cache.count > 1000 * 100)
    {
        cc_log(@"Warning: string number formatting cache had to be cleaned (up to now we got %i requests and %i were answered from cache)", times, cached);
        [cache removeAllObjects];
    }



	NSNumberFormatter *numberFormatter = numberOutputFormatters[hashString];
	if (!numberFormatter)
	{
		int styles[] = {NSNumberFormatterDecimalStyle, NSNumberFormatterScientificStyle, NSNumberFormatterCurrencyStyle, NSNumberFormatterPercentStyle, NSNumberFormatterNoStyle};
		numberFormatter = [NSNumberFormatter new];
		numberFormatter.usesGroupingSeparator = formatGrouping;
		numberFormatter.minimumFractionDigits = formatDecimals;
		numberFormatter.maximumFractionDigits = formatDecimals;
		numberFormatter.numberStyle = styles[formatNumber];

        if (formatNumber == formatNumberCurrency)
        {
            if (formatCurrencySymbolIndex)
                numberFormatter.currencySymbol = @[@"", @"$", @"€", @"¥", @"£"][formatCurrencySymbolIndex];
            else
                numberFormatter.currencySymbol = nil;
        }


		numberOutputFormatters[hashString] = numberFormatter;
	}


    if (formatNumber == formatNumberCustom)
	{
		//numberFormatter = [[NSNumberFormatter alloc] init];
		//[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		numberFormatter.positiveFormat = attributes[kFormatNumberCustomPositiveFormatKey];
		numberFormatter.negativeFormat = attributes[kFormatNumberCustomNegativeFormatKey];
	}

	NSString *tmp =  [numberFormatter stringFromNumber:number];

    cache[cacheString] = tmp;

	return tmp;
}

@end
