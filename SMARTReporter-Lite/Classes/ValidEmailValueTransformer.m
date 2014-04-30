//
//  ValidEmailValueTransformer.m
//  SMARTReporter
//
//  Created by CoreCode on 24.07.10.
/*	Copyright (c) 2004 - 2012 CoreCode
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "ValidEmailValueTransformer.h"
#import "JMEmailSender.h"

@implementation ValidEmailValueTransformer

+ (Class)transformedValueClass
{
	return [NSNumber class];
}

+ (BOOL)allowsReverseTransformation
{
	return NO;
}

- (id)transformedValue:(id)value
{
	if (!value || ![value respondsToSelector:@selector(componentsSeparatedByString:)] || ![value respondsToSelector:@selector(length)])
        return [NSNumber numberWithBool:FALSE];

	if ([(NSString *)value length] < 1)
		return [NSNumber numberWithBool:FALSE];

	NSArray *recipientList = [value componentsSeparatedByString:@"\n"];
	for (NSString *recipient in recipientList)
		if ([recipient length] && !isValidEmail([recipient UTF8String]))
			return [NSNumber numberWithBool:FALSE];

	return [NSNumber numberWithBool:TRUE];
}
@end
