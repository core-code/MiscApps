//
//  SUDiskImageUnarchiver.m
//  Sparkle
//
//  Created by Andy Matuschak on 6/16/08.
//  Copyright 2008 Andy Matuschak. All rights reserved.
//

#import "JMSUDiskImageUnarchiverDbg.h"
#import "CoreLib.h"

extern NSMutableString *globalOutput2;

@interface JMSUDiskImageUnarchiverDbg ()

@property (nonatomic, copy, readonly) NSString *archivePath;
@property (nullable, nonatomic, copy, readonly) NSString *decryptionPassword;

@end

@implementation JMSUDiskImageUnarchiverDbg

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
        
        NSMutableArray *arguments = [@[@"attach", self.archivePath,
                                       @"-debug",
                                       @"-mountpoint", mountPoint, /*@"-noverify",*/ @"-nobrowse", @"-noautoopen", @"-verbose"] mutableCopy];
        NSString *destination = [self.archivePath stringByDeletingLastPathComponent];
        destination = [destination stringByAppendingPathComponent:makeString(@"%@_folder", self.archivePath.lastPathComponent.stringByDeletingPathExtension)];
        [fileManager createDirectoryAtURL:destination.fileURL withIntermediateDirectories:YES attributes:nil error:NULL];
        
        
        NSData *output = nil, *outputError = nil;
        NSInteger taskResult = -1;
        @try
        {
            {   // test code for getting live output of hidutil NOT ENABLED BY DEFAULT
                NSTask *task = [[NSTask alloc] init];
                task.launchPath = @"/usr/bin/hdiutil";
                task.currentDirectoryPath = @"/";
                task.arguments = arguments;

                 __block dispatch_semaphore_t sema = dispatch_semaphore_create(0);
                NSMutableString *jobStdOutput = makeMutableString();
                NSMutableString *jobErrOutput = makeMutableString();
                
                NSPipe *taskStdPipe = [NSPipe pipe];
                NSPipe *taskErrPipe = [NSPipe pipe];
                NSPipe *inputPipe = [NSPipe pipe];

                task.standardOutput = taskStdPipe;
                task.standardError = taskErrPipe;
                task.standardInput = inputPipe;

                NSFileHandle *fileStdHandle = taskStdPipe.fileHandleForReading;
                NSFileHandle *fileErrHandle = taskErrPipe.fileHandleForReading;
                
                [fileStdHandle setReadabilityHandler:^(NSFileHandle *file)
                {
                    NSData *data = file.availableData;
                    NSString *string = data.string;
                    
                    if (string)
                        [jobStdOutput appendString:string];
                    
                    [globalOutput2 appendFormat:@"HDIUTIL std output: %@", string];
                }];
                [fileErrHandle setReadabilityHandler:^(NSFileHandle *file)
                {
                    NSData *data = file.availableData;
                    NSString *string = data.string;
                    
                    if (string)
                        [jobErrOutput appendString:string];
                    
                    [globalOutput2 appendFormat:@"HDIUTIL err output: %@", string];
                }];
                
                
                [task setTerminationHandler:^(NSTask *t)
                {
                    fileStdHandle.readabilityHandler = nil;
                    fileErrHandle.readabilityHandler = nil;
                    
                    [globalOutput2 appendFormat:@"HDIUTIL DONE - termination handler"];

                    assert(sema);
                    dispatch_semaphore_signal(sema);
                }];
                
                
                [task launch];
                [inputPipe.fileHandleForWriting writeData:promptData];
                [inputPipe.fileHandleForWriting closeFile];

                
                dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
                
                sema = NULL;
                                
                output = jobStdOutput.data;
                outputError = jobErrOutput.data;

                taskResult = task.terminationStatus;
                [globalOutput2 appendFormat:@"HDIUTIL DONE result %li", (long)taskResult];
            }
            
        }
        @catch (NSException *e)
        {
            errorString = e.description;
            goto reportError;
        }
        

        if (output) resultStr = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
        if (outputError) errorString = [[NSString alloc] initWithData:outputError encoding:NSUTF8StringEncoding];
        
        if (taskResult != 0)
        {
            errorString = makeString(@"hdiutil failed with code: %ld data: <<%@>> error: <<%@>>", (long)taskResult, resultStr, errorStr);
            [globalOutput2 appendFormat:@"%@", errorString];
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
            [globalOutput2 appendFormat:@"%@", errorString];
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

            [globalOutput2 appendFormat:@"copyItemAtPath:%@ toPath:%@", fromPath, toPath];

            if (![manager copyItemAtPath:fromPath toPath:toPath error:&error])
            {
                errorString = makeString(@"Couldn't copyItemAtPath:%@ toPath:%@ error:%@", fromPath, toPath, error.description);
                [globalOutput2 appendFormat:@"%@", errorString];
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
                [globalOutput2 appendFormat:@"Failed to unmount %@ Exception: %@", unmountPoint, exception];
            }
        } else {
            [globalOutput2 appendFormat:@"Can't mount DMG %@", self.archivePath];
        }
    }
    return error;

}

- (NSString *)description { return [NSString stringWithFormat:@"%@ <%@>", [self class], self.archivePath]; }

@end

