//
//  SMTPSender.h
//
//  Created by Julian Mayer on 31.10.04.
/*	Copyright (c) 2004 - 2012 A. Julian Mayer
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#define WIN32 0
#import <MailCore/MailCore.h>
#import "Mail.h"

@interface JMEmailSender : NSObject { }

+ (smtpResult)sendMailWithScriptingBridge:(NSString *)content subject:(NSString *)subject timeout:(uint16_t)secs to:(NSString *)recipients;
+ (smtpResult)sendMailWithMailCore:(NSString *)mail subject:(NSString *)subject server:(NSString *)server port:(uint16_t)port from:(NSString *)sender to:(NSString *)recipients auth:(BOOL)auth tls:(BOOL)tls username:(NSString *)username password:(NSString *)password;

@end

BOOL isValidEmail(const char *email);
