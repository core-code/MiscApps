//
//  SSKeychainTests.m
//  SSKeychainTests
//
//  Created by Sam Soffes on 10/3/11.
//  Copyright (c) 2011 Sam Soffes. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "SSKeychain.h"

static NSString *kSSToolkitTestsServiceName = @"SSToolkitTestService";
static NSString *kSSToolkitTestsAccountName = @"SSToolkitTestAccount";
static NSString *kSSToolkitTestsPassword1 = @"SSToolkitTestPasswordOLD";
static NSString *kSSToolkitTestsPassword2 = @"SSToolkitTestPasswordNEW";

@interface SSKeychainTests : SenTestCase

- (BOOL)_accounts:(NSArray *)accounts containsAccountWithName:(NSString *)name;

@end

@implementation SSKeychainTests

- (void)testAll {
	// Getting & Setings Passwords
	[SSKeychain setPassword:kSSToolkitTestsPassword1 forService:kSSToolkitTestsServiceName account:kSSToolkitTestsAccountName];
	NSString *password1 = [SSKeychain passwordForService:kSSToolkitTestsServiceName account:kSSToolkitTestsAccountName];
	STAssertEqualObjects(password1, kSSToolkitTestsPassword1, @"Password reads and writes");

	// Getting & Setings Passwords
	[SSKeychain setPassword:kSSToolkitTestsPassword2 forService:kSSToolkitTestsServiceName account:kSSToolkitTestsAccountName];
	NSString *password2 = [SSKeychain passwordForService:kSSToolkitTestsServiceName account:kSSToolkitTestsAccountName];
	STAssertEqualObjects(password2, kSSToolkitTestsPassword2, @"Password reads and writes");

	// Getting Accounts
	NSArray *accounts = [SSKeychain allAccounts];
	STAssertTrue([self _accounts:accounts containsAccountWithName:kSSToolkitTestsAccountName], @"All accounts");

	accounts = [SSKeychain accountsForService:kSSToolkitTestsServiceName];
	STAssertTrue([self _accounts:accounts containsAccountWithName:kSSToolkitTestsAccountName], @"Account for service");
	
	// Deleting Passwords
	[SSKeychain deletePasswordForService:kSSToolkitTestsServiceName account:kSSToolkitTestsAccountName];
	password2 = [SSKeychain passwordForService:kSSToolkitTestsServiceName account:kSSToolkitTestsAccountName];
	STAssertNil(password2, @"Password deletes");
}


- (BOOL)_accounts:(NSArray *)accounts containsAccountWithName:(NSString *)name {
	for (NSDictionary *dictionary in accounts) {
		if ([[dictionary objectForKey:@"acct"] isEqualToString:name]) {
			return YES;
		}
	}
	return NO;
}

@end
