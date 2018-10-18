//
//  CoreLib.h
//  CoreLib
//
//  Created by CoreCode on 12.04.12.
/*	Copyright © 2018 CoreCode Limited
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */



#ifdef __OBJC__

#ifndef CORELIB
#define CORELIB 1


// !!!: BASIC TYPES

#ifdef __BLOCKS__
typedef void (^BasicBlock)(void);
typedef void (^DoubleInBlock)(double input);
typedef void (^StringInBlock)(NSString *input);
typedef void (^ObjectInBlock)(id input);
typedef id (^ObjectInOutBlock)(id input);
typedef int (^ObjectInIntOutBlock)(id input);
typedef float (^ObjectInFloatOutBlock)(id input);
typedef int (^IntInOutBlock)(int input);
typedef void (^IntInBlock)(int input);
typedef int (^IntOutBlock)(void);
#endif

#define CC_ENUM(type, name) typedef NS_ENUM(type, name)

CC_ENUM(uint8_t, openChoice)
{
	openSupportRequestMail = 1,	// VendorProductPage info.plist key
	openBetaSignupMail,			// FeedbackEmail info.plist key
	openHomepageWebsite,		// VendorProductPage info.plist key
	openAppStoreWebsite,		// StoreProductPage info.plist key
	openAppStoreApp,			// StoreProductPage info.plist key
	openMacupdateWebsite		// MacupdateProductPage info.plist key
};


#define MAKE_MAKER(classname) \
static inline NS ## classname * make ## classname (void) { return (NS ## classname *)[NS ## classname new];}

MAKE_MAKER(MutableArray)



// !!!: CORELIB OBJ INTERFACE
@interface CoreLib : NSObject
// info bundle key convenience
@property (readonly, nonatomic) NSString *appBundleIdentifier;
@property (readonly, nonatomic) int appBuildNumber;
@property (readonly, nonatomic) NSString *appVersionString;
@property (readonly, nonatomic) NSString *appName;
// path convenience
@property (readonly, nonatomic) NSString *prefsPath;
@property (readonly, nonatomic) NSString *resDir;
@property (readonly, nonatomic) NSString *docDir;
@property (readonly, nonatomic) NSString *deskDir;
@property (readonly, nonatomic) NSString *suppDir;
@property (readonly, nonatomic) NSURL *prefsURL;
@property (readonly, nonatomic) NSURL *resURL;
@property (readonly, nonatomic) NSURL *docURL;
@property (readonly, nonatomic) NSURL *deskURL;
@property (readonly, nonatomic) NSURL *suppURL;
@property (readonly, nonatomic) NSURL *homeURLInsideSandbox;
@property (readonly, nonatomic) NSURL *homeURLOutsideSandbox;
// misc
@property (readonly, nonatomic) NSArray *appCrashLogs;
@property (readonly, nonatomic) NSString *appChecksumSHA;
- (void)openURL:(openChoice)choice;
- (void)sendSupportRequestMail:(NSString *)text;
@end



// !!!: GLOBALS
extern CoreLib *cc; // init CoreLib with: cc = [CoreLib new];
extern NSUserDefaults *userDefaults;
extern NSFileManager *fileManager;
extern NSNotificationCenter *notificationCenter;
extern NSBundle *bundle;
extern NSFontManager *fontManager;
extern NSDistributedNotificationCenter *distributedNotificationCenter;
extern NSWorkspace *workspace;
extern NSApplication *application;
extern NSProcessInfo *processInfo;


// !!!: ALERT FUNCTIONS
NSInteger alert_input(NSString *prompt, NSArray *buttons, NSString **result); // alert with text field prompting users
NSInteger alert_apptitled(NSString *message, NSString *defaultButton, NSString *alternateButton, NSString *otherButton);
NSInteger alert(NSString *title, NSString *message, NSString *defaultButton, NSString *alternateButton, NSString *otherButton);
void alert_feedback_fatal(NSString *usermsg, NSString *details) __attribute__((noreturn));



// !!!: OBJECT CREATION FUNCTIONS
NSString *makeString(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);
NSString *makeDescription(id sender, NSArray *args);
NSColor *makeColor(CGFloat r, CGFloat g, CGFloat b, CGFloat a);		// params from 0..1



// !!!: GRAND CENTRAL DISPATCH FUNCTIONS
void dispatch_after_main(float seconds, dispatch_block_t block);
void dispatch_after_back(float seconds, dispatch_block_t block);
void dispatch_async_main(dispatch_block_t block);
void dispatch_async_back(dispatch_block_t block);
void dispatch_sync_main(dispatch_block_t block);



// !!!: CONSTANT KEYS
#define CONST_KEY(name) \
static NSString *const k ## name ## Key = @ #name;
#define CONST_KEY_IMPLEMENTATION(name) \
NSString *const k ## name ## Key = @ #name;
#define CONST_KEY_DECLARATION(name) \
extern NSString *const k ## name ## Key;
#define CONST_KEY_ENUM(name, enumname) \
@interface name ## Key : NSString @property (assign, nonatomic) enumname defaultInt; @end \
static name ## Key *const k ## name ## Key = ( name ## Key *) @ #name;
#define CONST_KEY_ENUM_IMPLEMENTATION(name, enumname) \
name ## Key *const k ## name ## Key = ( name ## Key *) @ #name;
#define CONST_KEY_ENUM_DECLARATION(name, enumname) \
@interface name ## Key : NSString @property (assign, nonatomic) enumname defaultInt; @end \
extern name ## Key *const k ## name ## Key;


// !!!: LOGGING
void log_to_prefs(NSString *string);
void cc_log_enablecapturetofile(NSURL *fileURL, unsigned long long sizeLimit);

void cc_log_level(int level, NSString *format, ...) NS_FORMAT_FUNCTION(2,3);
#ifdef FORCE_LOG
#define cc_log_debug(...)     cc_log_level(5, __VA_ARGS__) // ASL_LEVEL_NOTICE
#elif defined(DEBUG) && !defined(FORCE_NOLOG)
#define cc_log_debug(...)     cc_log_level(7, __VA_ARGS__) // ASL_LEVEL_DEBUG
#else
#define cc_log_debug(...)
#endif
#define cc_log(...)           cc_log_level(5, __VA_ARGS__) // ASL_LEVEL_NOTICE
#define cc_log_error(...)     cc_log_level(3, __VA_ARGS__) // ASL_LEVEL_ERR
#define cc_log_emerg(...)     cc_log_level(0, __VA_ARGS__) // ASL_LEVEL_EMERG

#define LOGFUNC                    cc_log_debug(@"%@ (%p)", @(__PRETTY_FUNCTION__), (__bridge void *)self)
#define LOGFUNCPARAM(x)            cc_log_debug(@"%@ (%p) [%@]", @(__PRETTY_FUNCTION__), (__bridge void *)self, [(x) description])
#define LOG(x)					cc_log_debug(@"%@", [(x) description]);



// !!!: CONVENIENCE MACROS
#define OBJECT_OR(x,y)            ((x) ? (x) : (y))
#define NON_NIL_STR(x)            ((x) ? (x) : @"")
#define IS_DOUBLE_EQUAL(x,y)    (fabs((x)-(y)) < 0.000001)
#define OS_IS_POST_10_6            (NSAppKitVersionNumber >= (int)NSAppKitVersionNumber10_7)
#define OS_IS_POST_10_7            (NSAppKitVersionNumber >= (int)NSAppKitVersionNumber10_8)
#define OS_IS_POST_10_8            (NSAppKitVersionNumber >= (int)NSAppKitVersionNumber10_9)
#define OS_IS_POST_10_9            (NSAppKitVersionNumber >= (int)NSAppKitVersionNumber10_10)
#define OS_IS_POST_10_11        (NSAppKitVersionNumber >= (int)NSAppKitVersionNumber10_12)
#define OS_IS_POST_10_12        (NSAppKitVersionNumber >= (int)NSAppKitVersionNumber10_13)
#define MB_TO_BYTES(x)            ((x) * (1024 * 1024))


// !!!: MISC MACROS
#ifndef NSAppKitVersionNumber10_6
#define NSAppKitVersionNumber10_6 1038
#endif
#ifndef NSAppKitVersionNumber10_7
#define NSAppKitVersionNumber10_7 1138
#endif
#ifndef NSAppKitVersionNumber10_8
#define NSAppKitVersionNumber10_8 1187
#endif
#ifndef NSAppKitVersionNumber10_9
#define NSAppKitVersionNumber10_9 1265
#endif
#ifndef NSAppKitVersionNumber10_10
#define NSAppKitVersionNumber10_10 1343.14
#endif
#ifndef NSAppKitVersionNumber10_11
#define NSAppKitVersionNumber10_11 1404.11
#endif
#ifndef NSAppKitVersionNumber10_12
#define NSAppKitVersionNumber10_12 1504
#endif
#ifndef NSAppKitVersionNumber10_13
#define NSAppKitVersionNumber10_13 1561
#endif
#if ! __has_feature(objc_arc)
#define BRIDGE
#else
#define BRIDGE __bridge
#endif


// !!!: CONFIGURATION
#define kVendorHomepage @"https://www.corecode.io/"
#define kFeedbackEmail @"feedback@corecode.io"



// !!!: UNDEFS
// this makes sure youo not compare the return values of our alert*() functions against old values and use NSLog when you should use ASL. remove as appropriate
#define NSAlertDefaultReturn
#define NSAlertAlternateReturn
#define NSAlertOtherReturn
#define NSAlertErrorReturn
#define NSOKButton
#define NSCancelButton
#define asl_log
#define asl_NSLog_debug
#define NSLog
#define os_log
#define os_log_info
#define os_log_debug
#define os_log_error
#define os_log_fault



#endif







@interface NSArray <ObjectType> (CoreCode)

@property (readonly, nonatomic) NSArray *flattenedArray;
@property (readonly, nonatomic) NSArray <ObjectType> *reverseArray;
@property (readonly, nonatomic) NSMutableArray <ObjectType> *mutableObject;
@property (readonly, nonatomic) BOOL empty;
@property (readonly, nonatomic) NSData *XMLData;

@property (readonly, nonatomic) NSString *string;
@property (readonly, nonatomic) NSString *path;
@property (readonly, nonatomic) NSArray <ObjectType> *sorted;
@property (readonly, nonatomic) NSString *literalString;

- (NSArray <ObjectType>*)arrayByAddingNewObject:(ObjectType)anObject;            // adds the object only if it is not identical (contentwise) to existing entry
- (NSArray <ObjectType>*)arrayByRemovingObjectIdenticalTo:(ObjectType)anObject;
- (NSArray <ObjectType>*)arrayByRemovingObjectsIdenticalTo:(NSArray <ObjectType>*)objects;
- (NSArray <ObjectType>*)arrayByRemovingObjectAtIndex:(NSUInteger)index;
- (NSArray <ObjectType>*)arrayByRemovingObjectsAtIndexes:(NSIndexSet *)indexSet;
- (NSArray <ObjectType>*)arrayByReplacingObject:(ObjectType)anObject withObject:(ObjectType)newObject;
- (ObjectType)safeObjectAtIndex:(NSUInteger)index;
- (BOOL)containsDictionaryWithKey:(NSString *)key equalTo:(NSString *)value;
- (NSArray <ObjectType>*)sortedArrayByKey:(NSString *)key;
- (NSArray <ObjectType>*)sortedArrayByKey:(NSString *)key ascending:(BOOL)ascending;
- (BOOL)contains:(ObjectType)object;


- (NSArray <ObjectType>*)subarrayFromIndex:(NSUInteger)index;
- (NSArray <ObjectType>*)subarrayToIndex:(NSUInteger)index;



#if defined(TARGET_OS_MAC) && TARGET_OS_MAC && !TARGET_OS_IPHONE
- (NSString *)runAsTask;
- (NSString *)runAsTaskWithTerminationStatus:(NSInteger *)terminationStatus;
#endif
- (NSArray *)mapped:(id (^)(ObjectType input))block;
- (NSArray <ObjectType>*)filtered:(BOOL (^)(ObjectType input))block;
- (NSArray <ObjectType>*)filteredUsingPredicateString:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (NSInteger)reduce:(int (^)(ObjectType input))block;

// versions similar to cocoa methods
- (void)apply:(void (^)(ObjectType input))block;                                // enumerateObjectsUsingBlock:

// forwards for less typing
- (NSString *)joined:(NSString *)sep;                            // = componentsJoinedByString:

@property (readonly, nonatomic) NSSet <ObjectType> *set;

#if (MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_7)
@property (readonly, nonatomic) NSOrderedSet <ObjectType> *orderedSet;
#endif

@end



@interface NSMutableArray <ObjectType>(CoreCode)

@property (readonly, nonatomic) NSArray <ObjectType> *immutableObject;

- (void)addNewObject:(ObjectType)anObject;
- (void)addObjectSafely:(ObjectType)anObject;
- (void)map:(ObjectType (^)(ObjectType input))block;
- (void)filter:(int (^)(ObjectType input))block;
- (void)filterUsingPredicateString:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (void)removeFirstObject;
- (void)moveObjectAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
- (void)removeObjectPassingTest:(int (^)(ObjectType input))block;


@end





@interface NSString (CoreCode)

// filesystem support
@property (readonly, nonatomic) NSArray <NSString *> *dirContents;
@property (readonly, nonatomic) NSArray <NSString *> *dirContentsRecursive;
@property (readonly, nonatomic) NSArray <NSString *> *dirContentsAbsolute;
@property (readonly, nonatomic) NSArray <NSString *> *dirContentsRecursiveAbsolute;
@property (readonly, nonatomic) NSString *uniqueFile;
@property (readonly, nonatomic) BOOL fileExists;
#if defined(TARGET_OS_MAC) && TARGET_OS_MAC && !TARGET_OS_IPHONE
@property (readonly, nonatomic) BOOL fileIsRestricted;
@property (readonly, nonatomic) BOOL fileIsAlias;
@property (readonly, nonatomic) NSString *fileAliasTarget;
#endif
@property (readonly, nonatomic) unsigned long long fileSize;
@property (readonly, nonatomic) unsigned long long directorySize;
@property (readonly, nonatomic) BOOL isWriteablePath;
@property (readonly, nonatomic) NSRange fullRange;
@property (readonly, nonatomic) NSString *literalString;

@property (readonly, nonatomic) NSString *stringByResolvingSymlinksInPathFixed;

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
@property (readonly, nonatomic) NSArray <NSString *> *lines;
@property (readonly, nonatomic) NSArray <NSString *> *words;
@property (readonly, nonatomic) unichar firstCharacter;
@property (readonly, nonatomic) unichar lastCharacter;

@property (readonly, nonatomic) NSString *expanded;                        // = stringByExpandingTildeInPath
@property (readonly, nonatomic) NSString *trimmedOfWhitespace;
@property (readonly, nonatomic) NSString *trimmedOfWhitespaceAndNewlines;
@property (readonly, nonatomic) NSString *unescaped;
@property (readonly, nonatomic) NSString *escaped; // URL escaping
//@property (readonly, nonatomic) NSString *encoded; // total encoding, wont work with OPEN anymore as it encodes the slashes

@property (readonly, nonatomic) NSMutableString *mutableObject;

@property (readonly, nonatomic) NSString *rot13;
#ifdef USE_SECURITY
@property (readonly, nonatomic) NSString *SHA1;
#endif
@property (readonly, nonatomic) NSString *language;


@property (readonly, nonatomic) NSString *titlecaseString;
@property (readonly, nonatomic) NSString *propercaseString;
@property (readonly, nonatomic) BOOL isIntegerNumber;
@property (readonly, nonatomic) BOOL isIntegerNumberOnly;
@property (readonly, nonatomic) BOOL isValidEmail;
@property (readonly, nonatomic) BOOL isValidEmails;



@property (readonly, nonatomic) NSData *data;    // data of string contents
@property (readonly, nonatomic) NSData *dataFromHexString;


- (NSArray <NSArray <NSString *> *> *)parsedDSVWithDelimiter:(NSString *)delimiter;

- (NSString *)stringValue;

- (NSUInteger)countOccurencesOfString:(NSString *)str;
- (BOOL)contains:(NSString *)otherString insensitive:(BOOL)insensitive;
- (BOOL)contains:(NSString *)otherString;
- (BOOL)containsAny:(NSArray <NSString *>*)otherStrings;
- (BOOL)containsAll:(NSArray <NSString *>*)otherStrings;
- (BOOL)equalsAny:(NSArray <NSString *>*)otherStrings;
- (NSString *)stringByReplacingMultipleStrings:(NSDictionary <NSString *, NSString *>*)replacements;
- (NSString *)clamp:(NSUInteger)maximumLength;
//- (NSString *)arg:(id)arg, ...;



- (NSAttributedString *)hyperlinkWithURL:(NSURL *)url;


- (NSString *)capitalizedStringWithUppercaseWords:(NSArray <NSString *> *)uppercaseWords;
- (NSString *)titlecaseStringWithLowercaseWords:(NSArray <NSString *> *)lowercaseWords andUppercaseWords:(NSArray <NSString *> *)uppercaseWords;

- (NSString *)stringByTrimmingLeadingCharactersInSet:(NSCharacterSet *)characterSet;
- (NSString *)stringByTrimmingTrailingCharactersInSet:(NSCharacterSet *)characterSet;

#if defined(TARGET_OS_MAC) && TARGET_OS_MAC && !TARGET_OS_IPHONE
- (CGSize)sizeUsingFont:(NSFont *)font maxWidth:(CGFloat)maxWidth;
// FSEvents directory observing
- (void)startObserving:(BasicBlock)block;
- (void)stopObserving;
#endif

- (NSString *)removed:(NSString *)stringToRemove;

// forwards for less typing
- (NSString *)replaced:(NSString *)str1 with:(NSString *)str2;            // = stringByReplacingOccurencesOfString:withString:
- (NSArray <NSString *> *)split:(NSString *)sep;                                // = componentsSeparatedByString:



@end


@interface NSMutableString (CoreCode)

@property (readonly, nonatomic) NSString *immutableObject;

@end



@interface NSURL (CoreCode)


#if (MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_9)
+ (NSURL *)URLWithHost:(NSString *)host path:(NSString *)path query:(NSString *)query;
+ (NSURL *)URLWithHost:(NSString *)host path:(NSString *)path query:(NSString *)query user:(NSString *)user password:(NSString *)password fragment:(NSString *)fragment scheme:(NSString *)scheme port:(NSNumber *)port;
- (NSData *)performBlockingPOST;
- (NSData *)performBlockingGET;
- (void)performGET:(void (^)(NSData *data))completion;
- (void)performPOST:(void (^)(NSData *data))completion;
#endif

- (NSURL *)add:(NSString *)component;
- (void)open;

@property (readonly, nonatomic) BOOL fileIsDirectory;
//@property (readonly, nonatomic) NSString *path;
@property (readonly, nonatomic) NSArray <NSURL *> *dirContents;
@property (readonly, nonatomic) NSArray <NSURL *> *dirContentsRecursive;
@property (readonly, nonatomic) NSURL *uniqueFile;
@property (readonly, nonatomic) BOOL fileExists;
#if defined(TARGET_OS_MAC) && TARGET_OS_MAC && !TARGET_OS_IPHONE
@property (readonly, nonatomic) BOOL fileIsRestricted;
@property (readonly, nonatomic) BOOL fileIsAlias;
@property (readonly, nonatomic) NSURL *fileAliasTarget;
#endif
@property (readonly, nonatomic) unsigned long long fileSize;
@property (readonly, nonatomic) unsigned long long fileOrDirectorySize;
@property (readonly, nonatomic) unsigned long long directorySize;
@property (readonly, nonatomic) NSURLRequest *request;
@property (readonly, nonatomic) NSMutableURLRequest *mutableRequest;
@property (readonly, nonatomic) BOOL isWriteablePath;
// url string download
@property (readonly, nonatomic) NSData *download;
// path string filedata
@property (assign, nonatomic) NSData *contents;

@end



@interface NSData (CoreCode)

@property (readonly, nonatomic) NSMutableData *mutableObject;
@property (readonly, nonatomic) NSString *string;
@property (readonly, nonatomic) NSString *hexString;



#ifdef USE_SECURITY
@property (readonly, nonatomic) NSString *SHA1;
@property (readonly, nonatomic) NSString *MD5;
@property (readonly, nonatomic) NSString *SHA256;
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



@interface NSDictionary <KeyType, ObjectType>(CoreCode)


@property (readonly, nonatomic) NSData *XMLData;
@property (readonly, nonatomic) NSMutableDictionary <KeyType, ObjectType> *mutableObject;
- (NSDictionary *)dictionaryByAddingValue:(ObjectType)value forKey:(KeyType)key;
- (NSDictionary *)dictionaryByRemovingKey:(KeyType)key;
- (NSDictionary *)dictionaryByRemovingKeys:(NSArray <KeyType> *)keys;
@property (readonly, nonatomic) NSString *literalString;

@end


@interface NSMutableDictionary <KeyType, ObjectType>(CoreCode)

@property (readonly, nonatomic) NSDictionary <KeyType, ObjectType> *immutableObject;

@end






@interface NSObject (CoreCode)

@property (readonly, nonatomic) id id;
- (id)associatedValueForKey:(const NSString *)key;
- (void)setAssociatedValue:(id)value forKey:(const NSString *)key;
@property (retain, nonatomic) id associatedValue;
+ (instancetype)newWith:(NSDictionary *)dict;



@end





#endif




@interface NSTextField (NSTextField_AutoFontsize)

- (void)adjustFontSize;

@end



@interface JMAppMovedHandler : NSObject

+ (void)startMoveObservation;

@end



@interface JMCorrectTimer : NSObject

- (id)initWithFireDate:(NSDate *)d timerBlock:(void (^)(void))timerBlock dropBlock:(void (^)(void))dropBlock;
- (void)invalidate;

@end



@interface JMDocklessApplication : NSApplication


@end


typedef enum
{
    kSMTPSuccess = 0,
    kSMTPScriptingBridgeFailure,
    kSMTPCGIFailure,
    kSMTPMailCoreFailure,
    kSMTPToNilFailure,
    kSMTPFromNilFailure,
    kSMTPBlockedMail,
    kSMTPBlockedHost,
    kSMTPUnreachableHost
} smtpResult;


@interface JMEmailSender : NSObject

#ifdef USE_APPLEMAIL
+ (smtpResult)sendMailWithScriptingBridge:(NSString *)content
                                  subject:(NSString *)subject
                                       to:(NSString *)recipients
                                  timeout:(uint16_t)secs
                               attachment:(NSString *)attachmentFilePath;
#endif
#ifdef USE_MAILCORE
+ (smtpResult)sendMailWithMailCore:(NSString *)content
                           subject:(NSString *)subject
                           timeout:(uint16_t)secs
                            server:(NSString *)server
                              port:(uint16_t)port
                              from:(NSString *)sender
                                to:(NSString *)recipients
                              auth:(BOOL)auth
                               tls:(BOOL)tls
                          username:(NSString *)username
                          password:(NSString *)password;
#endif


@end



#ifdef USE_CGIMAIL
@interface JMEmailSender (CGIMail)
+ (smtpResult)sendMailWithCGI:(NSString *)content
                      subject:(NSString *)subject
                           to:(NSString *)recipients
                      timeout:(float)timeout
              checkBlocklists:(BOOL)checkBlocklists
                     testOnly:(BOOL)testOnly;

@end
#endif



#define kDiskNameKey                        @"DiskName"
#define kDiskNumberKey                      @"DiskNumber"

CC_ENUM(uint8_t, smartStatusEnum)
{
    kSMARTStatusUnknown = 0,
    kSMARTStatusError = 1,
    kSMARTStatusOK = 2
};


@interface JMHostInformation : NSObject

+ (NSURL *)growlInstallURL;
+ (NSString *)ipAddress:(bool)ipv6;
+ (NSString *)machineType;
+ (NSMutableArray *)mountedHarddisks:(BOOL)includeRAIDBackingDevices;
+ (NSString *)macAddress;
+ (BOOL)runsOnBattery;
+ (NSString *)volumeNamesForDevice:(NSInteger)deviceNumber;
+ (NSString *)bsdPathForVolume:(NSString *)volume;

@end



@interface NSTask (CoreCode)

- (BOOL)waitUntilExitWithTimeout:(NSTimeInterval)timeout;

@end



#ifdef __cplusplus
extern "C"
{
#endif

    BOOL IsLoginItem(void);
    void AddLoginItem(void);
    void RemoveLoginItem(void);


#ifdef __cplusplus
}
#endif
