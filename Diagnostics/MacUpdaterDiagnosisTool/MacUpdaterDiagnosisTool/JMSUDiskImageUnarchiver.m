//
//  SUDiskImageUnarchiver.m
//  Sparkle
//
//  Created by Andy Matuschak on 6/16/08.
//  Copyright 2008 Andy Matuschak. All rights reserved.
//

#import "JMSUDiskImageUnarchiver.h"
#import "CoreLib.h"

extern NSMutableString * globalOutput;


@interface JMSUDiskImageUnarchiver ()

@property (nonatomic, copy, readonly) NSString *archivePath;
@property (nullable, nonatomic, copy, readonly) NSString *decryptionPassword;

@end

@implementation JMSUDiskImageUnarchiver

@synthesize archivePath = _archivePath;
@synthesize decryptionPassword = _decryptionPassword;

+ (BOOL)canUnarchivePath:(NSString *)path
{
    return [[path pathExtension] isEqualToString:@"dmg"];
}

+ (BOOL)unsafeIfArchiveIsNotValidated
{
    return NO;
}

- (instancetype)initWithArchivePath:(NSString *)archivePath decryptionPassword:(nullable NSString *)decryptionPassword
{
    self = [super init];
    if (self != nil) {
        _archivePath = [archivePath copy];
        _decryptionPassword = [decryptionPassword copy];
    }
    return self;
}

- (NSError *)unarchive
{
    NSError *err =  [self extractDMG];
    return err;
}
#define SUSparkleErrorDomain  @"SUSparkleErrorDomain"

// Called on a non-main thread.
- (NSError *)extractDMG
{
    NSError *error;
    @autoreleasepool
    {
        BOOL mountedSuccessfully = NO;
        NSString *errorString = @"";
        
        // get a unique mount point path
        NSString *mountPoint = nil;
        NSString *unmountPoint = nil;
        NSString *resultStr;
        NSString *errorStr;

        NSFileManager *manager;
        NSArray *contents;
        do
        {
            // Using NSUUID would make creating UUIDs be done in Cocoa,
            // and thus managed under ARC. Sadly, the class is in 10.8 and later.
            CFUUIDRef uuid = CFUUIDCreate(NULL);
            if (uuid)
            {
                NSString *uuidString = CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
                if (uuidString)
                {
                    mountPoint = [@"/Volumes" stringByAppendingPathComponent:uuidString];
                }
                CFRelease(uuid);
            }
        }
        // Note: this check does not follow symbolic links, which is what we want
        while ([[NSURL fileURLWithPath:mountPoint] checkResourceIsReachableAndReturnError:NULL]);
        
        NSData *promptData = nil;
        promptData = [NSData dataWithBytes:"yes\n" length:4];
        
        NSMutableArray *arguments = [@[@"attach", self.archivePath, @"-mountpoint", mountPoint, /*@"-noverify",*/ @"-nobrowse", @"-noautoopen", @"-verbose"] mutableCopy];
        NSString *destination = [self.archivePath stringByDeletingLastPathComponent];
        destination = [destination stringByAppendingPathComponent:makeString(@"%@_folder", self.archivePath.lastPathComponent.stringByDeletingPathExtension)];
        [fileManager createDirectoryAtURL:destination.fileURL withIntermediateDirectories:YES attributes:nil error:NULL];
        
        
        NSData *output = nil, *outputError = nil;
        NSInteger taskResult = -1;
        @try
        {
            
            {
                [globalOutput appendString:@"PROG1"];
                 NSTask *task = [[NSTask alloc] init];
                task.launchPath = @"/usr/bin/hdiutil";
                task.currentDirectoryPath = @"/";
                task.arguments = arguments;

                NSPipe *inputPipe = [NSPipe pipe];
                NSPipe *outputPipe = [NSPipe pipe];
                NSPipe *errorPipe = [NSPipe pipe];
                [globalOutput appendString:@"PROG2"];

                task.standardInput = inputPipe;
                task.standardOutput = outputPipe;
                task.standardError = errorPipe;
                [globalOutput appendString:@"PROG3"];

                [task launch];
                [globalOutput appendString:@"PROG4"];


                [inputPipe.fileHandleForWriting writeData:promptData];
                [globalOutput appendString:@"PROG5"];
                [inputPipe.fileHandleForWriting closeFile];
                [globalOutput appendString:@"PROG6"];

                // Read data to end *before* waiting until the task ends so we don't deadlock if the stdout buffer becomes full if we haven't consumed from it
                output = [outputPipe.fileHandleForReading readDataToEndOfFile];
                [globalOutput appendString:@"PROG7"];
                outputError = [errorPipe.fileHandleForReading availableData];
                [globalOutput appendString:@"PROG8"];
                [task waitUntilExit];
                [globalOutput appendString:@"PROG9"];
                taskResult = task.terminationStatus;
            }
        }
        @catch (NSException *e)
        {
            errorString = e.description;
            [globalOutput appendString:errorString];

            goto reportError;
        }
        
        [globalOutput appendString:@"DONE"];

        if (output) resultStr = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
        if (outputError) errorString = [[NSString alloc] initWithData:outputError encoding:NSUTF8StringEncoding];
        
        if (taskResult != 0)
        {
            errorString = makeString(@"hdiutil failed with code: %ld data: <<%@>> error: <<%@>>", (long)taskResult, resultStr, errorStr);
            [globalOutput appendFormat:@"%@", errorString];
            goto reportError;
        }
        
        unmountPoint = mountPoint;
        if ([resultStr contains:@"Apple_APFS"])
        {
            for (NSString *line in [resultStr componentsSeparatedByString:@"\n"])
            {
                if ([line rangeOfString:@"GUID_partition_scheme"].location != NSNotFound && [line rangeOfString:@"/dev/disk"].location != NSNotFound)
                    unmountPoint = [[line stringByReplacingOccurrencesOfString:@"GUID_partition_scheme" withString:@""]  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            }
        }
        mountedSuccessfully = YES;
        
        // Now that we've mounted it, we need to copy out its contents.
        manager = [[NSFileManager alloc] init];
        contents = [manager contentsOfDirectoryAtPath:mountPoint error:&error];
        if (error)
        {
            errorString = makeString(@"Couldn't enumerate contents of archive mounted at %@: %@", mountPoint, error);
            [globalOutput appendFormat:@"%@", errorString];
            goto reportError;
        }

        double itemsCopied = 0;
//        double totalItems = [contents count];

        
        
        for (NSString *item in contents)
        {
            NSString *fromPath = [mountPoint stringByAppendingPathComponent:item];
            NSString *toPath = [destination stringByAppendingPathComponent:item];
            
         
            
            // We skip any files in the DMG which are not readable.
            if (![manager isReadableFileAtPath:fromPath]) {
                continue;
            }
            if ([item isEqualToString:@".Spotlight-V100"]) {
                continue;
            }
            
            itemsCopied += 1.0;

            [globalOutput appendFormat:@"copyItemAtPath:%@ toPath:%@", fromPath, toPath];

            if (![manager copyItemAtPath:fromPath toPath:toPath error:&error])
            {
                errorString = makeString(@"Couldn't copyItemAtPath:%@ toPath:%@ error:%@", fromPath, toPath, error.description);
                [globalOutput appendFormat:@"%@", errorString];
                goto reportError;
            }
        }
        
        error = nil;
        goto finally;
        
    reportError:
        if (!error)
            error = [NSError errorWithDomain:SUSparkleErrorDomain code:6 userInfo:
                     @{@"info" : @"extractDMG failed",
                       @"error" : ([errorString contains:@"expected   CRC32"] || [errorString contains:@"error 1000 calculating checksum"] ) ? @"err1crc" : errorString}];


    finally:
        if (mountedSuccessfully) {
            NSTask *task = [[NSTask alloc] init];
            task.launchPath = @"/usr/bin/hdiutil";
            task.arguments = @[@"detach", unmountPoint, @"-force"];
            task.standardOutput = [NSPipe pipe];
            task.standardError = [NSPipe pipe];
            
            @try {
                [task launch];
            } @catch (NSException *exception) {
                [globalOutput appendFormat:@"Failed to unmount %@ Exception: %@", unmountPoint, exception];
            }
        } else {
            [globalOutput appendFormat:@"Can't mount DMG %@", self.archivePath];
        }
    }
    return error;

}

- (NSString *)description { return [NSString stringWithFormat:@"%@ <%@>", [self class], self.archivePath]; }

@end

