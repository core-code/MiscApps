//
//  ValueTransformer.m
//  MusicWatch
//
//  Created by CoreCode on 20.06.07.
/*	Copyright (c) 2016 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/


#import "ValueTransformer.h"

extern NSImage *newIcon;

@implementation UnseenCountValueTransformer

+ (Class)transformedValueClass
{
	return [NSString class];
}

- (id)transformedValue:(id)value
{	
	NSDecimalNumber *intvalue =[NSDecimalNumber zero];
	if (value == nil) return nil;
	
	if ([value respondsToSelector: @selector(valueForKeyPath:)]) intvalue = [value valueForKeyPath:@"@sum.unseen"];
	else [NSException raise: NSInternalInconsistencyException format: @"Value (%@) does not respond to -valueForKeyPath.", [value class]];
		
	if (intvalue.intValue == 0)
		return @"";
	else
		return intvalue.stringValue;
}
@end

@implementation UnmatchedCountValueTransformer

+ (Class)transformedValueClass
{
	return [NSString class];
}

- (id)transformedValue:(id)value
{	
	NSSet *set;
	
	if (value == nil) return nil;
	  
	if ([value respondsToSelector: @selector(filteredSetUsingPredicate:)]) 
		set = [value filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"id == ''"]];
	else
		[NSException raise: NSInternalInconsistencyException format: @"Value (%@) does not respond to -filteredSetUsingPredicate.", [value class]];
	
	 
	 return [NSString stringWithFormat:@"%li", (unsigned long)set.count];
}
@end

@implementation AlbumColorValueTransformer

+ (Class)transformedValueClass
{
	return [NSColor class];
}

- (id)transformedValue:(id)value
{	
	if (value == nil) return nil;
	
	if (![value respondsToSelector: @selector(valueForKey:)])
		[NSException raise: NSInternalInconsistencyException format: @"Value (%@) does not respond to -valueForKey.", [value class]];
	
	if ([[value valueForKey:@"id"] isEqualToString:@""])
		return [NSColor redColor];
	else
		return [NSColor blackColor];
}
@end

@implementation UnseenIconValueTransformer

+ (Class)transformedValueClass
{
	return [NSImage class];
}

- (id)transformedValue:(id)value
{	
	if (value == nil) return nil;
	
	if (![value respondsToSelector: @selector(intValue)])
		[NSException raise: NSInternalInconsistencyException format: @"Value (%@) does not respond to -intValue.", [value class]];
	
	if ([value intValue] == 1)
		return newIcon;
	else
		return nil;
}
@end

@implementation EmptyValueTransformer

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
	if (!value || ![value respondsToSelector:@selector(length)])
        return [NSNumber numberWithBool:TRUE];
	
	if (((NSString *)value).length < 1)
		return [NSNumber numberWithBool:TRUE];
	else
        return [NSNumber numberWithBool:FALSE];
}
@end