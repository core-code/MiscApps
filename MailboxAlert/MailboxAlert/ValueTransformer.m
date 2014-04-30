//
//  ValueTransformer.m
//  SMARTReporter3
//
//  Created by CoreCode on 12.03.12.
//  Copyright (c) 2012 CoreCode. All rights reserved.
//

#import "ValueTransformer.h"


@implementation LargerthanOneValueTransformer

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
	int val = [value intValue];

	return @(val > 1);
}
@end

@implementation IsNotOneValueTransformer

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
	int val = [value intValue];

	return @(val != 1);
}
@end

@implementation IsOneValueTransformer

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
	int val = [value intValue];

	return @(val == 1);
}
@end

@implementation IsTwoValueTransformer

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
	int val = [value intValue];
    
	return @(val == 2);
}
@end


@implementation OddValueTransformer

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
	int val = [value intValue];

	return @(val % 2 == 1);
}
@end

@implementation EvenValueTransformer

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
	int val = [value intValue];

	return @(val % 2 == 0);
}
@end