//
//  AppKit+CoreCode.m
//  CoreLib
//
//  Created by CoreCode on 15.05.11.
/*	Copyright © 2018 CoreCode Limited
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "AppKit+CoreCode.h"


#if ! __has_feature(objc_arc)
#define BRIDGE
#else
#define BRIDGE __bridge
#endif

#if defined(TARGET_OS_MAC) && TARGET_OS_MAC && !TARGET_OS_IPHONE

#import <objc/runtime.h>


#define CONST_KEY(name) \
NSString *const k ## name ## Key = @ #name;

static CONST_KEY(CCProgressDetailInfo)
static CONST_KEY(CCProgressSheet)
static CONST_KEY(CCProgressIndicator)
static CONST_KEY(CoreCodeAssociatedValue)


@implementation NSWindow (CoreCode)


- (void)setProgressMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^
	{
		NSTextField *progressDetailInfo = [self associatedValueForKey:kCCProgressDetailInfoKey];

		[progressDetailInfo setStringValue:message];
	});
}

- (void)beginProgress:(NSString *)title
{
    dispatch_async(dispatch_get_main_queue(),^
	{
		NSWindow *progressPanel = [[NSWindow alloc] initWithContentRect:NSMakeRect(0.0f, 0.0f, 400.0f, 120.0f)
                                                              styleMask:NSWindowStyleMaskTitled
														 backing:NSBackingStoreBuffered
														   defer:NO];


		NSTextField *progressInfo = [[NSTextField alloc] initWithFrame:NSMakeRect(18.0f, 90.0f, 364.0f, 17.0f)];
		NSTextField *progressDetailInfo = [[NSTextField alloc] initWithFrame:NSMakeRect(18.0f, 65.0f, 364.0f, 17.0f)];
		NSTextField *waitLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(18.0f, 14.0f, 364.0f, 17.0f)];
		NSProgressIndicator *progressIndicator = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(20.0f, 41.0f, 360.0f, 20.0f)];


		[progressIndicator setCanDrawConcurrently:YES];


		[progressInfo setStringValue:title];
		[progressDetailInfo setStringValue:@""];
		[waitLabel setStringValue:@"Please wait until the operation finishes…"];

		[progressInfo setFont:[NSFont boldSystemFontOfSize:13]];

		for (NSTextField *textField in @[progressInfo, progressDetailInfo, waitLabel])
		{
            [textField setAlignment:NSTextAlignmentCenter];
			[textField setBezeled:NO];
			[textField setDrawsBackground:NO];
			[textField setEditable:NO];
			[textField setSelectable:NO];
			[[progressPanel contentView] addSubview:textField];
		}

		[[progressPanel contentView] addSubview:progressIndicator];
#if ! __has_feature(objc_arc)
		[progressIndicator release];
		[waitLabel release];
		[progressDetailInfo release];
		[progressInfo release];
#endif
		[progressPanel setReleasedWhenClosed:YES];

		[self setAssociatedValue:progressDetailInfo forKey:kCCProgressDetailInfoKey];
		[self setAssociatedValue:progressPanel forKey:kCCProgressSheetKey];
		[self setAssociatedValue:progressIndicator forKey:kCCProgressIndicatorKey];

		[NSApp activateIgnoringOtherApps:YES];

        [self beginSheet:progressPanel completionHandler:^(NSModalResponse resp){}];


		[progressIndicator startAnimation:self];
	});
}

- (void)endProgress
{
    dispatch_async(dispatch_get_main_queue(), ^
	{
		NSWindow *progressPanel = [self associatedValueForKey:kCCProgressSheetKey];
		NSProgressIndicator *progressIndicator = [self associatedValueForKey:kCCProgressIndicatorKey];

		[progressIndicator stopAnimation:self];
		[NSApp activateIgnoringOtherApps:YES];
		[self endSheet:progressPanel];
		[progressPanel orderOut:self];

		[self setAssociatedValue:nil forKey:kCCProgressDetailInfoKey];
		[self setAssociatedValue:nil forKey:kCCProgressSheetKey];
		[self setAssociatedValue:nil forKey:kCCProgressIndicatorKey];
	});
}


- (IBAction)performBorderlessClose:(id)sender
{
	if ([[self delegate] respondsToSelector:@selector(windowShouldClose:)])
	{
		if (![[self delegate] windowShouldClose:self])
			return;
	}
	[self close];
}
@end



@implementation NSObject (CoreCode)

@dynamic associatedValue, id;

- (void)setAssociatedValue:(id)value forKey:(NSString *)key
{
#if	TARGET_OS_IPHONE
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-objc-pointer-introspection"
    BOOL is64Bit = sizeof(void *) == 8;
    BOOL isTagged = ((uintptr_t)self & 0x1);
    assert(!(is64Bit && isTagged)); // associated values on tagged pointers broken on 64 bit iOS
#pragma clang diagnostic pop
#endif
    
    objc_setAssociatedObject(self, (BRIDGE const void *)(key), value, OBJC_ASSOCIATION_RETAIN);
}

- (id)associatedValueForKey:(NSString *)key
{
    return objc_getAssociatedObject(self, (BRIDGE const void *)(key));
}

- (void)setAssociatedValue:(id)value
{
    [self setAssociatedValue:value forKey:kCoreCodeAssociatedValueKey];
}

- (id)associatedValue
{
    return [self associatedValueForKey:kCoreCodeAssociatedValueKey];
}

+ (instancetype)newWith:(NSDictionary *)dict
{
    NSObject *obj = [self new];
    for (NSString *key in dict)
    {
        [obj setValue:dict[key] forKey:key];
    }
    
    return obj;
}

- (id)id
{
    return (id)self;
}
@end

#endif


