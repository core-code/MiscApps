//
//  AddressHelper.m
//  TableEdit-Lite
//
//  Created by CoreCode on 21.02.14.
/*    Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/


#import "AddressHelper.h"

@implementation AddressHelper

+ (NSString *)indicesToString:(NSInteger)columnIndex rowIndex:(NSInteger)rowIndex
{
	return makeString(@"%@%li", [self columnIndexToString:columnIndex], rowIndex+1);
}

+ (NSString *)indicesToAbsoluteString:(NSInteger)columnIndex rowIndex:(NSInteger)rowIndex
{
	return makeString(@"$%@$%li", [self columnIndexToString:columnIndex], rowIndex+1);
}

+ (NSString *)columnIndexToString:(NSInteger)columnIndex
{
	assert(columnIndex < 26 * 26 * 26 * 26);


	if (columnIndex < 26)
	{
		const char chars[] = {(char)('A'+columnIndex), 0};
		return [NSString stringWithCString:chars encoding:NSASCIIStringEncoding];
	}
	else if (columnIndex < 26 * 27)
	{
		NSInteger c3 = columnIndex / 26;
		columnIndex -= c3 * (26);

		const char chars[] = {(char)('A'+c3-1), (char)('A'+columnIndex), 0};
		return [NSString stringWithCString:chars encoding:NSASCIIStringEncoding];
	}
	else if (columnIndex < 26 * 26 * 27 + 26)
	{
		NSInteger c2 = (columnIndex - 26) / (26*26);
		if (c2)
			columnIndex -= (c2 * 26*26) + 26;


		NSInteger c3 = columnIndex / 26;
		columnIndex -= c3 * (26);

		const char chars[] = {(char)('A'+c2-1), (char)('A'+c3), (char)('A'+columnIndex), 0};
		return [NSString stringWithCString:chars encoding:NSASCIIStringEncoding];
	}
	else
	{
		NSInteger c1 = (columnIndex - (26*26 + 26)) / (26*26*26);
		if (c1)
			columnIndex -= (c1 * 26*26*26) + (26*26 + 26);

		NSInteger c2 = columnIndex / (26*26);
		if (c2)
			columnIndex -= (c2 * 26*26) ;


		NSInteger c3 = columnIndex / 26;
		columnIndex -= c3 * (26);


		const char chars[] = {(char)('A'+c1-1), (char)('A'+c2), (char)('A'+c3), (char)('A'+columnIndex), 0};
		return [NSString stringWithCString:chars encoding:NSASCIIStringEncoding];
	}
}

+ (coordinates)cellStringToIndex:(NSString *)cellString
{
	cellString = cellString.uppercaseString;


	if ([cellString rangeOfCharacterFromSet:cellAddressForbiddenCharacterset options:(NSStringCompareOptions)0].location != NSNotFound)
		@throw ([NSException exceptionWithName:@"#INVALID_CELLADDRESS!" reason:@"3" userInfo:nil]);

    NSUInteger row, column;


//    NSArray <NSString *> *comp = [cellString split:@"C"];
//
//    NSRange rangeOfDigitInFirst = [comp[0] rangeOfCharacterFromSet:NSCharacterSet.decimalDigitCharacterSet];
//
//    if (rangeOfDigitInFirst.location != NSNotFound && comp.count == 2) // R1C1
//    {
//        if (![comp[0] contains:@"R"])
//            @throw ([NSException exceptionWithName:@"#INVALID_CELLADDRESS!" reason:@(__LINE__).stringValue userInfo:nil]);
//
//        BOOL firstContainsClosingBracket = [comp[0] contains:@"]"];
//
//        if ([comp[0] hasPrefix:@"["])
//        {
//            if (!firstContainsClosingBracket)
//                @throw ([NSException exceptionWithName:@"#INVALID_CELLADDRESS!" reason:@(__LINE__).stringValue userInfo:nil]);
//
//            NSString *rowString = [comp[0] substringWithRange:NSMakeRange(rangeOfDigitInFirst.location, comp[0].length - rangeOfDigitInFirst.location - 1)];
//            row = (rowString.integerValue) - 1;
//
//        }
//        else
//        {
//            if (firstContainsClosingBracket)
//                @throw ([NSException exceptionWithName:@"#INVALID_CELLADDRESS!" reason:@(__LINE__).stringValue userInfo:nil]);
//
//            NSString *rowString = [comp[0] substringWithRange:NSMakeRange(rangeOfDigitInFirst.location, comp[0].length - rangeOfDigitInFirst.location)];
//            row = (rowString.integerValue) - 1;
//        }
//
//        BOOL firstEndsWithOpeningBracket = [comp[0] hasSuffix:@"["];
//
//        if ([comp[1] hasSuffix:@"]"])
//        {
//            if (!firstEndsWithOpeningBracket)
//                @throw ([NSException exceptionWithName:@"#INVALID_CELLADDRESS!" reason:@(__LINE__).stringValue userInfo:nil]);
//
//            NSString *columnString = [comp[1] substringWithRange:NSMakeRange(1, comp[1].length - 2)];
//            column = (columnString.integerValue) - 1;
//        }
//        else
//        {
//            if (firstEndsWithOpeningBracket)
//                @throw ([NSException exceptionWithName:@"#INVALID_CELLADDRESS!" reason:@(__LINE__).stringValue userInfo:nil]);
//
//
//            NSString *columnString = comp[1];
//            column = (columnString.integerValue) - 1;
//        }
//
//    }
//    else
    {
        NSRange numericLocation = ([cellString rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]]);
        if (numericLocation.location == NSNotFound)
            @throw ([NSException exceptionWithName:@"#INVALID_CELLADDRESS!" reason:@(__LINE__).stringValue userInfo:nil]);

        NSString *numericString = [cellString substringFromIndex:numericLocation.location];
        row = (numericString.intValue) - 1;

        NSString *columnString = [[cellString substringToIndex:numericLocation.location] replaced:@"$" with:@""];
        column = [self columnStringToIndex:columnString];
    }

	return (coordinates){column,row};
}

+ (NSUInteger)columnStringToIndex:(NSString *)columnString
{
	columnString = [columnString replaced:@"$" with:@""];
	NSUInteger columnSum = 0;
	NSUInteger multiplier = 1;
	for (NSInteger i = (int)columnString.length-1; i >= 0; i--)
	{
		int val = [columnString characterAtIndex:i] - 'A' + 1;
		columnSum += val * multiplier;

		multiplier *= 26;
	}

	return columnSum-1;
}
@end
