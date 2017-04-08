//
//  TimeValueTransformer.m
//  MovieDB
//
//  Created by CoreCode on 07.11.05.
/*	Copyright © 2017 CoreCode Limited
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "ValueTransformer.h"

@implementation TimeValueTransformer

+ (Class)transformedValueClass
{
	return [NSString class];
}

- (id)transformedValue:(id)value
{
	int intvalue = 0;
	
	if (value == nil) return nil;
	
	if ([value respondsToSelector: @selector(intValue)]) intvalue = [value intValue];
	else [NSException raise: NSInternalInconsistencyException format: @"Value (%@) does not respond to -intValue.", [value class]];
	
	if (intvalue == 0) return nil;
	
	/*// this could be optimized if performance becomes an issue - by doing the fucking thing ourselfes
	NSTimeZone *storedTimeZone = [NSTimeZone defaultTimeZone];
	[NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] initWithDateFormat:@"%Hh %Mm %Ss" allowNaturalLanguage:NO];
	NSString *string = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:intvalue]];
	
	[dateFormatter release];
	
	[NSTimeZone setDefaultTimeZone:storedTimeZone];
	
	return string;*/
	
	return [NSString stringWithFormat:@"%im", (intvalue / 60)];
}
@end

@implementation RatingValueTransformer

+ (Class)transformedValueClass
{
	return [NSString class];
}

- (id)transformedValue:(id)value
{
	int intvalue = 0;
	const static unichar u[] = {0x2605, 0x2605, 0x2605, 0x2605, 0x2605};
	if (value == nil) return nil;
	
	if ([value respondsToSelector: @selector(intValue)]) intvalue = [value intValue];
	else [NSException raise: NSInternalInconsistencyException format: @"Value (%@) does not respond to -intValue.", [value class]];
	
	switch (intvalue)
	{
		case 1:
			return [NSString stringWithCharacters:u length:1];
		case 2:
			return [NSString stringWithCharacters:u length:2];
		case 3:
			return [NSString stringWithCharacters:u length:3];
		case 4:
			return [NSString stringWithCharacters:u length:4];
		case 5:
			return [NSString stringWithCharacters:u length:5];
		default:
			return @"";
	}
}
@end


@implementation LanguageValueTransformer

+ (Class)transformedValueClass
{
	return [NSString class];
}

- (instancetype)init
{
	self = [super init];
	
	NSString *languages = [NSString stringWithContentsOfFile:[[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"language_list.txt"] encoding:NSUTF8StringEncoding error:NULL];
	
	NSMutableArray *ma = [NSMutableArray arrayWithArray:[languages componentsSeparatedByString:@"\n"]];
	[ma insertObject:@"" atIndex:5];
	la = [[NSArray alloc] initWithArray:ma];
	
	return self;
}


- (id)transformedValue:(id)value
{
	int intvalue = 0;
	
	if (value == nil)	return nil;
	
	if ([value respondsToSelector: @selector(intValue)]) intvalue = [value intValue];
	else [NSException raise: NSInternalInconsistencyException format: @"Value (%@) does not respond to -intValue.", [value class]];
	
	if (intvalue == 0)
		return nil;
	
	return la[intvalue-1];
}
@end

@implementation SizeValueTransformer

+ (Class)transformedValueClass
{
	return [NSString class];
}

- (id)transformedValue:(id)value
{
	NSInteger intvalue = 0;
	
	if (value == nil) return nil;
	
	if ([value respondsToSelector: @selector(integerValue)]) intvalue = [value integerValue];
	else [NSException raise: NSInternalInconsistencyException format: @"Value (%@) does not respond to -integerValue.", [value class]];
	//NSLog([value stringValue]);
	//NSLog([NSString stringWithFormat:@"%i MB", (int) (intvalue / 1048576)]);
	if (intvalue == 0)	return nil;
	else				return [NSString stringWithFormat:@"%iMB", (int) (intvalue / 1024)];
}
@end

@implementation TitleLinkValueTransformer

+ (Class)transformedValueClass
{
	return [NSAttributedString class];
}

- (id)transformedValue:(id)obj
{
	if (obj == nil) return nil;
	
	if (![obj respondsToSelector: @selector(valueForKey:)])
		[NSException raise: NSInternalInconsistencyException format: @"Value (%@) does not respond to -valueForKey.", [obj class]];
		
	NSString *title = [obj valueForKey:@"imdb_title"];
	NSString *imdb_id =  [obj valueForKey:@"imdb_id"];
	
	if (!title) return nil;
	if (!imdb_id) return [[NSAttributedString alloc] initWithString:title];
	
	NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:title];
	NSRange selectedRange = NSMakeRange(0, string.length);
	
	[string beginEditing];
	[string addAttribute:NSLinkAttributeName
				   value:[NSURL URLWithString:[[NSString stringWithFormat:@"http://www.imdb.com/title/%@/", imdb_id.stringValue] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
				   range:selectedRange];
	[string addAttribute:NSForegroundColorAttributeName
				   value:[NSColor blueColor]
				   range:selectedRange];
	[string addAttribute:NSUnderlineStyleAttributeName
				   value:@(NSUnderlineStyleSingle)
				   range:selectedRange];
	[string endEditing];
	
	return [[NSAttributedString alloc] initWithAttributedString:string];
}
@end

@implementation PeopleLinkValueTransformer

+ (Class)transformedValueClass
{
	return [NSAttributedString class];
}

+ (BOOL)allowsReverseTransformation
{
	return NO;//YES;
}

- (id)transformedValue:(id)value
{
	if (value == nil) return nil;
	
	NSString *component;
	NSArray *components = [value componentsSeparatedByString:@", "];
	NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
	
	for (component in components)
	{
		NSMutableAttributedString *substring = [[NSMutableAttributedString alloc] initWithString:component];
		NSRange selectedRange = NSMakeRange(0, substring.length);

        component = [component componentsSeparatedByString:@" ("][0];

		[substring beginEditing];
		[substring addAttribute:NSLinkAttributeName
						  value:[NSURL URLWithString:[[NSString stringWithFormat:@"http://www.imdb.com/find?s=nm&q=%@", component] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
						  range:selectedRange];
		[substring addAttribute:NSForegroundColorAttributeName
						  value:[NSColor blueColor]
						  range:selectedRange];
		[substring addAttribute:NSUnderlineStyleAttributeName
						  value:@(NSUnderlineStyleSingle)
						  range:selectedRange];
		[substring endEditing];
		
		if (string.length > 0)
			[string appendAttributedString:[[NSAttributedString alloc] initWithString:@", "]];
		
		[string appendAttributedString:substring];				
		
	}
	
	return string;
}
/*
- (id)reverseTransformedValue:(id)value
{
	if (value == nil) return nil;
	
	return [value string];
}*/
@end

@implementation CastLinkValueTransformer

+ (Class)transformedValueClass
{
	return [NSAttributedString class];
}

+ (BOOL)allowsReverseTransformation
{
	return NO; // YES;
}

- (id)transformedValue:(id)value
{
	if (value == nil) return nil;
	
	NSString *component;
	NSArray *components = [value componentsSeparatedByString:@"\n"];
	NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
	
	for (component in components)
	{
		NSArray *subcomponents = [component componentsSeparatedByString:@" ("];
		NSMutableAttributedString *substring = [[NSMutableAttributedString alloc] initWithString:subcomponents[0]];
		NSRange selectedRange = NSMakeRange(0, substring.length);
		
		[substring beginEditing];
		[substring addAttribute:NSLinkAttributeName
						  value:[NSURL URLWithString:[[NSString stringWithFormat:@"http://www.imdb.com/find?s=nm&q=%@", subcomponents[0]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
						  range:selectedRange];
		[substring addAttribute:NSForegroundColorAttributeName
						  value:[NSColor blueColor]
						  range:selectedRange];
		[substring addAttribute:NSUnderlineStyleAttributeName
						  value:@(NSUnderlineStyleSingle)
						  range:selectedRange];
		[substring endEditing];
		
		if (string.length > 0)
			[string.mutableString appendString:@"\n"];
		
		[string appendAttributedString:substring];
		
		if (subcomponents.count > 1)
		{
			[string appendAttributedString:[[NSAttributedString alloc] initWithString:@" ("]];
			[string.mutableString appendString:subcomponents[1]];			
		}
		
	}
	
	return string;
}
/*
- (id)reverseTransformedValue:(id)value
{
	if (value == nil) return nil;
	
	return [value string];
}*/
@end

@implementation YearLinkValueTransformer

+ (Class)transformedValueClass
{
	return [NSAttributedString class];
}

+ (BOOL)allowsReverseTransformation
{
	return NO;//YES;
}

- (id)transformedValue:(id)value
{
	if (value == nil) return nil;
	
	NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[value stringValue]];
	NSRange selectedRange = NSMakeRange(0, string.length);
	
	[string beginEditing];
	[string addAttribute:NSLinkAttributeName
				   value:[NSURL URLWithString:[[NSString stringWithFormat:@"http://imdb.com/Sections/Years/%@/", value] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
				   range:selectedRange];
	[string addAttribute:NSForegroundColorAttributeName
				   value:[NSColor blueColor]
				   range:selectedRange];
	[string addAttribute:NSUnderlineStyleAttributeName
				   value:@(NSUnderlineStyleSingle)
				   range:selectedRange];
	[string endEditing];
	
	return [[NSAttributedString alloc] initWithAttributedString:string];
}
/*
- (id)reverseTransformedValue:(id)value
{
	if (value == nil) return nil;
	
	return [value string];
}*/
@end

@implementation RatingLinkValueTransformer

+ (Class)transformedValueClass
{
	return [NSAttributedString class];
}

+ (BOOL)allowsReverseTransformation
{
	return NO;//YES;
}

- (id)transformedValue:(id)value
{
	if (value == nil) return nil;
	
	NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%1.1f", [value floatValue]]];
	NSRange selectedRange = NSMakeRange(0, string.length);
	NSString *lower;
	NSString *higher;
	
	if (fmodf([value floatValue], 1.0) > 0.5)
	{
		lower = [@((int)[value floatValue]).stringValue stringByAppendingString:@".5"];
		higher = @(((int)[value floatValue]) + 1).stringValue;
	}
	else
	{
		lower = @((int)[value floatValue]).stringValue;
		higher = [lower stringByAppendingString:@".5"];
	}
	
	
	[string beginEditing];
	[string addAttribute:NSLinkAttributeName
				   value:[NSURL URLWithString:[[NSString stringWithFormat:@"http://www.imdb.com/List?hi-rating=%@&&lo-rating=%@", higher, lower] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
				   range:selectedRange];
	[string addAttribute:NSForegroundColorAttributeName
				   value:[NSColor blueColor]
				   range:selectedRange];
	[string addAttribute:NSUnderlineStyleAttributeName
				   value:@(NSUnderlineStyleSingle)
				   range:selectedRange];
	[string endEditing];
	
	return [[NSAttributedString alloc] initWithAttributedString:string];
}
/*
- (id)reverseTransformedValue:(id)value
{
	if (value == nil) return nil;
	
	return [value string];
}*/
@end

@implementation GenreLinkValueTransformer

+ (Class)transformedValueClass
{
	return [NSAttributedString class];
}

+ (BOOL)allowsReverseTransformation
{
	return NO;//YES;
}

- (id)transformedValue:(id)value
{
	if (value == nil) return nil;
	
	NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:value];
	int index = 0;
	
	for (NSString *component in [value componentsSeparatedByString:@" | "])
	{
		NSRange selectedRange = NSMakeRange(index, component.length);
		
		[string beginEditing];
		[string addAttribute:NSLinkAttributeName
					   value:[NSURL URLWithString:[[NSString stringWithFormat:@"http://www.imdb.com/Sections/Genres/%@/", component] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
					   range:selectedRange];
		[string addAttribute:NSForegroundColorAttributeName
					   value:[NSColor blueColor]
					   range:selectedRange];
		[string addAttribute:NSUnderlineStyleAttributeName
					   value:@(NSUnderlineStyleSingle)
					   range:selectedRange];
		[string endEditing];
		
		index += component.length + 3;
	}
	
	
	return [[NSAttributedString alloc] initWithAttributedString:string];
}
/*
- (id)reverseTransformedValue:(id)value
{
	if (value == nil) return nil;
	
	return [value string];
}*/
@end

@implementation ImageDataValueTransformer

+ (Class)transformedValueClass
{
	return [NSImage class];
}

+ (BOOL)allowsReverseTransformation
{
	return NO;
}

- (id)transformedValue:(id)value
{
	if ((value == nil) || (![value isKindOfClass:[NSData class]])) return nil;
		

	NSImage *image = [[NSImage alloc] initWithData:value];
	
	if (image)
		return image;
	else 
		return nil;
}
@end

@implementation AudioCodecValueTransformer

+ (Class)transformedValueClass
{
	return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
	return NO;
}

- (id)transformedValue:(id)value
{
	NSDictionary *dict = @{@"85": @"MP3", @"80": @"MP3", @"8192": @"AC3", @"8193": @"DTS", @"353": @"WMA2", @"1": @"PCM", @"2": @"ADPCM", @"17": @"ADPCM"};
	if (value == nil) return nil;
	
	if (dict[value])
		return dict[value];
	else
		return [value uppercaseString];
}
@end