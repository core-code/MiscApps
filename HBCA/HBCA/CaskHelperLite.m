//
//  CaskHelperLite.m
//
//  Created by CoreCode on 12/05/2018.
//  Copyright © 2019 CoreCode Limited. All rights reserved.
//

#import "CaskHelperLite.h"
#import "CoreLib.h"


@implementation CaskHelper


+ (NSString *)getSHA256FromCaskfile:(NSString *)caskfileContents
{
    if ([caskfileContents contains:@"sha256 :no_check"]) return @":no_check";
    
    let shaLines = [caskfileContents.lines filtered:^BOOL(NSString *input) { return [input.trimmedOfWhitespace hasPrefix:@"sha256 '"]; }];
    var shaLine = shaLines.lastObject;
    
    shaLine = [shaLine.trimmedOfWhitespace replaced:@"sha256 " with:@""].trimmedOfWhitespace;
    shaLine = [shaLine substringWithRange:NSMakeRange(1, shaLine.length-2)]; // remove quotes
    
    return shaLine;
}

+ (NSString *)getHomepageURLFromCaskfile:(NSString *)caskfileContents
{
    let homepageLines = [caskfileContents.lines filtered:^BOOL(NSString *input) { return [input.trimmedOfWhitespace hasPrefix:@"homepage "]; }];
    var homepageLine = homepageLines.lastObject;
    homepageLine = [homepageLine.trimmedOfWhitespace replaced:@"homepage " with:@""].trimmedOfWhitespace;
    homepageLine = [homepageLine substringWithRange:NSMakeRange(1, homepageLine.length-2)]; // remove quotes ... we don't know which quotes, just strip first and last char
    
    var homepageURL = @"";
    
    if (![homepageLine contains:@"#{"]) // no need to parse URL, just extract it
        homepageURL = homepageLine;
    else
        cc_log_error(@"Error: not supported");
    
    return homepageURL;
}

+ (NSString *)getDownloadURLFromCaskfile:(NSString *)caskfileContents withVersion:(NSString *)version
{
    let urlLine = [CaskHelper getUnprocessedDownloadURLFromCaskfile:caskfileContents];
    var downloadURL = @"";

    if (![urlLine contains:@"#{"]) // no need to parse URL, just extract it
    {
        downloadURL = urlLine;
    }
    else
    {
        NSString * finalURL = [self replaceVersionInURL:urlLine version:version];
        
        downloadURL = finalURL;
        
        if ([finalURL contains:@"#{"])
            cc_log_error(@"Error: not supported");
    }
    
    return downloadURL;
}

+ (NSString *)getUnprocessedDownloadURLFromCaskfile:(NSString *)caskfileContents
{
    let urlLines = [caskfileContents.lines filtered:^BOOL(NSString *input) { return [input.trimmedOfWhitespace hasPrefix:@"url "]; }];
    var urlLine = @"";

    if (urlLines.count == 0)
        return nil;
    else
        urlLine = urlLines.lastObject;

    
    urlLine = [urlLine.trimmedOfWhitespace replaced:@"url " with:@""].trimmedOfWhitespace;
    
    if ([urlLine hasSuffix:@"\","] || ([urlLine hasSuffix:@"\',"]))
        urlLine = [urlLine substringWithRange:NSMakeRange(0, urlLine.length-1)]; // some end with a "," as they have a user_agent
    
    urlLine = [urlLine substringWithRange:NSMakeRange(1, urlLine.length-2)]; // remove quotes ... we don't know which quotes, just strip first and last char
    
    return urlLine;
}

+ (NSString *)getVersionFromCaskfile:(NSString *)caskfileContents
{
    let versionLines = [caskfileContents.lines filtered:^BOOL(NSString *input) { return [input.trimmedOfWhitespace hasPrefix:@"version "]; }];
    var versionLine = @"";
    
    if (versionLines.count == 0)
        return nil;
    else
        versionLine = versionLines.lastObject;
    
    if ([versionLine contains:@":latest"])
        return @":latest";
    
    versionLine = [versionLine.trimmedOfWhitespace replaced:@"version " with:@""].trimmedOfWhitespace;
    versionLine = [versionLine substringWithRange:NSMakeRange(1, versionLine.length-2)];
    
    return versionLine;
}

+ (NSString *)replaceVersionInURL:(NSString *)urlLine version:(NSString *)version
{
    NSString *finalURL = urlLine;
    
    if ([finalURL contains:@"#{version}"])
        finalURL = [finalURL replaced:@"#{version}" with:version];
    
    if (![finalURL contains:@"#{"]) return finalURL; // early out for common case
    
    NSCharacterSet *nonNumericOrPointCharacterSet = @"0123456789.".characterSet.invertedSet;
    NSString *versionForMajorMinor = [version componentsSeparatedByCharactersInSet:nonNumericOrPointCharacterSet][0]; // workaround for weird behaviour: 18.3-1719707.minor = 3
    
    if ([finalURL contains:@"#{version.before_comma.dots_to_underscores}"])
        finalURL = [finalURL replaced:@"#{version.before_comma.dots_to_underscores}" with:[[version split:@","][0] replaced:@"." with:@"_"]];
    if ([finalURL contains:@"#{version.before_comma.no_dots}"])
        finalURL = [finalURL replaced:@"#{version.before_comma.no_dots}" with:[[version split:@","][0] replaced:@"." with:@""]];
    if ([finalURL contains:@"#{version.major_minor.no_dots}"])
        finalURL = [finalURL replaced:@"#{version.major_minor.no_dots}" with:makeString(@"%@%@",
                                                                                        [versionForMajorMinor split:@"."][0],
                                                                                        OBJECT_OR([[versionForMajorMinor split:@"."] safeObjectAtIndex:1], @""))];
    if ([finalURL contains:@"#{version.dots_to_hyphens}"])
        finalURL = [finalURL replaced:@"#{version.dots_to_hyphens}" with:[version replaced:@"." with:@"-"]];
    if ([finalURL contains:@"#{version.major_minor_patch}"])
    {
        let dotcomponents = [versionForMajorMinor split:@"."];
        var majorminorpatch = dotcomponents[0];
        
        if (dotcomponents.count > 1)
        {
            majorminorpatch = [majorminorpatch stringByAppendingString:@"."];
            majorminorpatch = [majorminorpatch stringByAppendingString:dotcomponents[1]];
        }
        if (dotcomponents.count > 2)
        {
            majorminorpatch = [majorminorpatch stringByAppendingString:@"."];
            majorminorpatch = [majorminorpatch stringByAppendingString:dotcomponents[2]];
        }
        finalURL = [finalURL replaced:@"#{version.major_minor_patch}" with:majorminorpatch];
    }
    if ([finalURL contains:@"#{version.after_comma.before_colon}"])
        finalURL = [finalURL replaced:@"#{version.after_comma.before_colon}" with:[[[version split:@","] safeObjectAtIndex:1] split:@":"][0]];
    if ([finalURL contains:@"#{version.major_minor}"])
    {
        let dotcomponents = [versionForMajorMinor split:@"."];
        var majorminor = dotcomponents[0];
        
        if (dotcomponents.count > 1)
        {
            majorminor = [majorminor stringByAppendingString:@"."];
            majorminor = [majorminor stringByAppendingString:dotcomponents[1]];
        }
        finalURL = [finalURL replaced:@"#{version.major_minor}" with:majorminor];
    }
    if ([finalURL contains:@"#{version.dots_to_underscores}"])
        finalURL = [finalURL replaced:@"#{version.dots_to_underscores}" with:[version replaced:@"." with:@"_"]];
    if ([finalURL contains:@"#{version.after_comma}"])
        finalURL = [finalURL replaced:@"#{version.after_comma}" with:[[version split:@","] safeObjectAtIndex:1]];
    if ([finalURL contains:@"#{version.after_comma.dots_to_slashes}"])
        finalURL = [finalURL replaced:@"#{version.after_comma.dots_to_slashes}" with:[[[version split:@","] safeObjectAtIndex:1] replaced:@"." with:@"/"]];
    if ([finalURL contains:@"#{version.before_comma}"])
        finalURL = [finalURL replaced:@"#{version.before_comma}" with:[version split:@","][0]];
    if ([finalURL contains:@"#{version.after_colon}"])
        finalURL = [finalURL replaced:@"#{version.after_colon}" with:[[version split:@":"] safeObjectAtIndex:1]];
    if ([finalURL contains:@"#{version.major}"])
        finalURL = [finalURL replaced:@"#{version.major}" with:[versionForMajorMinor split:@"."][0]];
    if ([finalURL contains:@"#{version.minor}"])
        finalURL = [finalURL replaced:@"#{version.minor}" with:[[versionForMajorMinor split:@"."] safeObjectAtIndex:1]];
    if ([finalURL contains:@"#{version.patch}"])
        finalURL = [finalURL replaced:@"#{version.patch}" with:[[versionForMajorMinor split:@"."] safeObjectAtIndex:2]];
    if ([finalURL contains:@"#{version.no_dots}"])
        finalURL = [finalURL replaced:@"#{version.no_dots}" with:[version replaced:@"." with:@""]];
    
#ifdef CLI // just for appcasts
    if ([finalURL contains:@"#{version.split('.').last}"])
        finalURL = [finalURL replaced:@"#{version.split('.').last}" with:[version split:@"."].lastObject];

    if ([finalURL contains:@"#{version.after_comma.major}"])
        finalURL = [finalURL replaced:@"#{version.after_comma.major}" with:[[[version split:@","] safeObjectAtIndex:1] split:@"."].firstObject];
#endif

    return finalURL;
}

@end
