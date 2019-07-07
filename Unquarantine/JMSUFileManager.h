//
//  SUFileManager.h
//  Sparkle
//
//  Created by Mayur Pawashe on 7/18/15.
//  Copyright (c) 2015 zgcoder. All rights reserved.
//

@import Foundation;


NS_ASSUME_NONNULL_BEGIN

/**
 * A class used for performing file operations more suitable than NSFileManager for performing installation work.
 * All operations on this class may be used on thread other than the main thread.
 * This class provides just basic file operations and stays away from including much application-level logic.
 */
@interface JMSUFileManager : NSObject

/**
 * Initializes a new file manager
 *
 * @return A new file manager instance
 */
- (instancetype)init;

- (int)releaseItemFromQuarantineAtRootURL:(NSURL *)rootURL error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
