//
//  CaskHelper.h
//  MacUpdater
//
//  Created by CoreCode on 12/05/2018.
//  Copyright © 2019 CoreCode Limited. All rights reserved.
//

@import Foundation;


@interface CaskHelper : NSObject
+ (NSString *)getVersionFromCaskfile:(NSString *)caskfileContents;                      // this yields the final cleaned version e.g. @"1.2.3"

// download
+ (NSString *)getUnprocessedDownloadURLFromCaskfile:(NSString *)caskfileContents;       // this yields the url as given in the caskfile and can contain placeholders e.g. @"http://host.com/#{version}.zip" (or @":latest")
+ (NSString *)getDownloadURLFromCaskfile:(NSString *)caskfileContents withVersion:(NSString *)version; // this yields the final downloadable URL with placeholders substituted e.g. @"http://host.com/app123.zip"  (or @":latest")


+ (NSString *)getHomepageURLFromCaskfile:(NSString *)caskfileContents;                  // this yields the final openable URL e.g. @"http://host.com/appname/"
+ (NSString *)getSHA256FromCaskfile:(NSString *)caskfileContents;


+ (NSString *)replaceVersionInURL:(NSString *)urlLine version:(NSString *)version;


@end
