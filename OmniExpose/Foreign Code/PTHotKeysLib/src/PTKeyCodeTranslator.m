//
//  PTKeyCodeTranslator.m
//  PTHotKeysLib
//
//  Created by Finlay Dobbie on Sat Oct 11 2003.
//  Copyright (c) 2003 Cliché Software. All rights reserved.
//

#import "PTKeyCodeTranslator.h"

@implementation PTKeyCodeTranslator

+ (id)currentTranslator
{
	static PTKeyCodeTranslator *current = nil;
	KeyboardLayoutRef currentLayout;
	OSStatus err = KLGetCurrentKeyboardLayout( &currentLayout);

	if (err != noErr)
		return nil;

	if (current == nil)
		current = [[PTKeyCodeTranslator alloc] initWithKeyboardLayout:currentLayout];
	else if ([current keyboardLayout] != currentLayout)
	{
		[current release];
		current = [[PTKeyCodeTranslator alloc] initWithKeyboardLayout:currentLayout];
	}
	return current;
}

- (id)initWithKeyboardLayout:(KeyboardLayoutRef)aLayout
{
	if ((self = [super init]) != nil)
	{
		keyboardLayout = aLayout;
		OSStatus err = KLGetKeyboardLayoutProperty( aLayout, kKLKind, (const void **)&keyLayoutKind);

		if (err != noErr)
			return nil;

		if (keyLayoutKind == kKLKCHRKind)
		{
			err = KLGetKeyboardLayoutProperty( keyboardLayout, kKLKCHRData, (const void **)&KCHRData);
			if (err != noErr)
				return nil;
		}
		else
		{
			err = KLGetKeyboardLayoutProperty( keyboardLayout, kKLuchrData, (const void **)&uchrData);
			if (err != noErr)
				return nil;
		}
	}

	return self;
}

- (NSString *)translateKeyCode:(short)keyCode
{
	if (keyLayoutKind == kKLKCHRKind)
	{
		UInt32 charCode = KeyTranslate( KCHRData, keyCode, &keyTranslateState);
		char theChar = (charCode & 0x00FF);
		return [[[NSString alloc] initWithData:[NSData dataWithBytes:&theChar length:1] encoding:NSMacOSRomanStringEncoding] autorelease];
	}
	else
	{
		UniCharCount maxStringLength = 4, actualStringLength;
		UniChar unicodeString[4];

		UCKeyTranslate( uchrData, keyCode, kUCKeyActionDisplay, 0, LMGetKbdType(), kUCKeyTranslateNoDeadKeysBit, &deadKeyState, maxStringLength, &actualStringLength, unicodeString); // ingore err result
		return [NSString stringWithCharacters:unicodeString length:1];
	}
}

- (KeyboardLayoutRef)keyboardLayout
{
	return keyboardLayout;
}

- (NSString *)description
{
	NSString *kind;
	if (keyLayoutKind == kKLKCHRKind)
		kind = @"KCHR";
	else
		kind = @"uchr";

	NSString *layoutName;
	KLGetKeyboardLayoutProperty( keyboardLayout, kKLLocalizedName, (const void **)&layoutName);
	return [NSString stringWithFormat:@"PTKeyCodeTranslator layout=%@ (%@)", layoutName, kind];
}
@end