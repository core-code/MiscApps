//
//  Foundation+CoreCode.h
//  CoreLib
//
//  Created by CoreCode on 15.03.12.
/*	Copyright © 2017 CoreCode Limited
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */


#include "CoreLib.h"



@interface NSArray (CoreCode)

@property (readonly, nonatomic) NSArray *reverseArray;
@property (readonly, nonatomic) NSMutableArray *mutableObject;
@property (readonly, nonatomic) BOOL empty;
#if (MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_7) || (__IPHONE_OS_VERSION_MIN_REQUIRED >= 50000)
@property (readonly, nonatomic) NSData *JSONData;
#endif
@property (readonly, nonatomic) NSString *string;
@property (readonly, nonatomic) NSString *path;
@property (readonly, nonatomic) NSArray *sorted;

- (NSArray *)arrayByAddingNewObject:(id)anObject;			// adds the object only if it is not identical (contentwise) to existing entry
- (NSArray *)arrayByRemovingObjectIdenticalTo:(id)anObject;
- (NSArray *)arrayByRemovingObjectsIdenticalTo:(NSArray *)objects;
- (NSArray *)arrayByRemovingObjectAtIndex:(NSUInteger)index;
- (NSArray *)arrayByRemovingObjectsAtIndexes:(NSIndexSet *)indexSet;
- (NSArray *)arrayByReplacingObject:(id)anObject withObject:(id)newObject;
- (id)safeObjectAtIndex:(NSUInteger)index;
- (NSString *)safeStringAtIndex:(NSUInteger)index;
- (BOOL)containsDictionaryWithKey:(NSString *)key equalTo:(NSString *)value;
- (NSArray *)sortedArrayByKey:(NSString *)key;
- (NSArray *)sortedArrayByKey:(NSString *)key ascending:(BOOL)ascending;
- (BOOL)contains:(id)object;
- (CGRect)calculateExtentsOfPoints:(ObjectInPointOutBlock)block;
- (NSRange)calculateExtentsOfValues:(ObjectInIntOutBlock)block;


#if defined(TARGET_OS_MAC) && TARGET_OS_MAC && !TARGET_OS_IPHONE
- (NSString *)runAsTask;
- (NSString *)runAsTaskWithTerminationStatus:(NSInteger *)terminationStatus;
#endif

- (NSArray *)mapped:(ObjectInOutBlock)block;
- (NSArray *)filtered:(ObjectInIntOutBlock)block;
- (NSArray *)filteredUsingPredicateString:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (NSInteger)collect:(ObjectInIntOutBlock)block;

// versions similar to cocoa methods
- (void)apply:(ObjectInBlock)block;								// enumerateObjectsUsingBlock:

// forwards for less typing
- (NSString *)joined:(NSString *)sep;							// = componentsJoinedByString:

@property (readonly, nonatomic) NSSet *set;


@end



@interface NSMutableArray (CoreCode)

@property (readonly, nonatomic) NSArray *immutableObject;

- (void)addNewObject:(id)anObject;
- (void)addObjectSafely:(id)anObject;
- (void)map:(ObjectInOutBlock)block;
- (void)filter:(ObjectInIntOutBlock)block;
- (void)filterUsingPredicateString:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (void)removeFirstObject;
- (void)moveObjectAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
- (void)removeObjectPassingTest:(ObjectInIntOutBlock)block;


@end





@interface NSData (CoreCode)

@property (readonly, nonatomic) NSMutableData *mutableObject;
@property (readonly, nonatomic) NSString *string;
@property (readonly, nonatomic) NSString *hexString;
#if (MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_7) || (__IPHONE_OS_VERSION_MIN_REQUIRED >= 50000)
@property (readonly, nonatomic) NSDictionary *JSONDictionary;
@property (readonly, nonatomic) NSArray *JSONArray;
#endif

#ifdef USE_SNAPPY
@property (readonly, nonatomic) NSData *snappyCompressed;
@property (readonly, nonatomic) NSData *snappyDecompressed;
#endif

#ifdef USE_SECURITY
@property (readonly, nonatomic) NSString *SHA1;
#endif

@end



@interface NSDate (CoreCode)

// date format strings:   dd.MM.yyyy HH:mm:ss
+ (NSDate *)dateWithString:(NSString *)dateString format:(NSString *)dateFormat localeIdentifier:(NSString *)localeIdentifier;
+ (NSDate *)dateWithString:(NSString *)dateString format:(NSString *)dateFormat;
+ (NSDate *)dateWithPreprocessorDate:(const char *)preprocessorDateString;
- (NSString *)stringUsingFormat:(NSString *)dateFormat;
- (NSString *)stringUsingDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle;

@end



@interface NSDateFormatter (CoreCode)

+ (NSString *)formattedTimeFromTimeInterval:(NSTimeInterval)timeInterval;

@end



@interface NSDictionary (CoreCode)

#if (MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_7) || (__IPHONE_OS_VERSION_MIN_REQUIRED >= 50000)
@property (readonly, nonatomic) NSData *JSONData;
#endif
@property (readonly, nonatomic) NSMutableDictionary *mutableObject;
- (NSDictionary *)dictionaryByAddingValue:(id)value forKey:(NSString *)key;
- (NSDictionary *)dictionaryByRemovingKey:(NSString *)key;
- (NSDictionary *)dictionaryByRemovingKeys:(NSStringArray *)keys;

@end


@interface NSMutableDictionary (CoreCode)

@property (readonly, nonatomic) NSDictionary *immutableObject;

@end



@interface NSFileHandle (CoreCode)

- (float)readFloat;
- (int)readInt;

@end



@interface NSLocale (CoreCode)

+ (NSArray *)preferredLanguages3Letter;

@end




@interface NSObject (CoreCode)

@property (readonly, nonatomic) id id;
- (id)associatedValueForKey:(NSString *)key;
- (void)setAssociatedValue:(id)value forKey:(NSString *)key;
@property (retain, nonatomic) id associatedValue;
+ (instancetype)newWith:(NSDictionary *)dict;

@end




@interface NSString (CoreCode)

// filesystem support
@property (readonly, nonatomic) NSStringArray *dirContents;
@property (readonly, nonatomic) NSStringArray *dirContentsRecursive;
@property (readonly, nonatomic) NSStringArray *dirContentsAbsolute;
@property (readonly, nonatomic) NSStringArray *dirContentsRecursiveAbsolute;
@property (readonly, nonatomic) NSString *uniqueFile;
@property (readonly, nonatomic) BOOL fileExists;
#if defined(TARGET_OS_MAC) && TARGET_OS_MAC && !TARGET_OS_IPHONE
@property (readonly, nonatomic) BOOL fileIsAlias;
@property (readonly, nonatomic) NSString *fileAliasTarget;
#endif
@property (readonly, nonatomic) unsigned long long fileSize;
@property (readonly, nonatomic) unsigned long long directorySize;
@property (readonly, nonatomic) BOOL isWriteablePath;

// path string to url
@property (readonly, nonatomic) NSURL *fileURL;
@property (readonly, nonatomic) NSURL *URL;
// url string download
@property (readonly, nonatomic) NSData *download;
// path string filedata
@property (assign, nonatomic) NSData *contents;



// NSUserDefaults support
@property (copy, nonatomic) id defaultObject;
@property (copy, nonatomic) NSString *defaultString;
@property (copy, nonatomic) NSArray *defaultArray;
@property (copy, nonatomic) NSDictionary *defaultDict;
@property (copy, nonatomic) NSURL *defaultURL;
@property (assign, nonatomic) NSInteger defaultInt;
@property (assign, nonatomic) float defaultFloat;

@property (readonly, nonatomic) NSString *localized;

//  bundle contents to path
@property (readonly, nonatomic) NSString *resourcePath;
@property (readonly, nonatomic) NSURL *resourceURL;
#if defined(TARGET_OS_MAC) && TARGET_OS_MAC && !TARGET_OS_IPHONE
@property (readonly, nonatomic) NSImage *namedImage;
#else
@property (readonly, nonatomic) UIImage *namedImage;
#endif

// string things
@property (readonly, nonatomic) NSStringArray *lines;
@property (readonly, nonatomic) NSStringArray *words;
@property (readonly, nonatomic) NSString *expanded;						// = stringByExpandingTildeInPath
@property (readonly, nonatomic) NSString *trimmedOfWhitespace;
@property (readonly, nonatomic) NSString *trimmedOfWhitespaceAndNewlines;
@property (readonly, nonatomic) NSString *escaped; // URL escaping
@property (readonly, nonatomic) NSString *encoded; // total encoding, wont work with OPEN anymore as it encodes the slashes

@property (readonly, nonatomic) NSMutableString *mutableObject;
#ifdef USE_SECURITY
@property (readonly, nonatomic) NSString *SHA1;
#endif


@property (readonly, nonatomic) NSString *titlecaseString;
@property (readonly, nonatomic) NSString *propercaseString;
@property (readonly, nonatomic) BOOL isIntegerNumber;
@property (readonly, nonatomic) BOOL isFloatNumber;
@property (readonly, nonatomic) BOOL isValidEmail;



@property (readonly, nonatomic) NSData *data;	// data of string contents
@property (readonly, nonatomic) NSData *dataFromHexString;


- (NSArrayArray *)parsedDSVWithDelimiter:(NSString *)delimiter;

- (NSString *)stringValue;

- (NSUInteger)countOccurencesOfString:(NSString *)str;
- (BOOL)contains:(NSString *)otherString insensitive:(BOOL)insensitive;
- (BOOL)contains:(NSString *)otherString;
- (BOOL)containsAny:(NSArray *)otherStrings;
- (NSString *)stringByReplacingMultipleStrings:(NSDictionary *)replacements;
- (NSString *)clamp:(NSUInteger)maximumLength;
//- (NSString *)arg:(id)arg, ...;


- (NSString *)stringByTrimmingLeadingCharactersInSet:(NSCharacterSet *)characterSet;
- (NSString *)stringByTrimmingTrailingCharactersInSet:(NSCharacterSet *)characterSet;

#if defined(TARGET_OS_MAC) && TARGET_OS_MAC && !TARGET_OS_IPHONE
- (CGSize)sizeUsingFont:(NSFont *)font maxWidth:(float)maxWidth;
#endif


// forwards for less typing
- (NSString *)replaced:(NSString *)str1 with:(NSString *)str2;			// = stringByReplacingOccurencesOfString:withString:
- (NSStringArray *)split:(NSString *)sep;								// = componentsSeparatedByString:

@end


@interface NSMutableString (CoreCode)

@property (readonly, nonatomic) NSString *immutableObject;

@end



@interface NSURL (CoreCode)

- (NSURL *)add:(NSString *)component;
- (void)open;

@property (readonly, nonatomic) BOOL fileIsDirectory;
@property (readonly, nonatomic) NSString *path;
@property (readonly, nonatomic) NSURLArray *dirContents;
@property (readonly, nonatomic) NSURLArray *dirContentsRecursive;
@property (readonly, nonatomic) NSURL *uniqueFile;
@property (readonly, nonatomic) BOOL fileExists;
#if defined(TARGET_OS_MAC) && TARGET_OS_MAC && !TARGET_OS_IPHONE
@property (readonly, nonatomic) BOOL fileIsAlias;
@property (readonly, nonatomic) NSURL *fileAliasTarget;
#endif
@property (readonly, nonatomic) unsigned long long fileSize;
@property (readonly, nonatomic) unsigned long long directorySize;
@property (readonly, nonatomic) NSURLRequest *request;
@property (readonly, nonatomic) BOOL isWriteablePath;
// url string download
@property (readonly, nonatomic) NSData *download;
// path string filedata
@property (assign, nonatomic) NSData *contents;

@end


@interface NSCharacterSet (CoreCode)

@property (readonly, nonatomic) NSMutableCharacterSet *mutableObject;
@property (readonly, nonatomic) NSString *stringRepresentation;

@end

@interface NSMutableCharacterSet (CoreCode)

@property (readonly, nonatomic) NSCharacterSet *immutableObject;

@end


