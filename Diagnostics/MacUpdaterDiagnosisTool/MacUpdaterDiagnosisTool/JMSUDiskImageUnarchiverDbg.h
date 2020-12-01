//
//  SUDiskImageUnarchiver.h
//  Sparkle
//
//  Created by Andy Matuschak on 6/16/08.
//  Copyright 2008 Andy Matuschak. All rights reserved.
//

#ifndef JMSUDISKIMAGEUNARCHIVERDBG_H
#define JMSUDISKIMAGEUNARCHIVERDBG_H




NS_ASSUME_NONNULL_BEGIN

@interface JMSUDiskImageUnarchiverDbg : NSObject

- (instancetype)initWithArchivePath:(NSString *)archivePath decryptionPassword:(nullable NSString *)decryptionPassword;
- (NSError *)unarchive;

@end

NS_ASSUME_NONNULL_END

#endif

