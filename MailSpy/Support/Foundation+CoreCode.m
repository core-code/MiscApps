//
//  Foundation+CoreCode.m
//  CoreLib
//
//  Created by CoreCode on 15.03.12.
/*	Copyright © 2018 CoreCode Limited
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */


#import "Foundation+CoreCode.h"
#import <objc/runtime.h>
#ifdef USE_SECURITY
	#include <CommonCrypto/CommonDigest.h>
#endif
#ifdef USE_SNAPPY
	#import <snappy/snappy-c.h>
#endif

#if ! __has_feature(objc_arc)
	#define BRIDGE
#else
	#define BRIDGE __bridge
#endif
static CONST_KEY(CoreCodeAssociatedValue)



@implementation NSArray (CoreCode)

@dynamic mutableObject, empty, set, reverseArray, string, path, sorted;

- (NSArray *)sorted
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wselector"
	return [self sortedArrayUsingSelector:@selector(compare:)];
#pragma clang diagnostic pop
}

#if (MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_7) || (__IPHONE_OS_VERSION_MIN_REQUIRED >= 50000)
@dynamic JSONData;

- (NSData *)JSONData
{
    NSError *err;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:(NSJSONWritingOptions)0 error:&err];

    if (!data || err)
    {
        NSLog(@"Error: JSON write fails! input %@ data %@ err %@", self, data, err);
        return nil;
    }

    return data;
}
#endif

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu-statement-expression"

- (CGRect)calculateExtentsOfPoints:(ObjectInPointOutBlock)block
{
	CGPoint min = CGPointMake(INT_MAX, INT_MAX);
	CGPoint max = CGPointMake(INT_MIN, INT_MIN);

	for (NSObject *o in self)
	{
		CGPoint p = block(o);

		max.x = MAX(max.x, p.x);
		max.y = MAX(max.y, p.y);
		min.x = MIN(min.x, p.x);
		min.y = MIN(min.y, p.y);
	}

	return CGRectMake(min.x,min.y,max.x - min.x,max.y-min.y);
}

- (NSRange)calculateExtentsOfValues:(ObjectInIntOutBlock)block
{
	int min = INT_MAX, max = INT_MIN;

	for (NSObject *o in self)
	{
		int p = block(o);

		min = MIN(min, p);
		max = MAX(max, p);
	}

	return NSMakeRange(min, max-min);
}

#pragma clang diagnostic pop

- (NSString *)string
{
	NSString *ret = @"";

	for (NSString *str in self)
		ret = [ret stringByAppendingString:str];

	return ret;
}

- (NSString *)path
{
	NSString *ret = @"";
	
	for (NSString *str in self)
		ret = [ret stringByAppendingPathComponent:str];

	return ret;
}

- (BOOL)contains:(id)object
{
	return [self indexOfObject:object] != NSNotFound;
}

- (NSArray *)reverseArray
{
	return [[self reverseObjectEnumerator] allObjects];
}

- (NSSet *)set
{
	return [NSSet setWithArray:self];
}

- (NSArray *)arrayByAddingNewObject:(id)anObject
{
	if ([self indexOfObject:anObject] == NSNotFound)
		return [self arrayByAddingObject:anObject];
	else
		return self;
}

- (NSArray *)arrayByRemovingObjectIdenticalTo:(id)anObject
{
	NSMutableArray *array = [NSMutableArray arrayWithArray:self];

	[array removeObjectIdenticalTo:anObject];

	return [NSArray arrayWithArray:array];
}

- (NSArray *)arrayByRemovingObjectsIdenticalTo:(NSArray *)objects
{
	NSMutableArray *array = [NSMutableArray arrayWithArray:self];

    for (id obj in objects)
        [array removeObjectIdenticalTo:obj];

	return [NSArray arrayWithArray:array];
}

- (NSArray *)arrayByRemovingObjectsAtIndexes:(NSIndexSet *)indexSet
{
	NSMutableArray *array = [NSMutableArray arrayWithArray:self];

	[array removeObjectsAtIndexes:indexSet];

	return [NSArray arrayWithArray:array];
}

- (NSArray *)arrayByRemovingObjectAtIndex:(NSUInteger)index
{
	NSMutableArray *array = [NSMutableArray arrayWithArray:self];

	[array removeObjectAtIndex:index];

	return [NSArray arrayWithArray:array];
}

- (NSArray *)arrayByReplacingObject:(id)anObject withObject:(id)newObject
{
	NSMutableArray *mut = self.mutableObject;

	mut[[mut indexOfObject:anObject]] = newObject;

	return mut.immutableObject;
}

- (id)safeObjectAtIndex:(NSUInteger)index
{
    if ([self count] > index)
        return self[index];
    else
        return nil;
}

- (NSString *)safeStringAtIndex:(NSUInteger)index
{
    if ([self count] > index)
        return self[index];
    else
        return @"";
}

- (BOOL)containsDictionaryWithKey:(NSString *)key equalTo:(NSString *)value
{
	for (NSDictionary *dict in self)
		if ([[dict valueForKey:key] isEqual:value])
			return TRUE;

	return FALSE;
}

- (NSArray *)sortedArrayByKey:(NSString *)key
{
	return [self sortedArrayByKey:key ascending:YES];
}

- (NSArray *)sortedArrayByKey:(NSString *)key ascending:(BOOL)ascending
{
	NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:key ascending:ascending];
#if ! __has_feature(objc_arc)
	[sd autorelease];
#endif
	return [self sortedArrayUsingDescriptors:@[sd]];
}

- (NSMutableArray *)mutableObject
{
	return [NSMutableArray arrayWithArray:self];
}

- (BOOL)empty
{
	return [self count] == 0;
}

- (NSArray *)mapped:(ObjectInOutBlock)block
{
    NSMutableArray *resultArray = [NSMutableArray new];

    for (id object in self)
	{
		id result = block(object);
		if (result)
			[resultArray addObject:result];
	}
#if ! __has_feature(objc_arc)
	[resultArray autorelease];
#endif

    return [NSArray arrayWithArray:resultArray];
}

- (NSInteger)collect:(ObjectInIntOutBlock)block
{
    NSInteger value = 0;

    for (id object in self)
        value += block(object);

    return value;
}

- (NSArray *)filtered:(ObjectInIntOutBlock)block
{
    NSMutableArray *resultArray = [NSMutableArray new];

    for (id object in self)
        if (block(object))
            [resultArray addObject:object];

#if ! __has_feature(objc_arc)
	[resultArray autorelease];
#endif

    return [NSArray arrayWithArray:resultArray];
}

- (void)apply:(ObjectInBlock)block								// enumerateObjectsUsingBlock:
{
    for (id object in self)
		block(object);
}

// forwards for less typing
- (NSString *)joined:(NSString *)sep							// componentsJoinedByString:
{
	return [self componentsJoinedByString:sep];
}

- (NSArray *)filteredUsingPredicateString:(NSString *)format, ...
{
	va_list args;
	va_start(args, format);
	NSPredicate *pred = [NSPredicate predicateWithFormat:format arguments:args];
	va_end(args);

	return [self filteredArrayUsingPredicate:pred];
}


#if defined(TARGET_OS_MAC) && TARGET_OS_MAC && !TARGET_OS_IPHONE
- (NSString *)runAsTask
{
	return [self runAsTaskWithTerminationStatus:NULL];
}

- (NSString *)runAsTaskWithTerminationStatus:(NSInteger *)terminationStatus
{
	NSTask *task = [NSTask new];
	NSPipe *taskPipe = [NSPipe pipe];
	NSFileHandle *file = [taskPipe fileHandleForReading];

	[task setLaunchPath:self[0]];
	[task setStandardOutput:taskPipe];
	[task setStandardError:taskPipe];
	[task setArguments:[self subarrayWithRange:NSMakeRange(1, self.count-1)]];
	[task launch];

	NSData *data = [file readDataToEndOfFile];

	[task waitUntilExit];

	NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];


	if (terminationStatus)
		(*terminationStatus) = [task terminationStatus];

#if ! __has_feature(objc_arc)
	[task release];
	[string autorelease];
#endif

	return string;
}
#endif
@end


@implementation  NSMutableArray (CoreCode)

@dynamic immutableObject;

- (void)moveObjectAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
	id object = self[fromIndex];
	[self removeObjectAtIndex:fromIndex];
	[self insertObject:object atIndex:(fromIndex < toIndex) ? toIndex - 1 : toIndex];
}

- (void)removeObjectPassingTest:(ObjectInIntOutBlock)block
{
	NSInteger idx = [self indexOfObjectPassingTest:^BOOL(id obj, NSUInteger i, BOOL *s)
	{
		int res = block(obj);
		return (BOOL)res;
	}];

	[self removeObjectAtIndex:idx];
}

- (NSArray *)immutableObject
{
	return [NSArray arrayWithArray:self];
}

- (void)addNewObject:(id)anObject
{
	if (anObject && [self indexOfObject:anObject] == NSNotFound)
		[self addObject:anObject];
}

- (void)addObjectSafely:(id)anObject
{
	if (anObject)
		[self addObject:anObject];
}

- (void)map:(ObjectInOutBlock)block
{
    for (NSUInteger i = 0; i < [self count]; i++)
	{
		id result = block(self[i]);

		self[i] = result;
	}
}

- (void)filter:(ObjectInIntOutBlock)block
{
    NSMutableIndexSet *indices = [NSMutableIndexSet new];

    for (NSUInteger i = 0; i < [self count]; i++)
	{
		int result = block(self[i]);
		if (!result)
			[indices addIndex:i];
	}


	[self removeObjectsAtIndexes:indices];

#if ! __has_feature(objc_arc)
	[indices release];
#endif
}

- (void)filterUsingPredicateString:(NSString *)format, ...
{
	va_list args;
	va_start(args, format);
	NSPredicate *pred = [NSPredicate predicateWithFormat:format arguments:args];
	va_end(args);

	[self filterUsingPredicate:pred];
}

- (void)removeFirstObject
{
	[self removeObjectAtIndex:0];
}
@end



@implementation NSData (CoreCode)

@dynamic string, hexString, mutableObject;
#ifdef USE_SECURITY
@dynamic SHA1;
#endif


#ifdef USE_SECURITY
- (NSString *)SHA1
{
	const char *cStr = [self bytes];
	unsigned char result[CC_SHA1_DIGEST_LENGTH];
	CC_SHA1(cStr, (CC_LONG)[self length], result);
	NSString *s = [NSString  stringWithFormat:
				   @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
				   result[0], result[1], result[2], result[3], result[4],
				   result[5], result[6], result[7],
				   result[8], result[9], result[10], result[11], result[12],
				   result[13], result[14], result[15],
				   result[16], result[17], result[18], result[19]
				   ];

    return s;
}
#endif

#ifdef USE_SNAPPY
@dynamic snappyCompressed, snappyDecompressed;

- (NSData *)snappyDecompressed
{
    size_t uncompressedSize = 0;

    if( snappy_uncompressed_length(self.bytes, self.length, &uncompressedSize) != SNAPPY_OK )
	{
		NSLog(@"Error: can't calculate the uncompressed length!\n");
		return nil;
    }

    assert(uncompressedSize);

    char *buf = (char *)malloc(uncompressedSize);
    assert(buf);


	int res = snappy_uncompress(self.bytes, self.length, buf, &uncompressedSize);
    if(res != SNAPPY_OK)
	{
        NSLog(@"Error: can't uncompress the file!\n");
		free(buf);
		return nil;
    }


	NSData *d = [NSData dataWithBytesNoCopy:buf length:uncompressedSize];
#if ! __has_feature(objc_arc)
	[d autorelease];
#endif
	return d;
}

- (NSData *)snappyCompressed
{
	size_t output_length = snappy_max_compressed_length(self.length);
	char *buf = (char*)malloc(output_length);
    assert(buf);

	int res = snappy_compress(self.bytes, self.length, buf, &output_length);
	if (res != SNAPPY_OK )
	{
		NSLog(@"Error: problem compressing the file\n");
		free(buf);
		return nil;
	}

	NSData *d = [NSData dataWithBytesNoCopy:buf length:output_length];
#if ! __has_feature(objc_arc)
	[d autorelease];
#endif
	return d;
}
#endif

- (NSString *)string
{
	for (NSNumber *num in @[@(NSUTF8StringEncoding), @(NSUTF16StringEncoding), @(NSISOLatin1StringEncoding), @(NSASCIIStringEncoding)])
	{
		NSString *s = [[NSString alloc] initWithData:self encoding:num.integerValue];

		if (!s)
			continue;
	#if ! __has_feature(objc_arc)
		[s autorelease];
	#endif
		return s;
	}

	NSLog(@"Error: could not create string from data %@", self);
	return nil;
}

- (NSString *)hexString
{
    const unsigned char *dataBuffer = (const unsigned char *)[self bytes];

    if (!dataBuffer)
        return [NSString string];

    NSUInteger          dataLength  = [self length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];

    for (NSUInteger i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];

    return [NSString stringWithString:hexString];
}

- (NSMutableData *)mutableObject
{
	return [NSMutableData dataWithData:self];
}

#if (MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_7) || (__IPHONE_OS_VERSION_MIN_REQUIRED >= 50000)
@dynamic JSONArray, JSONDictionary;
- (id)JSONObject
{
    NSError *err;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:self options:(NSJSONReadingOptions)0 error:&err];

    if (!dict || err)
    {
        NSLog(@"Error: JSON read fails! input %@ dict %@ err %@", self, dict, err);
        return nil;
    }

    return dict;
}

- (NSArray *)JSONArray
{
    id res = [self JSONObject];

	if (![res isKindOfClass:[NSArray class]])
	{
        NSLog(@"Error: JSON read fails! input is class %@ instead of array", [[res class] description]);
        return nil;
    }

	return res;
}

- (NSDictionary *)JSONDictionary
{
    id res = [self JSONObject];

	if (![res isKindOfClass:[NSDictionary class]])
	{
        NSLog(@"Error: JSON read fails! input is class %@ instead of dictionary", [[res class] description]);
        return nil;
    }

	return res;
}
#endif

@end



@implementation NSDate (CoreCode)

+ (NSDate *)dateWithString:(NSString *)dateString format:(NSString *)dateFormat localeIdentifier:(NSString *)localeIdentifier
{
	NSDateFormatter *df = [NSDateFormatter new];
	[df setDateFormat:dateFormat];
	NSLocale *l = [[NSLocale alloc] initWithLocaleIdentifier:localeIdentifier];
	[df setLocale:l];
#if ! __has_feature(objc_arc)
	[l release];
	[df autorelease];
#endif
	return [df dateFromString:dateString];
}

+ (NSDate *)dateWithString:(NSString *)dateString format:(NSString *)dateFormat
{
	return [self dateWithString:dateString format:dateFormat localeIdentifier:@"en_US"];
}

+ (NSDate *)dateWithPreprocessorDate:(const char *)preprocessorDateString
{
	return [self dateWithString:@(preprocessorDateString) format:@"MMM d yyyy"];
}

- (NSString *)stringUsingFormat:(NSString *)dateFormat
{
    NSDateFormatter *df = [NSDateFormatter new];
	NSLocale *l = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[df setLocale:l];
    [df setDateFormat:dateFormat];
#if ! __has_feature(objc_arc)
	[l release];
	[df autorelease];
#endif
    return [df stringFromDate:self];
}

- (NSString *)stringUsingDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle
{
    NSDateFormatter *df = [NSDateFormatter new];

	[df setLocale:[NSLocale currentLocale]];
    [df setDateStyle:dateStyle];
    [df setTimeStyle:timeStyle];
#if ! __has_feature(objc_arc)
	[df autorelease];
#endif
    return [df stringFromDate:self];
}

@end


@implementation NSDateFormatter (CoreCode)

+ (NSString *)formattedTimeFromTimeInterval:(NSTimeInterval)timeInterval
{
	int minutes = (int)(timeInterval / 60);
	int seconds = (int)(timeInterval - (minutes * 60));


	if (minutes)
		return makeString(@"%im %is", minutes, seconds);
	else
		return makeString(@"%is", (int)timeInterval);
}

@end



@implementation NSDictionary (CoreCode)

@dynamic mutableObject;
#if (MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_7) || (__IPHONE_OS_VERSION_MIN_REQUIRED >= 50000)
@dynamic JSONData;

- (NSData *)JSONData
{
    NSError *err;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:(NSJSONWritingOptions)0 error:&err];

    if (!data || err)
    {
        NSLog(@"Error: JSON write fails! input %@ data %@ err %@", self, data, err);
        return nil;
    }

    return data;
}
#endif


- (NSMutableDictionary *)mutableObject
{
	return [NSMutableDictionary dictionaryWithDictionary:self];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wselector"
	return [super methodSignatureForSelector:@selector(valueForKey:)];
#pragma clang diagnostic pop
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    NSString *propertyName = NSStringFromSelector(invocation.selector);
    [invocation setSelector:@selector(valueForKey:)];
    [invocation setArgument:&propertyName atIndex:2];
    [invocation invokeWithTarget:self];
}

- (NSDictionary *)dictionaryByAddingValue:(id)value forKey:(NSString *)key
{
	NSMutableDictionary *mutable = self.mutableObject;

	mutable[key] = value;

	return mutable.immutableObject;
}

- (NSDictionary *)dictionaryByRemovingKey:(NSString *)key
{
	NSMutableDictionary *mutable = self.mutableObject;

	[mutable removeObjectForKey:key];

	return mutable.immutableObject;
}

- (NSDictionary *)dictionaryByRemovingKeys:(NSStringArray *)keys
{
	NSMutableDictionary *mutable = self.mutableObject;

	for (NSString *key in keys)
		[mutable removeObjectForKey:key];

	return mutable.immutableObject;
}

@end


@implementation  NSMutableDictionary (CoreCode)

@dynamic immutableObject;

- (NSDictionary *)immutableObject
{
	return [NSDictionary dictionaryWithDictionary:self];
}
@end



@implementation NSFileHandle (CoreCode)

- (float)readFloat
{
    float ret;
    [[self readDataOfLength:sizeof(float)] getBytes:&ret length:sizeof(float)];
    return ret;
}

- (int)readInt
{
    int ret;
    [[self readDataOfLength:sizeof(int)] getBytes:&ret length:sizeof(int)];
    return ret;
}
@end



@implementation NSLocale (CoreCode)

+ (NSArray *)preferredLanguages3Letter
{
	NSDictionary *iso2LetterTo3Letter = @{@"aa" : @"aar", @"ab" : @"abk", @"ae" : @"ave", @"af" : @"afr", @"ak" : @"aka", @"am" : @"amh", @"an" : @"arg", @"ar" : @"ara", @"as" : @"asm", @"av" : @"ava", @"ay" : @"aym", @"az" : @"aze", @"ba" : @"bak", @"be" : @"bel", @"bg" : @"bul", @"bh" : @"bih", @"bi" : @"bis", @"bm" : @"bam", @"bn" : @"ben", @"bo" : @"tib", @"bo" : @"tib", @"br" : @"bre", @"bs" : @"bos", @"ca" : @"cat", @"ce" : @"che", @"ch" : @"cha", @"co" : @"cos", @"cr" : @"cre", @"cs" : @"cze", @"cs" : @"cze", @"cu" : @"chu", @"cv" : @"chv", @"cy" : @"wel", @"cy" : @"wel", @"da" : @"dan", @"de" : @"ger", @"de" : @"ger", @"dv" : @"div", @"dz" : @"dzo", @"ee" : @"ewe", @"el" : @"gre", @"el" : @"gre", @"en" : @"eng", @"eo" : @"epo", @"es" : @"spa", @"et" : @"est", @"eu" : @"baq", @"eu" : @"baq", @"fa" : @"per", @"fa" : @"per", @"ff" : @"ful", @"fi" : @"fin", @"fj" : @"fij", @"fo" : @"fao", @"fr" : @"fre", @"fr" : @"fre", @"fy" : @"fry", @"ga" : @"gle", @"gd" : @"gla", @"gl" : @"glg", @"gn" : @"grn", @"gu" : @"guj", @"gv" : @"glv", @"ha" : @"hau", @"he" : @"heb", @"hi" : @"hin", @"ho" : @"hmo", @"hr" : @"hrv", @"ht" : @"hat", @"hu" : @"hun", @"hy" : @"arm", @"hy" : @"arm", @"hz" : @"her", @"ia" : @"ina", @"id" : @"ind", @"ie" : @"ile", @"ig" : @"ibo", @"ii" : @"iii", @"ik" : @"ipk", @"io" : @"ido", @"is" : @"ice", @"is" : @"ice", @"it" : @"ita", @"iu" : @"iku", @"ja" : @"jpn", @"jv" : @"jav", @"ka" : @"geo", @"ka" : @"geo", @"kg" : @"kon", @"ki" : @"kik", @"kj" : @"kua", @"kk" : @"kaz", @"kl" : @"kal", @"km" : @"khm", @"kn" : @"kan", @"ko" : @"kor", @"kr" : @"kau", @"ks" : @"kas", @"ku" : @"kur", @"kv" : @"kom", @"kw" : @"cor", @"ky" : @"kir", @"la" : @"lat", @"lb" : @"ltz", @"lg" : @"lug", @"li" : @"lim", @"ln" : @"lin", @"lo" : @"lao", @"lt" : @"lit", @"lu" : @"lub", @"lv" : @"lav", @"mg" : @"mlg", @"mh" : @"mah", @"mi" : @"mao", @"mi" : @"mao", @"mk" : @"mac", @"mk" : @"mac", @"ml" : @"mal", @"mn" : @"mon", @"mr" : @"mar", @"ms" : @"may", @"ms" : @"may", @"mt" : @"mlt", @"my" : @"bur", @"my" : @"bur", @"na" : @"nau", @"nb" : @"nob", @"nd" : @"nde", @"ne" : @"nep", @"ng" : @"ndo", @"nl" : @"dut", @"nl" : @"dut", @"nn" : @"nno", @"no" : @"nor", @"nr" : @"nbl", @"nv" : @"nav", @"ny" : @"nya", @"oc" : @"oci", @"oj" : @"oji", @"om" : @"orm", @"or" : @"ori", @"os" : @"oss", @"pa" : @"pan", @"pi" : @"pli", @"pl" : @"pol", @"ps" : @"pus", @"pt" : @"por", @"qu" : @"que", @"rm" : @"roh", @"rn" : @"run", @"ro" : @"rum", @"ro" : @"rum", @"ru" : @"rus", @"rw" : @"kin", @"sa" : @"san", @"sc" : @"srd", @"sd" : @"snd", @"se" : @"sme", @"sg" : @"sag", @"si" : @"sin", @"sk" : @"slo", @"sk" : @"slo", @"sl" : @"slv", @"sm" : @"smo", @"sn" : @"sna", @"so" : @"som", @"sq" : @"alb", @"sq" : @"alb", @"sr" : @"srp", @"ss" : @"ssw", @"st" : @"sot", @"su" : @"sun", @"sv" : @"swe", @"sw" : @"swa", @"ta" : @"tam", @"te" : @"tel", @"tg" : @"tgk", @"th" : @"tha", @"ti" : @"tir", @"tk" : @"tuk", @"tl" : @"tgl", @"tn" : @"tsn", @"to" : @"ton", @"tr" : @"tur", @"ts" : @"tso", @"tt" : @"tat", @"tw" : @"twi", @"ty" : @"tah", @"ug" : @"uig", @"uk" : @"ukr", @"ur" : @"urd", @"uz" : @"uzb", @"ve" : @"ven", @"vi" : @"vie", @"vo" : @"vol", @"wa" : @"wln", @"wo" : @"wol", @"xh" : @"xho", @"yi" : @"yid", @"yo" : @"yor", @"za" : @"zha", @"zh" : @"chi", @"zh" : @"chi", @"zu" : @"zul"};

	NSMutableArray *tmp = [NSMutableArray new];
	for (NSString *l in [NSLocale  preferredLanguages])
		[tmp addObject:(iso2LetterTo3Letter[l] ? iso2LetterTo3Letter[l] : l)];

#if ! __has_feature(objc_arc)
	[tmp autorelease];
#endif

	return [NSArray arrayWithArray:tmp];
}

@end



@implementation NSObject (CoreCode)

@dynamic associatedValue, id;

- (void)setAssociatedValue:(id)value forKey:(NSString *)key
{
#if	TARGET_OS_IPHONE
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-objc-pointer-introspection"
	BOOL is64Bit = sizeof(void *) == 8;
	BOOL isTagged = ((uintptr_t)self & 0x1);
	assert(!(is64Bit && isTagged)); // associated values on tagged pointers broken on 64 bit iOS
#pragma clang diagnostic pop
#endif

    objc_setAssociatedObject(self, (BRIDGE const void *)(key), value, OBJC_ASSOCIATION_RETAIN);
}

- (id)associatedValueForKey:(NSString *)key
{
    return objc_getAssociatedObject(self, (BRIDGE const void *)(key));
}

- (void)setAssociatedValue:(id)value
{
    [self setAssociatedValue:value forKey:kCoreCodeAssociatedValueKey];
}

- (id)associatedValue
{
    return [self associatedValueForKey:kCoreCodeAssociatedValueKey];
}

+ (instancetype)newWith:(NSDictionary *)dict
{
	NSObject *obj = [self new];
	for (NSString *key in dict)
	{
		[obj setValue:dict[key] forKey:key];
	}

	return obj;
}

- (id)id
{
    return (id)self;
}
@end



@implementation NSString (CoreCode)

@dynamic words, lines, trimmedOfWhitespace, trimmedOfWhitespaceAndNewlines, URL, fileURL, download, resourceURL, resourcePath, localized, defaultObject, defaultString, defaultInt, defaultFloat, defaultURL, dirContents, dirContentsRecursive, dirContentsAbsolute, dirContentsRecursiveAbsolute, fileExists, uniqueFile, expanded, defaultArray, defaultDict, isWriteablePath, fileSize, directorySize, contents, dataFromHexString, escaped, encoded, namedImage,  isIntegerNumber, isFloatNumber, data;

#if defined(TARGET_OS_MAC) && TARGET_OS_MAC && !TARGET_OS_IPHONE
@dynamic fileIsAlias, fileAliasTarget;
#endif

#ifdef USE_SECURITY
@dynamic SHA1;
#endif

#if defined(TARGET_OS_MAC) && TARGET_OS_MAC && !TARGET_OS_IPHONE
- (NSImage *)namedImage
{
	NSImage *image = [NSImage imageNamed:self];
	return image;
}
#else
- (UIImage *)namedImage
{
	UIImage *image = [UIImage imageNamed:self];
	return image;
}
#endif

#if defined(TARGET_OS_MAC) && TARGET_OS_MAC && !TARGET_OS_IPHONE
- (BOOL)fileIsAlias
{
    NSURL *url = [NSURL fileURLWithPath:self];
    CFURLRef cfurl = (BRIDGE CFURLRef) url;
    CFBooleanRef aliasBool = kCFBooleanFalse;
    BOOL success = CFURLCopyResourcePropertyForKey(cfurl, kCFURLIsAliasFileKey, &aliasBool, NULL);
    BOOL alias = CFBooleanGetValue(aliasBool);

    return alias && success;
}

- (NSString *)fileAliasTarget
{
	CFErrorRef *err = NULL;
	CFDataRef bookmark = CFURLCreateBookmarkDataFromFile(NULL, (BRIDGE CFURLRef)self.fileURL, err);
	if (bookmark == nil)
		return nil;
	CFURLRef url = CFURLCreateByResolvingBookmarkData (NULL, bookmark, kCFBookmarkResolutionWithoutUIMask, NULL, NULL, NULL, err);
	__autoreleasing NSURL *nurl = [(BRIDGE NSURL *)url copy];
	CFRelease(bookmark);
	CFRelease(url);
#if  !__has_feature(objc_arc)
	[nurl autorelease];
#endif
	return [nurl path];

}

- (CGSize)sizeUsingFont:(NSFont *)font maxWidth:(float)maxWidth
{
	NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:self];
	NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(maxWidth, FLT_MAX)];
	NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
	[layoutManager addTextContainer:textContainer];
	[textStorage addLayoutManager:layoutManager];
	[textStorage beginEditing];
	[textStorage setAttributes:@{NSFontAttributeName: font} range:NSMakeRange(0, [self length])];
	[textStorage endEditing];

	(void) [layoutManager glyphRangeForTextContainer:textContainer];

	NSRect r = [layoutManager usedRectForTextContainer:textContainer];

#if  !__has_feature(objc_arc)
	[textStorage release];
	[layoutManager release];
	[textContainer release];
#endif
	return r.size;
}
#endif

- (unsigned long long)fileSize
{
	NSDictionary *attr = [fileManager attributesOfItemAtPath:self error:NULL];
	if (!attr) return 0;
	return [attr[NSFileSize] unsignedLongLongValue];
}

- (unsigned long long)directorySize
{
	unsigned long long size = 0;
	for (NSString *file in self.dirContentsRecursiveAbsolute)
	{
		NSDictionary *attr = [fileManager attributesOfItemAtPath:file error:NULL];
		if (attr && !([attr[NSFileType] isEqualToString:NSFileTypeDirectory]))
			size += [attr[NSFileSize] unsignedLongLongValue];
	}
	return size;
}

- (BOOL)isIntegerNumber
{
	return [self rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location != NSNotFound;
}

- (BOOL)isFloatNumber
{
	static NSCharacterSet *cs;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^
	{
		NSMutableCharacterSet *tmp = [NSMutableCharacterSet decimalDigitCharacterSet];
		[tmp addCharactersInString:@",."];
		[tmp addCharactersInString:[(NSLocale *)[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator]];
		[tmp addCharactersInString:[(NSLocale *)[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator]];
		cs =  tmp.immutableObject;
	});

	return [self rangeOfCharacterFromSet:cs].location != NSNotFound;
}

- (BOOL)isWriteablePath
{
	if (self.fileExists)
		return NO;

	if (![@"TEST" writeToFile:self atomically:YES encoding:NSUTF8StringEncoding error:NULL])
		return NO;

	[fileManager removeItemAtPath:self error:NULL];

	return YES;
}

- (BOOL)isValidEmail
{
	if (self.length > 254)
		return NO;


	NSStringArray *portions = [self split:@"@"];

	if (portions.count != 2)
		return FALSE;

	NSString *local = portions[0];
	NSString *domain = portions[1];

	NSCharacterSet *localValid = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!#$%&'*+-/=?^_`{|}~."];
	NSCharacterSet *domainValid = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-."];

	if ([local rangeOfCharacterFromSet:localValid.invertedSet options:(NSStringCompareOptions)0].location != NSNotFound)
		return NO;

	if ([domain rangeOfCharacterFromSet:domainValid.invertedSet options:(NSStringCompareOptions)0].location != NSNotFound)
		return NO;

	return YES;
}

- (NSStringArray *)dirContents
{
	return (NSStringArray *)[[NSFileManager defaultManager] contentsOfDirectoryAtPath:self error:NULL];
}

- (NSStringArray *)dirContentsRecursive
{
	return (NSStringArray *)[[NSFileManager defaultManager] subpathsOfDirectoryAtPath:self error:NULL];
}

- (NSStringArray *)dirContentsAbsolute
{
	NSStringArray *c = self.dirContents;
	return (NSStringArray *)[c mapped:^NSString *(NSString *input) { return [self stringByAppendingPathComponent:input]; }];
}

- (NSStringArray *)dirContentsRecursiveAbsolute
{
	NSStringArray *c = self.dirContentsRecursive;
	return (NSStringArray *)[c mapped:^NSString *(NSString *input) { return [self stringByAppendingPathComponent:input]; }];
}


- (NSString *)uniqueFile
{
	if (![[NSFileManager defaultManager] fileExistsAtPath:self])	return self;
	else
	{
		NSString *ext = [self pathExtension];
		NSString *namewithoutext = [self stringByDeletingPathExtension];
		int i = 0;
		while ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@-%i.%@", namewithoutext, i,ext]]) i++;
		return [NSString stringWithFormat:@"%@-%i.%@", namewithoutext, i,ext];
	}
}

- (void)setContents:(NSData *)data
{
	NSError *err;

	if (![data writeToFile:self options:NSDataWritingAtomic error:&err])
		LOG(err);
}

- (NSData *)contents
{
#if  __has_feature(objc_arc)
	return [[NSData alloc] initWithContentsOfFile:self];
#else
	return [[[NSData alloc] initWithContentsOfFile:self] autorelease];
#endif
}

- (BOOL)fileExists
{
	return [[NSFileManager defaultManager] fileExistsAtPath:self];
}

- (NSUInteger)countOccurencesOfString:(NSString *)str
{
    return [[self componentsSeparatedByString:str] count] - 1;
}

- (BOOL)contains:(NSString *)otherString
{
	return ([self rangeOfString:otherString].location != NSNotFound);
}

- (BOOL)contains:(NSString *)otherString insensitive:(BOOL)insensitive
{
	return ([self rangeOfString:otherString options:insensitive ? NSCaseInsensitiveSearch : 0].location != NSNotFound);
}

- (BOOL)containsAny:(NSArray *)otherStrings
{
	for (NSString *otherString in otherStrings)
		if ([self rangeOfString:otherString].location != NSNotFound)
			return YES;

	return NO;
}

- (NSString *)localized
{
	return NSLocalizedString(self, nil);
}

- (NSString *)resourcePath
{
	return [[NSBundle mainBundle] pathForResource:self ofType:nil];
}

- (NSURL *)resourceURL
{
	return [[NSBundle mainBundle] URLForResource:self withExtension:nil];
}

- (NSURL *)URL
{
	return [NSURL URLWithString:self];
}

- (NSURL *)fileURL
{
	return [NSURL fileURLWithPath:self];
}

- (NSString *)expanded
{
	return [self stringByExpandingTildeInPath];
}

- (NSStringArray *)words
{
	return (NSStringArray *)[self componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSStringArray *)lines
{
	return (NSStringArray *)[self componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
}

- (NSString *)trimmedOfWhitespace
{
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString *)trimmedOfWhitespaceAndNewlines
{
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)clamp:(NSUInteger)maximumLength
{
    return (([self length] <= maximumLength) ? self : [self substringToIndex:maximumLength]);
}

- (NSString *)stringByReplacingMultipleStrings:(NSDictionary *)replacements
{
	NSString *ret = self;

	for (NSString *key in replacements)
	{
		if ([[NSNull null] isEqual:key] || [[NSNull null] isEqual:replacements[key]])
			continue;
		ret = [ret stringByReplacingOccurrencesOfString:key
                                             withString:[key stringByAppendingString:@"k9BBV15zFYi44YyB"]];
	}

    BOOL replaced;
    do
    {
        replaced = FALSE;
        for (NSString *key in replacements)
        {
            if ([[NSNull null] isEqual:key] || [[NSNull null] isEqual:replacements[key]])
                continue;
            NSString *tmp = [ret stringByReplacingOccurrencesOfString:[key stringByAppendingString:@"k9BBV15zFYi44YyB"]
														   withString:replacements[key]];

            if (![tmp isEqualToString:ret])
            {
                ret = tmp;
                replaced = YES;
            }
        }
    } while (replaced);

	return ret;
}

- (NSString *)titlecaseString
{
	NSString *cap = [self capitalizedString];
	NSString *res = [cap stringByReplacingMultipleStrings:@{@" A " : @" a ", @" An " : @" an ", @" And " : @" and ", @" As " : @" as ", @" At " : @" at ", @" But " : @" but ", @" By " : @" by ", @" En " : @" en ", @" For " : @" for ", @" If " : @" if ", @" In " : @" in ", @" Of " : @" of ", @" On " : @" on ", @" Or " : @" or ", @" Nor " : @" nor ", @" The " : @" the ", @" To " : @" to ", @" V " : @" v ", @" Via " : @" via ", @" Vs " : @" vs ", @" Up " : @" up ", @" It " : @" it "}];


	return res;
}

- (NSString *)propercaseString
{
	if ([self length] == 0)
		return @"";
	else if ([self length] == 1)
		return [self uppercaseString];

	return makeString(@"%@%@",
					  [[self substringToIndex:1] uppercaseString],
					  [[self substringFromIndex:1] lowercaseString]);
}

- (NSData *)download
{
#ifdef DEBUG
    if ([NSThread currentThread] == [NSThread mainThread])
        NSLog(@"Warning: performing blocking download on main thread");
#endif
	NSData *d = [[NSData alloc] initWithContentsOfURL:self.URL];
#if ! __has_feature(objc_arc)
	[d autorelease];
#endif
	return d;
}


#ifdef USE_SECURITY
- (NSString *)SHA1
{
	const char *cStr = [self UTF8String];
	unsigned char result[CC_SHA1_DIGEST_LENGTH];
	CC_SHA1(cStr, (CC_LONG)strlen(cStr), result);
	NSString *s = [NSString  stringWithFormat:
				   @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
				   result[0], result[1], result[2], result[3], result[4],
				   result[5], result[6], result[7],
				   result[8], result[9], result[10], result[11], result[12],
				   result[13], result[14], result[15],
				   result[16], result[17], result[18], result[19]
				   ];

    return s;
}
#endif

- (NSMutableString *)mutableObject
{
	return [NSMutableString stringWithString:self];
}

- (NSString *)replaced:(NSString *)str1 with:(NSString *)str2	// stringByReplacingOccurencesOfString:withString:
{
	return [self stringByReplacingOccurrencesOfString:str1 withString:str2];
}

- (NSStringArray *)split:(NSString *)sep								// componentsSeparatedByString:
{
	return (NSStringArray *)[self componentsSeparatedByString:sep];
}

- (NSArray *)defaultArray
{
	return [[NSUserDefaults standardUserDefaults] arrayForKey:self];
}

- (void)setDefaultArray:(NSArray *)newDefault
{
	[[NSUserDefaults standardUserDefaults] setObject:newDefault forKey:self];
}

- (NSDictionary *)defaultDict
{
	return [[NSUserDefaults standardUserDefaults] dictionaryForKey:self];
}

- (void)setDefaultDict:(NSDictionary *)newDefault
{
	[[NSUserDefaults standardUserDefaults] setObject:newDefault forKey:self];
}

- (id)defaultObject
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:self];
}

- (void)setDefaultObject:(id)newDefault
{
	[[NSUserDefaults standardUserDefaults] setObject:newDefault forKey:self];
}

- (NSString *)defaultString
{
	return [[NSUserDefaults standardUserDefaults] stringForKey:self];
}

- (void)setDefaultString:(NSString *)newDefault
{
	[[NSUserDefaults standardUserDefaults] setObject:newDefault forKey:self];
}

- (NSURL *)defaultURL
{
	return [[NSUserDefaults standardUserDefaults] URLForKey:self];
}

- (void)setDefaultURL:(NSURL *)newDefault
{
	[[NSUserDefaults standardUserDefaults] setURL:newDefault forKey:self];
}

- (NSInteger)defaultInt
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:self];
}

- (void)setDefaultInt:(NSInteger)newDefault
{
	[[NSUserDefaults standardUserDefaults] setInteger:newDefault forKey:self];
}

- (float)defaultFloat
{
	return [[NSUserDefaults standardUserDefaults] floatForKey:self];
}

- (void)setDefaultFloat:(float)newDefault
{
	[[NSUserDefaults standardUserDefaults] setFloat:newDefault forKey:self];
}

- (NSString *)stringValue
{
	return self;
}

- (NSNumber *)numberValue
{
	return @(self.doubleValue);
}

- (NSArrayArray *)parsedDSVWithDelimiter:(NSString *)delimiter
{	// credits to Drew McCormack
    NSMutableArray *rows = [NSMutableArray array];

	NSCharacterSet *whitespaceCharacterSet = [NSCharacterSet whitespaceCharacterSet];
    NSMutableCharacterSet *newlineCharacterSetMutable = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
    [newlineCharacterSetMutable formIntersectionWithCharacterSet:[whitespaceCharacterSet invertedSet]];
	NSCharacterSet *newlineCharacterSet = [NSCharacterSet characterSetWithBitmapRepresentation:[newlineCharacterSetMutable bitmapRepresentation]];
    NSMutableCharacterSet *importantCharactersSetMutable = [NSMutableCharacterSet characterSetWithCharactersInString:[delimiter stringByAppendingString:@"\""]];
    [importantCharactersSetMutable formUnionWithCharacterSet:newlineCharacterSet];
	NSCharacterSet *importantCharactersSet = [NSCharacterSet characterSetWithBitmapRepresentation:[importantCharactersSetMutable bitmapRepresentation]];

    NSScanner *scanner = [NSScanner scannerWithString:self];
    [scanner setCharactersToBeSkipped:nil];

    while (![scanner isAtEnd])
	{
		BOOL insideQuotes = NO;
        BOOL finishedRow = NO;
        NSMutableArray *columns = [NSMutableArray arrayWithCapacity:30];
        NSMutableString *currentColumn = [NSMutableString string];

        while (!finishedRow)
		{
            NSString *tempString;
            if ([scanner scanUpToCharactersFromSet:importantCharactersSet intoString:&tempString])
			{
                [currentColumn appendString:tempString];
            }

            if ([scanner isAtEnd])
			{
                if (![currentColumn isEqualToString:@""])
					[columns addObject:currentColumn];

                finishedRow = YES;
            }
            else if ([scanner scanCharactersFromSet:newlineCharacterSet intoString:&tempString])
			{
                if (insideQuotes)
				{
                    [currentColumn appendString:tempString];
                }
                else
				{
                    if (![currentColumn isEqualToString:@""])
						[columns addObject:currentColumn];
                    finishedRow = YES;
                }
            }
            else if ([scanner scanString:@"\"" intoString:NULL])
			{
                if (insideQuotes && [scanner scanString:@"\"" intoString:NULL])
				{
                    [currentColumn appendString:@"\""];
                }
                else
				{
                    insideQuotes = !insideQuotes;
                }
            }
            else if ([scanner scanString:delimiter intoString:NULL])
			{
                if (insideQuotes)
				{
                    [currentColumn appendString:delimiter];
                }
                else
				{
                    [columns addObject:currentColumn];
                    currentColumn = [NSMutableString string];
                    [scanner scanCharactersFromSet:whitespaceCharacterSet intoString:NULL];
                }
            }
        }
        if ([columns count] > 0)
			[rows addObject:columns];
    }

    return (NSArrayArray *)rows;
}

- (NSData *)data
{
	return [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
}

- (NSData *)dataFromHexString
{
	const char * bytes = [self cStringUsingEncoding: NSUTF8StringEncoding];
	NSUInteger length = strlen(bytes);
	unsigned char * r = (unsigned char *) malloc(length / 2 + 1);
	unsigned char * index = r;

	while ((*bytes) && (*(bytes +1)))
	{
		char encoder[3] = {'\0','\0','\0'};
		encoder[0] = *bytes;
		encoder[1] = *(bytes+1);
		*index = (char) strtol(encoder, NULL, 16);
		index++;
		bytes+=2;
	}
	*index = '\0';

	NSData *result = [NSData dataWithBytes: r length: length / 2];
	free(r);
    return result;
}


- (NSString *)escaped
{
#if  __has_feature(objc_arc)
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, NULL, kCFStringEncodingUTF8));
	return encodedString;
#else
    NSString *encodedString = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, NULL, kCFStringEncodingUTF8);
	return [encodedString autorelease];
#endif
}

- (NSString *)encoded
{
#if  __has_feature(objc_arc)
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
	return encodedString;
#else
    NSString *encodedString = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
	return [encodedString autorelease];
#endif
}

- (NSString *)stringByTrimmingLeadingCharactersInSet:(NSCharacterSet *)characterSet
{
	NSRange rangeOfFirstWantedCharacter = [self rangeOfCharacterFromSet:[characterSet invertedSet]];
	if (rangeOfFirstWantedCharacter.location == NSNotFound)
		return @"";

	return [self substringFromIndex:rangeOfFirstWantedCharacter.location];
}

- (NSString *)stringByTrimmingTrailingCharactersInSet:(NSCharacterSet *)characterSet
{
	NSRange rangeOfLastWantedCharacter = [self rangeOfCharacterFromSet:[characterSet invertedSet]
															   options:NSBackwardsSearch];
	if (rangeOfLastWantedCharacter.location == NSNotFound)
		return @"";

	return [self substringToIndex:rangeOfLastWantedCharacter.location+1];
}

//- (NSString *)arg:(id)arg, ...
//{
//	va_list args;
//	void *stackLocal = (__bridge void *)(arg);
//	struct __va_list_tag *stackLocal2 = stackLocal;
//    va_start(args, arg);
//
//    NSString *result = [[NSString alloc] initWithFormat:self arguments:stackLocal2];
//    va_end(args);
//
//#if ! __has_feature(objc_arc)
//	[d result];
//#endif
//	return result;
//}

@end


@implementation  NSMutableString (CoreCode)

@dynamic immutableObject;

- (NSString *)immutableObject
{
	return [NSString stringWithString:self];
}
@end



@implementation NSURL (CoreCode)

@dynamic dirContents, dirContentsRecursive, fileExists, uniqueFile, path, request, fileSize, directorySize, isWriteablePath, download, contents, fileIsDirectory;
#if defined(TARGET_OS_MAC) && TARGET_OS_MAC && !TARGET_OS_IPHONE
@dynamic fileIsAlias, fileAliasTarget;

- (BOOL)fileIsAlias
{
    CFURLRef cfurl = (BRIDGE CFURLRef) self;
    CFBooleanRef aliasBool = kCFBooleanFalse;
    BOOL success = CFURLCopyResourcePropertyForKey(cfurl, kCFURLIsAliasFileKey, &aliasBool, NULL);
    BOOL alias = CFBooleanGetValue(aliasBool);

    return alias && success;
}

- (BOOL)fileIsDirectory
{
	NSNumber *value;
	[self getResourceValue:&value forKey:NSURLIsDirectoryKey error:NULL];
	return value.boolValue;
}

- (NSURL *)fileAliasTarget
{
 	CFErrorRef *err = NULL;
	CFDataRef bookmark = CFURLCreateBookmarkDataFromFile(NULL, (BRIDGE CFURLRef)self, err);
	if (bookmark == nil)
		return nil;
	CFURLRef url = CFURLCreateByResolvingBookmarkData (NULL, bookmark, kCFBookmarkResolutionWithoutUIMask, NULL, NULL, NULL, err);
	__autoreleasing NSURL *nurl = [(BRIDGE NSURL *)url copy];
	CFRelease(bookmark);
	CFRelease(url);
#if  __has_feature(objc_arc)
	return nurl;
#else
	return [nurl autorelease];
#endif
}
#endif

- (NSURLRequest *)request
{
	return [NSURLRequest requestWithURL:self];
}

- (NSURL *)add:(NSString *)component
{
	return [self URLByAppendingPathComponent:component];
}

- (NSURLArray *)dirContents
{
	if (![self isFileURL]) return nil;
	NSArray *c = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self path] error:NULL];
	return (NSURLArray *)[c mapped:^id (NSString *input) { return [self URLByAppendingPathComponent:input]; }];
}

- (NSURLArray *)dirContentsRecursive
{
	if (![self isFileURL]) return nil;
	NSArray *c = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:[self path] error:NULL];
	return (NSURLArray *)[c mapped:^id (NSString *input) { return [self URLByAppendingPathComponent:input]; }];
}

- (NSURL *)uniqueFile
{
	if (![self isFileURL]) return nil;
	return [self path].uniqueFile.fileURL;
}

- (BOOL)fileExists
{
	return [self isFileURL] && [[NSFileManager defaultManager] fileExistsAtPath:[self path]];
}

- (unsigned long long)fileSize
{
	NSNumber *size;

	if ([self getResourceValue:&size forKey:NSURLFileSizeKey error:nil])
        return [size unsignedLongLongValue];
	else
		return 0;
}

- (unsigned long long)directorySize
{
	unsigned long long size = 0;
	for (NSString *file in self.dirContentsRecursive)
	{
		NSDictionary *attr = [fileManager attributesOfItemAtPath:@[self.path, file].path error:NULL];
		if (attr && !([attr[NSFileType] isEqualToString:NSFileTypeDirectory]))
			size += [attr[NSFileSize] unsignedLongLongValue];
	}
	return size;
}

- (void)open
{
#if defined(TARGET_OS_MAC) && TARGET_OS_MAC && !TARGET_OS_IPHONE
	[[NSWorkspace sharedWorkspace] openURL:self];
#else
	[[UIApplication sharedApplication] openURL:self];
#endif
}

- (BOOL)isWriteablePath
{
	if (self.fileExists)
		return NO;

	if (![@"TEST" writeToURL:self atomically:YES encoding:NSUTF8StringEncoding error:NULL])
		return NO;

	[fileManager removeItemAtURL:self error:NULL];

	return YES;
}


- (NSData *)download
{
#ifdef DEBUG
	if ([NSThread currentThread] == [NSThread mainThread] && !self.isFileURL)
        NSLog(@"Warning: performing blocking download on main thread");
#endif
	NSData *d = [[NSData alloc] initWithContentsOfURL:self];
#if ! __has_feature(objc_arc)
	[d autorelease];
#endif
	return d;
}

- (void)setContents:(NSData *)data
{
	NSError *err;

	if (![data writeToURL:self options:NSDataWritingAtomic error:&err])
		LOG(err);
}

- (NSData *)contents
{
	return self.download;
}
@end


@implementation  NSCharacterSet (CoreCode)

@dynamic stringRepresentation, mutableObject;

- (NSString *)stringRepresentation
{
	NSMutableString *tmp = [NSMutableString new];
	unichar unicharBuffer[20];
	int index = 0;

	for (unichar uc = 0; uc < (0xFFFF); uc ++)
	{
		if ([self characterIsMember:uc])
		{
			unicharBuffer[index] = uc;

			index ++;

			if (index == 20)
			{
				[tmp appendString:[NSString stringWithCharacters:unicharBuffer length:index]];

				index = 0;
			}
		}
	}

	if (index != 0)
		[tmp appendString:[NSString stringWithCharacters:unicharBuffer length:index]];

	return tmp;
}

- (NSMutableCharacterSet *)mutableObject
{
	return [NSMutableCharacterSet characterSetWithBitmapRepresentation:[self bitmapRepresentation]];
}
@end


@implementation  NSMutableCharacterSet (CoreCode)

@dynamic immutableObject;

- (NSCharacterSet *)immutableObject
{
	return [NSCharacterSet characterSetWithBitmapRepresentation:[self bitmapRepresentation]];
}
@end