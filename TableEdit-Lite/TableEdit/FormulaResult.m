//
//  FormulaResult.m
//  TableEdit-Lite
//
//  Created by CoreCode on 01.12.15.
/*    Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/


#import "FormulaResult.h"
#import "AddressHelper.h"
#import <wchar.h>



@implementation NSString(FormulaResultCategory)
@dynamic dateValue, numberValue;

- (NSDate *)dateValue
{
	static NSArray <NSDateFormatter *> *dateInputFormatters;
    static NSMutableDictionary <NSString *, NSDate *> *cache; // this would be a perfect usecase for cocoa's built in cache API

	ONCE_PER_FUNCTION(^
	{
		NSMutableArray <NSDateFormatter *> *tmp = makeMutableArray();
		NSLocale *l = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
		NSTimeZone *tz = [NSTimeZone timeZoneForSecondsFromGMT:0];

		  for (NSString *dateFormat in @[@"EEE, d MMM yyyy", @"MM/dd/yy", @"M/d/yy", @"MM/dd/yyyy", @"M/d/yyyy", @"dd.MM.yyyy", @"d.M.yyyy", @"dd/MM/yyyy", @"d/M/yyyy", @"yyyy-MM-dd", @"yyyy-M-d", @"yyyy.MM.dd", @"yyyy.M.d", @""])
		  {
			  for (NSString *timeFormat in @[@"'T'HH:mm:ss'Z'", @" HH:mm:ss", @" HH:mm", @" hh:mm a", @""])
			  {
				  NSDateFormatter *df = [NSDateFormatter new];
				  df.dateFormat = [dateFormat stringByAppendingString:timeFormat].trimmedOfWhitespace;
				  df.locale = l;
				  df.timeZone = tz;
				  assert(excelBaseDate);
				  df.defaultDate = excelBaseDate;

				  [tmp addObject:df];
			  }
		  }
		  dateInputFormatters = tmp.immutableObject;

        cache = makeMutableDictionary();
	});


    NSDate *cachedData = cache[self];
    static int times = 0, cached = 0;

    times++;
    if (cachedData)
    {
        cached++;
        return cachedData;
    }

    if (cache.count > 1000 * 100)
    {
        cc_log(@"Warning: string date cache had to be cleaned (up to now we got %i requests and %i were answered from cache)", times, cached);
        [cache removeAllObjects];
    }


	for (NSDateFormatter *dateFormatter in dateInputFormatters)
	{
		NSDate *date = [dateFormatter dateFromString:self];

		if (date)
        {
			cache[self] = date;
            return date;
        }
	}

    NSDate *date = self.numberValue.dateValue;
    cache[self] = date;
	return date;
}
- (NSNumber *)numberValue
{
	static NSArray <NSNumberFormatter *> *numberInputFormatters;
	static NSCharacterSet *invalidCharacterSet;


	ONCE_PER_FUNCTION(^
	{
		  NSMutableArray <NSNumberFormatter *> *tmpFormatters = makeMutableArray();
		  NSMutableCharacterSet *tmpCS = NSMutableCharacterSet.decimalDigitCharacterSet;
		  NSString *currentSeparator = [NSLocale.currentLocale objectForKey:NSLocaleDecimalSeparator];
		  [tmpCS addCharactersInString:@"-"];
		  [tmpCS addCharactersInString:@",."];
		  [tmpCS addCharactersInString:currentSeparator];

//		  for (NSString *locID in NSLocale.availableLocaleIdentifiers)
//		  {
//
//			  NSLocale *loc = [NSLocale localeWithLocaleIdentifier:locID];
//			  NSString *separator = [loc objectForKey:NSLocaleDecimalSeparator];
//
//
//			  [tmpCS addCharactersInString:separator];
//		  }

		if (kNumberFormatKey.defaultInt != inputFormatSystem)
		{
			for (NSNumber *hasThousandSeparators in @[@(YES), @(NO)])
			{
				NSNumberFormatter *ul = NSNumberFormatter.new;
				ul.locale = NSLocale.systemLocale;
				ul.numberStyle = kCFNumberFormatterDecimalStyle;
				ul.hasThousandSeparators = hasThousandSeparators.boolValue;



				if (kNumberFormatKey.defaultInt == inputFormatDECCOMMA_GROUPPOINT || kNumberFormatKey.defaultInt == inputFormatDECCOMMA_GROUPSPACE)
					ul.decimalSeparator = @",";
				else if (kNumberFormatKey.defaultInt == inputFormatDECPOINT_GROUPCOMMA || kNumberFormatKey.defaultInt == inputFormatDECPOINT_GROUPSPACE)
					ul.decimalSeparator = @".";

				if (kNumberFormatKey.defaultInt == inputFormatDECCOMMA_GROUPPOINT)
					ul.thousandSeparator = @".";
				else if (kNumberFormatKey.defaultInt == inputFormatDECPOINT_GROUPCOMMA)
					ul.thousandSeparator = @",";
				else if (kNumberFormatKey.defaultInt == inputFormatDECCOMMA_GROUPSPACE|| kNumberFormatKey.defaultInt == inputFormatDECPOINT_GROUPSPACE)
					ul.thousandSeparator = @" ";


				if (hasThousandSeparators.boolValue)
				{
					[tmpCS addCharactersInString:ul.thousandSeparator];
					[tmpCS addCharactersInString:ul.decimalSeparator];
					[tmpCS addCharactersInString:ul.negativeSuffix];
					[tmpCS addCharactersInString:ul.negativePrefix];
				}
				//LOG(makeString(@"systemLocale: %@", [sl stringFromNumber:@(1234.5678)]));

				[tmpFormatters addObject:ul];
			}
		}

		  for (NSNumber *hasThousandSeparators in @[@(YES), @(NO)])
		  {
			  NSNumberFormatter *cl = NSNumberFormatter.new;
			  cl.locale = NSLocale.currentLocale;
			  cl.numberStyle = kCFNumberFormatterDecimalStyle;
			  cl.hasThousandSeparators = hasThousandSeparators.boolValue;
			  if (hasThousandSeparators.boolValue)
              {
                  [tmpCS addCharactersInString:cl.thousandSeparator];
                  [tmpCS addCharactersInString:cl.decimalSeparator];
                  [tmpCS addCharactersInString:cl.negativeSuffix];
                  [tmpCS addCharactersInString:cl.negativePrefix];
              }
			  //LOG(makeString(@"currentLocale: %@", [cl stringFromNumber:@(1234.5678)]));

			  [tmpFormatters addObject:cl];
		  }

		  for (NSNumber *hasThousandSeparators in @[@(YES), @(NO)])
		  {
			  NSNumberFormatter *sl = NSNumberFormatter.new;
			  sl.locale = NSLocale.systemLocale;
			  sl.numberStyle = kCFNumberFormatterDecimalStyle;
			  sl.hasThousandSeparators = hasThousandSeparators.boolValue;
			  if (hasThousandSeparators.boolValue)
              {
                  [tmpCS addCharactersInString:sl.thousandSeparator];
                  [tmpCS addCharactersInString:sl.decimalSeparator];
                  [tmpCS addCharactersInString:sl.negativeSuffix];
                  [tmpCS addCharactersInString:sl.negativePrefix];
              }
			  //LOG(makeString(@"systemLocale: %@", [sl stringFromNumber:@(1234.5678)]));

			  [tmpFormatters addObject:sl];
		  }

		  for (NSNumber *hasThousandSeparators in @[@(YES), @(NO)])
		  {
			  NSNumberFormatter *el = NSNumberFormatter.new;
			  el.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
			  el.numberStyle = kCFNumberFormatterDecimalStyle;
			  el.hasThousandSeparators = hasThousandSeparators.boolValue;
			  if (hasThousandSeparators.boolValue)
              {
                  [tmpCS addCharactersInString:el.thousandSeparator];
                  [tmpCS addCharactersInString:el.decimalSeparator];
                  [tmpCS addCharactersInString:el.negativeSuffix];
                  [tmpCS addCharactersInString:el.negativePrefix];
              }
			  //LOG(makeString(@"posix: %@", [el stringFromNumber:@(1234.5678)]));

			  [tmpFormatters addObject:el];
		  }

		  invalidCharacterSet =  tmpCS.invertedSet;
		  numberInputFormatters = tmpFormatters.immutableObject;
	});

	// optim on
	NSUInteger      len = self.length;
	BOOL			valid = NO;
	if (!len)		return nil;
	else if (len < 18)
	{
		unichar         buffer[20];
		[self getCharacters:buffer range:NSMakeRange(0, len)];
		BOOL clean = TRUE;
		for (NSUInteger i = 0; i < len; i++)
		{
			if (buffer[i] < '0' || buffer[i] > '9')
				clean = NO;
			else
				valid = TRUE;
		}
		if (clean)
		{
			char *singlecharbuffer = (char *)&buffer;
			for (NSUInteger i = 0; i < len; i++)
				*singlecharbuffer++ = (char)buffer[i];
			*singlecharbuffer = 0;
			long res = atol((char *)buffer);
			NSNumber *resnum = @(res);
			return resnum;
		}
		if (!valid)
			return nil;
	}
	// optim off


	NSString *string = [self stringByTrimmingCharactersInSet:invalidCharacterSet];

	for (NSNumberFormatter *numberFormatter in numberInputFormatters)
	{
        NSNumber *number = [numberFormatter numberFromString:string]; // TODO: this is very slow

		if (number)
        {
            //cc_log_debug(@"converting string {%@} to number [%@] with formatter: %@", self, number, numberFormatter.description);
            return number;
        }
	}

	return nil;
}
@end


@implementation NSNumber(FormulaResultCategory)

@dynamic  dateValue, numberValue;


- (NSNumber *)numberValue
{
	return self;
}
- (NSDate *)dateValue
{
	double serialdate = self.doubleValue;
	NSTimeInterval theTimeInterval;
	static NSTimeInterval numberOfSecondsInOneDay = 86400;

	double integral;
	double fractional = modf(serialdate, &integral);

//	cc_log_debug(@"%@ %@ \r serialdate = %f, integral = %f, fractional = %f", [self class], NSStringFromSelector(_cmd), serialdate, integral, fractional);

	theTimeInterval = integral * numberOfSecondsInOneDay; //number of days
	if (fractional > 0)
		theTimeInterval += numberOfSecondsInOneDay * fractional; //portion of one day


	assert(excelBaseDate);


	
	NSDate *inputDate = [NSDate dateWithTimeInterval:theTimeInterval sinceDate:excelBaseDate];
	
//	cc_log_debug(@"%@ %@ \r serialdate %f, theTimeInterval = %f \r inputDate = %@", [self class], NSStringFromSelector(_cmd), serialdate, theTimeInterval, inputDate.description);

	return inputDate;
}
@end

@implementation NSDate(ExcelSerialDate)

@dynamic numberValue;

- (NSNumber *)numberValue
{
	static NSInteger numberOfSecondsInOneDay = 86400;

	assert(excelBaseDate);


	NSTimeInterval timeInterval = [self timeIntervalSinceDate:excelBaseDate];
	NSTimeInterval timeIntervalNormalized = timeInterval / numberOfSecondsInOneDay;


	//	cc_log_debug(@"%@ %@ \r serialdate %f, theTimeInterval = %f \r inputDate = %@", [self class], NSStringFromSelector(_cmd), serialdate, theTimeInterval, inputDate.description);

	return @(timeIntervalNormalized);
}
@end

