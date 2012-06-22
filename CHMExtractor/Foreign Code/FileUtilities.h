#import <Cocoa/Cocoa.h>

@interface FileUtilities : NSObject { }

+ (OSErr)makeRelativeAlias:(NSString *)aliasDestination toFile:(NSString *)targetFile;
+ (OSErr)getFSRefAtPath:(NSString *)sourceItem ref:(FSRef *)sourceRef;

@end