//
//  JMEmailSender.m
//
//  Created by CoreCode on 31.10.04.
/*	Copyright © 2017 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
// Some code here is derived from Apple Sample Code, but changes have been made

#import "JMEmailSender.h"

@implementation JMEmailSender

+ (smtpResult)sendMailWithScriptingBridge:(NSString *)content subject:(NSString *)subject timeout:(uint16_t)secs to:(NSString *)recipients
{
	asl_NSLog_debug(@"sendMailWithScriptingBridge %@\n\n sub: %@\n rec: %@", content, subject, recipients);

	BOOL validAddressFound = FALSE;
	NSArray *recipientList = [recipients componentsSeparatedByString:@"\n"];
	NSString *recipient;

	if (recipients == nil)
		return kToNilFailure;

	@try
	{
		smtpResult res;
		/* create a Scripting Bridge object for talking to the Mail application */
		MailApplication *mail = [SBApplication applicationWithBundleIdentifier:@"com.apple.Mail"];

        [mail setTimeout:secs*60];

		/* create a new outgoing message object */
		NSDictionary *messageProperties = [NSDictionary dictionaryWithObjectsAndKeys:subject, @"subject", content, @"content", nil];
		MailOutgoingMessage *emailMessage =	[[[mail classForScriptingClass:@"outgoing message"] alloc] initWithProperties:messageProperties];

		/* add the object to the mail app */
		[[mail outgoingMessages] addObject:emailMessage];

		/* set the sender, show the message */
		//emailMessage.visible = YES;

		/* create a new recipient and add it to the recipients list */
		for (recipient in recipientList) // the recipient string can be a newline seperated list of recipients
		{
			if (isValidEmail([recipient UTF8String]))
			{
				asl_NSLog_debug(@"sendMail: messageframework - sending to: %@", recipient);

				validAddressFound = TRUE;
				NSDictionary *recipientProperties = [NSDictionary dictionaryWithObjectsAndKeys:recipient, @"address", nil];
				MailToRecipient *theRecipient =	[[[mail classForScriptingClass:@"to recipient"] alloc] initWithProperties:recipientProperties];
				[emailMessage.toRecipients addObject:theRecipient];
				[theRecipient release];
			}
			else
			{
				asl_NSLog_debug(@"sendMail: %@ is not valid email!", recipient);
			}
		}

		asl_NSLog_debug(@"going to send");
		if (validAddressFound != TRUE)
			return kToNilFailure;
		
		if ([emailMessage send])
			res = kSuccess;
		else
			res = kScriptingBridgeFailure;
		asl_NSLog_debug(@"sent!");

		[emailMessage release];

		return res;
	}
	@catch (NSException *e)
	{
		asl_NSLog_debug(@"sendMailWithScriptingBridge, exception %@", [e description]);

		return kScriptingBridgeFailure;
	}

	return kScriptingBridgeFailure;  // just to silence the compiler
}

+ (smtpResult)sendMailWithMailCore:(NSString *)mail subject:(NSString *)subject server:(NSString *)server port:(uint16_t)port from:(NSString *)sender to:(NSString *)recipients auth:(BOOL)auth tls:(BOOL)tls username:(NSString *)username password:(NSString *)password
{
	asl_NSLog_debug(@"sendMailWithMailCore %@\n\n sub: %@\n sender: %@\nrec: %@", mail, subject, sender, recipients);

	BOOL validAddressFound = FALSE;
	NSArray *recipientList = [recipients componentsSeparatedByString:@"\n"];
	NSMutableSet *set = [NSMutableSet setWithCapacity:[recipientList count]];
	NSString *recipient;

	@try
	{
		if (recipients == nil)
			return kToNilFailure;
		if (sender == nil || [sender length] == 0 || !isValidEmail([sender UTF8String]))
			return kFromNilFailure;

		/* create a new recipient and add it to the recipients list */
		for (recipient in recipientList) // the recipient string can be a newline seperated list of recipients
		{
			if (isValidEmail([recipient UTF8String]))
			{
				asl_NSLog_debug(@"sendMail: mailcore - sending to: %@", recipient);

				validAddressFound = TRUE;
				[set addObject:[CTCoreAddress addressWithName:@"" email:recipient]];
			}
			else
			{
				asl_NSLog_debug(@"sendMail: %@ is not valid email!", recipient);
			}
		}

		if (!validAddressFound)
			return kToNilFailure;

		CTCoreMessage *msg = [[CTCoreMessage alloc] init];

		[msg setTo:set];
		[msg setFrom:[NSSet setWithObject:[CTCoreAddress addressWithName:@"" email:sender]]];
		[msg setBody:mail];
		[msg setSubject:subject];


		[CTSMTPConnection sendMessage:msg server:server username:username  password:password  port:port useTLS:tls useAuth:auth];

		[msg release];

		return kSuccess;
	}
	@catch (NSException *e)
	{
		asl_NSLog_debug(@"sendMailWithMailcore, exception %@", [e description]);

		return kMailCoreFailure;
	}

	return kMailCoreFailure; // just to silence the compiler
}
@end

BOOL isValidEmail(const char *email)
{
	char *i = NULL, *j = NULL;

	if (strlen(email) > 254)
		return FALSE;

	i = strchr(email, '@');

	if (i)
		j = strchr(i, '.');

	if (!i || !j || (j - i < 3))
		return FALSE;

	if (strchr(email, ';') || strchr(email, ':') || strchr(email, '|') || strchr(email, '/') || strchr(email, ',') || strchr(email, '&'))
		return FALSE;

	while ((i = strchr(j, '.')))
	{
		j = i;
		++j;
	}

	if (strlen(email) - ((int)(j - email)) < 2)
		return FALSE;

	return TRUE;
}
